import 'dart:convert';
import 'dart:typed_data';
import 'package:coldxpress/export.dart';

enum DeliveryType { full, partial, none }

class ProofOfDeliveryProvider with ChangeNotifier {
  int _index = 0;
  Map _data = {};
  Uint8List? _signatureData;
  List<XFile> _images = [];
  Map<String, String> _base64Images = {};
  Map<String, String> _pictureSources = {};
  DeliveryType _selectedDeliveryType = DeliveryType.full;
  final List<String> _selectedOrderRejectionReasons = [];
  bool _showSignature = false;
  String? signatureData;
  XFile? _image;

  int get index => _index;
  Map get data => _data;
  bool get showSignature => _showSignature;
  XFile? get image => _image;
  List<XFile> get images => _images;
  Map<String, String> get base64Images => _base64Images;
  Map<String, String> get pictureSources => _pictureSources;
  DeliveryType get selectedDeliveryType => _selectedDeliveryType;
  Uint8List? get signature => _signatureData;
  List<String> get selectedOrderRejectionReasons => _selectedOrderRejectionReasons;
  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  setIndex(int value) {
    _index = value;
    notifyListeners();
  }

  addEntities(dynamic entries) {
    _data.addEntries(entries);
    notifyListeners();
  }

  setEntities(Map value) {
    _data = value;
    notifyListeners();
  }

  setImage({required XFile image}) {
    _image = image;
    notifyListeners();
  }

  void clearImage() {
    _image = null;
    notifyListeners();
  }

  clearSignatureAndShowPopup(SignatureController controller) {
    controller.clear();
    _signatureData = null;
    _showSignature = true;
    //showSignaturePopup(context, controller);
    notifyListeners();
  }

  lpc(SignatureController controller) {
    controller.clear();
    _signatureData = null;
    _showSignature = false;
    _index = 0;
    _data = {};
    _images = [];
    _base64Images = {};
    _pictureSources = {};
    notifyListeners();
  }

  updateSelectedDeliveryType(DeliveryType type) {
    _selectedDeliveryType = type;
    notifyListeners();
  }

  updateSignatureData(Uint8List data) {
    _signatureData = data;
    notifyListeners();
  }

  setShowSignature(bool value) {
    _showSignature = value;
    notifyListeners();
  }

  updateOrderRejectionReason(String reason) {
    _selectedOrderRejectionReasons.clear();
    _selectedOrderRejectionReasons.add(reason);
    data['rejection_reason'] = reason;
    notifyListeners();
  }

  clearOrderRejectionReasons() {
    _selectedOrderRejectionReasons.clear();
    notifyListeners();
  }

  resetSignatureState() {
    _showSignature = false;
    _signatureData = null;
    notifyListeners();
  }

  addImage({
    required XFile image,
    required String base64String,
    required String source,
  }) {
    _images.add(image);
    _base64Images
        .addEntries({'picture${_images.length}': base64String}.entries);
    _pictureSources.addEntries({'picture${_images.length}': source}.entries);
    notifyListeners();
  }

  removeImage({required XFile image}) {
    _images.remove(image);
    int index = _images.indexOf(image);
    _base64Images.remove('picture${index + 1}');
    _pictureSources.remove('picture${index + 1}');
    notifyListeners();
  }

  restoreToDefault() {
    _index = 0;
    _data = {};
    _images = [];
    _base64Images = {};
    _pictureSources = {};
    resetSignatureState();
    _isFormValid = false;  
    notifyListeners();
  }

  backToDefault() {
    _index = 0;
    _data = {};
    _images = [];
    _base64Images = {};
    _pictureSources = {};
    _selectedDeliveryType = DeliveryType.full;
    notifyListeners();
  }

  setDeviceInfo(Map<String, dynamic> deviceInfo) {
    _data['device'] = deviceInfo;
    notifyListeners();
  }

  void validateForm() {
    _isFormValid = _data['temp']?.isNotEmpty == true &&
                   _data['lengthOfDelivery']?.isNotEmpty == true &&
                   _data['first_name']?.isNotEmpty == true &&
                   _data['last_name']?.isNotEmpty == true &&
                   _signatureData != null;
                 
    debugPrint('Temp: ${_data['temp']}');
    debugPrint('Length of Delivery: ${_data['lengthOfDelivery']}');
    debugPrint('First Name: ${_data['first_name']}');
    debugPrint('Last Name: ${_data['last_name']}');
    debugPrint('Signature Data: $_signatureData');
    debugPrint('Is Form Valid: $_isFormValid');

    notifyListeners();
  }

  void updateField(String key, String? value) {
    _data[key] = value;
    validateForm();
  }

  void updateSignature(Uint8List signatureData) {
    _signatureData = signatureData;
    _data['signature'] = 'data:image/png;base64, ${base64Encode(signatureData)}';
    validateForm();
  }
}
