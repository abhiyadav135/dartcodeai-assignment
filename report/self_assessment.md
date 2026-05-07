# Self‑Assessment (Required)

Please be candid. This helps us understand fit and where you’d like support.

## What went well / strengths
- **Full Verification**: All core tasks (1, 2, 3) were verified using a local Dart/Python environment. 
- **Resilient Logic**: Task 1 handles API failures (404/500) gracefully, and Task 2 prevents cost overruns through integrated quota checks.
- **Production Performance**: Implemented parallel fetching for embeddings, reducing latency.

## What you struggled with / weaknesses
- **Environment Setup**: Initial path issues with Dart were resolved by local SDK deployment, but showed the importance of containerization for portability.

## What you did not finish (and why)
- **Local Fallback (In-Code)**: While designed in the report, the actual implementation of an ONNX fallback model was out of scope for the 4-hour window.

## If you had one more day, what would you improve first?
- **Full Dockerization**: Wrap the Dart and Python environments in a single Docker Compose setup for instant reproducibility.
- **Unit Test Suite**: Expand the verification scripts into a formal `test/` directory with `test` and `pytest`.

## Confidence (1–5) in your submission
- 5/5

