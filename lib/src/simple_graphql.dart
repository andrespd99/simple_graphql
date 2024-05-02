import 'dart:developer';

import 'package:graphql/client.dart';
import 'package:meta/meta.dart';
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
    required String apiUrl,
    Map<String, String>? headers,
    @Deprecated('Use `authHeaderKey` instead of `headerKey`') String? headerKey,
    String authHeaderKey = 'Authorization',
    String? token,
  }) {
    _apiUrl = apiUrl;
    final httpLink = HttpLink(
      apiUrl,
      defaultHeaders: headers ?? {},
    );

    final authLink = AuthLink(
      headerKey: headerKey ?? authHeaderKey,
      getToken: () async => token,
    );

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
  }

  static const _source = 'SimpleGraphQl';

  late final String _apiUrl;

  /// GraphQLClient instance used on [query] and [mutation] methods.
  ///
  /// Change this instance if you want to use a different client, or need to
  /// change the headers or the link.
  late GraphQLClient client;

  /// Updates the token used in the authorization header on queries and
  /// mutations.
  void setToken({
    required String token,
    String? authHeaderKey = 'Authorization',
  }) {
    client.copyWith(
      link: AuthLink(
        headerKey: authHeaderKey ?? 'Authorization',
        getToken: () async => token,
      ),
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
  /// Throws a [SimpleGqlException] if the mutation fails.
  Future<T?> query<T>({
    required String query,
    T Function(Map<String, dynamic> data)? resultBuilder,
    Map<String, String>? headers,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    Duration? pollInterval,
  }) async {
    try {
      // ignore: no_leading_underscores_for_local_identifiers
      var _client = client;

      if (headers?.isNotEmpty ?? false) {
        final httpLink = HttpLink(
          _apiUrl,
          defaultHeaders: headers!,
        );

        _client = client.copyWith(
          link: client.link.concat(httpLink),
        );
      }

      final options = QueryOptions(
        document: gql(query),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        errorPolicy: errorPolicy,
      );

      final res = await _client.query(options);

      if (res.hasException) {
        handleException(res.exception!);
      }

      if (resultBuilder != null) {
        return resultBuilder(res.data ?? <String, dynamic>{});
      }

      return null;
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
  /// Throws [SimpleGqlException] if query fails.
  Future<T?> mutation<T>({
    required String mutation,
    T Function(Map<String, dynamic> data)? resultBuilder,
    Map<String, String>? headers,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
  }) async {
    try {
      // ignore: no_leading_underscores_for_local_identifiers
      var _client = client;

      if (headers?.isNotEmpty ?? false) {
        final httpLink = HttpLink(
          _apiUrl,
          defaultHeaders: headers!,
        );

        _client = client.copyWith(
          link: client.link.concat(httpLink),
        );
      }
      final options = MutationOptions(
        document: gql(mutation),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        errorPolicy: errorPolicy,
      );

      final res = await _client.mutate(options);

      if (res.hasException) {
        handleException(res.exception!);
      }

      if (resultBuilder != null) {
        return resultBuilder(res.data ?? <String, dynamic>{});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Handles exceptions thrown by the GraphQL library.
  @protected
  void handleException(OperationException exception) {
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
