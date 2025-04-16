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
    modalSetState?.call(() {}); // 모달 내부 갱신

    try {
      final api = ProductApi();
      if (_selectedGender != null || _selectedAge != null) {
        final suffix = [
          if (_selectedGender != null) _selectedGender,
          if (_selectedAge != null) _selectedAge,
        ].join(' ');
        query = '$query $suffix'.trim();
      }
      final result = await api.fetchRecommendedProducts(query);
      setState(() {
        _categorizedProducts = result;
        _selectedGender = null;
        _selectedAge = null;
      });

      // 키보드 숨기기: 부모 context 사용
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      // API 성공 시 모달 닫기 (부모 context를 사용)
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
      setState(() {
        _isLoading = false;
      });
      modalSetState?.call(() {});
    }
  }

  Future<void> _startNativeListening() async {
    setState(() => _isListening = true);
    try {
      final result = await platform.invokeMethod<String>('startListening');
      if (result != null && result.isNotEmpty) {
        setState(() {
          _commandController.text = result;
        });
      }
    } on PlatformException catch (e) {
      debugPrint("음성 인식 오류: ${e.message}");
    }
    setState(() => _isListening = false);
  }

  Future<void> _openBottomSheet() async {
    _bottomSheetContentKey = UniqueKey();
    _showingBottomSheet = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builderContext) {
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
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage == null)
                      VoiceCommandInputWidget(
                        controller: _commandController,
                        isListening: _isListening,
                        isLoading: _isLoading,
                        onMicPressed: _startNativeListening,
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
                          _fetchProducts(query, modalSetState: modalSetState);
                        },
                      ),
                    if (_errorMessage != null) ...[
                      _buildExtraInfoInput(modalSetState),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final query = _commandController.text.trim().isEmpty
                              ? ' '
                              : _commandController.text.trim();
                          // 필수 선택값 미입력 시 토스트 표시 후 API 호출 차단
                          if ((_errorMessage == 'gender' && _selectedGender == null) ||
                              (_errorMessage == 'age' && _selectedAge == null) ||
                              (_errorMessage == 'both' &&
                                  (_selectedGender == null || _selectedAge == null))) {
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

    // 모달이 닫히면 _showingBottomSheet를 false로 설정
    setState(() {
      _showingBottomSheet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ScaffoldMessenger는 부모 Scaffold 안에 자동으로 SnackBar를 표시하지만 여기서는 Fluttertoast를 사용하므로 별도의 설정은 필요 없습니다.
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
        child: Text('추천된 상품이 없습니다.',
            style: TextStyle(color: Colors.grey)),
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
              ...products
                  .map((product) => _buildProductCard(product))
                  .toList(),
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

  Widget _buildExtraInfoInput(StateSetter modalSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage == 'gender' || _errorMessage == 'both') ...[
          const Text(
            '자세한 추천을 위해 성별을 선택해주세요.',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'MALE',
                groupValue: _selectedGender,
                onChanged: (value) {
                  if (value != null) {
                    modalSetState(() {
                      _selectedGender = value;
                    });
                  }
                },
              ),
              const Text('남성', style: TextStyle(fontSize: 13, color: Colors.black87)),
              Radio<String>(
                value: 'FEMALE',
                groupValue: _selectedGender,
                onChanged: (value) {
                  if (value != null) {
                    modalSetState(() {
                      _selectedGender = value;
                    });
                  }
                },
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
                fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          Wrap(
            spacing: 8,
            children: AgeRange.values.map((range) {
              return ChoiceChip(
                label: Text(range.description, style: const TextStyle(fontSize: 11)),
                selected: _selectedAge == range.code,
                onSelected: (selected) {
                  if (selected) {
                    modalSetState(() {
                      _selectedAge = range.code;
                    });
                  }
                },
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
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
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
            )
          ],
        ),
      ),
    );
  }
}
