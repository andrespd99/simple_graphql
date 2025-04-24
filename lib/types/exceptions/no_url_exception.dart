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

class NoWsUrlException extends SimpleGqlException {
  /// {@macro no_url_exception}
  const NoWsUrlException()
      : super(
          'Tried to make a subscription call before setting the websocketUrl '
          'property. Try setting SimpleGraphQL.websocketUrl property first.',
        );
}
