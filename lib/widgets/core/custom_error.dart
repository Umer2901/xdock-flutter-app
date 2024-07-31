import 'package:coldxpress/export.dart';

class CustomError extends StatelessWidget {
  const CustomError({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: AppColors.lightpink,
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
          child: Center(
            child: Row(
              children: [
                Image.asset(AppImages.priority),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
