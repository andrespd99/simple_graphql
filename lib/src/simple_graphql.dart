import 'dart:developer';

import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:simple_graphql/types/exceptions/exceptions.dart';

export 'package:graphql/src/core/policies.dart';
export 'package:graphql/src/links/links.dart';
export 'package:simple_graphql/types/exceptions/exceptions.dart';

/// {@template graphql_controller}
/// A class that exposes simplified methods for query petitioning with graphql
/// library.
///
/// If authorization is required, pass the `token` parameter.
///
/// The `token` is used in the authorization header. Must include prefixes,
/// e.g. `Bearer $token`. By default, the header key is `Authorization`, but can
/// be changed in the `authHeaderKey` parameter.
/// {@endtemplate}
class SimpleGraphQl {
  /// {@macro graphql_controller}
  SimpleGraphQl({
    @Deprecated('Use `authHeaderKey` instead of `headerKey`') String? headerKey,
    String authHeaderKey = 'Authorization',
    String? token,
    GraphQLCache? cache,
    http.Client? httpClient,
  })  : _cache = cache ?? GraphQLCache(),
        _httpClient = httpClient ?? http.Client(),
        authHeader = (
          authKey: headerKey ?? authHeaderKey,
          token: token,
        );

  static const _source = 'SimpleGraphQl';

  final GraphQLCache _cache;
  final http.Client _httpClient;

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
  /// Throws a [SimpleGqlException] if the mutation fails.
  Future<T> query<T>({
    required String apiUrl,
    required String query,
    required T Function(Map<String, dynamic> data) resultBuilder,
    Map<String, String>? headers,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    Duration? pollInterval,
    http.Client? httpClient,
  }) async {
    try {
      final httpLink = HttpLink(
        apiUrl,
        httpClient: httpClient ?? _httpClient,
        defaultHeaders: headers ?? {},
      );

      final authLink = AuthLink(
        headerKey: authHeader.authKey,
        getToken: () async => authHeader.token,
      );

      final client = GraphQLClient(
        cache: _cache,
        link: authLink.concat(httpLink),
      );

      final options = QueryOptions(
        document: gql(query),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        errorPolicy: errorPolicy,
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
  /// Throws [SimpleGqlException] if query fails.
  Future<T> mutation<T>({
    required String apiUrl,
    required String mutation,
    required T Function(Map<String, dynamic> data) resultBuilder,
    Map<String, String>? headers,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    http.Client? httpClient,
  }) async {
    try {
      final httpLink = HttpLink(
        apiUrl,
        httpClient: httpClient ?? _httpClient,
        defaultHeaders: headers ?? {},
      );

      final authLink = AuthLink(
        headerKey: authHeader.authKey,
        getToken: () async => authHeader.token,
      );

      final client = GraphQLClient(
        cache: _cache,
        link: authLink.concat(httpLink),
      );

      final options = MutationOptions(
        document: gql(mutation),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        errorPolicy: errorPolicy,
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
