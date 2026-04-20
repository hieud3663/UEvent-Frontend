---
trigger: always_on
---

# DATA MAPPING RULES (EN)

## ROLE AND GOAL
You are a Flutter developer working in a model-first architecture with optional DTO usage in the data layer. Your goal is to keep API contracts stable, keep UI code clean, and ensure mapping logic is readable, testable, and reusable.

Scope note:
- This file defines data-layer architecture rules only.
- Product-specific decisions are documented in `docs/ARCHITECTURE_DECISIONS.md` and feature docs under `docs/features/`.
- Deep link and routing policies are documented in `.agents/rules/routing-rules.md`.

## CORE PRINCIPLES
1. API contracts are snake_case by default.
2. UI, View, Provider, and Controller layers work with Model objects only.
3. DTOs are allowed in the data layer when they improve contract isolation and parsing clarity.
4. Never expose DTO objects to UI, Provider, or Controller layers.
5. Production architecture must use `Repository` between Controller and data sources.
6. Repository is the single source of truth for choosing Remote vs Local data.

## ARCHITECTURE MODES
1. MVP/Small feature mode (allowed only with explicit approval):
- `Controller -> Service -> DTO -> Model`
- Allowed only when all conditions are true:
	- No offline requirement.
	- No cache requirement.
	- Short-lived/simple feature scope.
	- Team lead approval before implementation.

2. Production/Scalable mode (default):
- `Controller -> Repository -> Service/Local DataSource -> DTO -> Model`
- Required for new long-term features.

## LAYER RESPONSIBILITIES
1. View Layer
- Render UI from provider state only.
- Never parse API payload and never import DTO.

2. Provider Layer
- Expose state and controller entry points to UI.
- Keep provider wiring thin (no parsing/business mapping logic).

3. Controller Layer
- Handle actions and state transitions (refresh, markAsRead, optimistic update, retry).
- Call Repository and update state using Model objects.
- Store in `lib/features/<feature>/controller/`.

4. Repository Layer
- Abstract data origin from Controller (remote API, local cache, offline data).
- Apply data strategy (cache-first, network-first, stale-while-revalidate).
- Return Model types to Controller.
- Store in `lib/features/<feature>/repositories/`.

5. Service Layer (Remote IO)
- Perform API calls and transport-level mapping (raw JSON -> DTO when needed).
- Must not contain business orchestration logic.
- Store in `lib/features/<feature>/services/`.
- Service class must be named `<Feature>Service`.

6. Local Data Source Layer
- Handle local persistence (SQLite/Hive/Secure storage/cache table).
- Provide read/write operations for offline and cache scenarios.
- Store in `lib/features/<feature>/data_sources/local/`.

7. DTO Layer
- Parse request/response payloads from API.
- Keep fields close to backend contract.
- Store in `lib/features/<feature>/dtos/`.

8. Model Layer
- Represent business and UI-ready data.
- Can include computed getters for display.
- Store in `lib/features/<feature>/models/`.

## REFERENCE FLOW
Use this canonical production flow for Riverpod controller pattern:

`View`
`-> Provider`
`-> Controller`
`-> Repository`
`-> Service/Local DataSource`
`-> DTO`
`-> Model`
`-> Repository`
`-> Controller`
`-> Provider`
`-> View`

Notes:
- Provider is the access layer, not the business-logic layer.
- Controller is the behavior/state-orchestration layer.
- Repository is the data-orchestration layer.

## CONTROLLER STATE MECHANISM RULES
1. Default mechanism: `AsyncNotifier<T>` for async feature state.
2. Use `Notifier<T>` for synchronous-only state transitions.
3. Avoid mixing multiple state mechanisms in one feature unless there is a clear boundary.
4. Controller methods should mutate state only through notifier state APIs.

## REPOSITORY INTERFACE RULES
1. Repository must be defined as an abstract interface.
2. Controller must depend on repository interface, not implementation.
3. Keep implementation in `*RepositoryImpl` and wire it in provider/DI layer.

Repository reference pattern:
```dart
abstract interface class UserRepository {
	Future<UserModel> getCurrentUser();
}

class UserRepositoryImpl implements UserRepository {
	UserRepositoryImpl(this._service, this._local);

	final UserService _service;
	final UserLocalDataSource _local;

	@override
	Future<UserModel> getCurrentUser() async {
		final dto = await _service.fetchCurrentUser();
		final model = dto.toModel();
		await _local.saveCurrentUser(model);
		return model;
	}
}
```

