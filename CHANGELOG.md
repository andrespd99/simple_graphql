## 1.0.0
* fix (breaking!): Renamed from `SimpleGraphQl` to `SimpleGraphQL` for consistency and good Dart class naming practices.
* feat: added `defaultHeaders` parameter to `SimpleGraphQL` constructor to set default headers for all queries and mutations.
* feat: added `headersInjectionBehavior` parameter to `query()` and `mutation()` methods. It allows you to choose if the `headers` parameter should be merged with the `defaultHeaders` or override them.
* fix: Made `apiUrl` parameter optional. It can be set later by assigning a new value to the `apiUrl` instance property.
* feat: Added `NoUrlException` to handle cases where `apiUrl` is not set before calling `query()` or `mutation()` methods.
* feat: Added `authHeaderKey` and `token` parameters to `query()` and `mutation()` methods. Now you can set the `authHeaderKey` and `token` on a per-request basis.
* feat: You can now define your own `GraphQLCache` and `http.Client` instances to be used by `SimpleGraphQL` on every query and mutation call.
* feat: `query()` and `mutation()` methods now accept optional `client` parameter to use a custom `http.Client` on a per-request basis.
* feat: `authHeaderKey` and `token` parameters can now be set on constructor and/or on `query()` and `mutation()` methods.
* refactor: `headerKey` parameter in constructor was marked as deprecated in favor of `authHeaderKey`. It will be removed in future versions.
* docs: Documentation update.
* docs: New test examples in `example` folder.
## 0.1.0+2
* Documentation update.
  - The package usage have been documented.
  - CHANGELOG format fixed.
## 0.1.0+1
* `SimpleGraphQl` class for simplified GraphQL query petitioning.

## 0.1.1+1
* Added package exceptions to exports for easier reference.
