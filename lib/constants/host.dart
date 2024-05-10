class AppHost {
  static const String hostURL = 'https://staging.xdock.com.au';

  static const String login = '$hostURL/api/staff/v2/token';
  static const String logout = '$hostURL/api/staff/v2/logout';

  static const String resetPasswordEmail =
      '$hostURL/api/staff/v2/password/send-reset-password-email';
  static const String verifyOTP = '$hostURL/api/staff/v2/password/verify-otp';
  static const String resetPassword = '$hostURL/api/staff/v2/password/reset';

  static const String loginStaffData =
      '$hostURL/api/driver/profile/getLoginStaffData';
  static const String checkSubmissions =
      '$hostURL/api/driver/submission/v2/check_ckecklist_inbound_and_outbound_submission';
  static const String consignments =
      '$hostURL/api/driver/runSheet/v6/consignments';

  static const String indexPreChecklist = '$hostURL/api/driver/checklist/v5';
  static const String storePreChecklist =
      '$hostURL/api/driver/checklist/v5/store';

  static const String indexOutboundPallet =
      '$hostURL/api/driver/outbound_pallet/v6';
  static const String storeOutboundPallet =
      '$hostURL/api/driver/outbound_pallet/v6/store';

  static const String indexInboundPallet =
      '$hostURL/api/driver/return_pallet/v6';
  static const String storeInboundPallet =
      '$hostURL/api/driver/return_pallet/v6/store';
        static const String podfull = 
        '$hostURL/api/driver/runSheet/v6/singlePodRecord/2250955';
         static const String podpartial = 
        '$hostURL/api/driver/runSheet/v6/singlePodRecord/2250956';
         static const String podnone = 
        '$hostURL/api/driver/runSheet/v6/singlePodRecord/2250955';
}
