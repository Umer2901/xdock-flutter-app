import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/clock.dart';

class ProofOfDeliveryView extends StatefulWidget {
  const ProofOfDeliveryView({Key? key}) : super(key: key);

  @override
  State<ProofOfDeliveryView> createState() => _ProofOfDeliveryViewState();
}
class _ProofOfDeliveryViewState extends State<ProofOfDeliveryView> {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.black,
    exportBackgroundColor: AppColors.white,
  );

  final StreamController<dynamic> _consignmentStreamController =
      StreamController<dynamic>();

  final TextEditingController serviceTimeController = TextEditingController();
  bool showSignature =false;
  late Timer _timer;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
   fetchData();
  }

  @override
  void dispose() {
    _consignmentStreamController.close();
    _timer.cancel();
    super.dispose();
  }


  bool isLoading = false;
  Future<void> fetchData() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        final response = await http.get(
          Uri.parse('${AppHost.consignmentDetail}${Get.arguments}'),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (!_consignmentStreamController.isClosed) {
          if (response.statusCode == 200) {
            final dynamic data = json.decode(response.body);
            _consignmentStreamController.add(data);
          } else {
            print(
                'Failed to fetch data. Status code: ${response.statusCode}');
            _consignmentStreamController.addError('Failed to fetch data');
          }
        } else {
          print('Stream controller is closed. Status code: ${response.statusCode}');
        }
      } catch (e, stackTrace) {
        print('Error fetching data: $e');
        print('Stack trace: $stackTrace');
        if (!_consignmentStreamController.isClosed) {
          _consignmentStreamController.addError('Error fetching data');
        } else {
          print('Stream controller is closed. Skipping error addition.');
        }
      }
    } else {
      print('User is not authenticated');
      // Handle unauthenticated state if needed
    }
  }
 
  @override
  Widget build(BuildContext context) {
      var provider = Provider.of<ProofOfDeliveryProvider>(context);


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
              child: FormBuilder(
                      key: _formKey,
                child: StreamBuilder(
                  stream: _consignmentStreamController.stream,
                  builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print(snapshot.data); 
                        var id = snapshot.data['data']['id'];
                        var ref = snapshot.data['data']['customer_reference'];
                    return Column(
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
                                      'ID: ${snapshot.data['data']['id']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    VerticalDivider(
                                      color: AppColors.black.withOpacity(0.5),
                                      thickness: 2,
                                    ),
                                    Text(
                                      'REF: ${snapshot.data['data']['customer_reference']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
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
                                        (snapshot.data['data']
                                                        ['consignment_type'] ==
                                                    'delivery'
                                                ? snapshot.data['data']
                                                        ['delivery_addresses']
                                                    ['company_name']
                                                : snapshot.data['data']
                                                        ['pickup_addresses']
                                                    ['company_name']) ??
                                            'Not Provided',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      Text(
                                        'Recipient: ${(snapshot.data['data']['consignment_type'] == 'delivery' ? snapshot.data['data']['delivery_addresses']['customer_name'] : snapshot.data['data']['pickup_addresses']['customer_name']) ?? 'Not Provided'}',
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        snapshot.data['data']
                                                    ['consignment_type'] ==
                                                'delivery'
                                            ? '${snapshot.data['data']['delivery_addresses']['street_address']}, ${snapshot.data['data']['delivery_addresses']['suburb']}'
                                            : '${snapshot.data['data']['pickup_addresses']['street_address']}, ${snapshot.data['data']['pickup_addresses']['suburb']}',
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
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
                        const Divider(),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          AppText.selectDeliveryType,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                     CustomDropdown(
                    name: 'deliveryType',
                    hintText: 'Please Select',
                    fillColor: AppColors.white,
                   // value: Provider.of<ProofOfDeliveryProvider>(context).selectedDeliveryType,
                    onChanged: (newValue) {
                      context.read<ProofOfDeliveryProvider>().updateSelectedDeliveryType(newValue!);
                  
                    },
                    items: [
                      DropdownMenuItem(
                        value: DeliveryType.full,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 3.sp,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            const Text('Full Delivery'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: DeliveryType.partial,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.yellow,
                              radius: 3.sp,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            const Text('Partial Delivery'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: DeliveryType.none,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.red,
                              radius: 3.sp,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            const Text('No Delivery'),
                          ],
                        ),
                      ),
                    ],
                  ),

                   
                    SizedBox(
                      height: 2.h,
                    ),
                    
                        if (Provider.of<ProofOfDeliveryProvider>(context).selectedDeliveryType == DeliveryType.full)
                         Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.howManyDelivered,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PalletContainer(
                                name: 'cartons',
                                heading: AppText.cartons,
                                icon: SvgPicture.asset(AppSvgs.pallet),
                                hintText: '0',
                                 initialValue: context
                                        .read<ProofOfDeliveryProvider>()
                                        .data
                                        .containsKey('cartons')
                                    ? int.parse(context
                                        .read<ProofOfDeliveryProvider>()
                                        .data['cartons'])
                                    : 0,
                                totalPallet: 5,
                   
                              ),
                              PalletContainer(
                                name: 'pallets',
                                heading: AppText.pallets,
                                hintText: '0',
                                initialValue: context
                                        .read<ProofOfDeliveryProvider>()
                                        .data
                                        .containsKey('pallet')
                                    ? int.parse(context
                                        .read<ProofOfDeliveryProvider>()
                                        .data['pallet'])
                                    : 0,
                                    
                                totalPallet: 5,
                               
                              ),
                            
                        
                            ],
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.deliveryTemperature,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                       CustomTextField(
  name: 'temp',
  hintText: AppText.temperature,
  keyboardType: TextInputType.number,
  suffixIcon: Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
    child: Text(
      AppText.celsius,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    ),
  ),
  initialValue: context
          .read<ProofOfDeliveryProvider>()
          .data
          .containsKey('temperature')
      ? context
          .read<ProofOfDeliveryProvider>()
          .data['temperature']
      : null,
  controller: null, 
  onChanged: (value) {
    context.read<ProofOfDeliveryProvider>().data['temperature'] = value;
  },
),
                
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.serviceTime,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                         CustomTextField(
                      name: 'service',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      hintText:  serviceTimeController.text =
                          '${Provider.of<TimeProvider>(context).startTime.h}:${Provider.of<TimeProvider>(context).startTime.m} - ${Provider.of<TimeProvider>(context).endTime.h}:${Provider.of<TimeProvider>(context).endTime.m}',
                             controller:  serviceTimeController,
                      onTap: () {
                        Get.toNamed(AppRoutes.Stopwatch);
                       
                      },
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Text(
                              AppText.editHours,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.black.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                           
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 2.h,
                              color: AppColors.black.withOpacity(0.5),
                            )
                          ],
                        ),
                      ),
                        initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('servicetime')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['servicetime']
                                  : null,
                                    onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['servicetime'] = value;
                  },
                    ),
                    
                          SizedBox(
                            height: 1.h,
                          ),
                          CustomTextField(
                            name: 'length',
                            hintText: AppText.lengthOfDelivery,
                            keyboardType: TextInputType.number,
                            suffixIcon: Padding(
                              padding:
                    EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                              child: Text(
                                AppText.minutes,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                              ),
                            ),
                              initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('lengthOfDelivery')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['lengthOfDelivery']
                                  : null,
                                    onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['lengthOfDelivery'] = value;
                  },
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.receiverConfirmation,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           CustomTextField(
                            name: 'receiverFirstName',
                            hintText: AppText.receiverFirstName,
                                initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('first_name')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['first_name']
                                  : null, onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['first_name'] = value;
                  },
                                  
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           CustomTextField(
                            name: 'receiverLastName',
                            hintText: AppText.receiverLastName,
                             initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('last_name')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['last_name']
                                  : null,onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['last_name'] = value;
                  },
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
Consumer<ProofOfDeliveryProvider>(
        builder: (context, provider, _) {
          return SizedBox(
            width: 90.w,
            child: GestureDetector(
              onTap: () async{
                
                if (!provider.showSignature) {
               
                  provider.setShowSignature(true);
                  provider.showSignaturePopup(context, controller);
                  await controller.toPngBytes().then((bytes) {
                  context.read<ProofOfDeliveryProvider>().addEntities(
                                        {
                                          "signature":
                                              'data:image/png;base64, ${base64Encode(bytes as List<int>).toString()}',
                                         
                                        }.entries,
                                      );
                     });
                }
              },
                          child: Stack(
                            children: [
                              if (controller.isEmpty && !provider.showSignature)
                  Container(
                    height: 25.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navyBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.sp),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.w,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50.sp,
                          height: 50.sp,
                          child: Image.asset(
                            AppImages.handWithPen,
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
                              if (provider.showSignature)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navyBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.sp),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.w,
                    ),
                    child: Column(
                      children: [
                        Signature(
                          controller: controller,
                          width: 90.w,
                          height: 20.h,
                          backgroundColor: Colors.transparent,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 2,
                          color: AppColors.grey,
                        ),
                        CupertinoButton(
                          child: const Text(
                            "Redo",
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {
                          provider.clearSignatureAndShowPopup(context, controller);
                          },
                        ),
                      ],
                    ),
                  ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                        
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                             SizedBox(
                              width: 50.w,
                              child: Consumer<ProofOfDeliveryProvider>(
                                builder: (context, provider, _) => CustomButton(
                    label: "Next",
                   onPressed: () {
                 if (_formKey.currentState != null) {
                
                final temperature = _formKey.currentState!.fields['temp']!.value.toString();
                final first_name = _formKey.currentState!.fields['receiverFirstName']!.value.toString();
                final last_name = _formKey.currentState!.fields['receiverLastName']!.value.toString();
                final servicetime = _formKey.currentState!.fields['service']!.value.toString();
                final lengthofDelivery = _formKey.currentState!.fields['length']!.value.toString();
                final cartons = _formKey.currentState!.fields['cartons']!.value.toString();
                final pallets = _formKey.currentState!.fields['pallets']!.value.toString();
                final signature = context.read<ProofOfDeliveryProvider>().data['signature'];
    //  context.read<OutboundProvider>().addEntities({
                                        
    //                                     "pictures": context
    //                                         .read<OutboundProvider>()
    //                                         .base64Images,
    //                                     "pictureSources": context
    //                                         .read<OutboundProvider>()
    //                                         .pictureSources,
    //                                     "latitude": context
    //                                         .read<LocationProvider>()
    //                                         .current!
    //                                         .latitude,
    //                                     "longitude": context
    //                                         .read<LocationProvider>()
    //                                         .current!
    //                                         .longitude,
    //                                   }.entries);
    //                               context.read<OutboundProvider>().setIndex(1);
    //                             }
                                        
                  
                  final temp = {
                    "pod_type": "full",
                    "temperature": temperature,
                    "first_name": first_name,
                    "last_name": last_name,
                    "lengthofDelivery": lengthofDelivery,
                    "cartons": cartons,
                    "pallets": pallets,
                    "servicetime": servicetime,
                    "signature": signature,
                  };
                  context.read<ProofOfDeliveryProvider>().addEntities(temp.entries);
                 Get.toNamed(AppRoutes.podphotos);
                } else {
                  print("lpc");
                }
                   }
                ),
                    ),
                    
                           
                            )  ],
                          ),
                        
                        ],
                      ),
                    
                     if (Provider.of<ProofOfDeliveryProvider>(context).selectedDeliveryType == DeliveryType.partial)
                   
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.howManyDelivered,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                PalletContainer(
                                name: 'cartons',
                                heading: AppText.cartons,
                                icon: SvgPicture.asset(AppSvgs.pallet),
                                hintText: '0',
                                 initialValue: context
                                        .read<ProofOfDeliveryProvider>()
                                        .data
                                        .containsKey('cartons')
                                    ? int.parse(context
                                        .read<ProofOfDeliveryProvider>()
                                        .data['cartons'])
                                    : 0,
                                totalPallet: 5,
                   
                              ),
                              PalletContainer(
                                name: 'pallets',
                                heading: AppText.pallets,
                                hintText: '0',
                                initialValue: context
                                        .read<ProofOfDeliveryProvider>()
                                        .data
                                        .containsKey('pallet')
                                    ? int.parse(context
                                        .read<ProofOfDeliveryProvider>()
                                        .data['pallet'])
                                    : 0,
                                    
                                totalPallet: 5,
                               
                              ),
                            ],
                          ),
                             SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            "Reason for partial delivery",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                    
                          SizedBox(
                            height: 1.h,
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
                                child:
                                 CustomTextField(
                            name: 'Reasonpartial',
                            hintText:"Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
                           borderColor: AppColors.white,
                             initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('reason')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['reason']
                                  : null,onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['reason'] = value;
                  },
                          ),
                                
                                
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.deliveryTemperature,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          CustomTextField(
  name: 'temp',
  hintText: AppText.temperature,
  keyboardType: TextInputType.number,
  suffixIcon: Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
    child: Text(
      AppText.celsius,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    ),
  ),
  initialValue: context
          .read<ProofOfDeliveryProvider>()
          .data
          .containsKey('temperature')
      ? context
          .read<ProofOfDeliveryProvider>()
          .data['temperature']
      : null,
  controller: null, 
  onChanged: (value) {
    context.read<ProofOfDeliveryProvider>().data['temperature'] = value;
  },
),
                
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.serviceTime,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                         CustomTextField(
                      name: 'service',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      hintText:  serviceTimeController.text =
                          '${Provider.of<TimeProvider>(context).startTime.h}:${Provider.of<TimeProvider>(context).startTime.m} - ${Provider.of<TimeProvider>(context).endTime.h}:${Provider.of<TimeProvider>(context).endTime.m}',
                             controller:  serviceTimeController,
                      onTap: () {
                        Get.toNamed(AppRoutes.Stopwatch);
                       
                      },
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Text(
                              AppText.editHours,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.black.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                           
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 2.h,
                              color: AppColors.black.withOpacity(0.5),
                            )
                          ],
                        ),
                      ),
                        initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('servicetime')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['servicetime']
                                  : null,
                                    onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['servicetime'] = value;
                  },
                    ),
                    
                          SizedBox(
                            height: 1.h,
                          ),
                          CustomTextField(
                            name: 'length',
                            hintText: AppText.lengthOfDelivery,
                            keyboardType: TextInputType.number,
                            suffixIcon: Padding(
                              padding:
                    EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                              child: Text(
                                AppText.minutes,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                              ),
                            ),
                              initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('lengthOfDelivery')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['lengthOfDelivery']
                                  : null,
                                    onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['lengthOfDelivery'] = value;
                  },
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.receiverConfirmation,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           CustomTextField(
                            name: 'receiverFirstName',
                            hintText: AppText.receiverFirstName,
                                initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('first_name')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['first_name']
                                  : null, onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['first_name'] = value;
                  },
                                  
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           CustomTextField(
                            name: 'receiverLastName',
                            hintText: AppText.receiverLastName,
                             initialValue: context
                                      .read<ProofOfDeliveryProvider>()
                                      .data
                                      .containsKey('last_name')
                                  ? context
                                      .read<ProofOfDeliveryProvider>()
                                      .data['last_name']
                                  : null,onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['last_name'] = value;
                  },
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
Consumer<ProofOfDeliveryProvider>(
        builder: (context, provider, _) {
          return SizedBox(
            width: 90.w,
            child: GestureDetector(
              onTap: () async{
                
                if (!provider.showSignature) {
               
                  provider.setShowSignature(true);
                  provider.showSignaturePopup(context, controller);
                  await controller.toPngBytes().then((bytes) {
                  context.read<ProofOfDeliveryProvider>().addEntities(
                                        {
                                          "signature":
                                              'data:image/png;base64, ${base64Encode(bytes as List<int>).toString()}',
                                         
                                        }.entries,
                                      );
                     });
                }
              },
                          child: Stack(
                            children: [
                              if (controller.isEmpty && !provider.showSignature)
                  Container(
                    height: 25.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navyBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.sp),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.w,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50.sp,
                          height: 50.sp,
                          child: Image.asset(
                            AppImages.handWithPen,
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
                              if (provider.showSignature)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navyBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.sp),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.w,
                    ),
                    child: Column(
                      children: [
                        Signature(
                          controller: controller,
                          width: 90.w,
                          height: 20.h,
                          backgroundColor: Colors.transparent,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 2,
                          color: AppColors.grey,
                        ),
                        CupertinoButton(
                          child: const Text(
                            "Redo",
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {
                          provider.clearSignatureAndShowPopup(context, controller);
                          },
                        ),
                      ],
                    ),
                  ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                        
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                             SizedBox(
                              width: 50.w,
                              child: Consumer<ProofOfDeliveryProvider>(
                                builder: (context, provider, _) => CustomButton(
                    label: "Next",
                   onPressed: () {
                 if (_formKey.currentState != null) {
                
                final temperature = _formKey.currentState!.fields['temp']!.value.toString();
                final first_name = _formKey.currentState!.fields['receiverFirstName']!.value.toString();
                final last_name = _formKey.currentState!.fields['receiverLastName']!.value.toString();
                final servicetime = _formKey.currentState!.fields['service']!.value.toString();
                final lengthofDelivery = _formKey.currentState!.fields['length']!.value.toString();
                final cartons = _formKey.currentState!.fields['cartons']!.value.toString();
                final pallets = _formKey.currentState!.fields['pallets']!.value.toString();
                final signature = context.read<ProofOfDeliveryProvider>().data['signature'];
                final reason = _formKey.currentState!.fields['Reasonpartial']!.value.toString();

    //  context.read<OutboundProvider>().addEntities({
                                        
    //                                     "pictures": context
    //                                         .read<OutboundProvider>()
    //                                         .base64Images,
    //                                     "pictureSources": context
    //                                         .read<OutboundProvider>()
    //                                         .pictureSources,
    //                                     "latitude": context
    //                                         .read<LocationProvider>()
    //                                         .current!
    //                                         .latitude,
    //                                     "longitude": context
    //                                         .read<LocationProvider>()
    //                                         .current!
    //                                         .longitude,
    //                                   }.entries);
    //                               context.read<OutboundProvider>().setIndex(1);
    //                             }
                                        
                  
                  final temp = {
                    "pod_type": "partial",
                    "temperature": temperature,
                    "first_name": first_name,
                    "last_name": last_name,
                    "lengthofDelivery": lengthofDelivery,
                    "cartons": cartons,
                    "pallets": pallets,
                    "servicetime": servicetime,
                    "signature": signature,
                    "reason": reason,
                  };
                  context.read<ProofOfDeliveryProvider>().addEntities(temp.entries);
                 Get.toNamed(AppRoutes.podphotos);
                } else {
                  print("lpc");
                }
                   }
                ),
                    ),
                    
                           
                            )  ],
                          ),
                        
                        ],
                      ),
                      
                       if (provider.selectedDeliveryType == DeliveryType.none)
                    //      Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         AppText.howManyDelivered,
                    //         style: Theme.of(context).textTheme.headlineMedium,
                    //       ),
                    //       SizedBox(
                    //         height: 1.h,
                    //       ),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           PalletContainer(
                    //             name: 'cartons',
                    //             heading: AppText.cartons,
                    //             icon: SvgPicture.asset(AppSvgs.pallet),
                    //             hintText: '0',
                    //             initialValue: 0,
                    //             totalPallet: 5,
                    //             isErrorState: true,
                    //           ),
                    //           const PalletContainer(
                    //             name: 'pallets',
                    //             heading: AppText.pallets,
                    //             hintText: '0',
                    //             initialValue: 0,
                    //             totalPallet: 5,
                    //             isErrorState: true,
                    //           ),
                    //         ],
                    //       ),
                    //       SizedBox(
                    //         height: 3.h,
                    //       ),
                    //       Text(
                    //         "Reason for non delivery",
                    //         style: Theme.of(context).textTheme.headlineMedium,
                    //       ),
                    //       SizedBox(
                    //         height: 1.h,
                    //       ),
                    //        Text(
                    //         "Select a reason the delivery could not be completed. If you are unsure if you can complete the delivery please open the chat and message our admin staff.",
                    //         style: Theme.of(context).textTheme.bodySmall,
                    //       ),
                    //       SizedBox(
                    //         height: 3.h,
                    //       ),
                    //   Consumer<ProofOfDeliveryProvider>(
                    //         builder: (context, provider, _) {
                    //           return Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    
                               
                    // CustomContainer(
                    //   title: 'Wrong Address',
                    //   description: 'Address is wrong or the location has closed',
                    // ),
                    // SizedBox(
                    //       height: 3.h,
                    //     ),
                    // CustomContainer(
                    //   title: 'Receiver Not Open',
                    //   description: 'The receiver is unable to receive goods',
                    // ),
                    // SizedBox(
                    //       height: 3.h,
                    //     ),
                    // CustomContainer(
                    //      title: 'Temperature issue',
                    //   description: 'The stock is not the correct temperature',
                    //     ),
                    //     SizedBox(
                    //       height: 3.h,
                    //     ),
                    //     CustomContainer(
                    //      title: 'Damaged Goods',
                    //   description: 'The packaging or goods have been damaged',
                    //     ),
                    //     SizedBox(
                    //       height: 3.h,
                    //     ),
                    //      CustomContainer(
                    //       title: 'Other Rejection',
                    //       description: 'The customer refused the goods ',
                    //     )
                    
                    //             ]);}),
                    
                    
                     
                        
                    
                    //       SizedBox(
                    //         height: 1.h,
                    //       ),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.end,
                    //         children: [
                    //           SizedBox(
                    //             width: 50.w,
                    //             child: CustomButton(label: "Submit POD", onPressed: (){
                    //     postData();
                    
                    //             },backgroundColor: AppColors.red,borderColor: AppColors.red,)),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                       
                                 SizedBox(
                            height: 1.h,
                          ),   ],
                    );
                  }
                  
                  else  {
                
                    
                      return CircularProgressIndicator();
                    } 
                             
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//  class CustomContainer extends StatefulWidget {
//   final String title;
//   final String description;

