# SimpleGraphQL

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: BSD 3-Clause][license_badge]][license_link]

## Introduction

A simplified version of [graphql][graphql] package that saves you from all the boilerplate code. Cheers 🍻!

- [SimpleGraphQL](#simplegraphql)
  - [Introduction](#introduction)
  - [Get started](#get-started)
    - [Create a query](#create-a-query)
    - [Create a mutation](#create-a-mutation)
- [Advanced usage](#advanced-usage)
  - [Authentication and custom headers](#authentication-and-custom-headers)
  - [Custom policies](#custom-policies)
  - [Testing](#testing)




## Get started

Like the name implies, using this package is simple. Just import the package, and create a new `SimpleGraphQl` instance with your custom URL. 

```dart
import 'package:simple_graphql/simple_graphql.dart';

final client = SimpleGraphQl(apiUrl: 'https://api.myapi.example/graphql');
```

**Note**: API URLs must specify the graphql path at the end.

### Create a query

To execute a query, just call the `query()` method.

```dart
final client = SimpleGraphQl(apiUrl: 'https://api.myapi.example/graphql');

final result = client.query(
  query: "<Your query goes here>",
  resultBuilder: (data) {
    // Here is where you would want to serialize the result.
    return data;
  },
);
```

The `resultBuilder` parameter is a handy builder that returns a `Map` with the decoded result. You may serialize the result to a concrete object, or handle it as a `Map`.

When serializing to concrete classes, it is recommended to specify the type of the class, like so:

```dart
final result = client.query<User>(
  query: '''
    query ExampleQuery() {
      getUser {
        id,
        name,
        email
      }
    }
  
  ''',
  resultBuilder: (data) {
    return User.fromMap(data['getUser']);
  },
);
```

The first layer of the `Map` parameter of `resultBuilder` will always be named like the query or mutation being called. In the example above, the query is named `getUser`.

### Create a mutation 

Similar to executing queries, to execute a mutation, call the `mutate()` method.

```dart
final client = SimpleGraphQl(apiUrl: 'https://api.myapi.example/graphql');

final result = client.mutation(
  query: "<Your mutation goes here>",
  resultBuilder: (data) {
    // Here is where you would want to serialize the result.
    return data;
  },
);
```

# Advanced usage


## Authentication and custom headers

To set custom headers and authentication tokens for all your petitions, you must declare them when creating a `SimpleGraphQl` instance.

```dart
final client = SimpleGraphQl(
  apiUrl: 'https://api.myapi.example/graphql',
  headers: {
    'customHeaderKey': 'Custom value',
  },
  token: 'Bearer $token',
);
```

By default, the token's header key is `Authorization`, but you can override it by setting the [headerKey] parameter when creating a new instance of `SimpleGraphQl`.



## Custom policies

Like the original package, you can define the policies for your petition.

The available policies are to be defined are fetching, error and cache re-read policies. Todo do so, you can set the policies for both `query()` and `mutation()` methods via parameter, with the same [Policies] class from [graphql][graphql] package. Example below:

```dart
final client = SimpleGraphQl()

final result = client.mutation(
  fetchPolicy: FetchPolicy.noCache,
  cacheRereadPolicy: CacheRereadPolicy.mergeOptimistic,
  errorPolicy: ErrorPolicy.ignore,
  mutation: ...,
  resultBuilder: (data) => ...,
);
```

## Testing

To write unit tests for your queries and mutations, you can use the `SimpleGraphQlMock` class to mock the responses. 

```dart
test('query should execute successfully', () async {
      final client = SimpleGraphQlMock(
      final responseExpected = {'username': 'john_doe', 'password': '12345'};
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
```

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-BSD_3--clause-blue.svg
[license_link]: https://opensource.org/license/bsd-3-clause/
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
[graphql]: https://pub.dev/packages/graphql