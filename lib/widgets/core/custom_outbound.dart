import 'package:coldxpress/export.dart';

class CustomOutBoundHeader extends StatelessWidget {
  const CustomOutBoundHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.outboundPallets,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(color: AppColors.white),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                AppText.palletsDesc,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.white,
                    ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Consumer<OutboundProvider>(
                builder: (context, provider, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) {
                        return Icon(
                          index == provider.index
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
