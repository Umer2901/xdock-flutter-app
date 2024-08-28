// part of '../pre_start_checklist.dart';

// class DriverLicenceTab extends StatefulWidget {
//   final Map data;
//   const DriverLicenceTab({super.key, required this.data});

//   @override
//   State<DriverLicenceTab> createState() => _DriverLicenceTabState();
// }

// class _DriverLicenceTabState extends State<DriverLicenceTab> {
//   Map? vehicleRegistration;
//   String? expiryDate;
//   bool isError = false;
//   bool isLicenceError = false;
//   bool isRegistrationError = false;
//   bool isOdometerError = false;
//   final SingleValueDropDownController vehicleRego =
//       SingleValueDropDownController();
//   final _formKey = GlobalKey<FormBuilderState>();
//   List<DropDownValueModel> vehicleRegoList = [];

//   @override
//   void initState() {
//     super.initState();
//     expiryDate = (context
//                 .read<PreStartProvider>()
//                 .data
//                 .containsKey('expiryDate')
//             ? (DateTime.parse(
//                 context.read<PreStartProvider>().data['expiryDate']))
//             : DateTime.tryParse(
//                 (widget.data['driver_licence_expiry']?['value']).toString()))
//         ?.toIso8601String();

//     widget.data['vehicles'].map((vehicle) {
//       vehicleRegoList.add(DropDownValueModel(
//           name: vehicle['vehicle_rego'], value: vehicle['vehicle_rego']));
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           const CustomPreStartHeader(),
//           ClipRRect(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(isError == false ? 30.sp : 0),
//               topRight: Radius.circular(isError == false ? 30.sp : 0),
//             ),
//             child: Material(
//               color: AppColors.white,
//               child: Column(
//                 children: [
//                   isError == true
//                       ? const CustomError(
//                           text:
//                               'All sections must be filled out in order to continue.')
//                       : const SizedBox(),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 4.w),
//                     child: FormBuilder(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: 4.h,
//                           ),
//                           Text(
//                             AppText.driverLicence.toUpperCase(),
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headlineSmall
//                                 ?.copyWith(
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                           ),
//                           Text(
//                             AppText.pleaseConfirm,
//                             style:
//                                 Theme.of(context).textTheme.bodySmall!.copyWith(
//                                       color: AppColors.grey,
//                                     ),
//                           ),
//                           SizedBox(
//                             height: 2.h,
//                           ),
//                           Text(
//                             AppText.licenceNumber,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(fontWeight: FontWeight.w700),
//                           ),
//                           CustomTextField(
//                             name: 'licenceNumber',
//                             initialValue: context
//                                     .read<PreStartProvider>()
//                                     .data
//                                     .containsKey('licence_number')
//                                 ? context
//                                     .read<PreStartProvider>()
//                                     .data['licence_number']
//                                 : widget.data['driver_licence_number']
//                                     ?['value'],
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 4.w,
//                               vertical: 0,
//                             ),
//                             isErrorState: (isLicenceError),
//                             validator: (value) {
//                               if (value == null || value == '') {
//                                 setState(() {
//                                   isLicenceError = true;
//                                 });
//                               } else {
//                                 setState(() {
//                                   isError = false;
//                                   isLicenceError = false;
//                                 });
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(
//                             height: 1.h,
//                           ),
//                           Text(
//                             AppText.expiryDate,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(fontWeight: FontWeight.w700),
//                           ),
//                           CustomTextField(
//                             name: 'expiryDate',
//                             readOnly: true,
//                             onTap: () {
//                               _selectDate(
//                                 context,
//                                 expiryDate != null
//                                     ? DateTime.parse(expiryDate!)
//                                     : context
//                                             .read<PreStartProvider>()
//                                             .data
//                                             .containsKey('expiryDate')
//                                         ? (DateTime.parse(context
//                                             .read<PreStartProvider>()
//                                             .data['expiryDate']))
//                                         : widget.data['driver_licence_expiry']
//                                                     ?['value'] !=
//                                                 null
//                                             ? DateTime.parse(widget.data[
//                                                     'driver_licence_expiry']
//                                                 ['value'])
//                                             : DateTime.now(),
//                               );
//                             },
//                             hintText: expiryDate != null
//                                 ? DateFormat('dd/MM/yyyy')
//                                     .format(DateTime.parse(expiryDate!))
//                                 : context
//                                         .read<PreStartProvider>()
//                                         .data
//                                         .containsKey('expiryDate')
//                                     ? DateFormat('dd/MM/yyyy').format(
//                                         DateTime.parse(context
//                                             .read<PreStartProvider>()
//                                             .data['expiryDate']))
//                                     : widget.data['driver_licence_expiry']
//                                                 ?['value'] !=
//                                             null
//                                         ? DateFormat('dd/MM/yyyy').format(
//                                             DateTime.parse(widget.data[
//                                                     'driver_licence_expiry']
//                                                 ?['value']))
//                                         : null,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 4.w,
//                               vertical: 0,
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Checkbox(
//                                 value: context.read<PreStartProvider>().ischeck,
//                                 activeColor: AppColors.blue,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     context
//                                         .read<PreStartProvider>()
//                                         .setIsCheck(isCheck: value!);
//                                   });
//                                 },
//                               ),
//                               Text(
//                                 AppText.accurateDetail,
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 0.5.h,
//                           ),
//                           Text(
//                             AppText.vehicleRegistration,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headlineSmall
//                                 ?.copyWith(fontWeight: FontWeight.w700),
//                           ),
//                           Text(
//                             AppText.takePictureDesc,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall
//                                 ?.copyWith(color: AppColors.grey),
//                           ),
//                           SizedBox(
//                             height: 1.h,
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               context.read<PreStartProvider>().image == null
//                                   ? _takePhoto()
//                                   : null;
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: AppColors.navyBlue),
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10.sp),
//                                 ),
//                               ),
//                               child: SizedBox(
//                                 width: 92.w,
//                                 height: 18.h,
//                                 child: context.read<PreStartProvider>().image ==
//                                         null
//                                     ? Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           CircleAvatar(
//                                             radius: 6.5.w,
//                                             backgroundColor:
//                                                 AppColors.greyWhite,
//                                             child: Icon(
//                                               Icons.camera_alt_rounded,
//                                               color: AppColors.blue,
//                                               size: 24.sp,
//                                             ),
//                                           ),
//                                           SizedBox(height: 0.5.h),
//                                           Text(
//                                             AppText.takePhoto,
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyMedium
//                                                 ?.copyWith(
//                                                   color: AppColors.blue,
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                           ),
//                                         ],
//                                       )
//                                     : Padding(
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 1.w,
//                                           vertical: 1.h,
//                                         ),
//                                         child: Image.file(
//                                           File(context
//                                               .read<PreStartProvider>()
//                                               .image!
//                                               .path),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 0.5.h),
//                           context.read<PreStartProvider>().image != null
//                               ? GestureDetector(
//                                   onTap: () {
//                                     _takePhoto();
//                                   },
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       Icon(
//                                         Icons.rotate_right,
//                                         color: AppColors.blue,
//                                         size: 2.h,
//                                       ),
//                                       Text(
//                                         AppText.reTakePhoto,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodySmall
//                                             ?.copyWith(
//                                               color: AppColors.blue,
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                       )
//                                     ],
//                                   ),
//                                 )
//                               : const SizedBox(),
//                           SizedBox(
//                             height: 2.h,
//                           ),
//                           Text(
//                             AppText.vehicleRegistration,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(fontWeight: FontWeight.w700),
//                           ),

