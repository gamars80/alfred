import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../data/product_api.dart';
import '../model/product.dart';
import '../model/age_range.dart';
import '../widget/voice_command_input_widget.dart';
import 'product_webview_screen.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const platform = MethodChannel('com.alfred/voice');

  final TextEditingController _commandController = TextEditingController();
  Key? _bottomSheetContentKey;
  bool _showingBottomSheet = false;
  bool _isLoading = false;
  bool _isListening = false;
  Map<String, List<Product>> _categorizedProducts = {};
  final currencyFormatter = NumberFormat('#,###', 'ko_KR');

  String? _selectedGender;
  String? _selectedAge;
  String? _errorMessage;


  Future<void> _fetchProducts(String query, {StateSetter? modalSetState}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    modalSetState?.call(() {});

    try {
      final api = ProductApi();
      final fullQuery = _appendGenderAndAgeToQuery(query);
      print('✅ 호출된 Query: $fullQuery'); // 실제 API 호출 전 확인

      final result = await api.fetchRecommendedProducts(fullQuery);
      setState(() {
        _categorizedProducts = result;
        _selectedGender = null;
        _selectedAge = null;
      });

      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      if (_showingBottomSheet) {
        Navigator.pop(context);
        _showingBottomSheet = false;
      }
    } catch (e) {
      final message = e.toString();
      if (message.contains('Not Gender')) {
        setState(() => _errorMessage = 'gender');
      } else if (message.contains('Not Age')) {
        setState(() => _errorMessage = 'age');
      } else if (message.contains('More Information')) {
        setState(() => _errorMessage = 'both');
      } else {
        debugPrint('API 호출 실패: $e');
      }
      if (!_showingBottomSheet) {
        _showingBottomSheet = true;
        _openBottomSheet();
      }
    } finally {
      setState(() => _isLoading = false);
      modalSetState?.call(() {});
    }
  }

  Future<void> _startNativeListening(StateSetter modalSetState) async {
    modalSetState(() => _isListening = true);
    try {
      final result = await platform.invokeMethod<String>('startListening');
      if (result != null && result.isNotEmpty) {
        modalSetState(() {
          _commandController.text = result;
        });
      }
    } on PlatformException catch (e) {
      debugPrint("음성 인식 오류: ${e.message}");
    }
    modalSetState(() => _isListening = false);
  }

  Future<void> _openBottomSheet() async {
    setState(() {
      _commandController.clear();
      _selectedGender = null;
      _selectedAge = null;
      _errorMessage = null;
      _isListening = false;
    });
    _bottomSheetContentKey = UniqueKey();
    _showingBottomSheet = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builderContext) {
        final availableWidth = MediaQuery
            .of(context)
            .size
            .width - 40;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDFDFD),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  )
                ],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom + 16,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  key: _bottomSheetContentKey,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎙️ 명령 입력',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage == null)
                      SizedBox(
                        width: availableWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VoiceCommandInputWidget(
                              controller: _commandController,
                              isListening: _isListening,
                              isLoading: _isLoading,
                              onMicPressed: () =>
                                  _startNativeListening(modalSetState),
                              onSubmit: () {
                                final query = _commandController.text.trim();
                                if (query.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "검색어를 입력해주세요.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  return;
                                }
                                _fetchProducts(
                                    query, modalSetState: modalSetState);
                              },
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage != null) ...[
                      _buildExtraInfoInput(modalSetState),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final query = _commandController.text
                              .trim()
                              .isEmpty
                              ? ' '
                              : _commandController.text.trim();
                          if ((_errorMessage == 'gender' &&
                              _selectedGender == null) ||
                              (_errorMessage == 'age' &&
                                  _selectedAge == null) ||
                              (_errorMessage == 'both' &&
                                  (_selectedGender == null ||
                                      _selectedAge == null))) {
                            Fluttertoast.showToast(
                              msg: "필수 선택 항목을 입력해주세요.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            return;
                          }
                          _fetchProducts(query, modalSetState: modalSetState);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text('명령하기'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    setState(() => _showingBottomSheet = false);
  }

  Widget _buildExtraInfoInput(StateSetter modalSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage == 'gender' || _errorMessage == 'both') ...[
          const Text(
            '자세한 추천을 위해 성별을 선택해주세요.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'MALE',
                groupValue: _selectedGender,
                onChanged: (value) =>
                    modalSetState(() => _selectedGender = value),
              ),
              const Text('남성', style: TextStyle(fontSize: 13, color: Colors.black87)),
              Radio<String>(
                value: 'FEMALE',
                groupValue: _selectedGender,
                onChanged: (value) =>
                    modalSetState(() => _selectedGender = value),
              ),
              const Text('여성', style: TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ),
        ],
        if (_errorMessage == 'age' || _errorMessage == 'both') ...[
          const SizedBox(height: 12),
          const Text(
            '자세한 추천을 위해 연령대를 선택해주세요.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Wrap(
            spacing: 8,
            children: AgeRange.values.map((range) {
              return ChoiceChip(
                label: Text(
                    range.description, style: const TextStyle(fontSize: 11)),
                selected: _selectedAge == range.code,
                onSelected: (selected) =>
                    modalSetState(() =>
                    _selectedAge = selected ? range.code : null),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductWebViewScreen(url: product.link),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (product.mallName.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.mallName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₩ ${currencyFormatter.format(product.price)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  if (product.reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        product.reason,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('상품 추천', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categorizedProducts.isEmpty
          ? const Center(
        child: Text('추천된 상품이 없습니다.', style: TextStyle(color: Colors.grey)),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: _categorizedProducts.entries.map((entry) {
          final category = entry.key;
          final products = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              ...products.map((product) => _buildProductCard(product)).toList(),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBottomSheet,
        label: const Text('알프레드~'),
        icon: const Icon(Icons.mic),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  String _appendGenderAndAgeToQuery(String originalQuery) {
    final List<String> parts = [];

    if (originalQuery.trim().isNotEmpty) {
      parts.add(originalQuery.trim());
    }

    final localizedGender = _getLocalizedGender(_selectedGender);
    final localizedAge = _getLocalizedAge(_selectedAge);

    print('🎯 원본 gender: $_selectedGender → 변환: $localizedGender');
    print('🎯 원본 age: $_selectedAge → 변환: $localizedAge');

    if (localizedGender != null) parts.add(localizedGender);
    if (localizedAge != null) parts.add(localizedAge);

    final result = parts.join(' ').trim();
    print('👉 최종 Query (한글 변환됨) = $result');
    return result;
  }



  String? _getLocalizedGender(String? gender) {
    switch (gender) {
      case 'MALE':
        return '남성';
      case 'FEMALE':
        return '여성';
      default:
        return null;
    }
  }

  String? _getLocalizedAge(String? ageCode) {
    switch (ageCode) {
      case '0-5':
        return '0~5세';
      case '6-9':
        return '6~9세';
      case '10s':
        return '10대';
      case '20s':
        return '20대';
      case '30s':
        return '30대';
      case '40s':
        return '40대';
      case '50s':
        return '50대';
      case '60s':
      case '60+':
        return '60대'; // 또는 '60세'도 가능
      default:
        return null;
    }
  }
}
