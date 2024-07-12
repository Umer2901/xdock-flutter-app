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
  List<String> _selectedOrderRejectionReasons = [];
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

  clearSignatureAndShowPopup( SignatureController controller) {
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
    _base64Images.addEntries({'picture${_images.length}': base64String}.entries);
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
    
  }

   backToDefault() {
    _index = 0;
    _data = {};
    _images = [];
    _base64Images = {};
    _pictureSources = {};
  }

  setDeviceInfo(Map<String, dynamic> deviceInfo) {
    _data['device'] = deviceInfo;
    notifyListeners();
  }
}