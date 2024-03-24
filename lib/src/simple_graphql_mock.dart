import 'package:graphql/client.dart';
import 'package:simple_graphql/simple_graphql.dart';

/// {@template SimpleGraphQlMock}
/// SimpleGraphQlMock mock for queries
/// {@endtemplate}
class SimpleGraphQlMock extends SimpleGraphQl {
  /// {@macro SimpleGraphQlMock}
  SimpleGraphQlMock({
    required super.apiUrl,
    required MockGraphQlClientHandler handler,
    super.headers,
    super.headerKey = 'Authorization',
    super.token,
  })  : _token = token,
        _handler = handler,
        super();

  final String? _token;

  /// The handler for queries
  final MockGraphQlClientHandler _handler;

  @override
  Future<T> query<T>({
    required String query,
    required T Function(Map<String, dynamic> data) resultBuilder,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    Duration? pollInterval,
  }) async {
    final res = _handler(
      query,
      variables,
      _token,
    );

    if (res.hasException) {
      super.handleException(res.exception!);
    }

    return resultBuilder(res.data ?? <String, dynamic>{});
  }

  @override
  Future<T> mutation<T>({
    required String mutation,
    required T Function(Map<String, dynamic> data) resultBuilder,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    CacheRereadPolicy? cacheRereadPolicy,
    ErrorPolicy? errorPolicy,
    Duration? pollInterval,
  }) async {
    final res = _handler(
      mutation,
      variables,
      _token,
    );

    if (res.hasException) {
      handleException(res.exception!);
    }

    return resultBuilder(res.data ?? <String, dynamic>{});
  }
}

// /// A handler function that s
// typedef MockGraphQlClientHandler = Map<String, dynamic> Function({
//   required String operation,
//   Map<String, dynamic>? variables,
//   String? token,
// });

/// A handler function that s
typedef MockGraphQlClientHandler = QueryResult Function(
  String operation,
  Map<String, dynamic>? variables,
  String? token,
);

/// Creates a mock `QueryResult` object for testing purposes.
class MockQueryResult {
  /// Creates a mock `QueryResult` object for testing purposes.
  ///
  /// This constructor allows you to optionally specify various properties
  /// to simulate different query outcomes in your tests.
  ///
  /// * **data:** (Optional) The response data to include in the mock result.
  ///   This is typically used for simulating successful responses.
  /// * **variables:** (Optional) The variables used in the GraphQL operation
  ///   (can be omitted if not relevant to your test).
  /// * **options:** (Optional) The QueryOptions used for the query
  ///   (can be omitted if not relevant to your test).
  /// * **operation:** (Optional) The GraphQL operation string
  ///   (can be omitted if not relevant to your test).
  /// * **exception:** (Optional) An `OperationException` instance to simulate
  ///   an error in the query execution. This is required for tests that
  ///   need to verify error handling behavior.
  /// * **source:** (Optional) The source of the mock result (defaults to
  ///   QueryResultSource.network).
  static QueryResult test({
    /// Required for success responses
    Map<String, dynamic>? data,
    // Required for error tests
    OperationException? exception,
    Map<String, dynamic>? variables,
    QueryOptions? options,
    String? operation,
    QueryResultSource source = QueryResultSource.network,
  }) =>
      QueryResult(
        data: data ?? {},
        options: options ??
            QueryOptions(
              document: gql(operation ?? ''),
              variables: variables ?? <String, dynamic>{},
            ),
        exception: exception,
        source: QueryResultSource.network,
      );
}
