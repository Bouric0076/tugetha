# Tugetha Java and Spring Boot Engineering Rules

These rules are mandatory for the Tugetha backend. The app handles financial workflows, so correctness, auditability, and security are more important than speed of coding.

## Non-Negotiable Principles

1. Spring Boot is the only backend authority for business and financial logic.
2. PostgreSQL is the source of truth.
3. Flyway is the only way to change schema.
4. Ledger rows are immutable.
5. Wallet balance is computed from ledger entries.
6. Every money movement is idempotent.
7. Every protected endpoint has explicit authorization.
8. Every external webhook is verified, persisted, and idempotent.
9. Secrets never enter Git.
10. Flutter and web clients never perform financial calculations or trust decisions.

## Project Structure Rules

Use a package structure that keeps infrastructure, common behavior, and business modules separate:

```text
com.sinaps.tugetha
  config
  common
    auth
    audit
    exception
    idempotency
    logging
    web
  modules
    user
    wallet
    ledger
    payment
    loan
    group
    goal
    chama
    notification
    webhook
    kyc
    admin
  scheduler
```

Rules:

- A module owns its entities, repositories, services, DTOs, and controllers.
- Controllers call services, never repositories.
- Services call repositories in their own module only.
- Cross-module access must go through a service interface, not another module's repository.
- Shared utilities must live in `common` only when at least two modules need them.
- Do not create generic helper classes until duplication is real and harmful.
- Do not place business logic in controllers, DTOs, mappers, entities, filters, or repositories.

## Dependency Direction Rules

Allowed:

- `controller -> service -> repository`
- `module service -> another module public service interface`
- `scheduler -> service`
- `webhook handler -> provider verification -> service`

Forbidden:

- `controller -> repository`
- `module A repository -> module B repository`
- `entity -> service`
- `common -> modules`
- circular service injection
- static service lookups
- database writes from filters/interceptors except security audit events through a safe async/audit boundary

If two services need each other, the design is wrong. Extract the shared decision into a third service or publish a domain event.

## Circular Dependency Prevention

Rules:

- Constructor injection only.
- No field injection.
- No `@Lazy` to hide circular dependencies.
- No `ApplicationContext.getBean()` for normal business logic.
- Service interfaces are allowed only at module boundaries.
- If `WalletService` and `LedgerService` seem to need each other, `WalletService` must depend on `LedgerQueryService`; ledger posting remains inside `LedgerService`.
- If `PaymentService` and `TransactionService` seem to need each other, payment orchestration owns the workflow and calls ledger through one clear command method.

Pattern:

```text
PaymentApplicationService
  -> PaymentProvider
  -> LedgerService
  -> FirestoreSyncService temporary during migration
```

Not allowed:

```text
PaymentService -> WalletService -> LedgerService -> PaymentService
```

## Transaction Rules

Use `@Transactional` only at service-layer command methods that mutate state.

Rules:

- Never put `@Transactional` on controllers.
- Never perform long external HTTP calls inside a database transaction unless the external call must happen before any mutation and no lock is held.
- For payment workflows, separate provider call, transaction state update, and ledger posting carefully.
- Ledger posting and transaction completion must be atomic.
- Use optimistic locking (`@Version`) on mutable financial state records.
- Use pessimistic locks only for short critical sections with known ordering.
- Do not call `@Transactional` methods through `this.method()`, because Spring proxying will not apply.
- Do not mix async work and open transactions.

Lock ordering:

1. idempotency key
2. transaction row
3. wallet/account rows if needed
4. ledger insert
5. audit insert

Every code path must acquire locks in this order to avoid deadlocks.

## Database Design Rules

General:

- Every table has a primary key.
- Use `BIGSERIAL` or identity for user-facing aggregate tables, UUID for financial transaction records where external correlation matters.
- Every table has `created_at`.
- Mutable tables have `updated_at`.
- Financial mutable tables have `version`.
- Money uses `NUMERIC(12,2)` or stricter precision agreed per table. Never use floating point.
- Currency is stored as `VARCHAR(3)` with default `KES` until multi-currency is implemented.
- Use database constraints for invariants that must never be violated.
- Use indexes for every foreign key and high-volume query path.
- Use `TIMESTAMPTZ`, not local timestamp.

Financial:

- `ledger_entries` is append-only.
- Prevent `UPDATE` and `DELETE` on ledger tables at database level.
- Store raw webhook events permanently.
- Store provider references with unique constraints where applicable.
- Store idempotency keys with unique constraints.
- Transaction state transitions must be represented in append-only history or auditable metadata.
- Balance columns are allowed only as cache/read-model fields and must be clearly named as cache. They are never source of truth.

Flyway:

- Migrations are named `V001__description.sql`, `V002__description.sql`, etc.
- Never edit a migration after it has been applied outside local development.
- New schema change means a new migration.
- Migrations must be safe to run on empty staging databases.
- Destructive migrations require backup, migration notes, and explicit approval.

## Entity and JPA Rules

- Prefer explicit constructors/factory methods for valid aggregate creation.
- Do not use Lombok `@Data` on JPA entities.
- Avoid bidirectional relationships unless truly necessary.
- Default to `FetchType.LAZY` for relationships.
- Do not expose JPA entities from controllers.
- Do not accept entities as request bodies.
- Use DTOs for API requests and responses.
- Do not perform business calculations inside entity getters.
- Implement `equals` and `hashCode` carefully; prefer ID-based only after persistence.
- Avoid cascade delete on financial entities.
- Use repository methods with clear names and explicit query intent.

## API Rules

Path format:

- Public API: `/api/v1/**`
- Admin API: `/api/v1/admin/**`
- Webhooks: `/api/v1/webhooks/{provider}`
- Health: `/api/health` and/or `/actuator/health`

Rules:

- Every endpoint returns a stable DTO shape.
- Error responses use one global format.
- Request bodies are validated with Jakarta Bean Validation.
- Pagination is required for list endpoints.
- Do not return stack traces.
- Do not return provider secrets, raw tokens, internal IDs that are not needed, or sensitive metadata.
- Use idempotency keys for every payment, withdrawal, disbursement, repayment, and contribution command.
- Use correlation IDs in request and response headers.
- API versions must not be broken silently.

Standard error fields:

```json
{
  "code": "WALLET_INSUFFICIENT_FUNDS",
  "message": "Insufficient wallet balance.",
  "correlationId": "01HX...",
  "timestamp": "2026-06-16T10:15:30Z"
}
```

## Authentication Rules

V1/V2:

- Firebase Auth verifies phone ownership.
- Spring Boot verifies Firebase ID token server-side.
- Spring Boot maps Firebase UID to PostgreSQL user.
- Spring Boot decides role, status, and access.

Rules:

- Never trust a UID or phone number sent in the request body.
- Never trust a frontend-provided role.
- Do not allow inactive/suspended users into business APIs.
- Admin privileges must come from PostgreSQL role, not Firebase claims unless explicitly synchronized and validated.
- Token verification failures return 401.
- Authenticated but unauthorized access returns 403.

V3:

- Custom OTP and Spring-issued JWT replace Firebase Auth.
- Refresh tokens must rotate.
- Logout must blacklist active tokens or invalidate refresh tokens.
- OTP requests must be rate-limited by phone, IP, and device fingerprint where available.

## Authorization Rules

Every service command must answer:

- Who is acting?
- What resource are they touching?
- What relationship gives them permission?
- Is the account active?
- Is this operation allowed in the resource's current state?

Rules:

- Authorization belongs in service layer or dedicated authorization components, not only controllers.
- Admin bypasses must be explicit and audited.
- Group membership must be checked from PostgreSQL.
- Loan borrower/lender access must be checked from PostgreSQL.
- Chama standing order actions are allowed only for the consenting user.
- Webhook actions must be scoped to verified provider events.

## Ledger Rules

- Every ledger posting must balance.
- Every ledger entry amount is positive.
- Direction is represented by `DEBIT` or `CREDIT`, not negative numbers.
- A transaction cannot move from `COMPLETED` to `PROCESSING`.
- Reversals use new reversing ledger entries, never mutation.
- Ledger references are unique.
- Transaction status changes must follow the state machine.
- Ledger service is the only component allowed to write ledger entries.
- Payment, loan, goal, chama, and wallet modules must call ledger service instead of writing financial rows directly.

Required transaction states:

```text
INITIATED -> PROCESSING -> COMPLETED
INITIATED -> COMPLETED
INITIATED -> FAILED
PROCESSING -> FAILED
COMPLETED -> REVERSED
```

All other transitions are invalid.

## Payment Rules

- Business logic talks to `PaymentProvider`, not directly to Paystack.
- Provider-specific code stays in provider classes.
- Webhooks are verified before parsing business meaning.
- Raw webhook payloads are stored before processing.
- Duplicate webhook events return 200 and do nothing after logging.
- Provider references must be unique.
- Payment verification is allowed as a recovery path even if webhook fails.
- Never mark a payment complete until provider verification is successful.
- Never credit wallet without a ledger transaction.
- Never deduct wallet without a ledger transaction.

## Idempotency Rules

Required for:

- top-up initiation
- top-up verification
- withdrawal
- loan disbursement
- loan repayment
- goal contribution
- chama contribution
- chama disbursement
- standing order execution
- webhook processing

Rules:

