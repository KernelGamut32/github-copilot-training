# Lab 02: Building a React UI for an API Using GitHub Copilot - From Initial Spec to PR

> Audience: Healthcare developers and technical leads exploring **Agentic AI** with GitHub Copilot to extend an existing API into a user‑facing application. Tools: IntelliJ IDEA Community, GitHub Copilot (Agent mode + MCP), Claude via Copilot, **Spec Kit**, **Context7** MCP server, React 18+, Vite or Create React App, Jest + React Testing Library, GitHub CLI.

---

## Learning objectives

By the end you will be able to:

1. Use **Spec Kit** to generate a **specification** for a React front‑end that integrates with a Spring Boot API.
2. Configure **IntelliJ IDEA** with GitHub Copilot and an **MCP server** to build a React app via agentic prompting.
3. Generate, refine, and deconstruct React components using **Specification‑Driven Development (SDD)**.
4. Explore **alternative refactorings** (merge, split, rollback) using agent conversations.
5. Generate **component‑based tests** automatically with GitHub Copilot.
6. Leverage **Agentic AI** to perform pull request reviews and assist in resolving feedback.

---

## Scenario (healthcare context)

You’ll build a **React UI** to consume the Spring Boot Drug Interactions API built in the prior lab (<https://github.com/KernelGamut32/drug-interactions-api-ars>). The app will allow users to:

- Search two drug names.
- View any stored interaction notes.
- Retrieve aggregated **openFDA signal** data (co‑occurrence of reactions) via the API.
- Add or update a note for a drug pair.

The lab demonstrates how **agentic AI** can generate UI code from specification, guide iteration, and handle automated review cycles.

---

## Prerequisites

- **IntelliJ IDEA Community** (with Node.js + React plugin enabled)
- **Node.js 20+**, **npm** or **yarn**
- **GitHub Copilot (Agent mode)** with Claude + **Context7** MCP configured (as in Lab 1)
- Access to the completed Spring Boot API (local or hosted)

> Tip: Ensure the API is running on `http://localhost:8080` for local integration testing.

---

## Part A — Generate the specification using Spec Kit

### A1) Initialize project and Spec Kit

Create an empty repo `drug-interactions-ui` and open it in IntelliJ.

In Copilot chat:

```text
/spec init
Create a React 18 web app named Drug Interactions UI. Pages:
- HomePage: welcome & API connection status.
- SearchPage: form to enter Drug A and Drug B → calls API /signals.
- InteractionNotesPage: displays interaction note for selected drugs, allows edit & save via /interactions.
Include global navigation and shared components for DrugForm, SignalTable, and NoteCard.
Use Material‑UI for styling.
```

Save this as `/spec/ui-spec.yml` and commit.

### A2) Constitution (design & accessibility)

In Copilot chat:

```text
/speckit.constitution
Emphasize accessibility (ARIA labels), modular React architecture, state isolation (hooks/context), SOLID principles for components, and test coverage goals (>=80%). Include guidelines for healthcare data privacy and UI disclaimers.
```

Commit the generated constitution.

---

## Part B — Configure MCP in IntelliJ

Ensure Context7 is connected for contextual lookups.

In Copilot chat:

```text
@context7 search react material-ui hooks testing-library best practices
```

Verify output; this ensures MCP contextual grounding for Claude.

---

## Part C — Generate and scaffold the React app

**Prompt C1:**

```text
@github Using /spec/ui-spec.yml, scaffold a React 18 app using Vite. Include routes: /, /search, /notes. Use Material‑UI and React Router. Implement API client with axios targeting http://localhost:8080.
Generate main App.jsx, DrugForm.jsx, SignalTable.jsx, NoteCard.jsx, and NavigationBar.jsx.
```

Run:

```bash
npm install
npm run dev
```

> Verify that the app builds and basic routes render.

---

## Part D — Refine and explore alternatives

### D1) Decompose into child components

Prompt Copilot:

```text
Split SignalTable into smaller components: SignalTableHeader, SignalRow, and ReactionChart (using Chart.js). Refactor imports accordingly.
```

Review generated code; confirm correct prop passing and types.

### D2) Merge components back (rollback)

Ask the agent:

```text
Revert to a single SignalTable component merging the chart and header inline, explaining the trade‑offs in maintainability vs. performance.
```

Observe Copilot’s explanation and diff preview.

### D3) Add context provider

Prompt:

```text
Add a React context named ApiContext to centralize axios base URL and provide a hook useApi(). Refactor components to use this hook.
```

### D4) Agentic reasoning

Ask:

```text
Explain how the component hierarchy aligns with SOLID and how inversion of control is achieved through props and context.
```

---

## Part E — Automated component testing

### E1) Generate Jest/RTL tests

Prompt Copilot:

```text
Generate Jest + React Testing Library tests for DrugForm and SignalTable components. Cover user input, API call mocks, and rendering of results.
```

### E2) Add coverage & run tests

```bash
npm test -- --coverage
```

Inspect generated coverage report (`coverage/lcov-report/index.html`).

### E3) Test-driven enhancement (stretch)

Prompt:

```text
Add a new component InteractionNoteForm with tests first. Ensure validation messages appear for missing fields.
```

---

## Part F — Agentic pull request & review

### F1) Create PR via agent

```text
@github Create a PR titled "React UI for Drug Interactions API" with summary: Adds React front‑end, integrates with API, implements tests, and adheres to SDD.
```

### F2) Conduct agent review

After PR creation:

```text
@github Review PR #<number> for accessibility and component design. Identify issues and propose fixes.
```

### F3) Apply suggestions

Prompt:

```text
Apply agent recommendations for accessibility labels and test refactors. Commit changes to the same branch.
```
