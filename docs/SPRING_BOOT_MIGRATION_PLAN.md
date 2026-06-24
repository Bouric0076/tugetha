# Tugetha Spring Boot Migration Plan

Source: `tugetha_blueprint_v2.pdf` version 2.0 and current repository state.

## Current Repository State

Tugetha currently contains:

- `tugetha/`: Flutter mobile app, Android-first. It still uses Firebase Auth and Firestore directly for users, wallet display, groups, goals, and loans.
- `tugetha-web/`: Next.js marketing website with lightweight contact and waitlist routes.
- `tugetha-api/`: Spring Boot API shell using Java 21, Spring Boot 3.5.x, Spring Security, JPA, Redis, PostgreSQL, and Flyway.
- `tugetha_blueprint_v2.pdf`: active system design blueprint.

The old `tugetha-payments/` Django backend has been removed from the project. Remaining Flutter service references to the old local Django API must be migrated only after equivalent Spring Boot endpoints exist.

## Target Architecture

Tugetha must become a Spring Boot centered financial system:

- Spring Boot is the single source of truth for all business and financial data.
- PostgreSQL stores authoritative user, wallet, ledger, payment, loan, group, goal, chama, notification, KYC, and audit data.
- Flyway owns every schema change. Manual production database edits are forbidden.
- Redis supports idempotency, short-lived balance cache, rate limiting, distributed locks, and logout token blacklist.
- Firebase Auth remains a transition layer for phone OTP in V1/V2.
- Firebase FCM remains the push delivery channel.
- Firestore is demoted from source of truth to temporary cache/compatibility layer during phased migration.
- Flutter performs UI, local validation, secure token storage, and API calls only.
- No financial calculation, Paystack keys, ledger mutation, balance mutation, or authorization decisions may live in Flutter.

## Migration Principles

1. No big-bang rewrite.
2. Every migrated domain gets a Spring API, database migration, tests, and observability before Flutter switches reads.
3. During transition, use dual-write only where needed and for a defined validation window.
4. PostgreSQL becomes authoritative domain by domain.
5. Firestore writes are removed only after PostgreSQL parity is verified.
6. Money movement is always ledger-backed, idempotent, auditable, and recoverable.
7. A user-visible feature is not migrated until auth, authorization, audit, error handling, and rollback behavior are implemented.

## First Feature Slice

The first backend module is not payments. The first slice is the secure platform foundation that every future money feature depends on.

### Slice 1: Platform Foundation, Auth, Users, Audit, Idempotency, Ledger Base

Goal: establish the backend skeleton that can safely support financial operations.

Deliverables:

- Package structure aligned with the blueprint:
  - `config`
  - `common/auth`
  - `common/exception`
  - `common/audit`
  - `common/idempotency`
  - `modules/user`
  - `modules/ledger`
  - `modules/wallet`
- Environment-driven configuration. No database passwords, provider keys, Firebase credentials, or secrets in committed YAML.
- Spring Security stateless API configuration.
- Firebase ID token verification filter for V1/V2 auth.
- Authenticated principal model containing backend user ID, Firebase UID, phone, role, and active status.
- Strict role and ownership authorization helpers.
- User bootstrap endpoint that maps Firebase Auth users to PostgreSQL users.
- Flyway baseline migrations for:
  - users
  - user_profiles
  - user_devices
  - audit_logs
  - idempotency_keys
  - transactions
  - ledger_entries
  - wallet_accounts or ledger account metadata
- Global exception handler with consistent API error responses.
- Request correlation ID filter.
- Audit log writer for security-sensitive and financial actions.
- Redis-backed idempotency guard with PostgreSQL persistence for critical actions.
- Ledger domain types:
  - transaction status state machine
  - transaction type enum
  - ledger entry debit/credit enum
  - account type enum
- Immutable ledger database rules/triggers preventing update and delete.
- Wallet balance read service computed from ledger entries.
- Health endpoints:
  - public liveness
  - protected readiness/internal dependency checks
- Unit tests for state transitions and authorization helpers.
- Repository/service tests for ledger balance calculations.

Acceptance criteria:

- Unauthenticated requests cannot access protected APIs.
- A valid Firebase token maps to exactly one active PostgreSQL user.
- Suspended users cannot call protected business APIs.
- Users cannot access another user's records unless the endpoint explicitly allows it through role or membership rules.
- Ledger entries cannot be updated or deleted at database level.
- Wallet balance is computed from immutable entries, not from a mutable balance column.
- Every critical request has a correlation ID and audit path.
- The app starts with `ddl-auto=validate` and Flyway migrations are the only schema source.

## Initial Implementation Order

### Phase 0: Cleanup and Alignment

