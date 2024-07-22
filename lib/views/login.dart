import 'package:coldxpress/export.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool obscurePassword = true;

  final _formKey = GlobalKey<FormBuilderState>();

  bool isError = false;
  bool isEmailError = false;
  bool isPasswordError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  // padding: EdgeInsets.symmetric(
                  //   vertical: 2.h,
                  //   horizontal: 4.w,
                  // ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        AppImages.backgroundImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Image.asset(
                          AppImages.logo,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      isError == true ||
                              isEmailError == true ||
                              isPasswordError == true
                          ? const CustomError(
                              text: 'Incorrect email or password. Try again.')
                          : const SizedBox(),
                      SizedBox(
                        height: 4.h,
                      ),
                      Text(
                        AppText.login.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 36,
                            ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Get.toNamed(AppRoutes.register);
                      //   },
                      //   child: Text.rich(
                      //     TextSpan(
                      //       children: <InlineSpan>[
                      //         TextSpan(
                      //           text: AppText.noAccount,
                      //           style: Theme.of(context)
                      //               .textTheme
                      //               .bodyMedium!
                      //               .copyWith(
                      //                 color: AppColors.darkGrey,
                      //               ),
                      //         ),
                      //         TextSpan(
                      //           text: AppText.signup,
                      //           style: Theme.of(context)
                      //               .textTheme
                      //               .bodyMedium
                      //               ?.copyWith(
                      //                 color: AppColors.blue,
                      //                 fontWeight: FontWeight.w700,
                      //               ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 4.h,
                      ),
                      CustomTextField(
                        name: 'email',
                        hintText: AppText.email,
                        isErrorState: (isError || isEmailError),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                        ),
                        validator: (value) {
                          debugPrint(value);
                          if (value == null ||
                              value == '' ||
                              !value.contains('@') ||
                              !value.contains('.')) {
                            setState(() {
                              isEmailError = true;
                            });
                          } else {
                            setState(() {
                              isError = false;
                              isEmailError = false;
                            });
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      CustomTextField(
                        name: 'password',
                        hintText: AppText.password,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        obscureText: obscurePassword,
                        isErrorState: (isError || isPasswordError),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value == '' ||
                              value.length < 8) {
                            setState(() {
                              isPasswordError = true;
                            });
                          } else {
                            setState(() {
                              isError = false;
                              isPasswordError = false;
                            });
                          }
                          return null;
                        },
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
                            color: AppColors.darkGrey.withOpacity(0.7),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.resetPassword);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              AppText.forgotPassword,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: AppColors.darkBlue,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12.h,
                      )
                    ],
                  ),
                ),
              ),
              BlocConsumer<AuthenticationCubit, AuthenticationState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    Get.offAllNamed(AppRoutes.dashboard);
                  }
                  if (state is AuthenticationError) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Row(
                    //       children: [
                    //         const Icon(
                    //           Icons.error_outline_rounded,
                    //           color: AppColors.red,
                    //         ),
                    //         SizedBox(width: 2.w),
                    //         Expanded(
                    //           child: Text(
                    //             state.error.trim(),
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .bodyMedium
                    //                 ?.copyWith(color: AppColors.red),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(0),
                    //     ),
                    //     duration: const Duration(seconds: 2),
                    //     behavior: SnackBarBehavior.floating,
                    //     backgroundColor: AppColors.lightRed,
                    //     margin: EdgeInsets.only(bottom: 73.h),
                    //   ),
                    // );
                    setState(() {
                      isError = true;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is Authenticating) {
                    return CustomElevatedButton(
                      label: AppText.login,
                      isLoading: true,
                      onPressed: () {},
                    );
                  } else {
                    return CustomElevatedButton(
                      label: AppText.login,
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (!isError && !isEmailError && !isPasswordError) {
                            await BlocProvider.of<AuthenticationCubit>(context)
                                .login(
                              email: _formKey
                                  .currentState?.fields['email']?.value
                                  .trim(),
                              password: _formKey
                                  .currentState?.fields['password']?.value
                                  .trim(),
                              database:
                                  context.read<DatabaseProvider>().database,
                            )
                                .whenComplete(() {
                              context
                                  .read<BottomNavProvider>()
                                  .changeTabView(1);
                            });
                          }
                        }
                      },
                    );
                  }
                },
              ),
              SizedBox(
                height: 2.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
