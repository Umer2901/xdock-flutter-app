import 'package:coldxpress/export.dart';

class CustomDrawer extends StatefulWidget {
  final String name;
  const CustomDrawer({super.key, required this.name});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 2.h,
            horizontal: 4.w,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 12.w,
                    width: 12.w,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(AppImages.truck),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 55.w,
                          child: Text(
                            widget.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          AppText.driver,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.close,
                    ),
                  )
                ],
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    drawerItem(
                      icon: Icons.article_outlined,
                      title: AppText.consignment,
                      onTap: () {},
                      suffix: Container(
                        height: 2.h,
                        width: 6.w,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            '8',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    drawerItem(
                      icon: Icons.account_box_outlined,
                      title: AppText.performance,
                      onTap: () {},
                      suffix: Container(
                        height: 2.h,
                        width: 6.w,
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text('5',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Divider(
                      color: AppColors.darkGrey.withOpacity(0.1),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    drawerItem(
                      icon: Icons.dashboard,
                      title: AppText.dashboard,
                      onTap: () {},
                    ),
                    SizedBox(height: 2.h),
                    drawerItem(
                      icon: Icons.location_city_outlined,
                      title: AppText.consignmentMapView,
                      onTap: () {
                        Get.toNamed(AppRoutes.consignmentMap);
                      },
                    ),
                    SizedBox(height: 2.h),
                    drawerItem(
                      icon: Icons.checklist,
                      title: AppText.preStartTitle,
                      onTap: () {},
                    ),
                    SizedBox(height: 2.h),
                    drawerItem(
                      icon: Icons.reorder,
                      title: AppText.pallets,
                      onTap: () {},
                    ),
                    SizedBox(height: 2.h),
                    drawerItem(
                      icon: Icons.location_city_outlined,
                      title: AppText.training,
                      onTap: () {},
                    ),
                    SizedBox(height: 2.h),
                    drawerItem(
                      icon: Icons.pentagon_outlined,
                      title: AppText.pending,
                      onTap: () {},
                    ),
                    SizedBox(height: 2.h),
                    drawerItem(
                      icon: Icons.history,
                      title: AppText.podHoistory,
                      onTap: () {},
                    ),
                    SizedBox(height: 2.h),
                    Divider(
                      color: AppColors.darkGrey.withOpacity(0.1),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text(
                      AppText.version,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.darkGrey),
                    ),
                    SizedBox(height: 2.h),
                    drawerItem(
                      icon: Icons.help_outline,
                      title: AppText.help,
                      onTap: () {},
                    ),
                    SizedBox(height: 2.h),
                    BlocListener<AuthenticationCubit, AuthenticationState>(
                      listener: (context, state) {
                        if (state is Unauthenticated) {
                          Get.offAllNamed(AppRoutes.welcome);
                        }
                        if (state is AuthenticationError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.red,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    state.error.trim(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.red),
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
                              margin: EdgeInsets.only(bottom: 2.h),
                            ),
                          );
                        }
                      },
                      child: drawerItem(
                        icon: Icons.logout,
                        title: AppText.logout,
                        onTap: () {
                          AuthenticationState state =
                              BlocProvider.of<AuthenticationCubit>(context)
                                  .state;
                          if (state is Authenticated) {
                            BlocProvider.of<AuthenticationCubit>(context)
                                .logout(
                              token: state.token,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? suffix,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.darkGrey.withOpacity(0.6),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkGrey.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (suffix != null) suffix
        ],
      ),
    );
  }
}
