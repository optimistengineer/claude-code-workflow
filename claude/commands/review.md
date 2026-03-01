Review the following code or design: $ARGUMENTS

First, **read all target files** thoroughly. If $ARGUMENTS is a directory, read the key files within it. If it's a design doc, read the full document. Never review code you haven't read.

## Review Categories (5 total)

Evaluate across each category using a 3-level scale: **Pass**, **Warn**, **Fail**.

### 1. Correctness
- Does the logic handle edge cases?
- Are error paths covered?
- Are types/contracts satisfied?
- Are there off-by-one errors, race conditions, or null reference risks?

### 2. Design
- Does it follow SOLID principles?
- Is the abstraction level appropriate?
- Are responsibilities clearly separated?
- Is the code/design extensible without modification (open-closed)?
- Are there unnecessary abstractions or premature generalizations?

### 3. Performance
- Are there N+1 queries, unbounded loops, or memory leaks?
- Is caching used where appropriate?
- Are database queries indexed?
- Are there blocking calls that should be async?
- Will this scale to 10x current load?

### 4. Security
- Is input validated and sanitized?
- Are there injection risks (SQL, XSS, command)?
- Is authentication/authorization enforced?
- Are secrets hardcoded or logged?
- Does it follow least-privilege principle?

### 5. Maintainability
- Is the code readable without excessive comments?
- Are names descriptive and consistent?
- Is test coverage adequate?
- Is the error handling informative (not swallowing errors)?
- Would a new team member understand this in 15 minutes?

## Output Format

```
## Review Summary

| Category        | Status | Key Finding                    |
|-----------------|--------|--------------------------------|
| Correctness     | ✅/⚠️/❌ | ...                           |
| Design          | ✅/⚠️/❌ | ...                           |
| Performance     | ✅/⚠️/❌ | ...                           |
| Security        | ✅/⚠️/❌ | ...                           |
| Maintainability | ✅/⚠️/❌ | ...                           |

## Detailed Findings
(grouped by category, with file:line references)

## Prioritized Action Items
1. [MUST] ...
2. [MUST] ...
3. [SHOULD] ...
4. [COULD] ...
```

Order action items by: MUST (blocking) → SHOULD (important) → COULD (nice-to-have).
