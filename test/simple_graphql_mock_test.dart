import 'package:mocktail/mocktail.dart';
import 'package:simple_graphql/simple_graphql.dart';
import 'package:test/test.dart';

class SimpleGraphQlMock extends Mock implements SimpleGraphQl {}

void main() {
  setUpAll(() {
    registerFallbackValue(SimpleGraphQlMock());
  });

  group('SimpleGraphQlMock handles queries', () {
    test('should login successfully using correct credentials', () async {
      const query = r'''
        query Login($username: String, $password, String) { 
          login(username: $username, password: $password) {
            success
            token
          }
        }''';

      final client = SimpleGraphQlMock();

      final variables = {'username': 'john_doe', 'password': '12345'};

      when(
        () => client.query<Map<String, dynamic>>(
          query: any(named: 'query'),
          variables: any(named: 'variables'),
        ),
      ).thenAnswer(
        (_) async =>
            <String, dynamic>{'success': true, 'token': 'test_eyJhb....sw5c'},
      );

      final response = await client.query<Map<String, dynamic>>(
        variables: variables,
        query: query,
      );

      final captured = verify(
        () => client.query<Map<String, dynamic>>(
          query: captureAny(named: 'query'),
          variables: captureAny(named: 'variables'),
        ),
      ).captured.toList();

      // captured List contains the variables given.
      expect(captured, contains(variables));

      final capturedVariables = captured[1] as Map<String, dynamic>;

      // captured Map contains the 'username' and 'password' variables
      expect(capturedVariables.containsKey('username'), true);
      expect(capturedVariables.containsKey('password'), true);

      expect(
        response,
        {
          'success': true,
          'token': 'test_eyJhb....sw5c',
        },
      );
    });
  });
}