//   const CustomContainer({
//     Key? key,
//     required this.title,
//     required this.description,
//   }) : super(key: key);

//   @override
//   _CustomContainerState createState() => _CustomContainerState();
// }

// class _CustomContainerState extends State<CustomContainer> {
//   @override
//   Widget build(BuildContext context) {
//     final provider =
//         Provider.of<ProofOfDeliveryProvider>(context, listen: false);
//     bool isChecked = provider.selectedOrderRejectionReasons.contains(widget.title);

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           if (!isChecked) {
//             provider.clearOrderRejectionReasons();
//             provider.updateOrderRejectionReason(widget.title);
//           } else {
//             provider.updateOrderRejectionReason('');
//           }
//         });
//       },
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(12.sp),
//             decoration: BoxDecoration(
//               color: AppColors.grey,
//               borderRadius: BorderRadius.circular(10.sp),
//               border: Border.all(
//                 color: isChecked ? AppColors.blue : Colors.transparent,
//                 width: 2.0,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.title,
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 SizedBox(height: 1.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       widget.description,
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                        if (isChecked)
//                   CircleAvatar(
//                     radius: 8.sp,
//                     backgroundColor: AppColors.blue,
//                     child: Center(
//                       child: Icon(
//                         Icons.check,
//                         color: AppColors.white,
//                         size: 8.sp,
//                       ),
//                     ),
//                   ),
//                   ],
//                 ),
             
//               ],
//             ),
//           ),
//            if (isChecked && widget.title == 'Other Rejection')
             
//       Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//             SizedBox(
//         height: 3.h,
//       ),
//       Text(
//         "Order Rejection",
//         style: Theme.of(context).textTheme.headlineMedium,
//       ),
      
     
// Text(
//         "Please provide more detail",
//         style: Theme.of(context).textTheme.bodyMedium,
//       ),
//       SizedBox(
//         height: 1.h,
//       ),
//           Stack(
//             children: [
//               Container(
//                 height: 15.h,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.navyBlue),
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(5.sp),
//                   ),
//                 ),
//                 padding: EdgeInsets.symmetric(
//                     vertical: 1.h, horizontal: 2.w),
//                 child:  CustomTextField(
//                   borderColor: AppColors.white,
//             name: 'Order rejection',
//             hintText: "Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
            
              
//              onChanged: (value) {
//              Provider.of<ProofOfDeliveryProvider>(context, listen: false)
//               .updateDeliveryFormData(orderRejectionReason: value);
//             },
//           ),
//               ),
//             ],
//           ),
//         ],
//       ),
      
//         ],
//       ),
//     );
//   }
// }
