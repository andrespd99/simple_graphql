import 'dart:developer';

import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:simple_graphql/types/exceptions/exceptions.dart';
import 'package:simple_graphql/types/simple_query_result.dart';

export 'package:graphql/src/core/policies.dart';
export 'package:graphql/src/links/links.dart';
export 'package:simple_graphql/types/exceptions/exceptions.dart';

/// Different ways how the headers injection will be handled by this function
enum HeadersInjectionBehavior {
  /// Merges the given headers with the headers set on instance level.
  merge,

  /// Will ignore any headers configured on instance level and will only use
  /// the headers passed to the function.
  override;
}

/// {@template graphql_controller}
/// A class that exposes simplified methods for query petitioning with graphql
/// library.
///
/// `apiUrl` is the endpoint URL. Must include scheme and path
/// (including `/graphql` path). The `apiUrl` can be set on the constructor
/// or later by assigning a new value to the `apiUrl` property. If either
/// `query` or `mutation` methods are called before assigning an `apiUrl` value,
/// an exception will be thrown.
///
/// If authorization is required, pass the `token` parameter.
///
/// The `token` is used in the authorization header. Must include prefixes,
/// e.g. `Bearer $token`. By default, the header key is `Authorization`, but can
/// be changed in the `authHeaderKey` parameter.
///
/// You can pass an additional [Client] that will be used on every query and
/// mutation call if you need to extent the functionality further.
///
/// If `defaultHeaders` is declared, it will be used on every query and
/// mutation call from this [SimpleGraphQL] instance. They will, by default, be
/// merged with any headers passed to the [query] or [mutation] methods.
/// {@endtemplate}
class SimpleGraphQL {
  /// {@macro graphql_controller}
  SimpleGraphQL({
    String? apiUrl,
    String? websocketUrl,
    @Deprecated('Use `authHeaderKey` instead of `headerKey`') String? headerKey,
    String authHeaderKey = 'Authorization',
    String? token,
    // GraphQLCache? cache,
    http.Client? httpClient,
    Map<String, String>? defaultHeaders,
  })  : apiUrl = apiUrl ?? '',
        websocketUrl = websocketUrl ?? '',
        // _cache = cache,
        _httpClient = httpClient ?? http.Client(),
        defaultHeaders = defaultHeaders ?? {},
        authHeader = (
          authKey: headerKey ?? authHeaderKey,
          token: token,
        );

  static const _source = 'SimpleGraphQl';

  // final GraphQLCache? _cache;
  final http.Client _httpClient;

  /// Headers map that will be used on every query and mutation.
  final Map<String, String> defaultHeaders;

  /// Endpoint URL. Must include scheme and path (including `/graphql` path),
  /// e.g. `https://example.com/graphql`
  String apiUrl;

  /// Websocket URL.
  String websocketUrl;

  /// Authorization header. The first value is the header key, and the second
  /// is the token.
  ({String authKey, String? token}) authHeader;

  /// Updates the token used in the authorization header on queries and
  /// mutations.
  void setToken({
    required String token,
    String? authHeaderKey,
  }) {
    authHeader = (
      authKey: authHeaderKey ?? authHeader.authKey,
      token: token,
    );
  }

