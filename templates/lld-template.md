# Low-Level Design: [Module/Component Name]

**Author:** [Name]
**Date:** [Date]
**Status:** Draft | In Review | Approved
**Version:** 1.0
**Parent HLD:** [Link to HLD]

---

## 1. Overview

### 1.1 Module Purpose
[What this module does and why it exists]

### 1.2 Boundaries
- **Owns:** [What this module is responsible for]
- **Delegates:** [What it relies on other modules for]

### 1.3 Dependencies

| Dependency | Type | Purpose |
|-----------|------|---------|
| [Name] | Internal/External | [Why needed] |

### 1.4 Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | [e.g., Go 1.22] | |
| Framework | [e.g., Gin] | |
| Database | [e.g., PostgreSQL 16] | |
| Cache | [e.g., Redis 7] | |

---

## 2. Module Architecture

<!-- diagram-tool: excalidraw -->
> **[Excalidraw hero diagram]** — Generate using Excalidraw MCP `create_view`.
> Show: internal layers (API → Service → Repository), interfaces between layers,
> and connections to external systems.

---

## 3. Class/Module Design

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
classDiagram
    class Controller {
        +handleRequest(req) Response
        -validateInput(req) Error
    }
    class Service {
        +execute(cmd) Result
        -applyBusinessRules(data) Data
    }
    class Repository {
        +findById(id) Entity
        +save(entity) Error
    }
    class Entity {
        +id: UUID
        +status: Status
        +createdAt: Timestamp
        +validate() Error
    }

    Controller --> Service : uses
    Service --> Repository : uses
    Repository --> Entity : manages
```

### 3.1 Design Patterns Used

| Pattern | Where | Why |
|---------|-------|-----|
| [e.g., Repository] | Data access | Decouple business logic from DB |
| [e.g., Strategy] | [Where] | [Why] |

---

## 4. API Design

### 4.1 Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | /api/v1/resource | Create resource | Bearer |
| GET | /api/v1/resource/:id | Get resource | Bearer |
| PUT | /api/v1/resource/:id | Update resource | Bearer |
| DELETE | /api/v1/resource/:id | Delete resource | Bearer |
| GET | /api/v1/resources | List resources | Bearer |

### 4.2 Request/Response Schemas

**POST /api/v1/resource**

Request:
```json
{
  "name": "string (required, 1-255 chars)",
  "type": "enum: [typeA, typeB, typeC]",
  "metadata": {
    "key": "string"
  }
}
```

Response (201):
```json
{
  "id": "uuid",
  "name": "string",
  "type": "string",
  "status": "created",
  "metadata": {},
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601"
}
```

### 4.3 Error Codes

| Code | Message | HTTP Status | Retryable |
|------|---------|-------------|-----------|
| RESOURCE_NOT_FOUND | Resource not found | 404 | No |
| VALIDATION_ERROR | Invalid input | 400 | No (fix input) |
| CONFLICT | Resource already exists | 409 | No |
| RATE_LIMITED | Too many requests | 429 | Yes (after backoff) |
| INTERNAL_ERROR | Internal server error | 500 | Yes |
| SERVICE_UNAVAILABLE | Upstream unavailable | 503 | Yes |

### 4.4 Rate Limiting

| Endpoint | Limit | Window | Burst |
|----------|-------|--------|-------|
| POST | 100 | 1 min | 20 |
| GET | 500 | 1 min | 50 |
| LIST | 60 | 1 min | 10 |

### 4.5 Pagination

```
GET /api/v1/resources?cursor=<token>&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "token_or_null",
    "hasMore": true,
    "totalCount": 142
  }
}
```

---

## 5. API Flow

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Client
    participant GW as API Gateway
    participant Auth as Auth Service
    participant Svc as Service
    participant Cache as Cache
    participant DB as Database
    participant Queue as Event Queue

    Client->>GW: POST /api/v1/resource
    GW->>Auth: Validate token
    Auth-->>GW: Valid
    GW->>Svc: Forward request
    Svc->>Svc: Validate input
    Svc->>DB: Insert record
    DB-->>Svc: Created
    Svc->>Cache: Invalidate cache
    Svc->>Queue: Emit ResourceCreated event
    Svc-->>GW: 201 Created
    GW-->>Client: 201 + resource body
```

---

## 6. Database Design

