import 'package:graphql/client.dart';
import 'package:simple_graphql/simple_graphql.dart';
import 'package:simple_graphql/src/simple_graphql_mock.dart';
import 'package:test/test.dart';

// void main() {

// }

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  const apiUrl = 'https://api.myapi.example/graphql';

  group('SimpleGraphQlMock handles queries', () {
    test('should handles a query with a success response data', () async {
      final responseExpected = {'field1': 'value1', 'field2': 'value2'};
      final client = SimpleGraphQlMock(
        apiUrl: apiUrl,
        handler: (operation, variables, token) {
          return MockQueryResult.test(data: responseExpected);
        },
      );
      final response = await client.query(
        query: 'query ExampleQuery { data }',
        resultBuilder: (data) => data,
      );

      expect(
        response,
        responseExpected,
      );
    });

    test('should handles a query with an Exception', () async {
      final client = SimpleGraphQlMock(
        apiUrl: apiUrl,
        handler: (operation, variables, token) {
          return MockQueryResult.test(
            exception: OperationException(),
          );
        },
      );

      expect(
        () => client.query(
          query: 'query ExampleQuery { data }',
          resultBuilder: (data) => data,
        ),
        throwsA(isA<SimpleGqlException>()),
      );
    });

    test('should handles a query with a GraphQlError with message', () async {
      const errorMessageExpected = 'Ups, sorry';
      final client = SimpleGraphQlMock(
        apiUrl: apiUrl,
        handler: (operation, variables, token) {
          return MockQueryResult.test(
            exception: OperationException(
              graphqlErrors: [
                const GraphQLError(message: errorMessageExpected),
              ],
            ),
          );
        },
      );

      try {
        await client.query(
          query: 'query ExampleQuery { data }',
          resultBuilder: (data) => data,
        );
      } catch (e) {
        expect(e, isA<SimpleGqlException>());
        if (e is SimpleGqlException) {
          expect(e.message, errorMessageExpected);
        }
      }
    });
  });

  // test('handles a streamed request', () async {
  // final client = MockClient.streaming((request, bodyStream) async {
  //     final bodyString = await bodyStream.bytesToString();
  //     final stream =
  //         Stream.fromIterable(['Request body was "$bodyString"'.codeUnits]);
  //     return http.StreamedResponse(stream, 200);
  //   });

  //   final uri = Uri.http('example.com', '/foo');
  //   final request = http.Request('POST', uri)..body = 'hello, world';
  //   final streamedResponse = await client.send(request);
  //   final response = await http.Response.fromStream(streamedResponse);
  //   expect(response.body, equals('Request body was "hello, world"'));
  // });

  // test('handles a request with no body', () async {
  //   final client = MockClient((_) async => http.Response('you did it', 200));

  //   expect(
  //     await client.read(Uri.http('example.com', '/foo')),
  //     equals('you did it'),
  //   );
  // });
}
