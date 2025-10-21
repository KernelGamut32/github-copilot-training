# Lab 03: Refactoring Legacy JSP Code with Agentic AI (Claude) + GitHub Copilot in IntelliJ IDEA Community Edition

**Target Audience:** Healthcare developers modernizing legacy Java web modules  
**Objective:** Use Agentic AI (Claude) via GitHub Copilot to refactor an insecure, monolithic `.jsp` file into a clean, componentized Spring Boot + Thymeleaf application with tests, guided by a specification generated through Spec Kit and the Context7 MCP server.

---

## 💡 Learning Objectives

By the end of this lab, participants will be able to:

1. Generate a **specification** for a refactor using **Spec Kit**.  
2. Pair **GitHub Copilot Agentic AI (Claude)** with **Context7 MCP Server** to interpret and implement the spec.  
3. **Convert** a legacy `.jsp` file into a **Spring Boot MVC + Thymeleaf** application.  
4. Apply modern design practices:
   - Replace scriptlets with Thymeleaf EL.
   - Move business logic to **Service** and **Repository** layers.
   - Parameterize SQL and manage connections safely.
   - Fix shared mutable state and concurrency issues.
   - Add validation, error handling, and security.
   - De-duplicate view fragments and promote reusability.
5. Generate **robust JUnit tests** for the refactored code.

---

## Prerequisites

- **IntelliJ IDEA Community**
- **GitHub Copilot (Agent mode)** with Claude + **Context7** MCP configured

---

## Part A — Configure MCP in IntelliJ

Ensure Context7 is connected for contextual lookups.

In Copilot chat:

```text
@context7 Review the legacy.jsp file and tell me what you see in terms of architectural deficiency, bad practice, and potential problem areas (if any).
```

Verify output; this ensures MCP contextual grounding for Claude.

---

## Part B — Generate the specification using Spec Kit

### B1) Initialize project and Spec Kit

Create an empty repo `agentic-legacy`, open it in IntelliJ, and add the `legacyDashboard.jsp` file to it.

In Copilot chat:

```text
/speckit.constitution Review the legacyDashboard.jsp file for violations of modern architectural practices. Recommend a set of architectural guidelines that can be used to modernize this legacy implementation, bringing it in alignment with today's standards and best practices for design, security, state management, database integration, and SOLID.
```

Commit the generated constitution.

```text
/speckit.specify I want to build a modernized web UI to replace the legacy functionality in legacyDashboard.jsp. I'm looking for good separation of concerns and robust architectural implementation.
```

```text
/speckit.plan Please scaffold an initial Spring Boot MVC + Thymeleaf application that I can use as a user-friendly replacement for the legacy implementation in legacyDashboard.jsp.
```

Execute `/speckit.tasks` and `/speckit.implement`

---

## Part C — Building the App

**Prompt C1:**

```text
Using spec/legacyDashboard.yaml, scaffold an initial Spring Boot MVC + Thymeleaf application according to the spec.
```

**Prompt C2:**

```text
Enhance with a Thymeleaf template that replaces the JSP scriptlet loops and uses th:each for user listing.
```

**Prompt C3:**

```text
Generate a Spring Data JPA repository for User with findByNameContainingOrEmailContaining.
```

**Prompt C4:**

```text
Remove thread-unsafe shared state and use connection pooling via Hikari.
```

**Prompt C5:**

```text
Add @ControllerAdvice for global exception handling.
```

**Prompt C6:**

```text
Add validation annotations for User fields and HTML escaping in Thymeleaf.
```

**Prompt C7:**

```text
Create Thymeleaf fragment templates for header and footer.
```

**Prompt C8:**

```text
Refactor duplicated HTML rows into a reusable Thymeleaf fragment.
```

**Prompt C9:**

```text
Add unit tests using JUnit 5 and Mockito to cover all CRUD operations.
```
