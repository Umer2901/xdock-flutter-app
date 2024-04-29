import 'package:coldxpress/export.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    config();
  }

  config() async {
    context.read<LocationProvider>().getCurrentLocation();
    BlocProvider.of<AuthenticationCubit>(context).check();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Get.offAndToNamed(AppRoutes.dashboard);
        } else {
          Get.offAndToNamed(AppRoutes.welcome);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 4.h,
                horizontal: 4.w,
              ),
              child: Image.asset(
                AppImages.splash,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