Controller binding pattern:
```dart
final userControllerProvider =
		AsyncNotifierProvider<UserController, UserModel?>(UserController.new);

class UserController extends AsyncNotifier<UserModel?> {
	@override
	Future<UserModel?> build() => ref.read(userRepositoryProvider).getCurrentUser();
}
```

## JSON PARSING RULES
1. Prefer generated parsing.
2. Primary choice for new features: `dart_mappable`.
3. Use `json_serializable` only for legacy compatibility or existing modules already standardized on it.
4. Avoid repetitive manual mapping in `fromJson`.
5. If key fallback is required, define it in one place only (DTO mapper or common helper).
6. If the backend contract is finalized in snake_case, remove camelCase fallback to keep code short and maintainable.

## HELPER DESIGN RULES
1. Object-level helper
- `mapObjectData(responseData, mapper)`
- `mapper` takes `Map<String, dynamic>` and returns one object.

2. List-level helper
- `mapListData(responseData, mapper)`
- `mapper` takes one raw item and returns one object.

3. Do not put business rules inside mapping helpers.
4. Helpers should only:
- Extract object/list from payload.
- Apply mapper callback.

## DTO TO MODEL RULES
1. Default pattern: provide `toModel()` extension on DTO.
2. Use a dedicated mapper class only when mapping is complex (multi-step transforms, dependency-based mapping, or reusable composition across many DTOs).
3. Enum mapping must include a safe fallback.
4. DateTime parsing must be explicit for nullability and timezone handling.
5. UI-only transformations must live in Model layer, not in generic parsing helpers.

## NESTED MAPPING RULES
1. Nested DTO objects must be mapped recursively inside DTO `toModel()`.
2. Nested DTO lists must be mapped with `map((e) => e.toModel()).toList()`.
3. Keep parent `toModel()` orchestration simple and delegate nested conversion to child DTOs.

Example:
```dart
class OrderDto {
	final List<OrderItemDto> items;

	OrderModel toModel() => OrderModel(
				items: items.map((e) => e.toModel()).toList(),
			);
}
```

## SERVICE ERROR HANDLING RULES (REMOTE IO)
1. Service methods must convert transport/parser errors into app-level exceptions.
2. Do not leak raw `DioException` to Controller/UI.
3. Use a consistent exception family (for example `AppNetworkException`, `AppParseException`, `AppUnknownException`).

Reference pattern:
```dart
Future<Model> fetchSomething() async {
	try {
		final response = await client.get(...);
		return mapObjectData(response.data, (raw) => DtoMapper.fromMap(raw).toModel());
	} on DioException catch (e) {
		throw AppNetworkException.fromDio(e);
	} on FormatException catch (e) {
		throw AppParseException(e.toString());
	} catch (e) {
		throw AppUnknownException(e.toString());
	}
}
```

## REPOSITORY IMPLEMENTATION RULES
1. Service list method pattern
- Call API.
- Return DTO list (or parsed payload) without business orchestration.

2. Repository list method pattern
- Call service.
- Map DTO -> Model.
- Write-through local cache if needed.
- Return Model list to Controller.

3. Repository object method pattern
- Check local policy (cache-first/network-first).
- Merge/refresh from service when needed.
- Return Model object to Controller.

4. Mock and API branches must return the same Model type at Repository boundary.

## CACHE STRATEGY EXAMPLE
Cache-first reference implementation:

```dart
Future<UserModel> getUser(String id) async {
	final cached = await _local.getUser(id);
	if (cached != null) return cached;

	final dto = await _service.fetchUser(id);
	final model = dto.toModel();
	await _local.saveUser(model);
	return model;
}
```

Network-first reference implementation:

```dart
Future<EventModel> getEvent(String id) async {
	try {
		final dto = await _service.fetchEvent(id);
		final model = dto.toModel();
		await _local.saveEvent(model);
		return model;
	} on AppNetworkException {
		final cached = await _local.getEvent(id);
		if (cached != null) return cached;
		rethrow;
	}
}
```

