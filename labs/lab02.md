# Lab 02: Building an API Client from a Spec Using GitHub Copilot

This lab will reinforce key concepts related to using GitHub Copilot to generate a client application for an existing Java microservice guided by a defined spec. It will target agent-based code creation (like a pair programmer) and specs will instruct the agent to use TDD as the strategy for generating the tests and then the client code. While you may not see differences in the final results, it will allows us to explore the capabilities of Copilot as a pair programmer to follow an established pattern for testing.

1. Verify that you are still running in the previous Visual Studio Code workspace (where the Java API exists)
2. Open the GitHub Copilot chat and confirm that `Agent` is selected alongside a Claude model (e.g., `Claude Sonnet 4`)
3. Post the following spec to GitHub Copilot chat and submit:

```text
You are my AI pair programmer. We’ll build a new React client for the Java API code captured in this workspace:

react-playlist — React 19 client application that provides a UI for CRUD functions available in the catalog-service API in this workspace. I want you to use TDD - create the unit tests for the client application, and then generate just enough code for the client application to enusre all defined tests pass. The final client solution should consume the catalog-service API via HTTP, supporting:
    - --artist "Artist Name" → fetch tracks by artist;
    - --top N → limit to N tracks;
    - --create new artist
    - --update existing artist
    - --retrieve all artists
    - --create new tracks
    - --update existing track
    - --associate an artist to a track
    - Prints a playlist summary table with artist and track information.
```

4. Review the commentary provided by GitHub Copilot, including any errors uncovered during the generation/build and any mitigating steps the Agent took to proactively address
5. Explore the generated code
6. Click `Keep` for each chat-generated file to accept the generated code
7. If the agent helped launch the application for you, confirm that the application is working as expected
8. If not, submit the following prompt: `What steps do I need to take to run the API and client applications together so I can test end-to-end?`
9. Pick one of the defined React components (something that appears to be more complex) and ask Copilot to explain its design and operation to you
10. Submit the following prompt: `Update the styling of the application...`
11. Submit the following prompt: `Generate and store a file tree in the workspace that details out the file structure of the two applications in a clear and concise manner.`
12. With each step, review carefully what Copilot responds with in terms of commentary, approach, errors encountered, and steps taken to resolve any errors (in essence, validating and correcting itself as it goes)
13. Make sure you save the Java project (or use Auto Save in Visual Studio Code)
