import 'package:simple_graphql/src/device_storage/secure_storage_api.dart';

/// Enum with the most common HTTP headers.
enum HttpHeaderType {
  /// `Content-Type` header.
  contentType('Content-Type'),

  /// `Accept` header.
  accept('Accept'),

  /// `Accept-Language` header.
  acceptLanguage('Accept-Language'),

  /// `X-Token` header.
  xToken('x-token'),

  /// `X-Refresh-Token` header.
  xRefreshToken('x-refresh-token'),

  /// `Authorization` header.
  authorization('Authorization');

  const HttpHeaderType(this.key);

  /// The key to be used in the headers map.
  final String key;
}

///
class HttpHeadersInjector {
  ///
  const HttpHeadersInjector({
    required SecureStorageApi secureStorageApi,
  }) : _storage = secureStorageApi;

  final SecureStorageApi _storage;

  /// Retrieves the header value.
  ///
  /// You should use the [HttpHeaderType] values when using common headers.
  Future<String?> getHeader(String key) async {
    return _storage.getValue(key);
  }

  /// Stores the header-value pair.
  ///
  /// You should use the [HttpHeaderType] values when using common headers.
  Future<void> setHeader(String key, String value) async {
    return _storage.setValue(key: key, value: value);
  }

  /// Deletes the header value.
  ///
  /// You should use the [HttpHeaderType] values when using common headers.
  Future<void> deleteHeaderValue(String key) async {
    return _storage.deleteValue(key);
  }

  /// Builds the headers using the stored values and the extra headers. The
  /// extra headers have priority over the stored values but will not change
  /// them.
  Future<Map<String, String>> headers({Map<String, String>? extra}) async {
    final acceptLanguage = await getHeader(HttpHeaderType.acceptLanguage.key) ??
        extra?[HttpHeaderType.acceptLanguage.key];
    final authToken = extra?[HttpHeaderType.authorization.key] ??
        await getHeader(HttpHeaderType.authorization.key);
    final xToken = extra?[HttpHeaderType.xToken.key] ??
        await getHeader(HttpHeaderType.xToken.key);
    final accept = extra?[HttpHeaderType.accept.key] ?? 'application/json';
    final contentType =
        extra?[HttpHeaderType.contentType.key] ?? 'application/json';

    return {
      HttpHeaderType.accept.key: accept,
      HttpHeaderType.contentType.key: contentType,
      if (acceptLanguage != null)
        HttpHeaderType.acceptLanguage.key: acceptLanguage,
      if (xToken != null && xToken.isNotEmpty)
        HttpHeaderType.xToken.key: xToken,
      if (authToken != null && authToken.isNotEmpty)
        HttpHeaderType.authorization.key: authToken,
    };
  }
}
