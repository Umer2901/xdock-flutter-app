
import 'dart:typed_data';

import 'package:coldxpress/export.dart';

enum DeliveryType { full, partial, none }


class ProofOfDeliveryProvider with ChangeNotifier {
  DeliveryType _selectedDeliveryType = DeliveryType.full;
  int _palletValue = 0;
  int _cartonsValue = 0;
  bool _showSignature = false;
  String _temperature = '';
  String _serviceTime = '';
  String _lengthOfDelivery = '';
  String _receiverFirstName = '';
  String _receiverLastName = ''; 
  String _reasonpartialdelivery = ''; 
  String _orderRejectionReason = '';
  String _otherinfo = '';
  Uint8List? _signatureData;
 List<String> _selectedOrderRejectionReasons = [];
 bool _isTempValid = false;
 bool _isServiceTimeValid = false;
 bool _isLengthOfDeliveryValid = false;
 bool _isReceiverFirstNameValid = false;
 bool _isReceiverLastNameValid = false;
 bool _isReasonPartialValid = false;
 bool _isReasonNoneValid = false;
   List<XFile> _images = [];
  Map<String, String> _base64Images = {};
  Map<String, String> _pictureSources = {};

 

  

  DeliveryType get selectedDeliveryType => _selectedDeliveryType;
  int get palletValue => _palletValue;
  int get cartonsValue => _cartonsValue;
  bool get showSignature => _showSignature;
  String get temperature => _temperature;
  String get serviceTime => _serviceTime;
  String get lengthOfDelivery => _lengthOfDelivery;
  String get receiverFirstName => _receiverFirstName;
  String get receiverLastName => _receiverLastName; 
  String get reasonpartialdelivery => _reasonpartialdelivery;
  String get orderRejectionReason => _orderRejectionReason;
  String get otherinfo => _otherinfo;
  List<String> get selectedOrderRejectionReasons => _selectedOrderRejectionReasons;
  bool get isTempValid => _isTempValid;
  bool get isServiceTimeValid => _isServiceTimeValid;
  bool get isLengthOfDeliveryValid => _isLengthOfDeliveryValid;
  bool get isReceiverFirstNameValid => _isReceiverFirstNameValid;
  bool get isReceiverLastNameValid => _isReceiverLastNameValid;
  bool get isReasonPartialValid => _isReasonPartialValid;
  bool get isReasonNoneValid => _isReasonNoneValid;
  List<XFile> get images => _images;
  Map<String, String> get base64Images => _base64Images;
  Map<String, String> get pictureSources => _pictureSources;

 