## SECURE STORAGE RULES
1. Use FlutterSecureStorage for auth tokens, refresh tokens, and passkey credentials.
2. Never store sensitive credentials in Hive or SharedPreferences.
3. Auth token read/write belongs to AuthLocalDataSource, not mixed into feature-level local sources.
4. Token refresh logic belongs to network client interceptor layer, not Controller.

## WRITE OPERATION RULES
1. Write operations must go through Repository.
2. On success, update local cache only if the feature uses one, then return updated Model.
3. On failure, throw app-level exception and do not partially update local state.
4. Controller may perform optimistic UI update, but source of truth stays in Repository.

Pattern:
`Controller (optimistic UI update)`
`-> Repository.writeOperation()`
`-> Service.writeOperation()`
`-> LocalDataSource.updateCacheIfEnabled()`
`-> Controller (confirm or rollback state)`

Controller rollback pattern:

```dart
Future<void> performWrite() async {
	final previousState = state;

	state = AsyncData(optimisticModel);
	try {
		final updated = await ref.read(repositoryProvider).writeOperation();
		state = AsyncData(updated);
	} catch (e) {
		state = previousState;
		rethrow;
	}
}
```

## NAMING CONVENTIONS
1. DTO file: `<name>_dto.dart`
2. Model file: `<name>_model.dart`
3. Controller file: `<feature>_controller.dart`
4. Repository file: `<feature>_repository.dart`
5. Service file: `<feature>_service.dart`
6. Local data source file: `<feature>_local_data_source.dart`
7. Class naming:
- DTO class: `<Name>Dto` (example: `UserDto`)
- Model class: `<Name>Model` (example: `UserModel`)
- Mapper class (if needed): `<Name>Mapper` (example: `UserMapper`)
- Controller class: `<Feature>Controller` (example: `NotificationsController`)
- Repository class: `<Feature>Repository`
- Service class: `<Feature>Service`
- Local data source class: `<Feature>LocalDataSource`
8. Generated files:
- `*.mapper.dart` for `dart_mappable`
- `*.g.dart` for `json_serializable`

## REVIEW CHECKLIST
1. [Blocker] Does it follow snake_case backend contract?
2. [Blocker] Does the Repository return Model to Controller (not DTO)?
3. [Blocker] Does any UI/Provider/Controller import DTO? (If yes, fix it.)
4. [Blocker] Is Controller dependent on Repository (not direct Service)?
5. [Blocker] Is Service error handling mapped to app-level exceptions?
6. [Warning] If the feature requires cache/offline, is local data source implemented?
7. [Warning] Is Provider thin and free of business mapping logic?
8. [Blocker] Is analyzer clean?
9. [Blocker] Are important mapping fields covered by tests?
10. [Warning] Is mock data updated according to the new model?

## MIGRATION FLOW FOR NEW FEATURES
1. Create DTO.
2. Create Service interface/implementation.
	Create Local Data Source only if the feature requires cache or offline access.
3. Add DTO-to-Model mapping.
4. Create Repository and move data orchestration into Repository.
5. Refactor Controller to depend on Repository.
6. Run code generation.
7. Add/verify unit tests for DTO -> Model mapping and Repository behavior.
8. Run analyzer.
9. Smoke test the screen flow.

## ANTI-PATTERNS TO AVOID
1. DTO imported into View, Provider, or Controller.
2. Repeating manual mapping logic across multiple services.
3. Mixing camelCase and snake_case in the same finalized contract model.
4. Putting business logic into shared parsing helpers.
5. Putting controller/business actions directly in Provider.
6. Letting Controller call Service directly in production mode.

Common anti-pattern examples:
```dart
// BAD: DTO leaked into UI layer
class UserProfileView extends ConsumerWidget {
	final UserDto user;
	const UserProfileView({super.key, required this.user});
}

// BAD: business logic in Provider
final userProvider = Provider((ref) {
	if (DateTime.now().hour > 18) {
		// business rule should be in controller/service
	}
});

// BAD: Controller calls Service directly in production mode
class UserController extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() =>
	ref.read(userServiceProvider).fetchUser(); // Do not do this.
}

// BAD: write operation bypasses repository
Future<void> registerDirectly() async {
	await ref.read(registrationServiceProvider).postRegistration();
}
```
