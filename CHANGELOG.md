## 2.0.0
* Renamed `SimpleGraphQl` to `SimpleGraphQL` for consistency and good dart class naming practices.
* You can now define your own `GraphQLCache` and http `Client` instances to be used by `SimpleGraphQL`.
* `query()` and `mutation()` methods now accept optional `client` parameter to use a custom http client on a per-request basis.
## 1.0.0
* `SimpleGraphQl` constructor does not require `apiUrl` anymore. Instead, `query()` and `mutation()` methods require the `apiUrl` parameter.
* Constructor still accepts `authHeaderKey` and `token` optional parameter for token-based requests.
* New test examples in `example` folder.
* `headerKey` parameter in constructor was marked as deprecated in favor of `authHeaderKey`. It will be removed in future versions.
## 0.1.0+2
* Documentation update.
  - The package usage have been documented.
  - CHANGELOG format fixed.
## 0.1.0+1
* `SimpleGraphQl` class for simplified GraphQL query petitioning.

## 0.1.1+1
* Added package exceptions to exports for easier reference.
