# System Design — Scaling to 10k req/min

To handle 10k RPM (~167 RPS), the system requires a distributed, resilient architecture.

### Batching & Concurrency
Individual requests should be aggregated into batches (e.g., 32 strings) before calling the inference endpoint to maximize GPU utilization and minimize network RTT. A worker pool using `asyncio` or Dart Isolates can manage concurrent batch processing.

### Multi-Level Caching
A Redis-based LRU cache should store text-to-vector mappings using SHA-256 hashes as keys. This significantly reduces redundant computations for common phrases and lowers API costs.

### Backpressure & Rejection
Implement a token bucket rate limiter at the API gateway. When queues exceed capacity, the system should return HTTP 429 (Too Many Requests) to signal backpressure to upstream clients.

### Resilience & Retries
Client-side retries must include jittered exponential backoff to avoid "thundering herd" issues during recovery. Circuit breakers (e.g., Resilience4j) should trigger if failure rates cross a 25% threshold.

### Observability
Export throughput, latency (P50/P95/P99), and error rates to Prometheus. Centralized logging via ELK or Grafana Loki is essential for debugging distributed failures. Distributed tracing (OpenTelemetry) will help pinpoint bottlenecks in the batching pipeline.

### Fallback & Degraded Mode
If the primary GPU-backed endpoint is unavailable, the system should switch to a local CPU-optimized ONNX model (e.g., `sentence-transformers/all-MiniLM-L6-v2`) to provide basic functionality at higher latency.

### Capacity Planning
Horizontal scaling of worker nodes via Kubernetes HPA (based on CPU/Queue depth) ensures the system meets demand dynamically while maintaining cost efficiency.
