# Generate API and Integrations Using GitHub Copilot

```spec
You are my AI pair programmer. We’ll build two Java projects:

1. catalog-service — Spring Boot 3.3, JDK 21, Maven. Expose:
    - GET /api/v1/tracks → returns JSON array of Track {id: long, title: string, artist: string, durationSec: int, genre: string}
    - GET /api/v1/tracks/{id} → returns one Track or 404.
    - Seed with 8–10 sample tracks in memory (no DB).
    - Provide an OpenAPI 3.0 description (YAML) under src/main/resources/openapi/catalog.yaml.
    - Add validation, error handling (ProblemDetail JSON), and basic logging.
2. playlist-cli — Java 21 console app (Maven). It consumes catalog-service via HTTP, supports:
    - --artist "Artist Name" → fetch tracks by artist;
    - --top N → limit to N tracks;
    - Prints a playlist summary table with totals.
3. Generate a short README.md and basic JUnit tests for both.
Create a high-level plan first. Then scaffold both projects and show the proposed file tree."
```
