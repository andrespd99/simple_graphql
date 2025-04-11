import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simple_graphql/simple_graphql.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  const tUrl = 'http://localhost:3000';
  setUpAll(() {
    registerFallbackValue(Uri.parse(tUrl));
  });

  testWidgets('should execute request with custom http client', (tester) async {
    final http = MockClient();
    final client = SimpleGraphQL(httpClient: http, apiUrl: tUrl);
    when(() => http.get(any<Uri>())).thenAnswer(
      (_) async => Response('{"data": {}}', 200),
    );

    await client.query(query: '', resultBuilder: (_) {});

    verify(() => http.get(any())).called(1);
  });
}
