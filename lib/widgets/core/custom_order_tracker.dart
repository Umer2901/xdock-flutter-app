import 'package:coldxpress/export.dart';

class CustomOrderTracking extends StatefulWidget {
  const CustomOrderTracking({
    super.key,
    required this.title,
    this.subText,
    required this.isLastStep,
    required this.currentStep,
    required this.stepIndex,
  });

  final String title;
  final String? subText;
  final bool isLastStep;
  final int currentStep;
  final int stepIndex;

  @override
  State<CustomOrderTracking> createState() => _CustomOrderTrackingState();
}

class _CustomOrderTrackingState extends State<CustomOrderTracking>
    with SingleTickerProviderStateMixin {
  // bool get isCompleted => widget.currentStep == widget.stepIndex;

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _colorAnimation = ColorTween(
      begin: AppColors.white,
      end: AppColors.blue,
    ).animate(_controller);

    if (widget.currentStep >= widget.stepIndex) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CustomOrderTracking oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep >= widget.stepIndex && !_controller.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.blue),
                    borderRadius: BorderRadius.circular(20.sp),
                    color: _colorAnimation.value,
                  ),
                  width: 2.h,
                  height: 2.h,
                  child: child,
                );
              },
            ),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                widget.subText != '' && widget.subText != null
                    ? SizedBox(
                        width: 50.w,
                        child: Text(
                          widget.subText ?? '',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                  ),
                        ),
                      )
                    : const SizedBox(),
                !widget.isLastStep
                    ? SizedBox(height: 3.h)
                    : SizedBox(
                        height: 1.h,
                      ),
              ],
            ),
          ],
        ),
        if (!widget.isLastStep)
          Positioned(
            left: 2.1.w,
            top: 2.h,
            child: SizedBox(
              width: 2.w,
              height: 100.h,
              child: CustomPaint(
                painter: DottedLinePainter(),
              ),
            ),
          ),
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 0.4.w
      ..style = PaintingStyle.stroke;

    final double dashWidth = 1.5.w;
    final double dashSpace = 0.7.h;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
