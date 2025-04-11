import 'package:graphql/client.dart';
import 'package:meta/meta.dart';

/// Represents a simplified version of a GraphQL query result.
class SimpleQueryResult<T extends Object?> {
  /// Creates a SimpleQueryResult with the given [data] and [exception].
  SimpleQueryResult({
    this.data,
    this.exception,
  });

  /// Creates a SimpleQueryResult from a graphql [QueryResult] object.
  @protected
  factory SimpleQueryResult.fromQueryResult(
    QueryResult queryResult,
  ) {
    return SimpleQueryResult(
      data: queryResult.data != null ? queryResult.data!['data'] as T : null,
      exception: queryResult.exception,
    );
  }

  /// The data returned from the GraphQL query.
  final T? data;

  /// The exception that occurred during the query, if any.
  /// If the query was successful, this will be null.
  final Object? exception;
}
