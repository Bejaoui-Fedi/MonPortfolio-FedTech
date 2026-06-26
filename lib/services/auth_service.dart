import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/face_auth_js.dart' if (dart.library.io) '../utils/face_auth_stub.dart';


class AuthService extends ChangeNotifier {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  // Login via password from Supabase
  Future<bool> login(String password) async {
    try {
      final supabase = Supabase.instance.client;
      // Fetch the stored password from the profile table
      final profileData = await supabase.from('profile').select('admin_password').eq('id', 'main_profile').single();
      
      final String? storedPassword = profileData['admin_password'];
      
      // Fallback to admin123 if not set yet in DB
      final effectivePassword = storedPassword ?? 'admin123';

      if (password == effectivePassword) {
        _isAdmin = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login DB Fetch Error: $e');
      // If column doesn't exist yet or connection fails, fallback to 'admin123'
      // This ensures the user can still login to update their password later
      if (password == 'admin123') {
        _isAdmin = true;
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  Future<bool> authenticateWithLiveCamera() async {
    try {
      if (!kIsWeb) {
        debugPrint('Live face recognition is only supported on Web');
        return false;
      }

      // Step 1: Capture descriptor directly from camera feed via JS
      debugPrint('Starting biometric camera capture...');
      final List<double>? capturedDescriptor = await captureFaceFromCameraOnWeb();
      if (capturedDescriptor == null) {
        debugPrint('Biometric Error: Could not extract face descriptor from camera');
        return false;
      }
      debugPrint('Captured descriptor length: ${capturedDescriptor.length}');

      // Step 2: Fetch stored descriptor from Supabase
      debugPrint('Fetching enrolled biometric data from Supabase...');
      final supabase = Supabase.instance.client;
      final profileData = await supabase.from('profile').select('face_descriptor').eq('id', 'main_profile').single();
      
      final dynamic storedData = profileData['face_descriptor'];
      if (storedData == null) {
        debugPrint('Auth Error: No face descriptor enrolled for this user');
        return false;
      }

      // Handle both String (JSON) and List formats from Supabase
      List<double> storedDescriptor;
      if (storedData is String) {
        storedDescriptor = (jsonDecode(storedData) as List).map((e) => (e as num).toDouble()).toList();
      } else if (storedData is List) {
        storedDescriptor = storedData.map((e) => (e as num).toDouble()).toList();
      } else {
        debugPrint('Auth Error: Invalid face descriptor format in database');
        return false;
      }
      debugPrint('Stored descriptor length: ${storedDescriptor.length}');

      // Step 3: Calculate Euclidean distance
      if (capturedDescriptor.length != storedDescriptor.length) {
        debugPrint('Auth Error: Descriptor dimension mismatch (${capturedDescriptor.length} vs ${storedDescriptor.length})');
        return false;
      }

      final double distance = _euclideanDistance(capturedDescriptor, storedDescriptor);
      debugPrint('BIOMETRIC MATCH DISTANCE: $distance (Threshold: 0.6)');

      // Step 4: Compare with threshold
      if (distance < 0.6) {
        debugPrint('ACCESS GRANTED: Biometric match confirmed');
        _isAdmin = true;
        notifyListeners();
        return true;
      }

      debugPrint('ACCESS DENIED: Biometric match failed (distance too high)');
      return false;
    } catch (e) {
      debugPrint('Biometric System Failure: $e');
      return false;
    }
  }

  Future<bool> authenticateWithFace(String capturedUrl) async {
    try {
      if (!kIsWeb) {
        debugPrint('Face recognition is currently only supported on Web');
        return false;
      }

      // Step 1: Get descriptor from captured image
      final List<double>? capturedDescriptor = await getFaceDescriptorOnWeb(capturedUrl);
      if (capturedDescriptor == null) {
        debugPrint('Could not extract face descriptor from captured image');
        return false;
      }

      // Step 2: Fetch stored descriptor from Supabase
      final supabase = Supabase.instance.client;
      final profileData = await supabase.from('profile').select('face_descriptor').eq('id', 'main_profile').single();
      
      final dynamic storedData = profileData['face_descriptor'];
      if (storedData == null) {
        debugPrint('No face descriptor enrolled for this user');
        return false;
      }

      // Handle both String (JSON) and List formats from Supabase
      List<double> storedDescriptor;
      if (storedData is String) {
        storedDescriptor = (jsonDecode(storedData) as List).map((e) => (e as num).toDouble()).toList();
      } else if (storedData is List) {
        storedDescriptor = storedData.map((e) => (e as num).toDouble()).toList();
      } else {
        debugPrint('Invalid face descriptor format in database');
        return false;
      }

      // Step 3: Calculate Euclidean distance (matching PHP logic)
      final double distance = _euclideanDistance(capturedDescriptor, storedDescriptor);
      debugPrint('Face Match Distance: $distance');

      // Step 4: Compare with threshold (0.6 matching face-api.js and user request)
      if (distance < 0.6) {
        _isAdmin = true;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Face Auth Error: $e');
      return false;
    }
  }

  /// Calculates the Euclidean distance between two descriptors.
  /// Matches the logic in the provided PHP controller.
  double _euclideanDistance(List<double> desc1, List<double> desc2) {
    if (desc1.length != desc2.length) {
      return 1.0;
    }

    double sum = 0;
    for (int i = 0; i < desc1.length; i++) {
      sum += pow(desc1[i] - desc2[i], 2);
    }

    return sqrt(sum);
  }

  /// Enroll a face by saving its descriptor to Supabase
  Future<bool> enrollFace(String imageUrl) async {
    try {
      if (!kIsWeb) return false;

      final descriptor = await getFaceDescriptorOnWeb(imageUrl);
      if (descriptor == null) return false;

      final supabase = Supabase.instance.client;
      await supabase.from('profile').update({
        'face_descriptor': descriptor,
      }).eq('id', 'main_profile');

      return true;
    } catch (e) {
      debugPrint('Enroll Face Error: $e');
      return false;
    }
  }

  /// Enroll a face using the live webcam stream directly
  Future<bool> enrollWithLiveCamera() async {
    try {
      if (!kIsWeb) return false;

      final descriptor = await captureFaceFromCameraOnWeb();
      if (descriptor == null) return false;

      final supabase = Supabase.instance.client;
      await supabase.from('profile').update({
        'face_descriptor': descriptor,
      }).eq('id', 'main_profile');

      return true;
    } catch (e) {
      debugPrint('Live Enroll Face Error: $e');
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics({String? capturedUrl, String? referenceUrl}) async {
    // Keep existing biometric method for mobile, but use our new face logic for web
    if (kIsWeb && capturedUrl != null) {
      return await authenticateWithFace(capturedUrl);
    }
    
    try {

      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        debugPrint('Authentication not supported on this device');
        return false;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à la console admin',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        _isAdmin = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Biometric Error: $e');
      return false;
    }
    return false;
  }

  void logout() {
    _isAdmin = false;
    notifyListeners();
  }
}

