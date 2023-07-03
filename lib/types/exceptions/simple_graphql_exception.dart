/// {@template simple_gql_exception}
/// Exception thrown when an API call fails, either due to a network error, a
/// server error or a parameters error.
/// {@endtemplate}
class SimpleGqlException implements Exception {
  /// {@macro simple_gql_exception}
  const SimpleGqlException([this.message]);

  /// Error message.
  final String? message;
}