### 6.1 Schema

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
erDiagram
    resources {
        uuid id PK
        varchar name "NOT NULL"
        varchar type "NOT NULL"
        varchar status "DEFAULT 'created'"
        jsonb metadata "DEFAULT '{}'"
        timestamp created_at "NOT NULL"
        timestamp updated_at "NOT NULL"
        timestamp deleted_at "NULL (soft delete)"
    }

    resource_events {
        uuid id PK
        uuid resource_id FK
        varchar event_type "NOT NULL"
        jsonb payload "NOT NULL"
        timestamp created_at "NOT NULL"
    }

    resources ||--o{ resource_events : "has many"
```

### 6.2 Index Strategy

| Table | Index Name | Columns | Type | Purpose |
|-------|-----------|---------|------|---------|
| resources | idx_resources_status | status, created_at | B-tree | Filter by status + sort |
| resources | idx_resources_type | type | B-tree | Filter by type |
| resources | idx_resources_name_gin | name | GIN (trigram) | Full-text search |
| resource_events | idx_events_resource | resource_id, created_at | B-tree | Event lookup |

### 6.3 Migration Strategy
- Use versioned migrations (e.g., golang-migrate, Flyway, Alembic)
- All migrations must be reversible
- Test migrations on a copy of production data before deploying

---

## 7. Event Design

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart LR
    subgraph Producers["Producers (Blue)"]
        SVC[Service]
    end

    subgraph Broker["Message Broker (Grey)"]
        T1[resource.created]
        T2[resource.updated]
        T3[resource.deleted]
        DLQ[Dead Letter Queue]
    end

    subgraph Consumers["Consumers (Green)"]
        N[Notification Service]
        A[Analytics Service]
        S[Search Indexer]
    end

    SVC --> T1
    SVC --> T2
    SVC --> T3
    T1 --> N
    T1 --> A
    T2 --> S
    T3 --> S
    T1 -.->|"3 retries failed"| DLQ
    T2 -.->|"3 retries failed"| DLQ

    style Producers fill:#E3F2FD,stroke:#4A90D9
    style Broker fill:#FAFAFA,stroke:#9E9E9E
    style Consumers fill:#E8F5E9,stroke:#7CB342
```

### 7.1 Event Schema
```json
{
  "id": "uuid",
  "type": "resource.created",
  "source": "service-name",
  "timestamp": "ISO-8601",
  "data": {
    "resourceId": "uuid",
    "changes": {}
  },
  "metadata": {
    "correlationId": "uuid",
    "version": 1
  }
}
```

---

## 8. State Machine

<!-- diagram-tool: mermaid -->
```mermaid
%%{init: {'theme': 'neutral'}}%%
stateDiagram-v2
    [*] --> Created
    Created --> Active : activate()
    Created --> Cancelled : cancel()
    Active --> Suspended : suspend()
    Active --> Completed : complete()
    Suspended --> Active : resume()
    Suspended --> Cancelled : cancel()
    Completed --> [*]
    Cancelled --> [*]
```

### 8.1 Transition Rules

| From | To | Trigger | Guard Condition |
|------|----|---------|-----------------|
| Created | Active | activate() | All required fields set |
| Active | Suspended | suspend() | Admin only |
| Suspended | Active | resume() | Suspension reason resolved |

---

## 9. Error Handling

### 9.1 Error Taxonomy

| Category | Example | Action |
|----------|---------|--------|
| Validation | Missing field | Return 400 immediately |
| Business | Duplicate name | Return 409 immediately |
| Transient | DB timeout | Retry with backoff |
| Fatal | Schema mismatch | Alert + fail fast |

### 9.2 Retry Strategy

```yaml
retry:
  maxAttempts: 3
  initialDelay: 100ms
  maxDelay: 5s
  multiplier: 2.0
  retryableErrors:
    - DEADLINE_EXCEEDED
    - UNAVAILABLE
    - RESOURCE_EXHAUSTED
```

### 9.3 Circuit Breaker

```yaml
circuitBreaker:
  failureThreshold: 5        # trips after 5 failures
  successThreshold: 3         # resets after 3 successes
  timeout: 30s                # half-open after 30s
  monitoredExceptions:
    - TimeoutException
    - ConnectionRefused
```

### 9.4 Fallback Behavior
| Scenario | Fallback |
|----------|----------|
| Cache miss | Read from DB |
| Primary DB down | Read from replica (stale read) |
| Event queue down | Write to outbox table, process later |

---

## 10. Configuration

```yaml
# config.yaml — defaults
server:
  host: 0.0.0.0
  port: 8080
  readTimeout: 30s
  writeTimeout: 30s

database:
  host: localhost
  port: 5432
  name: mydb
  maxConnections: 25
  idleConnections: 5
  connMaxLifetime: 5m

cache:
  host: localhost
  port: 6379
  ttl: 5m
  maxRetries: 3

features:
  enableNewFlow: false
  enableBetaAPI: false

# Environment overrides (via env vars):
# SERVER_PORT=9090
# DATABASE_HOST=prod-db.internal
# FEATURES_ENABLE_NEW_FLOW=true
```

---

## 11. Testing Strategy

### 11.1 Test Pyramid

| Level | Count Target | What to Test |
|-------|-------------|-------------|
| Unit | ~80% | Business logic, validation, transformations |
| Integration | ~15% | DB queries, cache ops, API contracts |
| E2E | ~5% | Critical user journeys |

### 11.2 Key Test Scenarios

| Scenario | Type | Priority |
|----------|------|----------|
| Create resource — happy path | Integration | P0 |
| Create resource — duplicate name | Unit | P0 |
| State transition — invalid | Unit | P1 |
| API auth — expired token | Integration | P1 |
| Concurrent updates — optimistic lock | Integration | P1 |

### 11.3 Mocking Strategy
- External APIs: use interface stubs / HTTP record-replay
- Database: use testcontainers for integration, in-memory for unit
- Events: use in-memory broker for integration tests

---

## 12. Security

### 12.1 Authentication & Authorization
- Auth method: [JWT / OAuth2 / API Key]
- Token validation: [At gateway / per-service]
- RBAC roles: Admin, Editor, Viewer

### 12.2 Input Validation Rules

| Field | Rule |
|-------|------|
| name | 1-255 chars, alphanumeric + hyphens |
| type | Enum whitelist |
| metadata keys | Max 50 keys, key length ≤ 64 |

### 12.3 Encryption
- **At rest:** AES-256 for PII columns, KMS-managed keys
- **In transit:** TLS 1.3 for all service-to-service communication
- **Secrets:** Vault / AWS Secrets Manager — never in config files

### 12.4 OWASP Checklist

| Item | Status |
|------|--------|
| SQL injection prevention (parameterized queries) | ☐ |
| XSS prevention (output encoding) | ☐ |
| CSRF protection | ☐ |
| Rate limiting | ☐ |
| Security headers (CSP, HSTS, etc.) | ☐ |
| Dependency vulnerability scanning | ☐ |

---

## Appendix

### A. Glossary
| Term | Definition |
|------|-----------|
| [Term] | [Definition] |

### B. References
- [Link to HLD]
- [Link to API docs]