Status: started.

- Remove the old Django payment backend.
- Document remaining Flutter references to old Django URLs.
- Keep mobile code behavior unchanged until Spring endpoints are ready.
- Rename or align package structure if needed before new modules grow.
- Move committed secrets out of `application.yml` into environment variables.

### Phase 1: Spring Boot Foundation

Implement before any payment endpoint:

- Common API response/error format.
- Correlation ID filter.
- Global exception handling.
- Security config for stateless JWT/Firebase-token protected APIs.
- Role model: `USER`, `ADMIN`, optionally `SUPPORT`, `SYSTEM`.
- Request principal and current-user access helper.
- Database baseline migrations.
- Testcontainers setup for PostgreSQL and Redis.

Important endpoints:

- `GET /api/health` public liveness.
- `GET /actuator/health` public or infrastructure-only depending deployment.
- `GET /api/v1/me` protected current user.
- `POST /api/v1/auth/bootstrap` protected by Firebase token, creates or returns PostgreSQL user.

### Phase 2: User and Authorization Module

Purpose: make PostgreSQL the authoritative identity/profile store while Firebase still provides OTP.

Features:

- User creation from Firebase token.
- Profile completion/update endpoint.
- Device registration for FCM tokens.
- KYC status field, but KYC workflow can remain later.
- Role and active/suspended enforcement.
- Audit logs for login bootstrap, profile update, device registration, role changes, and suspension.

Important endpoints:

- `GET /api/v1/users/me`
- `PATCH /api/v1/users/me/profile`
- `POST /api/v1/users/me/devices`
- `DELETE /api/v1/users/me/devices/{deviceId}`
- `GET /api/v1/admin/users/{id}` admin-only
- `PATCH /api/v1/admin/users/{id}/status` admin-only

### Phase 3: Ledger and Wallet Read Module

Purpose: create the financial core before external payment providers.

Features:

- Transaction entity with enforced state transitions.
- Ledger entry entity with immutable database protection.
- Ledger service that posts balanced debit/credit entries in one transaction.
- Wallet balance computed from ledger.
- Balance cache with short Redis TTL, invalidated after ledger posting.
- Reconciliation query that verifies total debits equal total credits.
- Admin-only reconciliation endpoint.

Important endpoints:

- `GET /api/v1/wallet/balance`
- `GET /api/v1/wallet/transactions`
- `GET /api/v1/admin/ledger/reconcile`

### Phase 4: Payment Module

Purpose: replace old Django payment behavior with Spring Boot.

Features:

- `PaymentProvider` interface.
- `PaystackProvider` implementation.
- Top-up initiation.
- Top-up verification.
- Withdrawal initiation.
- Webhook event persistence.
- HMAC signature verification for webhooks.
- Duplicate webhook handling.
- Stuck transaction recovery job.
- Firestore one-way wallet sync only during migration.

Important endpoints:

- `POST /api/v1/payments/topup/initiate`
- `POST /api/v1/payments/topup/verify`
- `POST /api/v1/payments/withdraw`
- `POST /api/v1/webhooks/paystack`

Flutter migration target:

- Replace `http://127.0.0.1:8000/api` usage in payment and wallet services with configurable Spring API base URL.
- Keep Firebase ID token in `Authorization: Bearer <token>` during V1/V2.
- Remove direct payment result mutation in Flutter. Flutter displays returned transaction states only.

### Phase 5: Loan Module

Purpose: move loan lifecycle into Spring Boot and ledger-backed money movement.

Features:

- Loan request creation.
- Lender approval/rejection.
- Atomic disbursement through ledger.
- Repayment through ledger.
- Due-date tracking and reminders.
- Trust score inputs.
- Firestore dual-write only while Flutter screens are being migrated.

Important endpoints:

- `POST /api/v1/loans/request`
- `GET /api/v1/loans`
- `GET /api/v1/loans/{id}`
- `POST /api/v1/loans/{id}/approve`
- `POST /api/v1/loans/{id}/reject`
- `POST /api/v1/loans/{id}/disburse`
- `POST /api/v1/loans/{id}/repay`

Authorization rules:

- Borrower can view own borrowed loans.
- Lender can view own lent loans.
- Only selected lender can approve/disburse.
- Admin can view all with audit.

### Phase 6: Groups and Goals

Purpose: migrate social saving structures from Firestore to PostgreSQL.

Features:

- Group creation and membership.
- Invite code handling.
- Membership roles: owner/admin/member.
- Goal creation under group.
- Goal contributions through wallet/ledger.
- Group and goal activity feed.

Important endpoints:

- `POST /api/v1/groups`
- `GET /api/v1/groups`
- `GET /api/v1/groups/{id}`
- `POST /api/v1/groups/{id}/members`
- `DELETE /api/v1/groups/{id}/members/{userId}`
- `POST /api/v1/groups/{groupId}/goals`
- `GET /api/v1/groups/{groupId}/goals`
- `POST /api/v1/goals/{id}/contribute`

Authorization rules:

- Group data is visible only to members and admins.
- Only group owner/admin can change membership and settings.
- Contributions require active membership.

### Phase 7: Chama Module

Purpose: implement the blueprint's merry-go-round module after core ledger, wallet, users, groups, and payments are stable.

Features:

- Chama group setup.
- Cycle management.
- Contribution tracking.
- Manual confirmation.
- Daraja C2B webhook path when provider is ready.
- WhatsApp Business API webhook as enhancement, not dependency.
- Standing order consent, cancellation, and skip-safe auto-deduction.
- Automatic disbursement when all cycle contributions are received.

Important endpoints:

- `POST /api/v1/chamas`
- `GET /api/v1/chamas`
- `POST /api/v1/chamas/{id}/cycles/start`
- `POST /api/v1/chamas/{id}/contributions`
- `POST /api/v1/chamas/{id}/disburse`
- `POST /api/v1/standing-orders`
- `DELETE /api/v1/standing-orders/{id}`
- `POST /api/v1/webhooks/daraja`
- `POST /api/v1/webhooks/whatsapp`

### Phase 8: Admin Dashboard APIs

Purpose: support operations before public real-money launch.

Features:

- User search and account status changes.
- KYC review.
- Transaction search.
- Wallet ledger view.
- Webhook log search.
- Failed/stuck payment retry controls.
- Reconciliation reports.
- Loan and chama monitoring.
- System health view.

### Phase 9: Monitoring, Hardening, and Release Readiness

Required before public launch:

- Sentry error tracking.
- Structured JSON logs.
- Prometheus metrics.
- Grafana dashboard definitions.
- Payment success/failure metrics.
- Ledger imbalance alert.
- Dependency vulnerability scanning.
- Load testing of payment and wallet endpoints.
- Backup and restore test.
- Security review against authorization matrix.

### Phase 10: Full Firebase Auth Migration

Purpose: replace Firebase Auth with custom OTP and Spring Security JWT in V3.

Features:

- Africa's Talking OTP.
- OTP rate limiting and abuse controls.
- Refresh token rotation.
- Token blacklist on logout.
- Migration path for existing Firebase users.
- Removal of Firebase Auth dependency from mobile.

## Core Feature Priority

Must be implemented first:

1. Authentication bridge and user mapping.
2. Strict authorization and ownership model.
3. Flyway baseline schema.
4. Audit logs.
5. Idempotency.
6. Immutable ledger.
7. Wallet balance computed from ledger.
8. Payment provider abstraction.
9. Paystack top-up and withdrawal.
10. Webhook verification and recovery jobs.

Can wait until after payment replacement:

- Full loan migration.
- Full group and goal migration.
- Chama module.
- Standing orders.
- Admin dashboard UI.
- Custom OTP.

## Required Authorization Matrix

Every endpoint must define one of these scopes before implementation:

- Public: health, provider webhooks with signature verification.
- Authenticated user: own profile, own wallet, own devices.
- Owner/member: group, goal, loan, or chama resources where user has explicit relationship.
- Admin: support and operational endpoints.
- System: scheduled jobs and internal service actions.

Rules:

- Never infer access from a request body user ID.
- Always derive acting user from authenticated principal.
- Path IDs must be checked against database ownership/membership.
- Admin endpoints must be under `/api/v1/admin/**`.
- Webhooks must not use normal user auth; they require provider signature verification, event persistence, idempotency, and minimal response data.

## Migration Checkpoints

For each migrated domain:

1. Schema migration exists.
2. Service tests cover domain rules.
3. Authorization tests cover denied access.
4. API contract is documented.
5. Flutter client has a typed service wrapper.
6. Dual-write validation plan exists if Firestore data is involved.
7. Admin/audit visibility exists for financial records.
8. Rollback plan exists.
9. Observability exists.
10. Old code path is removed only after production parity is verified.

## Immediate Next Work

1. Move `tugetha-api/src/main/resources/application.yml` secrets to environment variables.
2. Add the baseline package structure.
3. Add Flyway `V001` for users, audit logs, idempotency keys, transactions, and ledger entries.
4. Implement Firebase token verification and user bootstrap.
5. Implement immutable ledger domain and balance read service.
6. Add Testcontainers for PostgreSQL and Redis.
7. Only then implement Spring payment endpoints to replace the deleted Django backend.
