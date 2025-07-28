// 🎨 Modern Voice Command Bottom Sheet - Redesigned with enhanced UI/UX
import 'package:alfred_clean/features/call/presentation/widget/voice_command_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/age_range.dart';
import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import 'package:permission_handler/permission_handler.dart';

// 🎨 Modern Design Constants
class VoiceSheetTheme {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color secondaryGradientStart = Color(0xFFf093fb);
  static const Color secondaryGradientEnd = Color(0xFFf5576c);
  static const Color backgroundGradientStart = Color(0xFFf8fafc);
  static const Color backgroundGradientEnd = Color(0xFFe2e8f0);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentColor = Color(0xFFed8936);
  static const Color successColor = Color(0xFF48bb78);
  static const Color warningColor = Color(0xFFed8936);
  static const Color errorColor = Color(0xFFf56565);
  static const double borderRadius = 24.0;
  static const double cardElevation = 20.0;
  static const double spacing = 20.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

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
                  builder: (context) => _buildPermissionDialog(),
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
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          VoiceSheetTheme.backgroundGradientStart,
                          VoiceSheetTheme.backgroundGradientEnd,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(VoiceSheetTheme.borderRadius)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(
                      bottom: VoiceSheetTheme.spacing,
                      left: VoiceSheetTheme.spacing,
                      right: VoiceSheetTheme.spacing,
                      top: VoiceSheetTheme.spacing,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModernHeader(),
                        const SizedBox(height: VoiceSheetTheme.spacing),
                        _buildModernCategorySelector(
                          localCategory,
                          (v) {
                            localCategory = v;
                            onCategoryChanged(v);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: VoiceSheetTheme.spacing),
                        _buildModernGenderSelector(
                          localGender,
                          (v) {
                            localGender = v;
                            onGenderChanged(v);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: VoiceSheetTheme.spacing),
                        _buildModernAgeSelector(
                          localAge,
                          (v) {
                            localAge = v;
                            onAgeChanged(v);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: VoiceSheetTheme.spacing),
                        _buildModernVoiceInput(
                          controller: controller,
                          isListening: modalIsListening,
                          onMicPressed: handleMic,
                          onSendPressed: () {
                            if (controller.text.isNotEmpty) {
                              Navigator.pop(context, controller.text);
                            }
                          },
                        ),
                        const SizedBox(height: VoiceSheetTheme.spacing),
                        _buildModernErrorDisplay(localErrorMessage),
                        const SizedBox(height: VoiceSheetTheme.spacing),
                        _buildModernRemainingCommands(remainingCommands),
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

  static Widget _buildModernHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: VoiceSheetTheme.textSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                VoiceSheetTheme.primaryGradientStart,
                VoiceSheetTheme.primaryGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 20,
          ),
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: VoiceSheetTheme.textSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  static Widget _buildModernCategorySelector(String? selectedCategory, ValueChanged<String> onChanged) {
    final categories = [
      {'name': '쇼핑', 'icon': Icons.shopping_bag},
      {'name': '시술/성형', 'icon': Icons.medical_services},
      {'name': '음식/식자재', 'icon': Icons.restaurant},
      {'name': '뷰티케어', 'icon': Icons.spa},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    VoiceSheetTheme.primaryGradientStart,
                    VoiceSheetTheme.primaryGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.category,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '카테고리 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VoiceSheetTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((category) {
            final isSelected = selectedCategory == category['name'];
            return GestureDetector(
              onTap: () => onChanged(category['name'] as String),
              child: AnimatedContainer(
                duration: VoiceSheetTheme.animationDuration,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            VoiceSheetTheme.primaryGradientStart,
                            VoiceSheetTheme.primaryGradientEnd,
                          ],
                        )
                      : null,
                  color: isSelected ? null : VoiceSheetTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? VoiceSheetTheme.primaryGradientStart.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected ? Colors.white : VoiceSheetTheme.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : VoiceSheetTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildModernGenderSelector(String? selectedGender, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    VoiceSheetTheme.secondaryGradientStart,
                    VoiceSheetTheme.secondaryGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '성별 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VoiceSheetTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('남성'),
                child: AnimatedContainer(
                  duration: VoiceSheetTheme.animationDuration,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: selectedGender == '남성'
                        ? const LinearGradient(
                            colors: [
                              VoiceSheetTheme.primaryGradientStart,
                              VoiceSheetTheme.primaryGradientEnd,
                            ],
                          )
                        : null,
                    color: selectedGender == '남성' ? null : VoiceSheetTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: selectedGender == '남성'
                            ? VoiceSheetTheme.primaryGradientStart.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: selectedGender == '남성' ? Colors.white : VoiceSheetTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '남성',
                        style: TextStyle(
                          color: selectedGender == '남성' ? Colors.white : VoiceSheetTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('여성'),
                child: AnimatedContainer(
                  duration: VoiceSheetTheme.animationDuration,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: selectedGender == '여성'
                        ? const LinearGradient(
                            colors: [
                              VoiceSheetTheme.primaryGradientStart,
                              VoiceSheetTheme.primaryGradientEnd,
                            ],
                          )
                        : null,
                    color: selectedGender == '여성' ? null : VoiceSheetTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: selectedGender == '여성'
                            ? VoiceSheetTheme.primaryGradientStart.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: selectedGender == '여성' ? Colors.white : VoiceSheetTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '여성',
                        style: TextStyle(
                          color: selectedGender == '여성' ? Colors.white : VoiceSheetTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildModernAgeSelector(String? selectedAge, ValueChanged<String?> onChanged) {
    final ageRanges = [
      {'name': '10대', 'icon': Icons.child_care},
      {'name': '20대', 'icon': Icons.school},
      {'name': '30대', 'icon': Icons.work},
      {'name': '40대', 'icon': Icons.business},
      {'name': '50대', 'icon': Icons.person},
      {'name': '60대 이상', 'icon': Icons.elderly},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    VoiceSheetTheme.accentColor,
                    VoiceSheetTheme.warningColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.cake,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '연령대 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VoiceSheetTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ageRanges.map((age) {
            final isSelected = selectedAge == age['name'];
            return GestureDetector(
              onTap: () => onChanged(age['name'] as String),
              child: AnimatedContainer(
                duration: VoiceSheetTheme.animationDuration,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            VoiceSheetTheme.primaryGradientStart,
                            VoiceSheetTheme.primaryGradientEnd,
                          ],
                        )
                      : null,
                  color: isSelected ? null : VoiceSheetTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? VoiceSheetTheme.primaryGradientStart.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      age['icon'] as IconData,
                      color: isSelected ? Colors.white : VoiceSheetTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      age['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : VoiceSheetTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildModernVoiceInput({
    required TextEditingController controller,
    required bool isListening,
    required VoidCallback onMicPressed,
    required VoidCallback onSendPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VoiceSheetTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: VoiceSheetTheme.backgroundGradientStart,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: VoiceSheetTheme.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: '음성 명령을 입력하세요...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: VoiceSheetTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(
                      color: VoiceSheetTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onMicPressed,
                child: AnimatedContainer(
                  duration: VoiceSheetTheme.animationDuration,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isListening
                        ? const LinearGradient(
                            colors: [
                              VoiceSheetTheme.errorColor,
                              VoiceSheetTheme.warningColor,
                            ],
                          )
                        : const LinearGradient(
                            colors: [
                              VoiceSheetTheme.primaryGradientStart,
                              VoiceSheetTheme.primaryGradientEnd,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isListening
                            ? VoiceSheetTheme.errorColor.withOpacity(0.4)
                            : VoiceSheetTheme.primaryGradientStart.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.text.isNotEmpty ? onSendPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: VoiceSheetTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                '명령 전송',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildModernErrorDisplay(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            VoiceSheetTheme.errorColor,
            VoiceSheetTheme.warningColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: VoiceSheetTheme.errorColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildModernRemainingCommands(int? remainingCommands) {
    if (remainingCommands == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            VoiceSheetTheme.successColor,
            VoiceSheetTheme.primaryGradientStart,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: VoiceSheetTheme.successColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '남은 명령권: $remainingCommands개',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPermissionDialog() {
    return Builder(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    VoiceSheetTheme.errorColor,
                    VoiceSheetTheme.warningColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.mic_off,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '마이크 권한 필요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          '음성 인식을 위해\n마이크 권한이 필요합니다.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: VoiceSheetTheme.primaryGradientStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('권한 설정하기'),
          ),
        ],
      ),
    );
  }
}
