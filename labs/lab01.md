# Lab 01: Building from an API Using GitHub Copilot - From Initial Spec to PR

## Audience

Healthcare devs, SDETs, and technical leaders evaluating agentic workflows in regulated domains. Tools: IntelliJ IDEA Community, GitHub Copilot (Agent mode + MCP), Claude (via Copilot), Spec‑Driven Development with Spec Kit, Context7 MCP server, Spring Boot 3.x, Maven, JUnit 5, Mockito, WireMock, GitHub CLI.

---

## Learning objectives

By the end of this lab you will be able to:

- Use Spec Kit to generate a specification and project constitution for a Spring Boot API.
- Configure GitHub Copilot (agent mode) in IntelliJ to use an MCP server (Context7) for up‑to‑date docs.
- Feed the spec to Copilot, generate & refine a Spring Boot Drug Interactions API that integrates with openFDA.
- Prompt Copilot to create unit tests (TDD & non‑TDD) and integration tests with mocked external data.
- Apply SOLID & loose coupling in the service design.
- Have the agent open a pull request with your changes.

---

## Scenario & architecture (healthcare context)

You’re building a Drug Interactions micro‑service for a hospital’s formulary portal. The service must:

- Store internal "interaction notes" (local knowledge base) for drug pairs.
- Provide an endpoint to query openFDA adverse event reports related to two supplied drug names aggregating counts/most common reactions for classroom demo purposes.
- Expose clean APIs with input validation and good error messages.
- Follow SOLID: hexagonal/ports‑and‑adapters style with OpenFdaClient as a port and a WebClient adapter.

---

## Prerequisites (10 min)

- IntelliJ IDEA Community installed.
- Git, Java 21, Maven 3.9+.
- GitHub account with Copilot enabled (Business/Enterprise/Pro+ per your org).
- Repo stub: Create an empty GitHub repo (e.g., drug-interactions-api-*initials*). Clone locally.
- Open project in IntelliJ, referencing the cloned repository folder

---

## Part A — Initialize the spec with Spec Kit

### A1) Install Spec Kit CLI

See <https://docs.astral.sh/uv/getting-started/installation/> for `uvx` installation instructions. spec-kit is available at <https://github.com/github/spec-kit>.

`uvx --from git+https://github.com/github/spec-kit.git specify --help`

### A2) Generate a project constitution (S.D.D. guardrails)

In your repo root, in GitHub Copilot chat:

```text
/speckit.constitution
Create principles emphasizing: SOLID, hexagonal architecture, WebClient over RestTemplate, UUIDs, Bean Validation, unit tests with Mockito & AssertJ, integration tests with WireMock, 80%+ line/branch coverage on service layer, security basics, reproducible builds, and style via Spotless. Include accessibility in API docs.
```

This should produce `speckit.constitution`. Commit it.

### A3) Draft the OpenAPI spec with Spec Kit

In your repo root, in GitHub Copilot chat:

```text
/spec init
Create an OpenAPI 3.1 spec named Drug Interactions API. Resources:
- POST /interactions: upsert an interaction note for a drug pair {drugA, drugB, note}.
- GET /interactions?drugA&drugB: fetch interaction note if present.
- GET /signals?drugA&drugB&limit=50: call openFDA drug/event to aggregate records where both names appear in patient.drug.medicinalproduct; return {count, topReactions[reaction, n]}.
- Validations: drug names 3–60 chars, alphabetic + spaces/hyphens.
- Errors: 400 validation, 404 for missing note, 502 for upstream errors.
- Security: none (classroom).
- Tags, examples, and JSON schemas.
```

This should generate a file called `openapi.yaml`. This file may contain errors and/or warnings. If it does, try submitting `Fix the identified errors and warnings in this file` with `openapi.yaml` referenced. You might also try regenerating the spec. Save the spec as `openapi.yaml` in `/spec` and commit.

---

## Part B — Configure MCP in IntelliJ with Context7

### B1) Enable MCP client in IntelliJ for Copilot (Agent mode)

In IntelliJ, open **File → Settings → Tools → GitHub Copilot → Model Context Protocol (MCP)** and click **Configure**. This should generate a `mcp.json` configuration file.

### B2) Register Context7 MCP

Context7 MCP servers are accessible at <https://github.com/upstash/context7>.

Use stdio with npx:

```json
{
    "servers": {
        "context7": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@upstash/context7-mcp", "--api-key", "CONTEXT7_API_KEY"]
        }
    }
}
```

Start the server to verify connection. In Copilot chat, run: @context7 help.

Why Context7? It gives agents up‑to‑date code/doc context (handy for API fields while crafting queries to openFDA) without hardcoding links.

---

## Part C — Ask Copilot (Claude) to scaffold the project

In Copilot Chat, from repo root, use these prompts (paste verbatim):

### Prompt C1 — Generate Spring Boot project

