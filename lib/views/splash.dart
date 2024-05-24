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
    await context
        .read<DatabaseProvider>()
        .initDatabase()
        .then((database) async {
      context.read<LocationProvider>().getCurrentLocation();
      await BlocProvider.of<AuthenticationCubit>(context).check(database);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) async {
        if (state is Authenticated) {
          await Future.delayed(
            const Duration(milliseconds: 1200),
          );

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
