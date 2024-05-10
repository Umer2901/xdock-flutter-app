import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';
class ProofOfDeliveryPhotos extends StatefulWidget {
  const ProofOfDeliveryPhotos({super.key});

  @override
  State<ProofOfDeliveryPhotos> createState() => _ProofOfDeliveryPhotosState();
}
bool isLoading = false;
class _ProofOfDeliveryPhotosState extends State<ProofOfDeliveryPhotos> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProofOfDeliveryProvider>(context);
    
Future<void> postData() async {
  setState(() {
    isLoading = true;
  });
  AuthenticationState state =
      BlocProvider.of<AuthenticationCubit>(context).state;
  if (state is Authenticated) {
    try {
      Map<String, dynamic> requestBody;
      String url;
      switch (provider.selectedDeliveryType) {
        case DeliveryType.full:
          requestBody = {
            //'pod_type': provider.selectedDeliveryType.toString(),
            'pod_type': 'full',
            'palletValue': provider.palletValue,
            'cartonsValue': provider.cartonsValue,
            'showSignature': provider.showSignature,
            'temperature': provider.temperature,
            'serviceTime': provider.serviceTime,
            'lengthOfDelivery': provider.lengthOfDelivery,
            'receiverFirstName': provider.receiverFirstName,
            'receiverLastName': provider.receiverLastName,
            'images': provider.base64Images.values.toList(),
            "otherinfo": provider.otherinfo,
          };
          url = AppHost.podfull;
          break;
        case DeliveryType.partial:
          requestBody = {
            'pod_type': 'partial',
            'palletValue': provider.palletValue,
            'cartonsValue': provider.cartonsValue,
            'showSignature': provider.showSignature,
            'temperature': provider.temperature,
            'serviceTime': provider.serviceTime,
            'lengthOfDelivery': provider.lengthOfDelivery,
            'receiverFirstName': provider.receiverFirstName,
            'receiverLastName': provider.receiverLastName,
            'reasonpartialdelivery': provider.reasonpartialdelivery,
            'images': provider.base64Images.values.toList(),
            "otherinfo": provider.otherinfo,
          };
          url = AppHost.podpartial;
          break;
        case DeliveryType.none:
          requestBody = {
            'pod_type': 'none',
            "orderrejectionreason": provider.orderRejectionReason,
            "rejectionreason": provider.selectedOrderRejectionReasons,
          };
          url = AppHost.podnone;
          
          break;
      }
       print('Request Body: $requestBody');
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer ${state.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  icon: SizedBox(
                    height: 20.w,
                    width: 20.w,
                    child: const Image(
                      image: AssetImage(AppImages.checkmark),
                      color: Colors.green,
                    ),
                  ),
                  title: Text(
                    'Your Outbound pallets have been submitted successfully',
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
                    Center(
                      child: CustomButton(
                        height: 5.h,
                        width: 30.w,
                        label: 'CLOSE',
                        backgroundColor: AppColors.blue,
                        borderColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        onPressed: () async {
                          context.read<ProofOfDeliveryProvider>().clearFormData();
                          Get.offAllNamed(AppRoutes.dashboard);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }  else {
            setState(() {
              isLoading = false;
            });
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
      } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }
}

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_horiz,
              size: 20.sp,
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          AppText.proofOfDelivery,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    centerTitle: true,
                    leading: const SizedBox.shrink(),
                    title: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ID: 123456',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          VerticalDivider(
                            color: AppColors.black.withOpacity(0.5),
                            thickness: 2,
                          ),
                          Text(
                            'REF: 1234',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: 13.5.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(50.sp),
                              border: Border.all()),
                          child: SvgPicture.asset(
                            AppSvgs.journey,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
      Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 8.h,
                        width: 18.w,
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
                            child: SizedBox(
                                width: 16.w,
                                height: 7.h,
                                child: Image.asset(AppImages.cardboard))),
                      ),
                      SizedBox(
                        width: 54.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ritchies IGA',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'Recipient: Drew Moran 830 Wellington road, Rowville',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: 13.5.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(50.sp),
                          ),
                          child: Icon(
                            Icons.call,
                            color: AppColors.white,
                            size: 4.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                      SizedBox(
                        height: 2.h,
                      ),
                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: AppColors.grey,
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Text(
                        "Photo Evidence",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    
                      SizedBox(
                        height: 1.h,
                      ),
                      GestureDetector(
                        onTap: () async{
                          // showModalBottomSheet(
                          //   backgroundColor: AppColors.white,
                          //   context: context,
                          //   builder: (BuildContext context) {
                          //     return Wrap(
                          //       children: <Widget>[
                          //         ListTile(
                          //           leading: const Icon(Icons.camera_alt),
                          //           title: Text(
                          //             'Take Photo',
                          //             style: Theme.of(context)
                          //                 .textTheme
                          //                 .bodyMedium
                          //                 ?.copyWith(
                          //                   fontWeight: FontWeight.w600,
                          //                 ),
                          //           ),
                          //           onTap: () async {
                          //             Navigator.pop(context);
                          //             await _takePhoto();
                          //           },
                          //         ),
                          //         ListTile(
                          //           leading: const Icon(Icons.image),
                          //           title: Text(
                          //             'Pick Image',
                          //             style: Theme.of(context)
                          //                 .textTheme
                          //                 .bodyMedium
                          //                 ?.copyWith(
                          //                   fontWeight: FontWeight.w600,
                          //                 ),
                          //           ),
                          //           onTap: () async {
                          //             Navigator.pop(context);
                          //             await _pickImage();
                          //           },
                          //         ),
                          //       ],
                          //     );
                          //   },
                          // );
                         await _takePhoto();
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
                                    .read<ProofOfDeliveryProvider>()
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
                                                    .read<ProofOfDeliveryProvider>()
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
                      Text(
                        "Other Information",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
     Stack(
        children: [
          Container(
            height: 15.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.navyBlue),
              borderRadius: BorderRadius.all(
                Radius.circular(5.sp),
              ),
            ),
            padding: EdgeInsets.symmetric(
                vertical: 1.h, horizontal: 2.w),
            child: CustomTextField(
              borderColor: AppColors.white,
      name: 'Textform',
      hintText: "Enter Text",
      onChanged: (value) {
    
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(otherinfo: value);
  },
            ),
          ),
        ],
      ),
      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
       SizedBox(
  width: 50.w,
  child: CustomButton(
    label: "Submit POD",
    onPressed: context.watch<ProofOfDeliveryProvider>().images.isNotEmpty
        ? () {
            postData();
          }
        : (){},
    backgroundColor: context.watch<ProofOfDeliveryProvider>().images.isNotEmpty
        ? AppColors.blue
        : AppColors.grey, 
    borderColor: context.watch<ProofOfDeliveryProvider>().images.isNotEmpty
        ? AppColors.blue
        : AppColors.grey,
  ),
),





        ],
      ),
      ]))))));
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
          context.read<ProofOfDeliveryProvider>().addImage(
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

   
 
}