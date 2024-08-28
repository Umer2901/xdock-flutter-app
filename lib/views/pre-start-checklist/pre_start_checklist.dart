// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:coldxpress/export.dart';

// import 'package:http/http.dart' as http;

// part 'tabs/driver_licence_tab.dart';
// part 'tabs/vehicle_check_tab.dart';
// part 'tabs/fridge_pan_check_tab.dart';
// part 'tabs/signature_confirm_tab.dart';

// class PreStartCheckListView extends StatelessWidget {
//   const PreStartCheckListView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     AuthenticationState state =
//         BlocProvider.of<AuthenticationCubit>(context).state;
//     final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
     
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: AppColors.preStartHeaderGradient,
//       ),
//       child: Scaffold(
//          key: _scaffoldKey,
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           leading: IconButton(
//             onPressed: () {
//               if (context.read<PreStartProvider>().index == 0) {
//                 context.read<PreStartProvider>().reset();
//                 Get.back();
//               } else {
//                 context.read<PreStartProvider>().setIndex(
//                       context.read<PreStartProvider>().index - 1,
//                     );
//               }
//             },
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: AppColors.white,
//               size: 15.sp,
//             ),
//           ),
//           actions: [
//             IconButton(
//               onPressed: () {          
//  _scaffoldKey.currentState?.openEndDrawer();
//               },
//               icon: Icon(
//                 Icons.more_horiz,
//                 color: AppColors.white,
//                 size: 20.sp,
//               ),
//             )
//           ],
//           centerTitle: true,
//           title: Text(
//             AppText.preStartAppBar,
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineSmall
//                 ?.copyWith(color: AppColors.white),
//           ),
//         ),
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               FutureBuilder(
//                 future: state is Authenticated
//                     ? PrecheckStatusService(
//                             context.read<DatabaseProvider>().database)
//                         .fetchPreChecklistQA(state.token)
//                     : null,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return Expanded(
//                       child: Consumer<PreStartProvider>(
//                         builder: (context, value, child) {
//                           return value.index == 0
//                               ? DriverLicenceTab(data: snapshot.data)
//                               : value.index == 1
//                                   ? VehicleCheckTab(
//                                       questions: snapshot.data['data'][0]
//                                           ['checklist_questions'],
//                                     )
//                                   : value.index == 2
//                                       ? FridgePanCheckTab(
//                                           data: snapshot.data['data'],
//                                         )
//                                       : const PreStartSignatureConfirmationTab();
//                         },
//                       ),
//                     );
//                   } else {
//                     return Expanded(
//                       child: Column(
//                         children: [
//                           const CustomPreStartHeader(),
//                           Expanded(
//                             child: ClipRRect(
//                                 borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(30.sp),
//                                   topRight: Radius.circular(30.sp),
//                                 ),
//                                 child: Shimmer.fromColors(
//                                   baseColor: AppColors.greyWhite,
//                                   highlightColor: AppColors.lightGrey,
//                                   child: Container(
//                                     width: double.maxFinite,
//                                     height: 10.h,
//                                     color: AppColors.greyWhite,
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//          endDrawer: const CustomDrawer(),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coldxpress/export.dart';

import 'package:http/http.dart' as http;

part 'tabs/driver_licence_tab.dart';
part 'tabs/vehicle_check_tab.dart';
part 'tabs/fridge_pan_check_tab.dart';
part 'tabs/signature_confirm_tab.dart';

class PreStartCheckListView extends StatelessWidget {
  const PreStartCheckListView({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.preStartHeaderGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              if (context.read<PreStartProvider>().index == 0) {
                context.read<PreStartProvider>().reset();
                Get.back();
              } else {
                context.read<PreStartProvider>().setIndex(
                      context.read<PreStartProvider>().index - 1,
                    );
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.white,
              size: 15.sp,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_horiz,
                color: AppColors.white,
                size: 20.sp,
              ),
            )
          ],
          centerTitle: true,
          title: Text(
            AppText.preStartAppBar,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder(
                future: state is Authenticated
                    ? PrecheckStatusService(
                            context.read<DatabaseProvider>().database)
                        .fetchPreChecklistQA(state.token)
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: Consumer<PreStartProvider>(
                        builder: (context, value, child) {
                          return value.index == 0
                              ? DriverLicenceTab(data: snapshot.data)
                              : value.index == 1
                                  ? VehicleCheckTab(
                                      questions: snapshot.data['data'][0]
                                          ['checklist_questions'],
                                    )
                                  : value.index == 2
                                      ? FridgePanCheckTab(
                                          data: snapshot.data['data'],
                                        )
                                      : const PreStartSignatureConfirmationTab();
                        },
                      ),
                    );
                  } else {
                    return Expanded(
                      child: Column(
                        children: [
                          const CustomPreStartHeader(),
                          Expanded(
                            child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30.sp),
                                  topRight: Radius.circular(30.sp),
                                ),
                                child: Shimmer.fromColors(
                                  baseColor: AppColors.greyWhite,
                                  highlightColor: AppColors.lightGrey,
                                  child: Container(
                                    width: double.maxFinite,
                                    height: 10.h,
                                    color: AppColors.greyWhite,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}