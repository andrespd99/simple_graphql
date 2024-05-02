abstract class IDeviceStorageApi {
  /// Stores the provided [value] under the given [key] name.
  Future<void> setValue({
    required String key,
    required String value,
  });

  /// Returns the stored value with the provided [key].
  ///
  /// Returns null if there is no value stored with the provided [key].
  Future<String?> getValue(String key);

  /// Clears the stored value with the provided [key].
  Future<void> deleteValue(String key);
}