```text
@github Using the /spec/openapi.yaml, scaffold a Spring Boot 3.3 Maven project named drug-interactions-api. Create modules:
:app (web/controller), :domain (model + ports), :adapters:openfda (WebClient adapter), :adapters:memory (in‑memory repo), :tests (shared test fixtures). Add dependencies: spring-boot-starter-web, validation, spring-boot-starter-test, jackson-databind, reactor-netty, wiremock-jre8, mockito, assertj, lombok (optional), spotless.
Adopt hexagonal architecture: controllers -> service (domain) -> ports; adapters implement ports. Generate code and wire configuration.
```

### Prompt C2 — Implement domain & ports

```text
Create domain model:
record DrugPair(String drugA, String drugB);
record InteractionNote(UUID id, DrugPair pair, String note, Instant updatedAt);
Port InteractionRepository { Optional<InteractionNote> find(DrugPair); InteractionNote upsert(InteractionNote); }
Port OpenFdaClient { Mono<OpenFdaSignal> fetchSignals(String drugA, String drugB, int limit); }
record OpenFdaSignal(long count, List<Map.Entry<String,Long>> topReactions);
Add service InteractionService with methods for notes and signals. Enforce validation & normalize names.
```

### Prompt C3 — Web adapter & DTOs

```text
Generate or update controllers:
POST /interactions {drugA,drugB,note}
GET /interactions?drugA&drugB
GET /signals?drugA&drugB&limit=50
Use jakarta validation on inputs; map domain <-> dto; global exception handler for 400/404/502.
```

### Prompt C4 — openFDA adapter

```text
Implement or update OpenFdaClient with WebClient using base https://api.fda.gov/drug/event.json. Build search where both drug names appear (case-insensitive) in patient.drug.medicinalproduct. Use fields aggregation on reactionmeddrapt. Map to OpenFdaSignal with top reactions and total count. Handle rate limits and errors; map upstream failures to 502.
```

> Sanity check: Let Copilot run, generate code, and commit.

---

## 💼 Activities: Using Copilot to Define and Enforce Business Rules

These exercises illustrate how to move beyond code generation and use Copilot + Claude to **enforce business logic and healthcare‑specific constraints** within your API. They can be performed after initial scaffolding is complete.

### **Activity 1: Define domain‑specific business rules**

**Objective:** Use Copilot to codify healthcare rules directly in code.

> 💬 **Prompt example**

```text
Add business rules to InteractionService:
1. Do not allow saving an interaction note where drugA == drugB.
2. Limit note length to 1000 characters.
3. Require at least one of the drugs to be on the hospital formulary list (mocked list).
Explain how these rules should be validated and how errors should be surfaced.
```

---

### **Activity 2: Enforce the rules through TDD**

**Objective:** Use test‑first generation to lock in business logic.

> 💬 **Prompt example**

```text
Write JUnit 5 tests verifying these business rules:
- reject identical drugs,
- reject notes >1000 chars,
- accept valid pairs.
Generate tests first (TDD style) and then minimal implementation to pass them.
```

---

### **Activity 3: Refactor rules into a dedicated policy class**

**Objective:** Show how Copilot supports modular rule enforcement.

> 💬 **Prompt example**

```text
Refactor validation logic into a new component InteractionPolicy that encapsulates all business rules.
Explain how this improves maintainability and aligns with SOLID principles.
```

---

### **Activity 4: Explore rule exceptions through agentic reasoning**

**Objective:** Negotiate rule variations interactively with Copilot.

> 💬 **Prompt example**

```text
Pharmacy input: allow non‑formulary drugs if the note includes the phrase 'clinical justification'.
Update validation to accommodate this exception and explain the trade‑offs.
```

---

### **Activity 5: Add auditing for compliance**

**Objective:** Extend rules to include audit trails and logging.

> 💬 **Prompt example**

```text
Instrument InteractionPolicy to log each rejected note with violated rule, timestamp, and user ID (mocked).
Suggest a consistent JSON logging format suitable for compliance auditing.
```

---

## Part D — Refine with prompts (understanding + SOLID)

Use these prompts to review/refactor:

- **Explain the code:**

```text
Walk me through how the controller depends on the domain service and how the WebClient adapter honors SOLID (single responsibility, dependency inversion). Identify any tight coupling or static calls and propose improvements.
```

- **Refactor for testability:**

```text
Refactor WebClient construction into a @Configuration with a Builder bean, inject timeouts and base URL via properties, and add retry policy (exponential backoff) only for Idempotent GETs.
```

- **Add mapping & validation polish:**

```text
Add Bean Validation to ensure drug names are 3–60 chars (letters, spaces, hyphens). Return ProblemDetails JSON for validation errors.
```

---

## Part E — Testing with Copilot

---

## ⚡ Activities: Using Copilot and Claude for Request Size Measurement & Performance Testing

These exercises extend Lab 1 by demonstrating how to use **GitHub Copilot** and **Claude (via Agent mode)** to measure performance, request sizes, and enforce performance best practices within your Spring Boot API.

