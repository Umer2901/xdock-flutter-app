import 'package:coldxpress/export.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 2.h,
                  horizontal: 4.w,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    MediaQuery.of(context).viewInsets.bottom + 8.h,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),
                      Center(
                        child: Image.asset(AppImages.logo),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppText.register.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(height: 1.h),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.login);
                        },
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: AppText.alreadyHaveAccount,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: AppColors.darkGrey),
                              ),
                              TextSpan(
                                text: AppText.signin,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: AppColors.blue,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      const CustomTextField(
                        name: 'name',
                        hintText: AppText.fullName,
                        prefixIcon: Icon(Icons.perm_identity),
                      ),
                      SizedBox(height: 2.h),
                      const CustomTextField(
                        name: 'email',
                        hintText: AppText.email,
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      SizedBox(height: 2.h),
                      CustomTextField(
                        name: 'password',
                        hintText: AppText.password,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        obscureText: obscurePassword,
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          child: Icon(
                            obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.darkGrey.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CustomButton(
              label: AppText.createAccount,
              onPressed: () {
                Get.toNamed(AppRoutes.dashboard);
              },
            ),
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  }
}