- Idempotency key must include operation meaning and target resource.
- Store keys in PostgreSQL for critical financial actions.
- Redis can accelerate locks but must not be the only record for money operations.
- Repeated request with same key and same payload returns the original result.
- Same key with different payload returns conflict.
- Failed transient operations may be retried only under explicit state rules.

## Scheduler and Async Rules

- MVP can use Spring Scheduler.
- Production recurring jobs move to Quartz.
- Event-driven workflows can move to RabbitMQ later.

Rules:

- Jobs must be idempotent.
- Jobs must record execution result.
- Jobs must not process unbounded data in one transaction.
- Jobs must use pagination/batches.
- Jobs must be safe when two instances run.
- Jobs must emit metrics and audit important decisions.

Required jobs:

- payment verification retry
- stuck transaction recovery
- daily reconciliation
- loan repayment reminders
- standing order execution
- chama contribution reminders
- failed withdrawal recovery
- weekly user summary
- trust score recalculation

## Frontend Integration Rules

Flutter:

- Flutter stores tokens in secure storage.
- Flutter sends `Authorization: Bearer <token>`.
- Flutter displays backend-calculated balances and transaction states.
- Flutter does not directly update wallet balances.
- Flutter does not calculate loan fees, platform fees, or disbursement amounts as authority.
- Flutter does not contain Paystack secret keys or backend provider keys.
- Firestore direct writes must be removed domain by domain after Spring APIs are ready.
- API base URL must be configurable per environment.

Tugetha product UI exception:

- Tugetha may use a very small number of emojis in warm onboarding and empty-state copy where they improve approachability for a consumer finance audience.
- Emojis are not allowed in security warnings, financial confirmations, transaction states, admin screens, error codes, buttons for money movement, or legal/compliance copy.
- Emoji use must be intentional, stable, and never replace a real icon, label, or status indicator.

Web:

- Marketing site can remain separate from authenticated product APIs.
- Admin dashboard must use protected admin APIs only.
- Admin dashboard must not call database or provider APIs directly.

## Logging and Audit Rules

Logging:

- Use structured logs.
- Include correlation ID.
- Include user ID when authenticated.
- Do not log tokens, OTPs, provider secrets, PINs, full raw KYC data, or full card/bank data.
- Provider errors are logged with sanitized references.

Audit:

- Audit user bootstrap, login-sensitive events, profile changes, role changes, status changes, KYC decisions, payment state changes, ledger postings, loan approval/disbursement/repayment, standing order consent/cancel/execute, admin actions, and webhook processing.
- Audit logs are append-only.
- Audit logs must include actor, action, target, correlation ID, timestamp, and metadata.

## Testing Rules

Minimum:

- Unit tests for domain rules and state machines.
- Service tests for authorization and command behavior.
- Repository/integration tests with Testcontainers for PostgreSQL.
- Redis integration tests for idempotency behavior.
- Controller tests for auth, validation, and error responses.
- Payment provider tests with mocked HTTP/provider client.
- Webhook tests for valid signature, invalid signature, duplicate event, and unknown event.

Financial tests must cover:

- balanced ledger posting
- unbalanced posting rejection
- invalid transaction state transition rejection
- duplicate idempotency key behavior
- insufficient funds
- withdrawal failure reversal
- duplicate webhook no-op
- unauthorized user cannot access another user's records

## Code Quality Rules

- Use Java 21 features where they improve clarity, but avoid cleverness.
- Prefer small services with clear responsibility.
- Prefer explicit names over abbreviations.
- Validate at boundaries.
- Fail fast for invalid state.
- Keep methods short enough to review.
- Avoid inheritance-heavy designs.
- Prefer composition.
- Do not introduce new dependencies without a clear need.
- Keep warnings at zero where practical.
- Run formatter and tests before merging.

## Security Rules

- No secrets in Git.
- No default production passwords.
- CORS must be environment-specific.
- CSRF can be disabled only for stateless APIs; browser session auth requires CSRF.
- Rate-limit auth, payment, and webhook-sensitive paths.
- Use HTTPS in deployed environments.
- Validate all external input.
- Sanitize logs.
- Use least privilege for database users and provider keys.
- Admin actions must be audited.
- Security-sensitive errors should not reveal whether a user, phone, or account exists unless UX explicitly requires it and risk is accepted.

## Review Gate Before Any Module Is Merged

Do not merge a module unless:

- Flyway migrations exist and pass.
- Tests cover happy path, invalid input, unauthorized access, and critical edge cases.
- No controller talks directly to a repository.
- No cross-module repository access exists.
- No circular dependency exists.
- No secret was committed.
- API errors use the global format.
- Authorization is explicit.
- Audit path exists for sensitive operations.
- Financial operations are idempotent.
- Documentation or API contract is updated.
