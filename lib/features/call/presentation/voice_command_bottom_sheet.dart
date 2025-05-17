// ✅ voice_command_bottom_sheet.dart (카테고리 상태 외부 반영 추가)
import 'package:alfred_clean/features/call/presentation/widget/voice_command_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/age_range.dart';


class VoiceCommandBottomSheet {
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
    String? localGender = selectedGender;
    String? localAge = selectedAge;
    String localCategory = selectedCategory;
    bool modalIsListening = false;

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
              if (result != null && result.isNotEmpty) {
                controller.text = result;
              }
            } catch (_) {
              Fluttertoast.showToast(msg: '음성 인식에 실패했습니다.');
            }

            modalIsListening = false;
            setModalState(() {});
          }

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFDFDFD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))],
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 20,
              right: 20,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
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
                  if (errorMessage == null)
                    VoiceCommandInputWidget(
                      controller: controller,
                      isListening: modalIsListening,
                      isLoading: isLoading,
                      onMicPressed: handleMic,
                      onSubmit: () {
                        final q = controller.text.trim();
                        if (q.isEmpty) {
                          Fluttertoast.showToast(msg: '검색어를 입력해주세요.');
                          return;
                        }
                        Navigator.pop(context, q);
                      },
                      category: localCategory,
                    )
                  else
                    _buildErrorInputs(
                      errorMessage,
                      localGender,
                      localAge,
                          (v) {
                        localGender = v;
                        onGenderChanged(v);
                        setModalState(() {});
                      },
                          (v) {
                        localAge = v;
                        onAgeChanged(v);
                        setModalState(() {});
                      },
                      context,
                      controller,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildCategorySelector(
      String selected,
      ValueChanged<String> onChanged,
      ) {
    return Row(
      children: [
        const Text('카테고리:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selected,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          items: const [
            DropdownMenuItem(value: '쇼핑', child: Text('쇼핑')),
            DropdownMenuItem(value: '시술/성형', child: Text('시술/성형')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }

  static Widget _buildErrorInputs(
      String? error,
      String? selectedGender,
      String? selectedAge,
      ValueChanged<String?> onGenderChanged,
      ValueChanged<String?> onAgeChanged,
      BuildContext context,
      TextEditingController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error == 'gender' || error == 'both') ...[
          const Text('성별을 선택해주세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Radio<String>(
                value: 'MALE',
                groupValue: selectedGender,
                onChanged: (v) => onGenderChanged(v),
              ),
              const Text('남자'),
              const SizedBox(width: 16),
              Radio<String>(
                value: 'FEMALE',
                groupValue: selectedGender,
                onChanged: (v) => onGenderChanged(v),
              ),
              const Text('여자'),
            ],
          ),
        ],
        if (error == 'age' || error == 'both') ...[
          const SizedBox(height: 16),
          const Text('연령대를 선택해주세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AgeRange.values.map((r) {
              return ChoiceChip(
                label: Text(r.description),
                selected: selectedAge == r.code,
                onSelected: (s) => onAgeChanged(s ? r.code : null),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('명령하기'),
          ),
        ),
      ],
    );
  }
}
