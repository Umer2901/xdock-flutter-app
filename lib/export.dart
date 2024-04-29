// Design Exports
export 'package:sizer/sizer.dart';
export 'package:flutter/material.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:loading_indicator/loading_indicator.dart';
export 'package:flutter_form_builder/flutter_form_builder.dart';
export 'package:flutter/cupertino.dart' hide RefreshCallback;
export 'package:get/get.dart';
export 'package:shimmer/shimmer.dart';
export 'package:pinput/pinput.dart';

// View Exports
export 'views/splash.dart';
export 'views/welcome.dart';
export 'views/login.dart';
export 'views/register.dart';
export 'views/reset_password.dart';
export 'views/dashboard.dart';
export 'views/verify_otp.dart';

// Tab Exports
export 'views/tabs/home.dart';
export 'views/new_password.dart';
export 'views/pre-start-checklist/pre_start_checklist.dart';
export 'views/outboundPallets/outbound_pallets.dart';
export 'views/inboundPallets/inbound_pallets.dart';

// Tab Exports
export 'views/tabs/consignment_map.dart';
export 'views/tabs/consignments/my_consigments.dart';
export 'views/tabs/consignments/sub_views/single_consigment.dart';
export 'views/tabs/consignments/sub_views/consigment_reorder.dart';

// Constant Exports
export 'constants/colors.dart';
export 'constants/text.dart';
export 'constants/host.dart';

// Util Exports
export 'utils/images.dart';
export 'utils/svgs.dart';

// Widget Exports
export 'widgets/core/custom_button.dart';
export 'widgets/core/custom_elevated_button.dart';
export 'widgets/core/custom_textfield.dart';
export 'widgets/core/custom_drawer.dart';
export 'widgets/core/pallet_container.dart';
export 'widgets/core/custom_dropdown.dart';
export 'widgets/core/custom_pre_start.dart';
export 'widgets/core/custom_error.dart';
export 'widgets/core/custom_outbound.dart';
export 'widgets/core/custom_inbound.dart';
export 'widgets/core/custom_valuefield.dart';
export 'widgets/core/custom_order_tracker.dart';
export 'widgets/core/custom_delivery_details.dart';
export 'widgets/core/custom_product_type_time.dart';
export 'widgets/core/custom_my_consigments_container.dart';
export 'widgets/core/custom_consigment_container.dart';

// Routes
export 'routes/app_pages.dart';
export 'routes/app_routes.dart';

// Other Exports
export 'package:google_maps_flutter/google_maps_flutter.dart';
export 'package:signature/signature.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:shared_preferences/shared_preferences.dart';
export 'package:form_builder_validators/form_builder_validators.dart';
export 'package:image_picker/image_picker.dart';
export 'package:fluttertoast/fluttertoast.dart';
export 'package:flutter_svg/svg.dart';
export 'package:dropdown_search/dropdown_search.dart'
    hide ErrorBuilder, defaultScrollNotificationPredicate;

//Provider Exports
export 'package:provider/provider.dart';
export 'providers/pre_start_provider.dart';
export 'providers/outbound_provider.dart';
export 'providers/inbound_provider.dart';
export 'providers/location_provider.dart';

// Bloc Exports
export 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
export 'bloc/authentication/authentication_cubit.dart';
export 'bloc/forgot-password/forgot_password_cubit.dart';
