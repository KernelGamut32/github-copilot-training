# Lab 03: Enhancing an Existing API to Add Database Using GitHub Copilot

This lab will reinforce key concepts related to using GitHub Copilot to accomplish development tasks like adding a database to an existing Java application. It will target agent-based code creation (like a pair programmer) and demonstrate iterative development, moving an application approach through multiple layers of evolution.

1. Verify that you are still running in the previous Visual Studio Code workspace (where the Java API exists)
2. Open the GitHub Copilot chat and confirm that `Agent` is selected alongside a Claude model (e.g., `Claude Sonnet 4`)
3. Post the following spec to GitHub Copilot chat and submit:

```text
You are my AI pair programmer. We’ll add a persistent datastore to replace the in-memory data store in the Java API defined in this workspace:

catalog-service — Add a SQLite database to the Java API. All of the following should be accounted for:
    - --table for artists
    - --table for tracks
    - --appropriate relationships between the two based on previously defined specs
    - --data access code consistent with proper Spring Boot and JPA standards (make sure you maintain good partitioning in the code)
    - --if necessary, adjust the design to ensure that the data access approach is sufficiently isolated from the rest of the API (loose coupling and follow SOLID principles) - I may want to change the data approach to NoSQL in the future and I want that change to be as minimally disruptive as possible
Add unit tests for any new code and make sure you are taking advantage of Mockito to sufficiently isolate testing at the "unit" level. Also, make any required updates to the generated file tree. Finally, make sure all unit tests pass and verify that the application continues to function end-to-end.
```

4. Review the commentary provided by GitHub Copilot, including any errors uncovered during the generation/build and any mitigating steps the Agent took to proactively address
5. Explore the generated code
6. Click `Keep` for each chat-generated file to accept the generated code
7. Ask Copilot to update the data access layer to use NoSQL instead...
8. With each step, review carefully what Copilot responds with in terms of commentary, approach, errors encountered, and steps taken to resolve any errors (in essence, validating and correcting itself as it goes)
9. Make sure you save the Java project (or use Auto Save in Visual Studio Code)
