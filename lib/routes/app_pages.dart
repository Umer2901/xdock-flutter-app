import 'package:coldxpress/export.dart';
import 'package:coldxpress/views/pending_view.dart';
import 'package:coldxpress/views/pod_history_view.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/clock.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/proof_of_delivery.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/proof_of_delivery_photos.dart';

import '../views/pod_history.dart';

class AppPages extends AppRoutes {
  static const String initialRoute = AppRoutes.splash;
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => VerifyOtpView(),
      arguments: Get.arguments,
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeView(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      arguments: Get.arguments,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
    ),
    GetPage(
      name: AppRoutes.newPassword,
      page: () => const NewPasswordView(),
    ),
    GetPage(
      name: AppRoutes.preStartChecklist,
      page: () => const PreStartCheckListView(),
    ),
    GetPage(
      name: AppRoutes.consignmentMap,
      page: () => const ConsignmentMapTab(),
    ),
    GetPage(
      name: AppRoutes.outboundPallet,
      page: () => const OutboundPalletsScreen(),
    ),
    GetPage(
      name: AppRoutes.inboundPallet,
      page: () => const InboundPalletsScreen(),
    ),
    GetPage(
      name: AppRoutes.singleConsigment,
      page: () => const SingleConsigmentView(),
      alignment: Get.arguments,
    ),
    GetPage(
      name: AppRoutes.consigmentReorder,
      page: () => const MyConsigmentReorder(),
      arguments: Get.arguments,
    ),
    GetPage(
      name: AppRoutes.stopwatch,
      page: () => const EditTime(),
      arguments: Get.arguments,
    ),
    GetPage(
      name: AppRoutes.proofOfDelivery,
      page: () => ProofOfDeliveryView(
        arguments: Get.arguments.cast<String, dynamic>(),
      ),
    ),
    GetPage(
      name: AppRoutes.podphotos,
      page: () => ProofOfDeliveryPhotos(
        arguments: Get.arguments,
      ),
    ),
    GetPage(
      name: AppRoutes.consigmentGroup,
      page: () => const MyConsigmentGroup(),
      arguments: Get.arguments,
    ),
    GetPage(
      name: AppRoutes.podhistory,
      page: () => const PodHistory(),
      arguments: Get.arguments,
    ),
    GetPage(
      name: AppRoutes.podhistoryview,
      page: () => const PodHistoryView(),
      arguments: Get.arguments,
    ),
    GetPage(
      name: AppRoutes.pending,
      page: () => const PendingView(),
      arguments: Get.arguments,
    ),
  ];
}
