import 'package:coldxpress/export.dart';

class AppColors {
  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      Color(0xFF091E42),
      Color(0xFF091E42),
      Color(0xFF1D4AF3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    tileMode: TileMode.clamp,
  );
  static const LinearGradient preStartGradient = LinearGradient(
    colors: [
      Color(0xE92662FD),
      Color(0xFF2662FD),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.5, 0.5],
    transform: GradientRotation(-150 + 360),
  );
  static const LinearGradient preStartHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF4579fd),
      Color(0xFF356dfd),
      Color(0xFF356dfd),
      Color(0xFF2d67fd),
      Color(0xFF2d67fd),
      Color(0xFF2662FD),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.115, 0.115, 0.16, 0.16, 0.208, 0.208],
    transform: GradientRotation(150),
  );
  static const LinearGradient outInBoundGradient = LinearGradient(
    colors: [
      Color(0xE9333333),
      Color(0xFF333333),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.5, 0.5],
    transform: GradientRotation(-150 + 360),
  );
  static const LinearGradient outInBoundHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF2c3f5d),
      Color(0xFF1a2e4f),
      Color(0xFF1a2e4f),
      Color(0xFF102548),
      Color(0xFF102548),
      Color(0xFF091e42),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.108, 0.108, 0.15, 0.15, 0.195, 0.195],
    transform: GradientRotation(150),
  );
  static const Color blue = Color(0xFF2662FD);
  static const Color darkBlue = Color(0xFF182DB5);
  static const Color darkBlueOne = Color(0xFF000B6E);
  static const Color navyBlue = Color(0xFF243757);
  static const Color lightNavyBlue = Color(0xFF173996);
  static const Color lightBlue = Color(0xFF7796EA);
  static const Color midBlue = Color(0xFF1A51A3);
  static const Color newBlue = Color(0xFF9AC2FF);
  static const Color skyBlue = Color(0xFF8FBAFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyWhite = Color(0xFFEBEDF0);
  static const Color black = Color(0xFF000000);
  static const Color lightBlack = Color(0xFF353535);
  static const Color darkGrey = Color(0xFF333333);
  static const Color grey = Color(0xFFC6C6C6);
  static const Color border = Color(0xFF302551);
  static const Color lightGrey = Color(0xFFD8DADC);
  static const Color belowMidGreyTwo = Color(0xFFD1D1D1);
  static const Color belowMidGreyOne = Color(0xFF6F6F6F);
  static const Color midGrey = Color(0xFF575757);
  static const Color red = Color(0xFFB1030F);
  static const Color lightRed = Color(0xFFFC4343);
  static const Color lightpink = Color(0xFFFFF0F1);
  static const Color yellow = Color(0xFFFFC30B);

  static final kEnableBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.sp),
    borderSide: const BorderSide(
      color: AppColors.border,
    ),
  );

  static final kFocuseBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.sp),
    borderSide: const BorderSide(
      color: AppColors.black,
    ),
  );

  static final kErrorOutlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.sp),
    borderSide: const BorderSide(
      color: Colors.red,
    ),
  );
}
