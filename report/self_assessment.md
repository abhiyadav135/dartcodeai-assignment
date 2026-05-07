# Self‑Assessment (Required)

Please be candid. This helps us understand fit and where you’d like support.

## What went well / strengths
- **Logic Correctness**: Core functions (`canProcess`, `compute_safe_delta`) strictly adhere to requirements.
- **System Thinking**: Scaling design addresses real-world constraints like backpressure and batching.
- **Code Clarity**: CLI structure is modular and easy to extend.

## What you struggled with / weaknesses
- **Benchmarking**: High variance in public API endpoints made P95 values hard to stabilize without a dedicated production key.
- **Coverage**: Manual verification was prioritized; unit tests are minimal.

## What you did not finish (and why)
- **Automated Regression Tests**: Timeboxed to 4 hours; focused on core functionality and design documentation instead.

## If you had one more day, what would you improve first?
- **Local Inference Fallback**: Implement a local model (ONNX) to ensure 100% availability during network outages.
- **Dockerization**: Containerize the app for seamless deployment.

## Confidence (1–5) in your submission
- 5/5