  /// Loads GraphQL query results.
  ///
  /// `query` is a GraphQL query as a string.
  ///
  /// `resultBuilder` converts the server response in an object and returns
  /// it.
  ///
  /// You can pass variables to the query via the `variables` parameter. The
  /// name of the variable must match the name of the variable in the query.
  ///
  /// `pollInteval` is the time interval on which this query should be
  /// re-fetched from the server
  ///
  /// `null` results should be handled by the caller.
  ///
  /// You can specify the `httpClient` to override the default client of this
  /// instance.
  ///
  /// If the `headers` argument is passed, it will, by default, be merged with
  /// any current headers configuration. They will be consumed on this call but
  /// will not be stored for further use. If you require the new headers to be
  /// saved for following calls, consider updating [headers] variable instead.
  ///
  /// You can override any headers set on this instance by setting
  /// `headersInjectionBehaviour` to [HeadersInjectionBehavior.override].
  ///
  /// Throws a [SimpleGqlException] if the mutation fails.
  Future<T> query<T>({
    required String query,
    required T Function(Map<String, dynamic> data) resultBuilder,
    http.Client? httpClient,
    String? authHeaderKey,
    String? token,
    HeadersInjectionBehavior headersInjectionBehavior =
        HeadersInjectionBehavior.merge,
    Map<String, String>? headers,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    Duration? pollInterval,
    Duration? queryRequestTimeout,
  }) async {
    if (apiUrl.isEmpty) {
      throw const NoUrlException();
    }
    try {
      final defaultHeaders = (headersInjectionBehavior ==
              HeadersInjectionBehavior.override)
          ? headers ?? {}
          : {...this.defaultHeaders}
        ..addAll(headers ?? {});

      final httpLink = HttpLink(
        apiUrl,
        httpClient: httpClient ?? _httpClient,
        defaultHeaders: defaultHeaders,
      );

      final authLink = AuthLink(
        headerKey: authHeaderKey ?? authHeader.authKey,
        getToken: () async => token ?? authHeader.token,
      );

      final client = GraphQLClient(
        cache: GraphQLCache(),
        // cache: _cache ?? GraphQLCache(),
        link: authLink.concat(httpLink),
      );

      final options = QueryOptions(
        document: gql(query),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        pollInterval: pollInterval,
        errorPolicy: errorPolicy,
        queryRequestTimeout: queryRequestTimeout,
      );

      final res = await client.query(options);

      if (res.hasException) {
        _handleException(res.exception!);
      }

      return resultBuilder(res.data ?? <String, dynamic>{});
    } catch (e) {
      rethrow;
    }
  }

  /// Loads GraphQL mutation results.
  ///
  /// `mutation` is a GraphQL mutation query as a string.
  ///
  /// `resultBuilder` converts the server response in an object and returns
  /// it.
  ///
  /// `null` results should be handled in the function that calls this.
  ///
  /// You can specify the `httpClient` to override the default client of this
  /// instance.
  ///
  /// If the `headers` argument is passed, it will, by default, be merged with
  /// any current headers configuration. They will be consumed on this call but
  /// will not be stored for further use. If you require the new headers to be
  /// saved for following calls, consider updating [headers] variable instead.
  ///
  /// You can override any headers set on this instance by setting
  /// `headersInjectionBehaviour` to [HeadersInjectionBehavior.override].
  ///
  /// Throws [SimpleGqlException] if query fails.
  Future<T> mutation<T>({
    required String mutation,
    required T Function(Map<String, dynamic> data) resultBuilder,
    http.Client? httpClient,
    String? authHeaderKey,
    String? token,
    HeadersInjectionBehavior headersInjectionBehaviour =
        HeadersInjectionBehavior.merge,
    Map<String, String>? headers,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    Duration? queryRequestTimeout,
  }) async {
    if (apiUrl.isEmpty) {
      throw const NoUrlException();
    }
    try {
      final defaultHeaders = (headersInjectionBehaviour ==
              HeadersInjectionBehavior.override)
          ? headers ?? {}
          : {...this.defaultHeaders}
        ..addAll(headers ?? {});

      final httpLink = HttpLink(
        apiUrl,
        httpClient: httpClient ?? _httpClient,
        defaultHeaders: defaultHeaders,
      );

      final authLink = AuthLink(
        headerKey: authHeaderKey ?? authHeader.authKey,
        getToken: () async => token ?? authHeader.token,
      );

      final client = GraphQLClient(
        cache: GraphQLCache(),
        // cache: _cache ?? GraphQLCache(),
        link: authLink.concat(httpLink),
      );

      final options = MutationOptions(
        document: gql(mutation),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        errorPolicy: errorPolicy,
        queryRequestTimeout: queryRequestTimeout,
      );

      final res = await client.mutate(options);

      if (res.hasException) {
        _handleException(res.exception!);
      }

      return resultBuilder(res.data ?? <String, dynamic>{});
    } catch (e) {
      rethrow;
    }
  }