//                           SizedBox(
//                             width: 90.w,
//                             child: DropDownTextField(
//                               textStyle: Theme.of(context).textTheme.bodyMedium,
//                               textFieldDecoration: InputDecoration(
//                                   hintText: 'Please Select',
//                                   hintStyle: Theme.of(context)
//                                       .textTheme
//                                       .bodyMedium
//                                       ?.copyWith(
//                                         letterSpacing: 1,
//                                         color: AppColors.black.withOpacity(0.5),
//                                       ),
//                                   isDense: true,
//                                   border: OutlineInputBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(10.sp)),
//                                   focusedBorder: AppColors.kFocuseBorder,
//                                   errorBorder: AppColors.kErrorOutlineBorder,
//                                   enabledBorder: AppColors.kEnableBorder,
//                                   errorStyle: Theme.of(context)
//                                       .textTheme
//                                       .bodyLarge
//                                       ?.copyWith(fontSize: 0.sp)),
//                               // controller: vehicleRego,
//                               initialValue: context
//                                       .read<PreStartProvider>()
//                                       .data
//                                       .containsKey('vehicle_rego')
//                                   ? context
//                                       .read<PreStartProvider>()
//                                       .data['vehicle_rego']
//                                   : null,
//                               clearOption: true,
//                               enableSearch: true,
//                               clearIconProperty:
//                                   IconProperty(color: AppColors.blue),
//                               searchTextStyle:
//                                   const TextStyle(color: AppColors.blue),
//                               searchDecoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.sp)),
//                                 hintText: 'Search',
//                                 hintStyle: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall
//                                     ?.copyWith(
//                                       letterSpacing: 1,
//                                       color: AppColors.black.withOpacity(0.5),
//                                     ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value == '') {
//                                   return '';
//                                 } else {
//                                   return null;
//                                 }
//                               },
//                               dropDownList: vehicleRegoList,
//                               onChanged: (value) {
//                                 if (value != null && value != '') {
//                                   vehicleRegistration =
//                                       widget.data['vehicles'].firstWhere(
//                                     (vehicle) =>
//                                         vehicle['vehicle_rego'] == value.value,
//                                   );
//                                 } else {
//                                   debugPrint('------------');
//                                 }
//                               },
//                             ),
//                           ),
                     
