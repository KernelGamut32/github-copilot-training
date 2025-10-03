# Lab 01: Building from an Initial Spec Using GitHub Copilot

This lab will reinforce key concepts related to using GitHub Copilot to generate a Java API from a defined spec. It will target agent-based code creation (like a pair programmer) focusing first on the generation of code for an API built using Spring Boot and the JDK.

1. In Visual Studio Code, open the GitHub Copilot chat and confirm that `Agent` is selected alongside a Claude model (e.g., `Claude Sonnet 4`)
2. Post the following spec to GitHub Copilot chat and submit:

```text
You are my AI pair programmer. We’ll build a new Java API:

catalog-service — Spring Boot 3.3, JDK 21, Maven. Expose:
    - GET /api/v1/tracks → returns JSON array of Track {id: long, title: string, artist: string, durationSec: int, genre: string}
    - GET /api/v1/tracks/{id} → returns one Track or 404.
    - Seed with 8–10 sample tracks in memory (no DB).
    - Provide an OpenAPI 3.0 description (YAML) under src/main/resources/openapi/catalog.yaml.
    - Add validation, error handling (ProblemDetail JSON), and basic logging.
```

3. Review the commentary provided by GitHub Copilot, including any errors uncovered during the generation/build and any mitigating steps the Agent took to proactively address
4. Explore the generated code
5. Click `Keep` for each chat-generated file to accept the generated code
6. Switch Copilot to `Ask` and submit the following prompt: `What steps do I need to take to run this API and test using cURL or POSTMan?`
6. Run the API and verify operation via cURL or POSTMan
7. In Copilot, switch back to `Agent` and submit the following prompt: `Please generate Swagger endpoints for this API`. **NOTE:** In testing, Copilot errored a few times throughout generation; `Try Again` was used repeatedly to complete.
8. If Copilot offers to start up the application to verify Swagger endpoints, click `Allow` (you may be prompted for `Allow` at multiple steps along the way).
9. If there are errors called out by Copilot, click `Allow` to enable Copilot to attempt to correct - this may be a multi-step process but it highlights the collaborative nature of Copilot.
10. If Copilot did not offer to start up the application, switch to `Ask` and submit the following prompt: `What steps do I need to take to run this API and test the Swagger endpoints via browser?`
11. Follow the provided steps to confirm API successfully operates via its Swagger endpoints
12. Using `Ask` in Copilot, submit the following prompt: `Explain to me the end-to-end process used by the API to provide the "get all tracks" functionality`
13. Using `Ask` in Copilot, submit the following prompt: `Explain to me the end-to-end process used by the API to provide the "get track by ID" functionality`
14. Switch to `Edit` in Copilot, and submit the following prompt: `Update the application to include operations for adding a new track, updating and existing track, and deleting an existing track. Make sure you include proper code aligned by application "tier" (i.e., controller, service, etc.).`
15. Using `Edit` in Copilot, submit the following prompt: `Update the application to include artists with operations to support CRUD for artists`
16. Using `Edit` in Copilot, submit the following prompt: `Implement a relationship in the API operations between artists and tracks. For this purpose, assume an artist can have multiple tracks but that a track only has a single artist.`
