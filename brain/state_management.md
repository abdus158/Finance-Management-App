# State Management Strategy

## Selected Solution
Riverpod

## Reason
- Better scalability
- Cleaner dependency injection
- Easier async handling
- Less boilerplate than BLoC
- Better compatibility with Clean Architecture

## Rules
- UI never directly accesses repositories
- Providers only communicate with UseCases
- Use AsyncNotifier for async flows
- Avoid global mutable state

## Flow

```
UI
↓
Provider
↓
UseCase
↓
Repository
↓
Datasource (Isar/API)
```

## Required Providers

- authProvider
- transactionProvider
- walletProvider
- analyticsProvider
- forecastProvider
- syncProvider

## Provider Naming Convention

- `transactionProvider`
- `walletBalanceProvider`
- `monthlyAnalyticsProvider`
