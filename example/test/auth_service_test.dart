// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simple_graphql/simple_graphql.dart';
import 'package:simple_graphql_example/auth_service.dart';

class SimpleGraphQlMock extends Mock implements SimpleGraphQl {}

void main() {
  group('AuthService', () {
    late SimpleGraphQlMock client;

    setUp(() {
      client = SimpleGraphQlMock();
    });

    test('login mutation includes "username" and "password" variables',
        () async {
      final service = AuthService(client: client);

      when(
        () => client.query<LoginResponseDto>(
          query: any(named: 'query'),
          variables: any(named: 'variables'),
          resultBuilder: any(named: 'resultBuilder'),
        ),
      ).thenAnswer(
        (_) async => LoginResponseDto.fromJson(
          {'success': true, 'token': 'test_eyJhb....sw5c'},
        ),
      );

      await service.login(username: 'john_doe', password: '12345');

      final captured = verify(
        () => client.query<LoginResponseDto>(
          query: any(named: 'query'),
          variables: captureAny(named: 'variables'),
          resultBuilder: any(named: 'resultBuilder'),
        ),
      ).captured;

      /// Login mutation includes username and password variables.
      expect(captured[0].containsKey('username'), true);
      expect(captured[0].containsKey('password'), true);
    });

    test('login query should return a LoginResponseDTO object', () async {
      final service = AuthService(client: client);

      when(
        () => client.query<LoginResponseDto>(
          query: any(named: 'query'),
          variables: any(named: 'variables'),
          resultBuilder: any(named: 'resultBuilder'),
        ),
      ).thenAnswer(
        (_) async => LoginResponseDto.fromJson(
          {'success': true, 'token': 'test_eyJhb....sw5c'},
        ),
      );

      final response = await service.login(
        username: 'john_doe',
        password: '12345',
      );

      expect(response, isA<LoginResponseDto>());
    });

    test('should login successfully using correct credentials', () async {
      final service = AuthService(client: client);

      when(
        () => client.query<LoginResponseDto>(
          query: any(named: 'query'),
          variables: any(named: 'variables'),
          resultBuilder: any(named: 'resultBuilder'),
        ),
      ).thenAnswer(
        (_) async => LoginResponseDto.fromJson(
          {'success': true, 'token': 'test_eyJhb....sw5c'},
        ),
      );

      final response = await service.login(
        username: 'john_doe',
        password: '12345',
      );

      expect(response.success, true);
      expect(response.token, 'test_eyJhb....sw5c');
    });

    test('login should fail when incorrect credentials are sent', () async {
      final service = AuthService(client: client);

      when(
        () => client.query<LoginResponseDto>(
          query: any(named: 'query'),
          variables: any(named: 'variables'),
          resultBuilder: any(named: 'resultBuilder'),
        ),
      ).thenAnswer(
        (_) async => LoginResponseDto.fromJson(
          {'success': false, 'token': null},
        ),
      );

      final response = await service.login(
        username: 'john_doe',
        password: 'wrong password',
      );

      expect(response.success, false);
      expect(response.token, null);
    });
  });
}
