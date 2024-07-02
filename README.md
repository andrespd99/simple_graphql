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
  - [Authentication with token-based requests](#authentication-with-token-based-requests)
    - [Set token on constructor](#set-token-on-constructor)
    - [Set token on query or mutation](#set-token-on-query-or-mutation)
  - [Custom headers](#custom-headers)
    - [Set headers on constructor](#set-headers-on-constructor)
    - [Set headers on query or mutation](#set-headers-on-query-or-mutation)
  - [Custom policies](#custom-policies)




## Get started

Like the name implies, using this package is simple. Just import it and create a new `SimpleGraphQL` instance with your custom URL. 

```dart
import 'package:simple_graphql/simple_graphql.dart';

final client = SimpleGraphQL(apiUrl: 'https://api.example/graphql');
```

> **1st Note**: API URLs must specify the `/graphql` or any other path at the end.

> **2nd Note**: Setting the `apiUrl` property in the constructor is optional. More on this later.

### Create a query

To execute a query, just call the `query()` method.

```dart
final client = SimpleGraphQL(apiUrl: 'https://api.example/graphql');

final result = client.query(
  query: "<Your query goes here>",
  resultBuilder: (data) {
    // Here is where you would want to serialize the result.
    return data;
  },
);
```

The `resultBuilder` parameter is a handy builder that returns a `Map` with the decoded result. Here's were you would normally serialize the result into a concrete object, or return the raw `Map` directly.

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

Similar to executing queries, to execute a mutation, call the `mutation()` method.

```dart
final client = SimpleGraphQL(apiUrl: 'https://api.example/graphql');

final result = client.mutation(
  query: "<Your mutation goes here>",
  resultBuilder: (data) {
    // Here is where you would want to serialize the result.
    return data;
  },
);
```

# Advanced usage

## Authentication with token-based requests

You can set a token to be used in the authorization header in two ways. You can either set it on the constructor, or on each query/mutation.

### Set token on constructor

```dart
final client = SimpleGraphQL(
  apiUrl: 'https://api.example/graphql',
  token: 'Bearer $token', // Must include prefixes, like "Bearer"
  authHeaderKey = 'Authorization', // Optional, defaults to 'Authorization'
);
```

This will set the token to be used in the [AuthLink] on all queries and mutations.

### Set token on query or mutation

```dart
final client = SimpleGraphQL(apiUrl: 'https://api.example/graphql');

final result = client.query(
  query: "<Your query goes here>",
  resultBuilder: (data) {
    // Here is where you would want to serialize the result.
    return data;
  },
  token: 'Bearer $token', // Must include prefixes, like "Bearer"
  authHeaderKey = 'Authorization', // Optional, defaults to 'Authorization'
);
```

This will set the token to be used in the [AuthLink] on the query or mutation. Will override any token set on the constructor.

## Custom headers

You can set custom headers in different ways, similar to the token. You can either set them on the constructor, or on each query/mutation.

### Set headers on constructor

```dart
final client = SimpleGraphQL(
  apiUrl: 'https://api.example/graphql',
  defaultHeaders: {
    'customHeaderKey': 'Custom value',
  },
);
```

### Set headers on query or mutation

```dart
final client = SimpleGraphQL(apiUrl: 'https://api.example/graphql');

final result = client.query(
  headers: {
    'customHeaderKey': 'Custom value',
  },
  query: "<Your query goes here>",
  resultBuilder: (data) {
    // Here is where you would want to serialize the result.
    return data;
  },
);
```

By default, the `headers` parameter of both `query()` and `mutation()` methods will be merged with the `defaultHeaders` passed to the constructor. You can change this behavior with the `headersInjectionBehavior` parameter.

```dart
final client = SimpleGraphQL(
  apiUrl: 'https://api.myapi.example/graphql',
  headers: {
    'customHeaderKey': 'Custom value',
  },
);

final result = client.query(
  headers: {
    'newCustomHeaderKey': 'New custom value (overrides default)',
  },
  headersInjectionBehavior: HeadersInjectionBehavior.override,
  query: "<Your query goes here>",
  resultBuilder: (data) => data,
);
```

This will in turn send a map with `newCustomHeaderKey` only, overriding the default headers.


## Custom policies

Like the original package, you can define the policies for your petition.

The available policies are to be defined are fetching, error and cache re-read policies. Todo do so, you can set the policies for both `query()` and `mutation()` methods via parameter, with the same [Policies] class from [graphql][graphql] package. Example below:

```dart
final client = SimpleGraphQL()

final result = client.mutation(
  fetchPolicy: FetchPolicy.noCache,
  cacheRereadPolicy: CacheRereadPolicy.mergeOptimistic,
  errorPolicy: ErrorPolicy.ignore,
  mutation: ...,
  resultBuilder: (data) => ...,
);
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