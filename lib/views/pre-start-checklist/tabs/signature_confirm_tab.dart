part of '../pre_start_checklist.dart';

class PreStartSignatureConfirmationTab extends StatefulWidget {
  const PreStartSignatureConfirmationTab({super.key});

  @override
  State<PreStartSignatureConfirmationTab> createState() =>
      _PreStartSignatureConfirmationTabState();
}

class _PreStartSignatureConfirmationTabState
    extends State<PreStartSignatureConfirmationTab> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.black,
    exportBackgroundColor: AppColors.white,
  );

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  Future<void> postData() async {
    setState(() {
      isLoading = true;
    });
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        await http
            .post(
          Uri.parse(AppHost.storePreChecklist),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(context.read<PreStartProvider>().data),
        )
            .then((response) {
          setState(() {
            isLoading = false;
          });
          if (response.statusCode == 200) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  surfaceTintColor: AppColors.white,
                  icon: SizedBox(
                    height: 20.w,
                    width: 20.w,
                    child: const Image(
                      image: AssetImage(AppImages.checkmark),
                      color: Color.fromRGBO(109, 166, 108, 1),
                    ),
                  ),
                  title: Text(
                    'Success!',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  titlePadding: EdgeInsets.symmetric(
                    vertical: 1.h,
                    horizontal: 2.w,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.5.h,
                    horizontal: 4.w,
                  ),
                  iconPadding: EdgeInsets.symmetric(vertical: 1.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  content: Text(
                    'Your Pre-Start Checklist has been complete successfully. Drive safe!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10.sp,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: AppColors.white,
                  actions: <Widget>[
                    SizedBox(height: 2.h),
                    Center(
                      child: CustomButton(
                        height: 5.h,
                        width: 30.w,
                        label: 'Close',
                        onPressed: () {
                          context.read<PreStartProvider>().setEntities({});
                          context.read<PreStartProvider>().setIndex(0);
                          context
                              .read<PreStartProvider>()
                              .setIsCheck(isCheck: false);
                          context.read<PreStartProvider>().clearImage();
                          Get.offAllNamed(
                            AppRoutes.dashboard,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            final Map<String, dynamic> responseData =
                json.decode(response.body);
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
                        responseData['message'].trim(),
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
                margin: EdgeInsets.only(bottom: 2.h),
              ),
            );
          }
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CustomPreStartHeader(),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.sp),
              topRight: Radius.circular(30.sp),
            ),
            child: Material(
              color: AppColors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 4.h,
                    ),
                    Text(
                      AppText.signatureConfirmation.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      AppText.preCheckSignatureConfirmationDesc,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.grey),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Stack(
                      children: [
                        if (_controller.isEmpty)
                          Positioned(
                            left: 4.w,
                            right: 4.w,
                            top: 2.h,
                            bottom: 2.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 50.sp,
                                  height: 50.sp,
                                  child: const Image(
                                    image: AssetImage(AppImages.handWithPen),
                                  ),
                                ),
                                Text(
                                  AppText.tapHereToSign,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.navyBlue),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.sp),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 1.h, horizontal: 2.w),
                          child: Signature(
                            controller: _controller,
                            width: 90.w,
                            height: 20.h,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 5.h,
                        width: 40.w,
                        child: CustomButton(
                          label: AppText.submit,
                          backgroundColor: _controller.isEmpty
                              ? AppColors.grey
                              : AppColors.blue,
                          isLoading: isLoading,
                          borderColor: _controller.isEmpty
                              ? AppColors.grey
                              : AppColors.blue,
                          onPressed: () async {
                            await _controller.toPngBytes().then((bytes) {
                              if (bytes != null) {
                                  context.read<PreStartProvider>().addEntities(
                                        {
                                          "driver_signature":
                                              'data:image/png;base64, ${base64Encode(bytes).toString()}',
                                          "total_question": 29.toString(),
                                        }.entries,
                                      );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      surfaceTintColor: AppColors.white,
                                      icon: SizedBox(
                                        height: 20.w,
                                        width: 20.w,
                                        child: const Image(
                                          image: AssetImage(
                                              AppImages.brakeWarning),
                                        ),
                                      ),
                                      title: Text(
                                        'Contact your supervisor',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                        textAlign: TextAlign.center,
                                      ),
                                      titlePadding: EdgeInsets.symmetric(
                                        vertical: 1.h,
                                        horizontal: 2.w,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0.5.h,
                                        horizontal: 4.w,
                                      ),
                                      iconPadding:
                                          EdgeInsets.symmetric(vertical: 1.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      content: Text(
                                        'If you said \'no\' to a question, it means you or your vehicle might not be ready for delivery today. If you made a mistake, you can change your answer. Otherwise, talk to your supervisor about what to do next.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 10.sp,
                                            ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      backgroundColor: AppColors.white,
                                      actions: <Widget>[
                                        SizedBox(height: 2.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            CustomButton(
                                              height: 5.h,
                                              width: 30.w,
                                              label: 'Edit',
                                              backgroundColor: AppColors.white,
                                              borderColor: AppColors.yellow,
                                              foregroundColor: AppColors.yellow,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                context
                                                    .read<PreStartProvider>()
                                                    .setIndex(0);
                                              },
                                            ),
                                            CustomButton(
                                              height: 5.h,
                                              width: 30.w,
                                              label: 'CONTINUE',
                                              backgroundColor: AppColors.yellow,
                                              borderColor: AppColors.yellow,
                                              foregroundColor: AppColors.white,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                postData();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
