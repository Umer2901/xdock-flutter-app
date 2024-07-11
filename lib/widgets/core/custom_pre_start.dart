import 'package:coldxpress/export.dart';

class CustomPreStartHeader extends StatelessWidget {
  const CustomPreStartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.preStartTitle.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              ),
              SizedBox(
                height: 1.h,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    // Text(
                    //   AppText.cxf009,
                    //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //         color: AppColors.white,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    // ),
                    // VerticalDivider(
                    //   color: AppColors.white,
                    //   thickness: 0.2.w,
                    // ),
                    // Text(
                    //   AppText.issue,
                    //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //         color: AppColors.white,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    // ),
                    // VerticalDivider(
                    //   color: AppColors.white,
                    //   thickness: 0.2.w,
                    // ),
                    Text(
                      DateFormat('dd/MM/yy').format(
                        DateTime.now(),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                AppText.preStartDesc,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.white),
              ),
              SizedBox(
                height: 2.h,
              ),
              Consumer<PreStartProvider>(
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) {
                        return Icon(
                          index == value.index
                              ? Icons.circle
                              : Icons.circle_outlined,
                          size: 1.5.h,
                          color: AppColors.white,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 1.h,
        ),
      ],
    );
  }
}
