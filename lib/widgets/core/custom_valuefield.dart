import 'package:coldxpress/export.dart';

class CustomValueField extends StatelessWidget {
  const CustomValueField({
    super.key,
    required this.title,
    required this.value,
    this.svgImage,
  });
  final String title;
  final String value;
  final Widget? svgImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(
              width: svgImage != null ? 22.w : 26.w,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.belowMidGreyOne),
                maxLines: 1,
              ),
            ),
          ],
        ),
        svgImage != null
            ? SizedBox(
                height: 3.5.h,
                width: 8.w,
                child: svgImage,
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
