import 'package:simple_graphql/types/exceptions/simple_graphql_exception.dart';

/// {@template no_url_exception}
/// Exception thrown when trying to make a call before setting the
/// `SimpleGraphQL.apiUrl` property.
/// {@endtemplate}
class NoUrlException extends SimpleGqlException {
  /// {@macro no_url_exception}
  const NoUrlException()
      : super(
          'Tried to make a call before setting the apiUrl property. '
          'Try setting SimpleGraphQL.apiUrl property first.',
        );
}
