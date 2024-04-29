import 'package:coldxpress/export.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Flexible(
            child: SizedBox(
              width: double.infinity,
              child: Image(
                image: AssetImage(AppImages.welcome),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 2.h,
              horizontal: 4.w,
            ),
            child: Column(
              children: [
                Text(
                  AppText.welcomeTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  AppText.welcomeSubtitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 4.h),
                Text(
                  AppText.welcomeDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 2.h),
                CustomButton(
                  label: AppText.login,
                  onPressed: () {
                    Get.toNamed(AppRoutes.login);
                  },
                ),
                // SizedBox(height: 2.h),
                // CustomButton(
                //   label: AppText.signup,
                //   onPressed: () {
                //     Get.toNamed(AppRoutes.register);
                //   },
                //   backgroundColor: AppColors.white,
                //   foregroundColor: AppColors.blue,
                // )
              ],
            ),
          )
        ],
      ),
    );
  }
}
