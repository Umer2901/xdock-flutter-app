part of '../inbound_pallets.dart';

class InboundPalletCountTab extends StatefulWidget {
  final Map data;
  const InboundPalletCountTab({super.key, required this.data});

  @override
  State<InboundPalletCountTab> createState() => _InboundPalletCountTabState();
}

class _InboundPalletCountTabState extends State<InboundPalletCountTab> {
  final _formKey = GlobalKey<FormBuilderState>();

  List palletsCheck = [];

  Map<String, dynamic> balance = {};

  @override
  void initState() {
    super.initState();
    config();
    palletsCheck = List.generate(
      widget.data['data']['pallet_types'].entries.length,
      (index) => {'isErrorState': false, 'isChecked': false},
    );
  }

  config() {
    for (int i = 1;
        i <= widget.data['data']['driver_outstanding_pallet'].length;
        i++) {
      balance.addAll({
        '${widget.data['data']['driver_outstanding_pallet'][i - 1]['pallet_id']}':
            widget.data['data']['driver_outstanding_pallet'][i - 1]['balance']
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CustomInBoundHeader(),
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
                        AppText.palletReturn.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      Text(
                        AppText.palletReturnDesc,
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
                              totalPallet: balance.containsKey(i.toString())
                                  ? balance[i.toString()]
                                  : 0,
                              initialValue: context
                                      .read<InboundProvider>()
                                      .data
                                      .containsKey('pallet_qty_$i')
                                  ? int.parse(context
                                      .read<InboundProvider>()
                                      .data['pallet_qty_$i'])
                                  : 0,
                              isErrorState: palletsCheck[i - 1]['isErrorState'],
                              heading: widget.data['data']['pallet_types']['$i']
                                  .split(' ')
                                  .first,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 0,
                              ),
                              validator: (value) {
                                setState(() {
                                  if (widget
                                      .data['data']['driver_outstanding_pallet']
                                      .isNotEmpty) {
                                    if (int.parse(value ?? '0') >
                                        widget.data['data']
                                                ['driver_outstanding_pallet']
                                            [i - 1]['balance']) {
                                      palletsCheck[i - 1]['isErrorState'] =
                                          true;
                                    } else {
                                      palletsCheck[i - 1]['isErrorState'] =
                                          false;
                                    }
                                  }
                                });
                                return null;
                              },
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
                                    .read<InboundProvider>()
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
                                                    .read<InboundProvider>()
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
                              backgroundColor:
                                  context.read<InboundProvider>().images.isEmpty
                                      ? AppColors.darkGrey
                                      : AppColors.blue,
                              borderColor:
                                  context.read<InboundProvider>().images.isEmpty
                                      ? AppColors.darkGrey
                                      : AppColors.blue,
                              label: AppText.next,
                              onPressed: () {
                                if (context
                                    .read<InboundProvider>()
                                    .images
                                    .isNotEmpty) {
                                  if (_formKey.currentState!.validate() &&
                                      palletsCheck.toString() ==
                                          List.generate(
                                            widget.data['data']['pallet_types']
                                                .entries.length,
                                            (index) => {
                                              'isErrorState': false,
                                              'isChecked': false
                                            },
                                          ).toString()) {
                                    dialogBox(1);
                                  }
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
          context.read<InboundProvider>().addImage(
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
          context.read<InboundProvider>().addImage(
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

  void dialogBox(int index) {
    if (index > widget.data['data']['pallet_types'].entries.length ||
        widget.data['data']['driver_outstanding_pallet'].isEmpty) {
      for (int i = 0;
          i < widget.data['data']['pallet_types'].entries.length;
          i++) {
        context.read<InboundProvider>().addEntities(
              {
                "pallet_id_$i": "${i + 1}",
                "pallet_qty_${i + 1}":
                    _formKey.currentState!.fields['pallet_qty_${i + 1}']!.value,
              }.entries,
            );
      }
      context.read<InboundProvider>().addEntities({
            "total_pallet_types":
                widget.data['data']['pallet_types'].entries.length,
            "pictures": context.read<InboundProvider>().base64Images,
            "pictureSources": context.read<InboundProvider>().pictureSources,
            "latitude": context.read<LocationProvider>().current!.latitude,
            "longitude": context.read<LocationProvider>().current!.longitude,
          }.entries);
      context.read<InboundProvider>().setIndex(1);
    } else if (widget.data['data']['driver_outstanding_pallet'][index - 1]
            ['balance'] ==
        int.parse(_formKey.currentState!.fields['pallet_qty_$index']!.value)) {
      dialogBox(index + 1);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: SizedBox(
              height: 20.w,
              width: 20.w,
              child: const Image(
                image: AssetImage(AppImages.brakeWarning),
              ),
            ),
            title: Text(
              'You are missing ${widget.data['data']['driver_outstanding_pallet'][index - 1]['balance'] - int.parse(_formKey.currentState!.fields['pallet_qty_$index']!.value)} ${widget.data['data']['pallet_types']['$index'].split(' ').first} pallets. Is this correct?',
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
            iconPadding: EdgeInsets.symmetric(vertical: 1.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.sp),
            ),
            backgroundColor: AppColors.white,
            actions: <Widget>[
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomButton(
                    height: 5.h,
                    width: 30.w,
                    label: 'Edit',
                    backgroundColor: AppColors.white,
                    borderColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    onPressed: () {
                      Navigator.pop(context);
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
                      dialogBox(index + 1);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }
}
