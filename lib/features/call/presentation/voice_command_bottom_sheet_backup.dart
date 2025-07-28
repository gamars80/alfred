// lib/features/call/presentation/voice_command_bottom_sheet.dart
import 'package:alfred_clean/features/call/presentation/widget/voice_command_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/age_range.dart';
import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceCommandBottomSheet {
  static final Dio _dio = DioClient.dio;

  static Future<String?> show({
    required BuildContext context,
    required String selectedCategory,
    required String? selectedGender,
    required String? selectedAge,
    required String? errorMessage,
    required TextEditingController controller,
    required bool isListening,
    required bool isLoading,
    required ValueChanged<String?> onGenderChanged,
    required ValueChanged<String?> onAgeChanged,
    required ValueChanged<String> onCategoryChanged,
  }) {
    final _bottomSheetScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    String? localGender = selectedGender;
    String? localAge = selectedAge;
    String? localCategory = selectedCategory.isEmpty ? null : selectedCategory;
    bool modalIsListening = false;
    int? remainingCommands;
    String? localErrorMessage;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> handleMic() async {
            modalIsListening = true;
            setModalState(() {});
            try {
              const platform = MethodChannel('com.alfred/voice');
              final result = await platform.invokeMethod<String>('startListening');
              controller.text = result ?? '';
            } catch (e) {
              if (e.toString().contains('PERMISSION_DENIED')) {
                final shouldOpenSettings = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('마이크 권한 필요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    content: const Text('음성 인식을 위해\n마이크 권한이 필요합니다.', style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('권한 설정하기')),
                    ],
                  ),
                );
                if (shouldOpenSettings == true) {
                  await openAppSettings();
                }
              } else {
                Fluttertoast.showToast(msg: '음성 인식에 실패했습니다.');
              }
            } finally {
              modalIsListening = false;
              setModalState(() {});
            }
          }
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: ScaffoldMessenger(
                key: _bottomSheetScaffoldMessengerKey,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))
                      ],
                    ),
                    padding: const EdgeInsets.only(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      top: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategorySelector(
                          localCategory,
                          (v) {
                            localCategory = v;
                            onCategoryChanged(v);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildGenderSelector(
                          localGender,
                          (v) {
                            localGender = v;
                            onGenderChanged(v);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildAgeSelector(
                          localAge,
                          (v) {
                            localAge = v;
                            onAgeChanged(v);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        VoiceCommandInputWidget(
                          controller: controller,
                          isListening: modalIsListening,
                          onMicPressed: handleMic,
                          onSendPressed: () {
                            if (controller.text.isNotEmpty) {
                              Navigator.pop(context, controller.text);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildErrorDisplay(localErrorMessage),
                        const SizedBox(height: 16),
                        _buildRemainingCommands(remainingCommands),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildCategorySelector(String? selectedCategory, ValueChanged<String> onChanged) {
    final categories = ['쇼핑', '시술/성형', '음식/식자재', '뷰티케어'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return GestureDetector(
              onTap: () => onChanged(category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6200EE) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildGenderSelector(String? selectedGender, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성별 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('남성'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedGender == '남성' ? const Color(0xFF6200EE) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '남성',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selectedGender == '남성' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('여성'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedGender == '여성' ? const Color(0xFF6200EE) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '여성',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selectedGender == '여성' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildAgeSelector(String? selectedAge, ValueChanged<String?> onChanged) {
    final ageRanges = [
      '10대', '20대', '30대', '40대', '50대', '60대 이상'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '연령대 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ageRanges.map((age) {
            final isSelected = selectedAge == age;
            return GestureDetector(
              onTap: () => onChanged(age),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6200EE) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  age,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildErrorDisplay(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildRemainingCommands(int? remainingCommands) {
    if (remainingCommands == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '남은 명령권: $remainingCommands개',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 