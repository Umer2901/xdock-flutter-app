part of '../outbound_pallets.dart';

class OutboundPalletCountTab extends StatefulWidget {
  final Map data;
  const OutboundPalletCountTab({super.key, required this.data});

  @override
  State<OutboundPalletCountTab> createState() => _OutboundPalletCountTabState();
}

class _OutboundPalletCountTabState extends State<OutboundPalletCountTab> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map? vehicleRegistration;
  bool isRegistrationError = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CustomOutBoundHeader(),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.sp),
              topRight: Radius.circular(30.sp),
            ),
            child: Material(
              color: AppColors.white,
              child: Padding(
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
                        AppText.vehicleRegistration.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      Text(
                        AppText.vehicleRegistrationDesc,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: AppColors.grey,
                            ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      SizedBox(
                        height: 6.h,
                        width: 90.w,
                        child: DropdownSearch(
                          items: widget.data['data']['vehicles'].map((vehicle) {
                            return vehicle['vehicle_rego'];
                          }).toList(),
                          validator: (value) {
                            debugPrint(value);
                            if (value == null || value == '') {
                              setState(() {
                                isRegistrationError = true;
                              });
                            } else {
                              setState(() {
                                isRegistrationError = false;
                              });
                            }
                            return null;
                          },
                          onChanged: (value) {
                            vehicleRegistration = widget.data['data']
                                    ['vehicles']
                                .firstWhere((vehicle) =>
                                    vehicle['vehicle_rego'] == value);
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: isRegistrationError == false
                                        ? AppColors.black
                                        : AppColors.red),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              hintText: 'Please Select',
                              hintStyle: const TextStyle(
                                fontSize: 16,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchDelay: Duration.zero,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                hintText: 'Search',
                              ),
                            ),
                          ),
                        ),
                      ),
                      // CustomDropdown(
                      //   name: 'vehicle_rego',
                      //   validator: FormBuilderValidators.required(),
                      //   initialValue: context
                      //           .read<OutboundProvider>()
                      //           .data
                      //           .containsKey('vehicle_rego')
                      //       ? context
                      //           .read<OutboundProvider>()
                      //           .data['vehicle_rego']
                      //       : null,
                      //   hintText: 'Please Select',
                      //   fillColor: AppColors.white,
                      //   items: widget.data['data']['vehicles']
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
                      //     vehicleRegistration = widget.data['data']['vehicles']
                      //         .firstWhere((vehicle) =>
                      //             vehicle['vehicle_rego'] == value);
                      //   },
                      // ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Text(
                        AppText.palletCount.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      Text(
                        AppText.palletCountDesc,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: AppColors.grey,
                            ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Wrap(
                        runAlignment: WrapAlignment.spaceBetween,
                        children: [
                          for (int i = 1;
                              i <=
                                  widget.data['data']['pallet_types'].entries
                                      .length;
                              i++) ...{
                            PalletContainer(
                              name: 'pallet_qty_$i',
                              initialValue: context
                                      .read<OutboundProvider>()
                                      .data
                                      .containsKey('pallet_qty_$i')
                                  ? int.parse(context
                                      .read<OutboundProvider>()
                                      .data['pallet_qty_$i'])
                                  : 0,
                              heading: widget.data['data']['pallet_types']['$i']
                                  .split(' ')
                                  .first,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 0,
                              ),
                            ),
                          }
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Text(
                        AppText.palletPhotos,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        AppText.palletPhotosDesc,
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
                          showModalBottomSheet(
                            backgroundColor: AppColors.white,
                            context: context,
                            builder: (BuildContext context) {
                              return Wrap(
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: Text(
                                      'Take Photo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await _takePhoto();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.image),
                                    title: Text(
                                      'Pick Image',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await _pickImage();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 6.5.w,
                                  backgroundColor: AppColors.greyWhite,
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
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(height: 0.5.h),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Icon(
                      //       Icons.rotate_right,
                      //       color: AppColors.blue,
                      //       size: 2.h,
                      //     ),
                      //     Text(
                      //       AppText.reTakePhoto,
                      //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      //             color: AppColors.blue,
                      //             fontWeight: FontWeight.w700,
                      //           ),
                      //     )
                      //   ],
                      // ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: context
                                    .read<OutboundProvider>()
                                    .images
                                    .map(
                                      (image) => Padding(
                                        padding: EdgeInsets.only(right: 2.w),
                                        child: Container(
                                          height: 13.h,
                                          width: 28.w,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.sp),
                                            image: DecorationImage(
                                              image: FileImage(
                                                File(image.path),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                context
                                                    .read<OutboundProvider>()
                                                    .removeImage(image: image);
                                              });
                                            },
                                            child: const Align(
                                              alignment: Alignment.topRight,
                                              child: Icon(
                                                Icons.cancel,
                                                color: AppColors.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
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
                              backgroundColor: context
                                      .read<OutboundProvider>()
                                      .images
                                      .isEmpty
                                  ? AppColors.darkGrey
                                  : AppColors.blue,
                              borderColor: context
                                      .read<OutboundProvider>()
                                      .images
                                      .isEmpty
                                  ? AppColors.darkGrey
                                  : AppColors.blue,
                              label: AppText.next,
                              onPressed: () {
                                if (context
                                        .read<OutboundProvider>()
                                        .images
                                        .isNotEmpty &&
                                    !isRegistrationError) {
                                  for (int i = 0;
                                      i <
                                          widget.data['data']['pallet_types']
                                              .entries.length;
                                      i++) {
                                    context
                                        .read<InboundProvider>()
                                        .addEntities({
                                          "pallet_id_$i": "${i + 1}",
                                          "pallet_qty_${i + 1}": _formKey
                                              .currentState!
                                              .fields['pallet_qty_${i + 1}']!
                                              .value,
                                        }.entries);
                                  }

                                  context.read<OutboundProvider>().addEntities({
                                        "vehicle_rego": vehicleRegistration![
                                            'vehicle_rego'],
                                        "selectedVehicle":
                                            vehicleRegistration.toString(),
                                        "total_pallet_types": widget
                                            .data['data']['pallet_types']
                                            .entries
                                            .length,
                                        "pictures": context
                                            .read<OutboundProvider>()
                                            .base64Images,
                                        "pictureSources": context
                                            .read<OutboundProvider>()
                                            .pictureSources,
                                        "latitude": context
                                            .read<LocationProvider>()
                                            .current!
                                            .latitude,
                                        "longitude": context
                                            .read<LocationProvider>()
                                            .current!
                                            .longitude,
                                      }.entries);
                                  context.read<OutboundProvider>().setIndex(1);
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        imageQuality: 10,
        source: ImageSource.camera,
      );

      if (image != null) {
        Uint8List bytes = await image.readAsBytes();
        setState(() {
          context.read<OutboundProvider>().addImage(
                image: image,
                base64String:
                    'data:image/jpeg;base64,${base64Encode(bytes).toString()}',
                source: 'By Camera',
              );
        });
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        imageQuality: 10,
        source: ImageSource.gallery,
      );

      if (image != null) {
        Uint8List bytes = await image.readAsBytes();
        setState(() {
          context.read<OutboundProvider>().addImage(
                image: image,
                base64String:
                    'data:image/jpeg;base64,${base64Encode(bytes).toString()}',
                source: 'By Gallery',
              );
        });
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
  }
}
