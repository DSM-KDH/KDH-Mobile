# KDH Mobile — Project Guidelines for Claude

## State Management

Use **Riverpod** (`flutter_riverpod`) for all state management.

### Rules
- `StateNotifierProvider` for complex state that exposes multiple actions (e.g., timers, forms with validation)
- `Provider` / `FutureProvider` / `StreamProvider` for read-only or async-derived state
- Always use `autoDispose` on feature-specific providers to prevent memory leaks
- Use `.family` when a provider depends on an external parameter (e.g., timer config, item ID)
- Provider files live in `lib/features/<feature>/presentation/providers/`
- Do **not** use `ChangeNotifier`, `ValueNotifier`, or `setState` for shared or feature-level state — use Riverpod
- Use Provider for health management and Dio for HTTP linkage. 
- The file structure is based on a clean architecture.

### Naming
- Notifier class: `<Feature>Notifier` (e.g., `IntervalTimerNotifier`)
- State class: `<Feature>State` (e.g., `IntervalTimerState`)
- Provider variable: `<feature>Provider` (e.g., `intervalTimerProvider`)

### Example
```dart
final exampleProvider = StateNotifierProvider.autoDispose
    .family<ExampleNotifier, ExampleState, ExampleConfig>(
  (ref, config) => ExampleNotifier(config),
);
```

---

## HTTP Client

Use **Dio** (`dio`) for all HTTP requests. Do **not** use `http` or `dart:io HttpClient`.

### Setup
- Create a singleton Dio instance with base options in `lib/core/network/dio_client.dart`
- Register it as a Riverpod `Provider<Dio>` so it can be overridden in tests
- Add interceptors for auth headers, logging, and error handling in the same file

### Rules
- All API calls go through repository classes in `lib/features/<feature>/data/repositories/`
- Repositories depend on the Dio provider via `ref.watch`
- Use `try/catch` with `DioException` for error handling — never let network errors propagate to UI uncaught
- Return typed result objects (or throw domain exceptions) from repositories — not raw `Response`

### Example
```dart
// lib/core/network/dio_client.dart
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://api.example.com'))
    ..interceptors.add(LogInterceptor());
});

// lib/features/user/data/repositories/user_repository.dart
class UserRepository {
  UserRepository(this._dio);
  final Dio _dio;

  Future<User> fetchUser(String id) async {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data);
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(dioProvider)),
);
```
