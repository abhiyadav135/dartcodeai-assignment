# System Design — Scaling to 10k req/min

To handle 10k RPM (~167 RPS), the system requires a distributed, resilient architecture building on the core logic implemented in Tasks 1-3.

### Batching & Concurrency
Building on the **Parallel Fetching** (Task 1), individual requests should be aggregated into larger batches (e.g., 32 strings) before calling the inference endpoint. This maximizes GPU utilization and minimizes network RTT.

### Multi-Level Caching
A Redis-based LRU cache should store text-to-vector mappings. The current modular fetching logic makes it easy to inject a caching layer before the API call.

### Backpressure & Quota Rejection
The **Integrated Quota Enforcement** (Task 2) should be moved to the API Gateway level. By rejecting over-limit requests at the edge using the `canProcess` logic, we save downstream compute and inference resources.

### Resilience & Retries
Client-side retries must include jittered exponential backoff. The implemented timeout handling in Dart provides the foundation for failing fast and triggering circuit breakers.

### Observability
Leverage the **Safe Analytics Delta** (Task 3) logic to compute throughput and data ingestion rates accurately, even during system restarts or telemetry spikes. Export these metrics to Prometheus for P95 latency monitoring.

### Fallback & Degraded Mode
If the primary GPU endpoint is unavailable, switch to a local CPU-optimized ONNX model (e.g., `sentence-transformers/all-MiniLM-L6-v2`) to provide basic functionality as outlined in the self-assessment.