### **Activity 1 — Instrument the API for request/response measurement**

**Objective:** Add automatic metrics logging for payload size and latency.

> 💬 **Prompt example**

```text
Add request and response metrics to all /signals and /interactions endpoints.
Track request body size (bytes), response size, and total processing time.
Use Spring's HandlerInterceptor or WebFilter to capture metrics and log them to a dedicated logger named 'PerformanceMetrics'.
```

---

### **Activity 2 — Agent-Assisted Profiling with Mock Loads**

**Objective:** Use the agent to simulate synthetic load and analyze results.

> 💬 **Prompt example**

```text
Generate a JMeter or k6 script to test/signals endpoint with 10, 50, and 200 concurrent users.
Include parameters for varying payload sizes and show how to capture response times and error rates.
```

> 🧠 *Follow-up prompt:* Summarize how response latency scales with request size and concurrency, then propose classroom demo thresholds.

---

### **Activity 3 — Automated Performance Testing via JUnit (Copilot)**

**Objective:** Have Copilot generate performance guardrails inside test suites.

> 💬 **Prompt example**

```text
Write a JUnit 5 test that calls the /signals endpoint 100 times asynchronously
and asserts that the 95th percentile response time is below 250 ms.
Use System.nanoTime() or a simple benchmarking library.
```

---

### **Activity 4 — Diagnose and Optimize with Agentic AI**

**Objective:** Use Copilot + Claude to analyze and optimize code for performance.

> 💬 **Prompt example**

```text
Analyze InteractionService for performance bottlenecks when calling openFDA.
Suggest caching strategies, reactive optimizations, or batch requests to improve throughput.
```

---

### **Activity 5 — Automated PR-Based Performance Review**

**Objective:** Demonstrate automated agentic review focused on performance.

> 💬 **Prompt example**

```text
@github Review PR #<number> focusing on performance. Identify blocking calls, redundant serialization, or inefficient logging, and propose fixes.
```

---

### E1) TDD for domain service

**Prompt E1:**

```text
Write JUnit 5 tests for InteractionService using Mockito for the ports. Scenarios: (1) normalize names to lowercase/trim; (2) upsert returns updated note; (3) calling OpenFdaClient aggregates correctly; (4) invalid inputs -> ConstraintViolationException.
Generate failing tests first (TDD), then implement the minimal code to pass them.
```

### E2) Non‑TDD unit tests

**Prompt E2:**

```text
Generate additional unit tests for the controller layer using @WebMvcTest, mocking InteractionService. Cover 400 and 404 flows.
```

### E3) Integration tests with WireMock

**Prompt E3:**

```text
Create @SpringBootTest integration tests that start WireMock on a random port, inject that as openFDA base URL, and stub:
- 200 with a payload containing multiple patient.reaction.* entries — assert top reactions and count.
- 429/500 responses — assert we map to 502 ProblemDetails.
Also include a test for non‑ASCII drug names.
```

```text
WireMock stub example:
{
  "request": {"method": "GET", "urlPath": "/drug/event.json", "queryParameters": {"search": {"contains": "patient.drug.medicinalproduct"}}},
  "response": {"status": 200, "jsonBody": {"results": [{"patient": {"reaction": [{"reactionmeddrapt": "Headache"}, {"reactionmeddrapt": "Nausea"}]}}], "meta": {"results": {"total": 123}}}}
}
```

---

## Part F — Integration with openFDA: query design

Have Copilot generate the exact query it uses.

```text
Show the full URL it would call against https://api.fda.gov/drug/event.json for drugA="warfarin" and drugB="amiodarone" with limit=50. Use case-insensitive search on patient.drug.medicinalproduct and aggregate reactionmeddrapt counts. Explain the query params.
```

Then run the app and test:

```bash
mvn -q -DskipTests spring-boot:run
curl "http://localhost:8080/signals?drugA=warfarin&drugB=amiodarone&limit=50" | jq
```

---

## Part G — Agent‑originated Pull Request

```text
@github Create a PR titled "Drug Interactions API: initial implementation with openFDA integration". Include a description, list key endpoints, note SOLID/hexagonal design, and summarize tests. Target main from feature/initial.
```

---

## Prompt appendix (copy/paste)

1. **Explain design choices:**

```text
Explain how the design adheres to SOLID. Identify possible refactorings to further decouple the controller from the openFDA adapter.
```

2. **Generate DTO mappers:**

```text
Create MapStruct mappers for InteractionNote <-> DTOs. Add unit tests.
```

3. **Improve error handling:**

```text
Add a ControllerAdvice returning RFC 7807 ProblemDetails with specific error codes for upstream failures and validation errors.
```

4. **Extend features:**

```text
Add optional query param "+reactionFilter" to /signals to restrict aggregation to a subset of reactions.
```

5. **Docs:**

```text
Generate SpringDoc OpenAPI UI config and write sections in README on setup, running, and curl examples.
```
