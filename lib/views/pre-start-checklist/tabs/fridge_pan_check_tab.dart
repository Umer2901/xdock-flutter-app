part of '../pre_start_checklist.dart';

class FridgePanCheckTab extends StatefulWidget {
  final List data;
  const FridgePanCheckTab({super.key, required this.data});

  @override
  State<FridgePanCheckTab> createState() => _FridgePanCheckTabState();
}

class _FridgePanCheckTabState extends State<FridgePanCheckTab> {
  Map checklistAnswers = {};
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
                      SizedBox(
                        height: 4.h,
                      ),
                      Text(
                        AppText.fridgePanCheck.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        AppText.fridgePanCheckDesc,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.grey),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      for (int i = 0;
                          i < widget.data[1]['checklist_questions'].length;
                          i++) ...{
                        Text(
                          widget.data[1]['checklist_questions'][i]['question'],
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        Wrap(
                          children: [
                            for (int j = 0;
                                j <
                                    widget
                                        .data[1]['checklist_questions'][i]
                                            ['options']['option']
                                        .length;
                                j++) ...{
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio(
                                    value: widget.data[1]['checklist_questions']
                                        [i]['options']['option'][j],
                                    groupValue: checklistAnswers.containsKey(
                                            'answer_${widget.data[1]['checklist_questions'][i]['id']}')
                                        ? checklistAnswers[
                                            'answer_${widget.data[1]['checklist_questions'][i]['id']}']
                                        : context
                                                .read<PreStartProvider>()
                                                .data
                                                .containsKey(
                                                    'answer_${widget.data[1]['checklist_questions'][i]['id']}')
                                            ? context
                                                    .read<PreStartProvider>()
                                                    .data[
                                                'answer_${widget.data[1]['checklist_questions'][i]['id']}']
                                            : null,
                                    activeColor: (checklistAnswers.containsKey(
                                                    'answer_${widget.data[1]['checklist_questions'][i]['id']}')
                                                ? checklistAnswers[
                                                    'answer_${widget.data[1]['checklist_questions'][i]['id']}']
                                                : null) ==
                                            'No'
                                        ? AppColors.red
                                        : AppColors.blue,
                                    onChanged: (value) {
                                      setState(() {
                                        final temp = {
                                          'question_id_${(widget.data[0]['checklist_questions'].length) + widget.data[1]['checklist_questions'].indexOf(widget.data[1]['checklist_questions'][i])}':
                                              widget.data[1]
                                                      ['checklist_questions'][i]
                                                      ['id']
                                                  .toString(),
                                          'comment_${widget.data[1]['checklist_questions'][i]['id']}':
                                              '',
                                          'answer_${widget.data[1]['checklist_questions'][i]['id']}':
                                              value.toString(),
                                        };
                                        checklistAnswers
                                            .addEntries(temp.entries);
                                      });
                                    },
                                  ),
                                  Text(
                                    widget.data[1]['checklist_questions'][i]
                                        ['options']['option'][j],
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
                                    'answer_${widget.data[1]['checklist_questions'][i]['id']}')
                                ? checklistAnswers[
                                    'answer_${widget.data[1]['checklist_questions'][i]['id']}']
                                : null) ==
                            'No') ...{
                          CustomTextField(
                            name: 'comment',
                            hintText: 'Comment',
                            onChanged: (value) {
                              setState(() {
                                checklistAnswers[
                                        'comment_${widget.data[1]['checklist_questions'][i]['id']}'] =
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
                      const Divider(),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        AppText.fitForWork.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        AppText.fitForWorkDesc,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.grey),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      for (int i = 0;
                          i < widget.data[2]['checklist_questions'].length;
                          i++) ...{
                        Text(
                          widget.data[2]['checklist_questions'][i]['question'],
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        Wrap(
                          children: [
                            for (int j = 0;
                                j <
                                    widget
                                        .data[2]['checklist_questions'][i]
                                            ['options']['option']
                                        .length;
                                j++) ...{
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio(
                                    value: widget.data[2]['checklist_questions']
                                        [i]['options']['option'][j],
                                    groupValue: checklistAnswers.containsKey(
                                            'answer_${widget.data[2]['checklist_questions'][i]['id']}')
                                        ? checklistAnswers[
                                            'answer_${widget.data[2]['checklist_questions'][i]['id']}']
                                        : context
                                                .read<PreStartProvider>()
                                                .data
                                                .containsKey(
                                                    'answer_${widget.data[2]['checklist_questions'][i]['id']}')
                                            ? context
                                                    .read<PreStartProvider>()
                                                    .data[
                                                'answer_${widget.data[2]['checklist_questions'][i]['id']}']
                                            : null,
                                    activeColor: (checklistAnswers.containsKey(
                                                    'answer_${widget.data[2]['checklist_questions'][i]['id']}')
                                                ? checklistAnswers[
                                                    'answer_${widget.data[2]['checklist_questions'][i]['id']}']
                                                : null) ==
                                            'No'
                                        ? AppColors.red
                                        : AppColors.blue,
                                    onChanged: (value) {
                                      setState(() {
                                        final temp = {
                                          'question_id_${(widget.data[0]['checklist_questions'].length) + (widget.data[1]['checklist_questions'].length) + widget.data[2]['checklist_questions'].indexOf(widget.data[2]['checklist_questions'][i])}':
                                              widget.data[2]
                                                      ['checklist_questions'][i]
                                                      ['id']
                                                  .toString(),
                                          'comment_${widget.data[2]['checklist_questions'][i]['id']}':
                                              '',
                                          'answer_${widget.data[2]['checklist_questions'][i]['id']}':
                                              value.toString(),
                                        };
                                        checklistAnswers
                                            .addEntries(temp.entries);
                                      });
                                    },
                                  ),
                                  Text(
                                    widget.data[2]['checklist_questions'][i]
                                        ['options']['option'][j],
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
                                    'answer_${widget.data[2]['checklist_questions'][i]['id']}')
                                ? checklistAnswers[
                                    'answer_${widget.data[2]['checklist_questions'][i]['id']}']
                                : null) ==
                            'No') ...{
                          CustomTextField(
                            name: 'comment',
                            hintText: 'Comment',
                            onChanged: (value) {
                              setState(() {
                                checklistAnswers[
                                        'comment_${widget.data[2]['checklist_questions'][i]['id']}'] =
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
                      Text(
                        AppText.fleetAndCompliance,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      CustomTextField(
                        name: 'fleet_and_compliance',
                        maxLines: 3,
                        hintText: AppText.fleetAndCompliance,
                        initialValue: context
                                .read<PreStartProvider>()
                                .data
                                .containsKey('fleet_and_compliance')
                            ? context
                                .read<PreStartProvider>()
                                .data['fleet_and_compliance']
                            : null,
                        validator: FormBuilderValidators.required(),
                      ),
                      SizedBox(
                        height: 4.h,
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
                              for (var value in widget.data[1]
                                  ['checklist_questions']) {
                                if (!checklistAnswers
                                        .containsKey('answer_${value['id']}') &&
                                    !context
                                        .read<PreStartProvider>()
                                        .data
                                        .containsKey('answer_${value['id']}')) {
                                  validate = false;
                                }
                              }
                              for (var value in widget.data[2]
                                  ['checklist_questions']) {
                                if (!checklistAnswers
                                        .containsKey('answer_${value['id']}') &&
                                    !context
                                        .read<PreStartProvider>()
                                        .data
                                        .containsKey('answer_${value['id']}')) {
                                  validate = false;
                                }
                              }
                              if (validate &&
                                  _formKey.currentState!.validate()) {
                                context
                                    .read<PreStartProvider>()
                                    .addEntities(checklistAnswers.entries);
                                context.read<PreStartProvider>().addEntities({
                                      'fleet_and_compliance': _formKey
                                          .currentState!
                                          .fields['fleet_and_compliance']!
                                          .value
                                    }.entries);
                                context.read<PreStartProvider>().setIndex(3);
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
          ),
        ],
      ),
    );
  }
}
