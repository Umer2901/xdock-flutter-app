part of '../pre_start_checklist.dart';

class VehicleCheckTab extends StatefulWidget {
  final List questions;
  const VehicleCheckTab({super.key, required this.questions});

  @override
  State<VehicleCheckTab> createState() => _VehicleCheckTabState();
}

class _VehicleCheckTabState extends State<VehicleCheckTab> {
  Map checklistAnswers = {};

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 4.h,
                    ),
                    Text(
                      AppText.vehicleChecks.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      AppText.vehicleChecksDesc,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.grey),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    for (int i = 0; i < widget.questions.length; i++) ...{
                      Text(
                        widget.questions[i]['question'],
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Wrap(
                        children: [
                          for (int j = 0;
                              j <
                                  widget
                                      .questions[i]['options']['option'].length;
                              j++) ...{
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio(
                                  value: widget.questions[i]['options']
                                      ['option'][j],
                                  groupValue: checklistAnswers.containsKey(
                                          'answer_${widget.questions[i]['id']}')
                                      ? checklistAnswers[
                                          'answer_${widget.questions[i]['id']}']
                                      : context
                                              .read<PreStartProvider>()
                                              .data
                                              .containsKey(
                                                  'answer_${widget.questions[i]['id']}')
                                          ? context
                                                  .read<PreStartProvider>()
                                                  .data[
                                              'answer_${widget.questions[i]['id']}']
                                          : null,
                                  activeColor: (checklistAnswers.containsKey(
                                                  'answer_${widget.questions[i]['id']}')
                                              ? checklistAnswers[
                                                  'answer_${widget.questions[i]['id']}']
                                              : null) ==
                                          'No'
                                      ? AppColors.red
                                      : AppColors.blue,
                                  onChanged: (value) {
                                    if (!widget.questions[i]['options']
                                            .containsKey('required_answer') ||
                                        widget.questions[i]['options']
                                                ['required_answer']
                                            .contains(value) ||
                                        widget
                                            .questions[i]['options']
                                                ['required_answer']
                                            .isEmpty) {
                                      setState(() {
                                        final temp = {
                                          'question_id_${widget.questions.indexOf(widget.questions[i])}':
                                              widget.questions[i]['id']
                                                  .toString(),
                                          'comment_${widget.questions[i]['id']}':
                                              '',
                                          'answer_${widget.questions[i]['id']}':
                                              value.toString(),
                                        };
                                        checklistAnswers
                                            .addEntries(temp.entries);
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.error_outline_rounded,
                                                color: AppColors.red,
                                              ),
                                              SizedBox(width: 2.w),
                                              Expanded(
                                                child: Text(
                                                  '${widget.questions[i]['question']} value can\'t be $value. Contact your supervise!',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          color: AppColors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: AppColors.lightRed,
                                          margin: EdgeInsets.only(bottom: 1.h),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  widget.questions[i]['options']['option'][j],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 10.sp),
                                )
                              ],
                            ),
                          }
                        ],
                      ),
                      if ((checklistAnswers.containsKey(
                                  'answer_${widget.questions[i]['id']}')
                              ? checklistAnswers[
                                  'answer_${widget.questions[i]['id']}']
                              : null) ==
                          'No') ...{
                        CustomTextField(
                          name: 'comment',
                          hintText: 'Comment',
                          onChanged: (value) {
                            setState(() {
                              checklistAnswers[
                                      'comment_${widget.questions[i]['id']}'] =
                                  value;
                            });
                          },
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 0,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                      }
                    },
                    SizedBox(
                      height: 2.h,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 5.h,
                        width: 40.w,
                        child: CustomButton(
                          label: AppText.next,
                          onPressed: () {
                            bool validate = true;
                            for (var value in widget.questions) {
                              if (!checklistAnswers
                                      .containsKey('answer_${value['id']}') &&
                                  !context
                                      .read<PreStartProvider>()
                                      .data
                                      .containsKey('answer_${value['id']}')) {
                                validate = false;
                              }
                            }
                            if (validate) {
                              context
                                  .read<PreStartProvider>()
                                  .addEntities(checklistAnswers.entries);
                              context.read<PreStartProvider>().setIndex(2);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'All sections must be filled out in order to continue.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
