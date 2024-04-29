import 'package:coldxpress/export.dart';

class VerifyOtpView extends StatelessWidget {
  VerifyOtpView({super.key});

  final defaultPinTheme = PinTheme(
    width: 55,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 22,
      color: AppColors.black,
    ),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: AppColors.greyWhite),
    ),
  );

  final _formKey = GlobalKey<FormBuilderState>();
  final otpController = TextEditingController();

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
                        AppText.verifyOTPTitle,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        AppText.verifyOTPDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.darkGrey.withOpacity(0.4),
                            ),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 4.h),
                      Pinput(
                        length: 6,
                        controller: otpController,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          height: 55,
                          width: 60,
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                            color: AppColors.white,
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.equalLength(6),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                listener: (context, state) {
                  if (state is OTPVerified) {
                    Get.offAndToNamed(AppRoutes.newPassword,
                        arguments: {'email': state.email, 'otp': state.otp});
                  }
                  if (state is OTPError) {
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
                  }
                },
                builder: (context, state) {
                  if (state is VerifyingOTP) {
                    return CustomButton(
                      label: AppText.verify,
                      isLoading: true,
                      onPressed: () {},
                    );
                  } else {
                    return CustomButton(
                      label: AppText.verify,
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          await BlocProvider.of<ForgotPasswordCubit>(context)
                              .verifyOTP(
                            email: Get.arguments,
                            otp: otpController.text,
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
}