//                           SizedBox(
//                             height: 1.h,
//                           ),
//                           Text(
//                             AppText.odometer,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.copyWith(fontWeight: FontWeight.w700),
//                           ),
//                           Text(
//                             AppText.odometerDesc,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall
//                                 ?.copyWith(color: AppColors.grey),
//                           ),
//                           CustomTextField(
//                             name: 'odometer',
//                             keyboardType: TextInputType.number,
//                             isErrorState: (isOdometerError),
//                             initialValue: context
//                                     .read<PreStartProvider>()
//                                     .data
//                                     .containsKey('current_odometer_reading')
//                                 ? context
//                                     .read<PreStartProvider>()
//                                     .data['current_odometer_reading']
//                                 : null,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 4.w,
//                               vertical: 0,
//                             ),
//                             validator: (value) {
//                               if (value == null || value == '') {
//                                 setState(() {
//                                   isOdometerError = true;
//                                 });
//                               } else {
//                                 setState(() {
//                                   isError = false;
//                                   isOdometerError = false;
//                                 });
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(
//                             height: 2.h,
//                           ),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: SizedBox(
//                               height: 5.h,
//                               width: 40.w,
//                               child: CustomButton(
//                                   label: AppText.next,
//                                   onPressed: () async {
//                                     if ((_formKey.currentState?.validate() ??
//                                             false) &&
//                                         context
//                                                 .read<PreStartProvider>()
//                                                 .image !=
//                                             null &&
//                                         context
//                                                 .read<PreStartProvider>()
//                                                 .ischeck ==
//                                             true) {
//                                       if (!isError &&
//                                           !isLicenceError &&
//                                           !isRegistrationError &&
//                                           !isOdometerError) {
//                                         await context
//                                             .read<PreStartProvider>()
//                                             .image!
//                                             .readAsBytes()
//                                             .then((bytes) {
//                                           final temp = {
//                                             "vehicle_rego": context
//                                                     .read<PreStartProvider>()
//                                                     .data
//                                                     .containsKey('vehicle_rego')
//                                                 ? context
//                                                     .read<PreStartProvider>()
//                                                     .data['vehicle_rego']
//                                                 : vehicleRegistration![
//                                                     'vehicle_rego'],
//                                             "selectedVehicle": context
//                                                     .read<PreStartProvider>()
//                                                     .data
//                                                     .containsKey(
//                                                         'selectedVehicle')
//                                                 ? context
//                                                     .read<PreStartProvider>()
//                                                     .data['selectedVehicle']
//                                                 : vehicleRegistration,
//                                             "current_odometer_reading": _formKey
//                                                 .currentState!
//                                                 .fields['odometer']!
//                                                 .value
//                                                 .toString(),
//                                             "vehicle_registration_image":
//                                                 'data:image/png;base64,${base64Encode(bytes).toString()}',
//                                             "licence_expiry": expiryDate ??
//                                                 (
//                                                   context
//                                                           .read<
//                                                               PreStartProvider>()
//                                                           .data
//                                                           .containsKey(
//                                                               'expiryDate')
//                                                       ? context
//                                                           .read<
//                                                               PreStartProvider>()
//                                                           .data['expiryDate']
//                                                       : widget.data[
//                                                               'driver_licence_expiry']
//                                                           ['value'],
//                                                 ),
//                                             "licence_number": _formKey
//                                                 .currentState!
//                                                 .fields['licenceNumber']!
//                                                 .value
//                                                 .toString(),
//                                           };
//                                           context
//                                               .read<PreStartProvider>()
//                                               .addEntities(temp.entries);
//                                           context
//                                               .read<PreStartProvider>()
//                                               .setIndex(1);
//                                         });
//                                       }
//                                     } else {
//                                       setState(() {
//                                         isError = true;
//                                       });
//                                     }
//                                   }),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2.h,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Future<void> _selectDate(BuildContext context, DateTime selectedDate) async {
//   //   await showDatePicker(
//   //     context: context,
//   //     initialDate: selectedDate,
//   //     firstDate: DateTime.now(),
//   //     lastDate: DateTime(DateTime.now().year + 100),
//   //   ).then((pickedDate) {
//   //     if (pickedDate != null && pickedDate != selectedDate) {
//   //       setState(() {
//   //         expiryDate = pickedDate.toIso8601String();
//   //         _formKey.currentState!.fields['expiryDate']!
//   //             .setValue(DateFormat('dd/MM/yyyy').format(pickedDate));
//   //       });
//   //     }
//   //   });
//   // }
// Future<void> _selectDate(BuildContext context, DateTime selectedDate) async {
//   final DateTime now = DateTime.now();
//   final DateTime initialDate = selectedDate.isBefore(now) ? now : selectedDate;

//   await showDatePicker(
//     context: context,
//     initialDate: initialDate,
//     firstDate: now,
//     lastDate: DateTime(now.year + 100),
//   ).then((pickedDate) {
//     if (pickedDate != null && pickedDate != selectedDate) {
//       setState(() {
//         expiryDate = pickedDate.toIso8601String();
//         _formKey.currentState!.fields['expiryDate']!
//             .setValue(DateFormat('dd/MM/yyyy').format(pickedDate));
//       });
//     }
//   });
// }

//   Future<void> _takePhoto() async {
//     final ImagePicker picker = ImagePicker();
//     try {
//       final XFile? image = await picker.pickImage(
//         // imageQuality: 10,
//         source: ImageSource.camera,
//       );

//       if (image != null) {
//         setState(() {
//           context.read<PreStartProvider>().setImage(image: image);
//         });
//       }
//     } catch (e) {
//       debugPrint('Error picking image from camera: $e');
//     }
//   }
// }
part of '../pre_start_checklist.dart';

class DriverLicenceTab extends StatefulWidget {
  final Map data;
  const DriverLicenceTab({super.key, required this.data});

  @override
  State<DriverLicenceTab> createState() => _DriverLicenceTabState();
}

class _DriverLicenceTabState extends State<DriverLicenceTab> {
  Map? vehicleRegistration;
  String? expiryDate;
  bool isError = false;
  bool isLicenceError = false;
  bool isRegistrationError = false;
  bool isOdometerError = false;
  final SingleValueDropDownController vehicleRego =
      SingleValueDropDownController();
  final _formKey = GlobalKey<FormBuilderState>();
  List<DropDownValueModel> vehicleRegoList = [];

  @override
  void initState() {
    super.initState();
    expiryDate = (context
                .read<PreStartProvider>()
                .data
                .containsKey('expiryDate')
            ? (DateTime.parse(
                context.read<PreStartProvider>().data['expiryDate']))
            : DateTime.tryParse(
                (widget.data['driver_licence_expiry']?['value']).toString()))
        ?.toIso8601String();

    widget.data['vehicles'].map((vehicle) {
      vehicleRegoList.add(DropDownValueModel(
          name: vehicle['vehicle_rego'], value: vehicle['vehicle_rego']));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CustomPreStartHeader(),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isError == false ? 30.sp : 0),
              topRight: Radius.circular(isError == false ? 30.sp : 0),
            ),
            child: Material(
              color: AppColors.white,
              child: Column(
                children: [
                  isError == true
                      ? const CustomError(
                          text:
                              'All sections must be filled out in order to continue.')
                      : const SizedBox(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 4.h,
                          ),
                          Text(
                            AppText.driverLicence.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            AppText.pleaseConfirm,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: AppColors.grey,
                                    ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            AppText.licenceNumber,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          CustomTextField(
                            name: 'licenceNumber',
                            initialValue: context
                                    .read<PreStartProvider>()
                                    .data
                                    .containsKey('licence_number')
                                ? context
                                    .read<PreStartProvider>()
                                    .data['licence_number']
                                : widget.data['driver_licence_number']
                                    ?['value'],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 0,
                            ),
                            isErrorState: (isLicenceError),
                            validator: (value) {
                              if (value == null || value == '') {
                                setState(() {
                                  isLicenceError = true;
                                });
                              } else {
                                setState(() {
                                  isError = false;
                                  isLicenceError = false;
                                });
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(
                            AppText.expiryDate,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          CustomTextField(
                            name: 'expiryDate',
                            readOnly: true,
                            onTap: () {
                              _selectDate(
                                context,
                                expiryDate != null
                                    ? DateTime.parse(expiryDate!)
                                    : context
                                            .read<PreStartProvider>()
                                            .data
                                            .containsKey('expiryDate')
                                        ? (DateTime.parse(context
                                            .read<PreStartProvider>()
                                            .data['expiryDate']))
                                        : widget.data['driver_licence_expiry']
                                                    ?['value'] !=
                                                null
                                            ? DateTime.parse(widget.data[
                                                    'driver_licence_expiry']
                                                ['value'])
                                            : DateTime.now(),
                              );
                            },
                            hintText: expiryDate != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(DateTime.parse(expiryDate!))
                                : context
                                        .read<PreStartProvider>()
                                        .data
                                        .containsKey('expiryDate')
                                    ? DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(context
                                            .read<PreStartProvider>()
                                            .data['expiryDate']))
                                    : widget.data['driver_licence_expiry']
                                                ?['value'] !=
                                            null
                                        ? DateFormat('dd/MM/yyyy').format(
                                            DateTime.parse(widget.data[
                                                    'driver_licence_expiry']
                                                ?['value']))
                                        : null,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 0,
                            ),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: context.read<PreStartProvider>().ischeck,
                                activeColor: AppColors.blue,
                                onChanged: (value) {
                                  setState(() {
                                    context
                                        .read<PreStartProvider>()
                                        .setIsCheck(isCheck: value!);
                                  });
                                },
                              ),
                              Text(
                                AppText.accurateDetail,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 0.5.h,
                          ),
                          Text(
                            AppText.vehicleRegistration,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            AppText.takePictureDesc,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.grey),
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<PreStartProvider>().image == null
                                  ? _takePhoto()
                                  : null;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.navyBlue),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.sp),
                                ),
                              ),
                              child: SizedBox(
                                width: 92.w,
                                height: 18.h,
                                child: context.read<PreStartProvider>().image ==
                                        null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 6.5.w,
                                            backgroundColor:
                                                AppColors.greyWhite,
                                            child: Icon(
                                              Icons.camera_alt_rounded,
                                              color: AppColors.blue,
                                              size: 24.sp,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            AppText.takePhoto,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.blue,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 1.w,
                                          vertical: 1.h,
                                        ),
                                        child: Image.file(
                                          File(context
                                              .read<PreStartProvider>()
                                              .image!
                                              .path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          context.read<PreStartProvider>().image != null
                              ? GestureDetector(
                                  onTap: () {
                                    _takePhoto();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.rotate_right,
                                        color: AppColors.blue,
                                        size: 2.h,
                                      ),
                                      Text(
                                        AppText.reTakePhoto,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.blue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      )
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            AppText.vehicleRegistration,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),

                          SizedBox(
                            width: 90.w,
                            child: DropDownTextField(
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              textFieldDecoration: InputDecoration(
                                  hintText: 'Please Select',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        letterSpacing: 1,
                                        color: AppColors.black.withOpacity(0.5),
                                      ),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.sp)),
                                  focusedBorder: AppColors.kFocuseBorder,
                                  errorBorder: AppColors.kErrorOutlineBorder,
                                  enabledBorder: AppColors.kEnableBorder,
                                  errorStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontSize: 0.sp)),
                              // controller: vehicleRego,
                              initialValue: context
                                      .read<PreStartProvider>()
                                      .data
                                      .containsKey('vehicle_rego')
                                  ? context
                                      .read<PreStartProvider>()
                                      .data['vehicle_rego']
                                  : null,
                              clearOption: true,
                              enableSearch: true,
                              clearIconProperty:
                                  IconProperty(color: AppColors.blue),
                              searchTextStyle:
                                  const TextStyle(color: AppColors.blue),
                              searchDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.sp)),
                                hintText: 'Search',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      letterSpacing: 1,
                                      color: AppColors.black.withOpacity(0.5),
                                    ),
                              ),
                              validator: (value) {
                                if (value == null || value == '') {
                                  return '';
                                } else {
                                  return null;
                                }
                              },
                              dropDownList: vehicleRegoList,
                              onChanged: (value) {
                                if (value != null && value != '') {
                                  vehicleRegistration =
                                      widget.data['vehicles'].firstWhere(
                                    (vehicle) =>
                                        vehicle['vehicle_rego'] == value.value,
                                  );
                                } else {
                                  debugPrint('------------');
                                }
                              },
                            ),
                          ),
                          // TypeAheadField(
                          //   suggestionsCallback: (search) => searchVehicleReg(
                          //       widget.data['vehicles'].map((vehicle) {
                          //         return vehicle['vehicle_rego'];
                          //       }).toList(),
                          //       search),
                          //   controller: vehicleRego,
                          //   builder: (context, controller, focusNode) {
                          //     return CustomTextField(
                          //       name: 'vehicle_rego',
                          //       hintText: 'Please Select',
                          //       focusNode: focusNode,
                          //       controller: controller,
                          //       fillColor: AppColors.white,
                          //       validator: FormBuilderValidators.required(),
                          //     );
                          //   },
                          //   itemBuilder: (context, value) {
                          //     return ListTile(
                          //       title: Text(
                          //         value,
                          //         style: Theme.of(context).textTheme.bodyMedium,
                          //       ),
                          //     );
                          //   },
                          //   onSelected: (value) {
                          //     vehicleRegistration =
                          //         widget.data['vehicles'].firstWhere(
                          //       (vehicle) => vehicle['vehicle_rego'] == value,
                          //     );
                          //     _formKey.currentState!.fields['vehicle_rego']!
                          //         .setValue(value);
                          //     vehicleRego.setText(value);
                          //   },
                          // ),
                          // SizedBox(
                          //   height: 6.h,
                          //   width: 90.w,
                          //   child: DropdownSearch(
                          //     items: widget.data['vehicles'].map((vehicle) {
                          //       return vehicle['vehicle_rego'];
                          //     }).toList(),
                          //     validator: (value) {
                          //       if (value == null || value == '') {
                          //         setState(() {
                          //           isRegistrationError = true;
                          //         });
                          //       } else {
                          //         setState(() {
                          //           isError = false;
                          //           isRegistrationError = false;
                          //         });
                          //       }
                          //       return null;
                          //     },
                          //     onChanged: (value) {
                          //       setState(() {
                          //         vehicleRegistration =
                          //             widget.data['vehicles'].firstWhere(
                          //           (vehicle) =>
                          //               vehicle['vehicle_rego'] == value,
                          //         );
                          //       });
                          //     },
                          //     dropdownDecoratorProps: DropDownDecoratorProps(
                          //       dropdownSearchDecoration: InputDecoration(
                          //         enabledBorder: OutlineInputBorder(
                          //           borderSide: BorderSide(
                          //               color: isRegistrationError == false
                          //                   ? AppColors.black
                          //                   : AppColors.red),
                          //           borderRadius: const BorderRadius.all(
                          //             Radius.circular(15),
                          //           ),
                          //         ),
                          //         hintText: 'Please Select',
                          //         hintStyle: const TextStyle(
                          //           fontSize: 16,
                          //           letterSpacing: 1,
                          //           fontWeight: FontWeight.w400,
                          //           color: AppColors.black,
                          //         ),
                          //       ),
                          //     ),
                          //     popupProps: const PopupProps.menu(
                          //       showSearchBox: true,
                          //       searchDelay: Duration.zero,
                          //       searchFieldProps: TextFieldProps(
                          //         decoration: InputDecoration(
                          //           enabledBorder: OutlineInputBorder(
                          //             borderRadius: BorderRadius.all(
                          //               Radius.circular(10),
                          //             ),
                          //           ),
                          //           border: OutlineInputBorder(
                          //             borderRadius: BorderRadius.all(
                          //               Radius.circular(10),
                          //             ),
                          //           ),
                          //           hintText: 'Search',
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // CustomDropdown(
                          //   name: 'vehicle_rego',
                          //   isErrorState: (isRegistrationError),
                          //   validator: (value) {
                          //     debugPrint(value);
                          //     if (value == null || value == '') {
                          //       setState(() {
                          //         isRegistrationError = true;
                          //       });
                          //     } else {
                          //       setState(() {
                          //         isError = false;
                          //         isRegistrationError = false;
                          //       });
                          //     }
                          //     return null;
                          //   },
                          //   initialValue: context
                          //           .read<PreStartProvider>()
                          //           .data
                          //           .containsKey('vehicle_rego')
                          //       ? context
                          //           .read<PreStartProvider>()
                          //           .data['vehicle_rego']
                          //       : null,
                          //   hintText: 'Please Select',
                          //   fillColor: AppColors.white,
                          //   items: widget.data['vehicles']
                          //       .map<DropdownMenuItem<String>>((vehicle) {
                          //     return DropdownMenuItem<String>(
                          //       value: vehicle['vehicle_rego'],
                          //       child: Text(
                          //         vehicle['vehicle_rego'],
                          //         style: Theme.of(context).textTheme.bodyMedium,
                          //       ),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     vehicleRegistration = widget.data['vehicles']
                          //         .firstWhere((vehicle) =>
                          //             vehicle['vehicle_rego'] == value);
                          //   },
                          // ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(
                            AppText.odometer,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            AppText.odometerDesc,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.grey),
                          ),
                          CustomTextField(
                            name: 'odometer',
                            keyboardType: TextInputType.number,
                            isErrorState: (isOdometerError),
                            initialValue: context
                                    .read<PreStartProvider>()
                                    .data
                                    .containsKey('current_odometer_reading')
                                ? context
                                    .read<PreStartProvider>()
                                    .data['current_odometer_reading']
                                : null,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 0,
                            ),
                            validator: (value) {
                              if (value == null || value == '') {
                                setState(() {
                                  isOdometerError = true;
                                });
                              } else {
                                setState(() {
                                  isError = false;
                                  isOdometerError = false;
                                });
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              height: 5.h,
                              width: 40.w,
                              child: CustomButton(
                                  label: AppText.next,
                                  onPressed: () async {
                                    if ((_formKey.currentState?.validate() ??
                                            false) &&
                                        context
                                                .read<PreStartProvider>()
                                                .image !=
                                            null &&
                                        context
                                                .read<PreStartProvider>()
                                                .ischeck ==
                                            true) {
                                      if (!isError &&
                                          !isLicenceError &&
                                          !isRegistrationError &&
                                          !isOdometerError) {
                                        await context
                                            .read<PreStartProvider>()
                                            .image!
                                            .readAsBytes()
                                            .then((bytes) {
                                          final temp = {
                                            "vehicle_rego": context
                                                    .read<PreStartProvider>()
                                                    .data
                                                    .containsKey('vehicle_rego')
                                                ? context
                                                    .read<PreStartProvider>()
                                                    .data['vehicle_rego']
                                                : vehicleRegistration![
                                                    'vehicle_rego'],
                                            "selectedVehicle": context
                                                    .read<PreStartProvider>()
                                                    .data
                                                    .containsKey(
                                                        'selectedVehicle')
                                                ? context
                                                    .read<PreStartProvider>()
                                                    .data['selectedVehicle']
                                                : vehicleRegistration,
                                            "current_odometer_reading": _formKey
                                                .currentState!
                                                .fields['odometer']!
                                                .value
                                                .toString(),
                                            "vehicle_registration_image":
                                                'data:image/png;base64,${base64Encode(bytes).toString()}',
                                            "licence_expiry": expiryDate ??
                                                (
                                                  context
                                                          .read<
                                                              PreStartProvider>()
                                                          .data
                                                          .containsKey(
                                                              'expiryDate')
                                                      ? context
                                                          .read<
                                                              PreStartProvider>()
                                                          .data['expiryDate']
                                                      : widget.data[
                                                              'driver_licence_expiry']
                                                          ['value'],
                                                ),
                                            "licence_number": _formKey
                                                .currentState!
                                                .fields['licenceNumber']!
                                                .value
                                                .toString(),
                                          };
                                          context
                                              .read<PreStartProvider>()
                                              .addEntities(temp.entries);
                                          context
                                              .read<PreStartProvider>()
                                              .setIndex(1);
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        isError = true;
                                      });
                                    }
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime selectedDate) async {
    await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 100),
    ).then((pickedDate) {
      if (pickedDate != null && pickedDate != selectedDate) {
        setState(() {
          expiryDate = pickedDate.toIso8601String();
          _formKey.currentState!.fields['expiryDate']!
              .setValue(DateFormat('dd/MM/yyyy').format(pickedDate));
        });
      }
    });
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        // imageQuality: 10,
        source: ImageSource.camera,
      );

      if (image != null) {
        setState(() {
          context.read<PreStartProvider>().setImage(image: image);
        });
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }
}