import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageManger {
  LocalStorageManger._();

  static const _andriodOptions =
      AndroidOptions(encryptedSharedPreferences: true);

  static const _iosOptions =
      IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  static const FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(iOptions: _iosOptions, aOptions: _andriodOptions);

  static Future<void> setString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String> getString(String key) async {
    return await _secureStorage.read(key: key) ?? '';
  }

  static Future<void> removeString(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> removeAllString(String key) async {
    await _secureStorage.deleteAll();
  }
  
}
