import 'package:coldxpress/export.dart';

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({super.key});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final _formKey = GlobalKey<FormBuilderState>();

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
                  padding: EdgeInsets.symmetric(
                    vertical: 2.h,
                    horizontal: 4.w,
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        AppImages.backgroundImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      0,
                      0,
                      MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6.h),
                        Center(
                          child: Image.asset(
                            AppImages.logo,
                          ),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          AppText.enterNewPassword,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          AppText.passwordRequirement,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkGrey.withOpacity(0.4),
                                  ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              for (String value
                                  in AppText.passwordRequirementList) ...{
                                listItem(value),
                              }
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        CustomTextField(
                          name: 'password',
                          hintText: AppText.newPassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          obscureText: obscurePassword,
                          keyboardType: TextInputType.emailAddress,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          isErrorState: isPasswordError,
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
                              color: AppColors.grey.withOpacity(0.4),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        CustomTextField(
                          name: 'confirmPassword',
                          hintText: AppText.confirmPassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          obscureText: obscureConfirmPassword,
                          keyboardType: TextInputType.emailAddress,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          isErrorState: isPasswordError,
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                            child: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.grey.withOpacity(0.4),
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              AppText.passwordMustMatch,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                listener: (context, state) {
                  if (state is PasswordUpdated) {
                    Get.offAllNamed(AppRoutes.login);
                  }
                  if (state is PasswordError) {
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
                      isPasswordError = true;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is UpdatingPassword) {
                    return CustomButton(
                      label: AppText.submit,
                      isLoading: true,
                      onPressed: () {},
                    );
                  } else {
                    return CustomButton(
                      label: AppText.submit,
                      onPressed: () async {
                        setState(() {
                          isPasswordError = false;
                        });
                        if (_formKey.currentState?.validate() ?? false) {
                          await BlocProvider.of<ForgotPasswordCubit>(context)
                              .resetPassword(
                            email: Get.arguments['email'],
                            otp: Get.arguments['otp'],
                            password: _formKey
                                .currentState?.fields['password']?.value
                                .trim(),
                            confirmPassword: _formKey
                                .currentState?.fields['confirmPassword']?.value
                                .trim(),
                          );
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

  Widget listItem(String value) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 5.sp,
          color: AppColors.darkGrey.withOpacity(0.4),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkGrey.withOpacity(0.4),
                ),
          ),
        ),
      ],
    );
  }
}
