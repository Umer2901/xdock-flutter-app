import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/clock.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/proof_of_delivery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationCubit>(create: (_) => AuthenticationCubit()),
        BlocProvider<ForgotPasswordCubit>(create: (_) => ForgotPasswordCubit()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<PreStartProvider>(
            create: (_) => PreStartProvider(),
          ),
          ChangeNotifierProvider<OutboundProvider>(
            create: (_) => OutboundProvider(),
          ),
          ChangeNotifierProvider<InboundProvider>(
            create: (_) => InboundProvider(),
          ),
          ChangeNotifierProvider<LocationProvider>(
            create: (_) => LocationProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => TimeProvider(),
            child: EditTime(),
          ),
           ChangeNotifierProvider(
            create: (_) => ProofOfDeliveryProvider(),
            child: ProofOfDeliveryView(),
             
          ),

        ],
        child: Sizer(
          builder: (context, language, child) {
            return GetMaterialApp(
              title: 'ColdXPress',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                textTheme: TextTheme(
                  headlineLarge: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                  ),
                  headlineMedium: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                  headlineSmall: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                  bodyLarge: GoogleFonts.nunito(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                  bodyMedium: GoogleFonts.nunito(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                  ),
                  bodySmall: GoogleFonts.nunito(
                    fontWeight: FontWeight.w300,
                    fontSize: 11.sp,
                  ),
                ),
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              initialRoute: AppPages.initialRoute,
              getPages: AppPages.routes,
            );
          },
        ),
      ),
    );
  }
}
