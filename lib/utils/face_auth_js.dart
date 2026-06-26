import 'dart:js_interop';

@JS()
external JSPromise<JSBoolean> verifyFace(JSString capturedImageUrl, JSString referenceImageUrl);

@JS()
external JSPromise<JSArray<JSNumber>?> getFaceDescriptor(JSString imageUrl);

@JS()
external JSPromise<JSArray<JSNumber>?> captureFaceFromCamera();

Future<bool> verifyFaceOnWeb(String capturedUrl, String referenceUrl) async {
  try {
    final result = await verifyFace(capturedUrl.toJS, referenceUrl.toJS).toDart;
    return result.toDart;
  } catch (e) {
    print('JS Error during face verification: $e');
    return false;
  }
}

Future<List<double>?> getFaceDescriptorOnWeb(String imageUrl) async {
  try {
    final JSArray<JSNumber>? result = await getFaceDescriptor(imageUrl.toJS).toDart;
    if (result == null) return null;
    
    return result.toDart.map((e) => e.toDartDouble).toList();
  } catch (e) {
    print('JS Error during face descriptor extraction: $e');
    return null;
  }
}

Future<List<double>?> captureFaceFromCameraOnWeb() async {
  try {
    final JSArray<JSNumber>? result = await captureFaceFromCamera().toDart;
    if (result == null) return null;
    
    return result.toDart.map((e) => e.toDartDouble).toList();
  } catch (e) {
    print('JS Error during camera capture: $e');
    return null;
  }
}