  void showSignaturePopup(BuildContext context, SignatureController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          child: Transform.rotate(
            angle: 90 * 3.14159 / 180,
            child: Container(
              height: 47.h,
              width: 80.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        "Signature",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      CupertinoButton(
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          // Perform any necessary actions
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      height: 24.h,
                      width: 90.w,
                      alignment: Alignment.center,
                      child: Signature(
                        controller: controller,
                        width: 85.w,
                        height: 20.h,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Divider(
                          height: 1,
                          thickness: 2,
                          color: AppColors.grey,
                        ),
                      ),
                      CupertinoButton(
                        child: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          controller.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  
  
  void updateDeliveryFormData({
    DeliveryType? selectedDeliveryType,
    int? palletValue,
    int? cartonsValue,
    bool? showSignature,
    String? temperature,
    String? serviceTime,
    String? lengthOfDelivery,
    String? receiverFirstName,
    String? receiverLastName,
    String? reasonpartialdelivery,
    String? orderRejectionReason,
    String? otherinfo,


  }) {
    if (selectedDeliveryType != null) {
      _selectedDeliveryType = selectedDeliveryType;
    }
    if (palletValue != null) {
      _palletValue = palletValue;
    }
    if (cartonsValue != null) {
      _cartonsValue = cartonsValue;
    }
    if (showSignature != null) {
      _showSignature = showSignature;
    }
    if (temperature != null) {
      _temperature = temperature;
    }
    if (serviceTime != null) {
      _serviceTime = serviceTime;
    }
    if (lengthOfDelivery != null) {
      _lengthOfDelivery = lengthOfDelivery;
    }
    if (receiverFirstName != null) {
      _receiverFirstName = receiverFirstName;
    }
    if (receiverLastName != null) {
      _receiverLastName = receiverLastName;
    }
    if (reasonpartialdelivery != null) {
      _reasonpartialdelivery = reasonpartialdelivery;
    }
     if (orderRejectionReason != null) {
      _orderRejectionReason = orderRejectionReason;
    }
    if ( otherinfo != null) {
      _otherinfo =  otherinfo;
    }
    notifyListeners();
  }

void updateTempValidity(bool isValid) {
    _isTempValid = isValid;
    notifyListeners();
  }

  void updateServiceTimeValidity(bool isValid) {
    _isServiceTimeValid = isValid;
    notifyListeners();
  }

  void updateLengthOfDeliveryValidity(bool isValid) {
    _isLengthOfDeliveryValid = isValid;
    notifyListeners();
  }

  void updateReceiverFirstNameValidity(bool isValid) {
    _isReceiverFirstNameValid = isValid;
    notifyListeners();
  }

  void updateReceiverLastNameValidity(bool isValid) {
    _isReceiverLastNameValid = isValid;
    notifyListeners();
  }

  void updateisReasonPartialValidity(bool isValid) {
    _isReasonPartialValid = isValid;
    notifyListeners();
  }
   void updateisReasonNoneValidity(bool isValid) {
    _isReasonNoneValid = isValid;
    notifyListeners();
  }


  void updateSelectedDeliveryType(DeliveryType type) {
    _selectedDeliveryType = type;
    notifyListeners();
  }

  void updatePalletValue(int value) {
    _palletValue = value;
    notifyListeners();
  }

  void updateCartonsValue(int value) {
    _cartonsValue = value;
    notifyListeners();
  }

  void updateSignatureData(Uint8List data) {
    _signatureData = data;
    notifyListeners();
  }

  void clearSignatureAndShowPopup(BuildContext context, SignatureController controller) {
    controller.clear();
    _showSignature = false;
    notifyListeners();
    showSignaturePopup(context, controller);
  }

   void updateOrderRejectionReason(String reason) {
    if (_selectedOrderRejectionReasons.contains(reason)) {
      _selectedOrderRejectionReasons.remove(reason);
    } else {
      _selectedOrderRejectionReasons.add(reason);
    }
    notifyListeners();
  }

   void clearOrderRejectionReasons() {
    _selectedOrderRejectionReasons.clear();
    notifyListeners();
  }

 
  

  void clearFormData() {
  _selectedDeliveryType = DeliveryType.full;
  _palletValue = 0;
  _cartonsValue = 0;
  _showSignature = false;
  _temperature = '';
  _serviceTime = '';
  _lengthOfDelivery = '';
  _receiverFirstName = '';
  _receiverLastName = '';
  _reasonpartialdelivery = '';
  _orderRejectionReason = '';
  _otherinfo = '';
  _selectedOrderRejectionReasons.clear();
  _isTempValid = false;
  _isServiceTimeValid = false;
  _isLengthOfDeliveryValid = false;
  _isReceiverFirstNameValid = false;
  _isReceiverLastNameValid = false;
  _isReasonPartialValid = false;
  _isReasonNoneValid = false;
  _images.clear();
  _base64Images.clear();
  _pictureSources.clear();
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

    removeImage({
    required XFile image,
  }) {
    _images.remove(image);
    int index = _images.indexOf(image);
    _base64Images.remove('picture${index + 1}');
    _pictureSources.remove('picture${index + 1}');
    notifyListeners();
  }

    void setShowSignature(bool value) {
    _showSignature = value;
    notifyListeners();
  }
}
 