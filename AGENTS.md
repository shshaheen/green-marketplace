# AGENTS.md — Green Marketplace Flutter App

Instructions for AI coding assistants working in this repository. Business rules,
decisions and the API live in the backend repo — read them first:

- `../green_marketplace_backend/docs/PROJECT_CONTEXT.md` (product, rules, decision log)
- `../green_marketplace_backend/README.md` (API reference)
- `../green_marketplace_backend/AGENTS.md` (working agreement — applies here too)

## 1. Working agreement (from the owner)

- Analyse first; present a plan; **wait for approval** before implementing a module.
- Implement only the approved scope. If the request conflicts with the backend or an
  earlier decision, stop and ask. **The backend API is the source of truth.**
- Commit when verified; **push only when asked**. **No AI attribution** in commits/PRs.
- Never log or print tokens, MPINs, OTPs or personal details.
- Done means: `flutter analyze` shows **no issues** and `flutter test` passes.

## 2. Terminology (strict)

Use **Order Request**, **My Requests** (customer), **Order Requests** (admin),
**Submit Request**. Never use Enquiry, Checkout, Cart or Pay Now. An Order Request is
never a confirmed order; prices are indicative.

## 3. Stack

Flutter 3.44 / Dart 3.12, **flutter_riverpod 3** (Notifier / AsyncNotifier / Provider
only), go_router, dio, flutter_secure_storage, shared_preferences, cached_network_image,
flutter_screenutil, intl. **No code generation**: no freezed, json_serializable or
build_runner.

## 4. Run

```bash
flutter run --dart-define-from-file=config/dev.json    # dev (Android emulator → 10.0.2.2)
flutter run --dart-define-from-file=config/prod.json   # prod
flutter analyze
flutter test
```

`config/*.json` holds build-time settings (`FLAVOR`, `API_ORIGIN`) — never secrets.
For the iOS simulator use `http://localhost:4000`; for a physical device use the
computer's LAN IP.

## 5. Architecture

```
lib/
  main.dart, app.dart
  core/          shared infrastructure: config, theme, network, error, storage, router,
                 utils, widgets
  domain/        PURE DART: entities, enums, abstract repositories (+ their input types)
  data/          models (manual fromJson/toJson/toEntity), datasources (remote/local),
                 repository implementations
  providers/     repository_providers.dart — Riverpod wiring (Dio, storage, repos)
  presentation/  customer/… and admin/… features: providers/, screens/, widgets/
```

**Dependency rules**

| Layer | May import | Must not import |
|---|---|---|
| `domain/` | `dart:*` only | Flutter, dio, core, data, presentation |
| `data/` | domain, core | presentation |
| `presentation/` | domain, core, `providers/` | `data/`, dio |
| `core/` | domain (enums/entities for shared widgets), packages | data, presentation |

- Notifiers depend on **abstract repositories** via providers, never on implementations.
- Widgets stay declarative: pagination, filtering, MOQ clamping, persistence and error
  handling live in notifiers, entities or core utils.
- Enums/sealed classes centralise rules: `OrderRequestStatus` (transitions, customer
  cancel, note required), `AppFailure` (error UI). Switch over them exhaustively.

## 6. Conventions

**API**
- Endpoints only in `core/network/api_endpoints.dart` (mirrors backend routes).
- Success envelope `{ success, data, meta? }` → `ApiResponse`; errors
  `{ success:false, error:{ code, message, details[] } }` → `ApiErrorBody`.
- Repositories catch everything and `throw mapToFailure(e)`; the UI only sees `AppFailure`.
- `ValidationFailure.fieldErrors` keys are backend field paths without the `body.` prefix
  (e.g. `customerDetails.phone`) — map them to form fields.

**Auth**
- Two separate sessions (`AuthScope.admin`, `AuthScope.customer`), tokens in
  `flutter_secure_storage` only. `AuthInterceptor` attaches the right token by path
  (`/admin/*` → admin, `/order-requests/*` → customer, catalogue/auth → none), refreshes
  once on 401 and calls `onSessionExpired` when refresh fails.
- Customers: email OTP registration + email/MPIN login; browsing works without login,
  **Submit Request requires login**. Admins: pre-created, email + MPIN, initial MPIN setup
  and reset via email OTP. No admin sign-up anywhere.
- `shared_preferences` only for non-sensitive data (the draft Order Request).

**Data**
- Money is `Money` in whole **paise**; format with `Formatters.inrFromPaise`.
- Dates without time are sent as `yyyy-MM-dd` (`Formatters.apiDate`).
- Plant quantity is clamped to `minOrderQty…maxQuantityPerItem`
  (`DraftRequestItem.clampQuantity`); out-of-stock plants can still be requested.
- Models: immutable classes, `const` constructors, explicit `fromJson`/`toJson`/
  `toEntity`, reading JSON through the `JsonRead` helpers (they throw `ParseException`).

**UI**
- Colours, spacing, radii and text only from `core/theme/` (`AppColors`, `AppSpacing`,
  `AppTypography`). Reuse `core/widgets/` (`AppButton`, `AppTextField`, `AsyncStateView`,
  `StatusBadge`, `PlantThumbnail`, `showConfirmDialog`).
- Every async screen uses `AsyncStateView` (loading / empty / error + retry). No mock data.

## 7. Testing

- Unit tests for validators, formatters, parsing, error mapping, enums and entities;
  widget tests for shared widgets and screens; fake repositories via provider overrides.
- Network tests use a fake `HttpClientAdapter` (see `test/core/auth_interceptor_test.dart`).

## 8. Decisions that differ from the original app spec

| Spec | Implemented | Why |
|---|---|---|
| No customer login, tracking tokens | Customer email OTP + MPIN; login required to Submit Request; My Requests from the server | Owner decision 2026-11-20; backend auth already built |
| Admin username + password | Email + MPIN with OTP initial setup / reset | Matches backend |
| `{ success, message, data, meta }` | `{ success, data, meta? }` / `error{code,message,details}` | Matches backend |
| Logout on 401 | Refresh once, then expire the session | Backend issues refresh tokens |
| Signed direct Cloudinary upload | Multipart upload to `POST /admin/plants/:id/images` | Backend validates files server-side |
| PUT, `/dashboard/summary`, `/categories/:id/subcategories`, `{status, adminNotes}` | PATCH, `/dashboard/stats`, `POST /admin/categories` with `parent`, `{status, note}` + `PATCH /notes` | Matches backend |
| `auth_repository.dart` (one contract) | `CustomerAuthRepository` + `AdminAuthRepository` in that file | Two separate account types |
| Domain enums file list | Added `plant_enums.dart`, `intended_use.dart`; entities `money.dart`, `app_user.dart`, `paginated.dart` | Needed by the contracts |