  /// Loads GraphQL mutation results.
  ///
  /// `subscription` is a GraphQL subscription query as a string.
  ///
  /// `streamMapper` is the mapper used on the incoming stream of data from
  /// graphql.
  ///
  /// `null` results should be handled in the function that calls this.
  ///
  /// You can specify the `httpClient` to override the default client of this
  /// instance.
  ///
  /// If the `headers` argument is passed, it will, by default, be merged with
  /// any current headers configuration. They will be consumed on this call but
  /// will not be stored for further use. If you require the new headers to be
  /// saved for following calls, consider updating [headers] variable instead.
  ///
  /// You can override any headers set on this instance by setting
  /// `headersInjectionBehaviour` to [HeadersInjectionBehavior.override].
  ///
  /// Throws [SimpleGqlException] if query fails.
  Stream<SimpleQueryResult<T>> subcribe<T>({
    required String subscription,
    required T Function(Map<String, dynamic> data) resultBuilder,
    String? authHeaderKey,
    String? token,
    HeadersInjectionBehavior headersInjectionBehaviour =
        HeadersInjectionBehavior.merge,
    Map<String, String>? headers,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    http.Client? httpClient,
  }) {
    if (apiUrl.isEmpty) {
      throw const NoUrlException();
    }
    if (websocketUrl.isEmpty) {
      throw const NoWsUrlException();
    }
    try {
      final defaultHeaders = (headersInjectionBehaviour ==
              HeadersInjectionBehavior.override)
          ? headers ?? {}
          : {...this.defaultHeaders}
        ..addAll(headers ?? {});

      final httpLink = HttpLink(
        apiUrl,
        httpClient: httpClient ?? _httpClient,
        defaultHeaders: defaultHeaders,
      );

      final authLink = AuthLink(
        headerKey: authHeaderKey ?? authHeader.authKey,
        getToken: () async => token ?? authHeader.token,
      );

      final wsLink = WebSocketLink(
        websocketUrl,
        config: SocketClientConfig(
          initialPayload: () async {
            return {
              ...defaultHeaders,
              authHeaderKey ?? authHeader.authKey: token ?? authHeader.token,
            };
          },
        ),
        subProtocol: GraphQLProtocol.graphqlTransportWs,
      );

      final socketLink = wsLink.concat(httpLink);

      final finalLink = Link.split(
        (request) => request.isSubscription,
        socketLink,
        authLink,
      );

      final client = GraphQLClient(
        cache: GraphQLCache(),
        // cache: _cache ?? GraphQLCache(),
        link: finalLink,
      );

      final options = SubscriptionOptions(
        document: gql(subscription),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        errorPolicy: errorPolicy,
      );

      final res = client.subscribe(options);

      return res.map(
        (result) => SimpleQueryResult.fromQueryResult(result, resultBuilder),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Handles exceptions thrown by the GraphQL library.
  void _handleException(OperationException exception) {
    if (exception.linkException != null) {
      log(
        '❌ [LinkException] thrown when executing query or mutation',
        name: _source,
        error: exception,
      );
      throw const SimpleGqlException();
    }
    if (exception.graphqlErrors.isEmpty) {
      log(
        '❌ [OperationException] thrown but no GraphQL errors were found',
        name: _source,
        error: exception,
      );
      throw const SimpleGqlException();
    }

    log(
      '❌ [OperationException] thrown when executing query or mutation',
      name: _source,
      error: exception,
    );
    throw SimpleGqlException(exception.graphqlErrors.first.message);
  }
}
