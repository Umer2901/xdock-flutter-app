part of '../pre_start_checklist.dart';

class FridgePanCheckTab extends StatefulWidget {
  final List data;
  const FridgePanCheckTab({super.key, required this.data});

  @override
  State<FridgePanCheckTab> createState() => _FridgePanCheckTabState();
}

class _FridgePanCheckTabState extends State<FridgePanCheckTab> {
  Map<String, String> checklistAnswers = {};
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CustomPreStartHeader(),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.sp),
              topRight: Radius.circular(30.sp),
            ),
            child: Material(
              color: AppColors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        AppText.fridgePanCheck.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        AppText.fridgePanCheckDesc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                      ),
                      SizedBox(height: 2.h),
                      ...widget.data[1]['checklist_questions'].map<Widget>((questionData) {
                        final questionId = questionData['id'];
                        final options = questionData['options']['option'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionData['question'],
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Wrap(
                              children: options.map<Widget>((option) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: option,
                                      groupValue: checklistAnswers['answer_$questionId'],
                                      activeColor: option == 'No' ? AppColors.red : AppColors.blue,
                                      onChanged: (value) {
                                        if (value != null) {
                                          final temp = {
                                            'question_id_${widget.data[0]['checklist_questions'].length + widget.data[1]['checklist_questions'].indexOf(questionData)}': questionId.toString(),
                                            'comment_$questionId': '',
                                            'answer_$questionId': value,
                                          };
                                          setState(() {
                                            checklistAnswers.addEntries(temp.entries);
                                          });
                                        }
                                      },
                                    ),
                                    Text(
                                      option,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            if (checklistAnswers['answer_$questionId'] == 'No') ...[
                              CustomTextField(
                                name: 'comment$questionId',
                                hintText: 'Comment',
                                onChanged: (value) {
                                  setState(() {
                                    checklistAnswers['comment_$questionId'] = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
                              ),
                              SizedBox(height: 1.5.h),
                            ],
                            SizedBox(height: 1.h),
                          ],
                        );
                      }).toList(),
                      const Divider(),
                      SizedBox(height: 2.h),
                      Text(
                        AppText.fitForWork.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        AppText.fitForWorkDesc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                      ),
                      SizedBox(height: 2.h),
                      ...widget.data[2]['checklist_questions'].map<Widget>((questionData) {
                        final questionId = questionData['id'];
                        final options = questionData['options']['option'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionData['question'],
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Wrap(
                              children: options.map<Widget>((option) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: option,
                                      groupValue: checklistAnswers['answer_$questionId'],
                                      activeColor: option == 'No' ? AppColors.red : AppColors.blue,
                                      onChanged: (value) {
                                        if (value != null) {
                                          final temp = {
                                            'question_id_${widget.data[0]['checklist_questions'].length + widget.data[1]['checklist_questions'].length + widget.data[2]['checklist_questions'].indexOf(questionData)}': questionId.toString(),
                                            'comment_$questionId': '',
                                            'answer_$questionId': value,
                                          };
                                          setState(() {
                                            checklistAnswers.addEntries(temp.entries);
                                          });
                                        }
                                      },
                                    ),
                                    Text(
                                      option,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            if (checklistAnswers['answer_$questionId'] == 'No') ...[
                              CustomTextField(
                                name: 'comment$questionId',
                                hintText: 'Comment',
                                onChanged: (value) {
                                  setState(() {
                                    checklistAnswers['comment_$questionId'] = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
                              ),
                              SizedBox(height: 1.5.h),
                            ],
                            SizedBox(height: 1.h),
                          ],
                        );
                      }).toList(),
                      SizedBox(height: 2.h),
                      Text(
                        AppText.fleetAndCompliance,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 1.h),
                      CustomTextField(
                        name: 'fleet_and_compliance',
                        maxLines: 3,
                        hintText: AppText.fleetAndCompliance,
                        initialValue: context.read<PreStartProvider>().data.containsKey('fleet_and_compliance')
                            ? context.read<PreStartProvider>().data['fleet_and_compliance']
                            : null,
                        validator: FormBuilderValidators.required(),
                      ),
                      SizedBox(height: 4.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: 5.h,
                          width: 40.w,
                          child: CustomButton(
                            label: AppText.next,
                            onPressed: () {
                              bool isValid = true;
                              for (var section in [widget.data[1], widget.data[2]]) {
                                for (var question in section['checklist_questions']) {
                                  final questionId = question['id'];
                                  if (!checklistAnswers.containsKey('answer_$questionId') &&
                                      !context.read<PreStartProvider>().data.containsKey('answer_$questionId')) {
                                    isValid = false;
                                  }
                                }
                              }
                              if (isValid && _formKey.currentState!.validate()) {
                                // Check for invalid answers and provide feedback
                                bool hasErrors = false;
                                for (var section in [widget.data[1], widget.data[2]]) {
                                  for (var question in section['checklist_questions']) {
                                    final questionId = question['id'];
                                    if (checklistAnswers['answer_$questionId'] != null &&
                                        question['options'].containsKey('required_answer') &&
                                        !question['options']['required_answer'].contains(checklistAnswers['answer_$questionId'])) {
                                      hasErrors = true;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.error_outline_rounded,
                                                color: AppColors.white,
                                              ),
                                              SizedBox(width: 2.w),
                                              Expanded(
                                                child: Text(
                                                  '${question['question']} value can\'t be "${checklistAnswers['answer_$questionId']}". Contact your supervise!',
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: AppColors.lightRed,
                                          margin: EdgeInsets.only(bottom: 1.h),
                                        ),
                                      );
                                    }
                                  }
                                }
                                if (!hasErrors) {
                                  context.read<PreStartProvider>().addEntities(checklistAnswers.entries);
                                  context.read<PreStartProvider>().addEntities({
                                    'fleet_and_compliance': _formKey.currentState!.fields['fleet_and_compliance']!.value
                                  }.entries);
                                  context.read<PreStartProvider>().setIndex(3);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All sections must be filled out in order to continue.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
