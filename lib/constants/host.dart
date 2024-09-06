class AppHost {
  static const String hostURL = 'https://staging.xdock.com.au';

  static const String login = '$hostURL/api/staff/v6/token';
  static const String logout = '$hostURL/api/staff/v6/logout';

  static const String resetPasswordEmail =
      '$hostURL/api/staff/v6/password/send-reset-password-email';
  static const String verifyOTP = '$hostURL/api/staff/v6/password/verify-otp';
  static const String resetPassword = '$hostURL/api/staff/v6/password/reset';

  static const String loginStaffData =
      '$hostURL/api/driver/profile/v6/getLoginStaffData';
  static const String checkSubmissions =
      '$hostURL/api/driver/submission/v6/check_checklist_inbound_and_outbound_submission';

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

  static const String reorderConsignments =
      '$hostURL/api/driver/runSheet/v6/reOrder';
  static const String consignmentDetail =
      '$hostURL/api/driver/consignments/v6/';
  static const String podfull =
      '$hostURL/api/driver/runSheet/v6/singlePodRecord/';
  static const String podpartial =
      '$hostURL/api/driver/runSheet/v6/singlePodRecord/';
  static const String notopen =
      '$hostURL/api/driver/runSheet/v6/podErrorRecord/';
  static const String wrongaddress =
      '$hostURL/api/driver/runSheet/v6/podErrorRecord/';
  static const String temperateissue =
      '$hostURL/api/driver/runSheet/v6/podErrorRecord/';
  static const String damagegoods =
      '$hostURL/api/driver/runSheet/v6/podErrorRecord/';
  static const String otherrejection =
      '$hostURL/api/driver/runSheet/v6/podErrorRecord/';
  static const String group = 
      '$hostURL/api/driver/runSheet/v6/groupPodRecord';
      static const String grouppop = 
      '$hostURL/api/driver/runSheet/v6/groupPodRecord';
  static const String singlepop = 
      '$hostURL/api/driver/runSheet/v6/singlePodRecord/';
  static const String updatetime = 
      '$hostURL/api/driver/runSheet/v6/updateServiceTimeWindows';

 
}
