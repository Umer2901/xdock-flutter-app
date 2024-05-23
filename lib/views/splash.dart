import 'dart:io';

import 'package:coldxpress/export.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
        .whenComplete(() async {
      context.read<LocationProvider>().getCurrentLocation();
      await BlocProvider.of<AuthenticationCubit>(context)
          .check()
          .whenComplete(() {
        onStart();
      });
    });
  }

  void onStart() {
    Connectivity().onConnectivityChanged.listen((event) async {
      try {
        if (event.contains(ConnectivityResult.wifi) ||
            event.contains(ConnectivityResult.mobile)) {
          await InternetAddress.lookup('google.com').then((value) {
            AuthenticationState state =
                BlocProvider.of<AuthenticationCubit>(context).state;
            if (state is Authenticated) {
              ConsignmentService(context.read<DatabaseProvider>().database)
                  .fetchAndStore(state.token);
            }
          });
        }
      } on SocketException catch (e) {
        throw Exception('No Internet ($e)');
      } catch (e) {
        throw Exception('Something went wrong! ($e)');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) async {
        if (state is Authenticated) {
          await PreCheckDatabase(context.read<DatabaseProvider>().database)
              .read()
              .then((submissions) async {
            if (submissions.isEmpty) {
              try {
                await PrecheckStatusService(
                  context.read<DatabaseProvider>().database,
                ).fetchAndStore(state.token);
              } catch (e) {
                debugPrint("Not Connected to Network");
              }
            }
          });

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