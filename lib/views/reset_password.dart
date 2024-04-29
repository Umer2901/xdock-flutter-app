import 'package:coldxpress/export.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormBuilderState>();

  bool isEmailError = false;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h),
                      Center(
                        child: Image.asset(AppImages.logo),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppText.resetPassword,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(fontSize: 36),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        AppText.resetSubtext,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.darkGrey,
                            ),
                        // textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 4.h),
                      CustomTextField(
                        name: 'email',
                        hintText: AppText.email,
                        isErrorState: isEmailError,
                        prefixIcon: const Icon(Icons.mail_outline),
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
                              isEmailError = false;
                            });
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                listener: (context, state) {
                  if (state is EmailSended) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.notifications,
                              color: Colors.green,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Password reset otp is sended to your email.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.green),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.lightRed,
                        margin: EdgeInsets.only(bottom: 73.h),
                      ),
                    );
                    Get.toNamed(AppRoutes.verifyOtp, arguments: state.email);
                  }
                  if (state is EmailError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.red,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                state.error.trim(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.red),
                              ),
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.lightRed,
                        margin: EdgeInsets.only(bottom: 73.h),
                      ),
                    );
                    setState(() {
                      isEmailError = true;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is SendingEmail) {
                    return CustomElevatedButton(
                      label: AppText.submit,
                      isLoading: true,
                      onPressed: () {},
                    );
                  } else {
                    return CustomElevatedButton(
                      label: AppText.submit,
                      onPressed: () async {
                        setState(() {
                          isEmailError = false;
                        });
                        if (_formKey.currentState?.validate() ?? false) {
                          if (!isEmailError) {
                            await BlocProvider.of<ForgotPasswordCubit>(context)
                                .sendEmail(
                              email: _formKey
                                  .currentState?.fields['email']?.value
                                  .trim(),
                            );
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
