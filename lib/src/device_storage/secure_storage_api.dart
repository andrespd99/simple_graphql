import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple_graphql/src/device_storage/device_storage_api.dart';

class SecureStorageApi implements IDeviceStorageApi {
  const SecureStorageApi();

  @override
  Future<void> deleteValue(String key) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: key);
  }

  @override
  Future<String?> getValue(String key) async {
    const storage = FlutterSecureStorage();
    return storage.read(key: key);
  }

  @override
  Future<void> setValue({required String key, required String value}) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: key, value: value);
  }
}
