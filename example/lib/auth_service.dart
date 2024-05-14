import 'package:simple_graphql/simple_graphql.dart';

class LoginResponseDto {
  LoginResponseDto({
    required this.success,
    required this.token,
  });

  final bool success;
  final String? token;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      success: json['success'] as bool,
      token: json['token'] as String?,
    );
  }
}

class AuthService {
  AuthService({
    required this.client,
  });

  final SimpleGraphQl client;

  Future<LoginResponseDto> login({
    required String username,
    required String password,
  }) async {
    const query = r'''
      query Login($username: String, $password, String) { 
        login(username: $username, password: $password) {
          success
          token
        }
      }''';

    final variables = {'username': username, 'password': password};

    final response = await client.query<LoginResponseDto>(
        apiUrl: '',
        variables: variables,
        query: query,
        resultBuilder: (data) {
          return LoginResponseDto.fromJson(
            data['login'] as Map<String, dynamic>,
          );
        });

    return response;
  }
}
