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

  void clearSignatureAndShowPopup(BuildContext context, SignatureController controller) {
    controller.clear();
    _signatureData = null;
    _showSignature = true;
    showSignaturePopup(context, controller);
    notifyListeners();
    
  }
    void lpc(BuildContext context, SignatureController controller) {
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

  void updateSelectedDeliveryType(DeliveryType type) {
    _selectedDeliveryType = type;
    notifyListeners();
  }

  void updateSignatureData(Uint8List data) {
    _signatureData = data;
    notifyListeners();
  }

  void setShowSignature(bool value) {
    _showSignature = value;
    notifyListeners();
  }


  void updateOrderRejectionReason(String reason) {
    _selectedOrderRejectionReasons.clear();
    _selectedOrderRejectionReasons.add(reason);
    data['rejection_reason'] = reason;
    notifyListeners();
  }

  void clearOrderRejectionReasons() {
    _selectedOrderRejectionReasons.clear();
    notifyListeners();
  }
 void resetSignatureState() {
    _showSignature = false;
    _signatureData = null;
    notifyListeners();
  }
  void showSignaturePopup(BuildContext context, SignatureController controller) {
    showDialog(
      barrierDismissible: false,
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
                           controller.clear();
                          context.read<ProofOfDeliveryProvider>().resetSignatureState();
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
                        onPressed: () async {
                          final bytes = await controller.toPngBytes();
                          if (bytes != null) {
                            context.read<ProofOfDeliveryProvider>().updateSignatureData(bytes);
                            Navigator.pop(context);
                          }
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

  void setDeviceInfo(Map<String, dynamic> deviceInfo) {
    _data['device'] = deviceInfo;
    notifyListeners();
    print("Device madarcghd: $_data");
  }
}
