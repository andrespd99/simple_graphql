import 'dart:developer';

import 'package:graphql/client.dart';
import 'package:simple_graphql/types/exceptions/exceptions.dart';

/// {@template graphql_controller}

/// A class that exposes simplified methods for query petitioning with graphql
/// library.
///
/// If authorization is required, pass the `token` parameter. By default, the
/// header key is `Authorization`, but you can change it with the `headerKey`
/// parameter.
///
/// `token` is the token to be used in the authorization header.
/// Must include prefixes, e.g. `Bearer $token`
/// {@endtemplate}
class SimpleGraphQl {
  /// {@macro graphql_controller}
  SimpleGraphQl({
    required String apiUrl,
    Map<String, String>? headers,
    String headerKey = 'Authorization',
    String? token,
  }) {
    final httpLink = HttpLink(
      apiUrl,
      defaultHeaders: headers ?? {},
    );

    final authLink = AuthLink(
      headerKey: headerKey,
      getToken: () async => token,
    );

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
  }

  static const _source = 'SimpleGraphQl';

  late final GraphQLClient _client;

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
  Future<T> query<T>({
    required String query,
    required T Function(Map<String, dynamic> data) resultBuilder,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    Duration? pollInterval,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(query),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        errorPolicy: errorPolicy,
      );

      final res = await _client.query(options);

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
  /// Throws [SimpleGqlException] if query fails.
  Future<T> mutation<T>({
    required String mutation,
    required T Function(Map<String, dynamic> data) resultBuilder,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(mutation),
        variables: variables ?? <String, dynamic>{},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        errorPolicy: errorPolicy,
      );

      final res = await _client.mutate(options);

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
