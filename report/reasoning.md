# Reasoning Notes

### Embeddings Endpoint
- **Choice**: HuggingFace `all-MiniLM-L6-v2` via Inference API.
- **Tradeoff**: Fast, high-quality embeddings. Parallel fetching (`Future.wait`) used to reduce network RTT by ~50%.

### Cosine Similarity
- **Implementation**: Standard dot product normalized by magnitudes.
- **Edge Cases**: Zero-magnitude vectors return `0.0` to avoid division-by-zero errors.

### Quota Logic
- **Enforcement**: Integrated directly into the CLI entry points (`runInference`, `runEmbeddingComparison`).
- **Rationale**: Rejecting requests *before* the API call saves compute cost and provides faster feedback (HTTP 429) to the user.
- **Limits**: 512 token caps prevent large-context cost spikes.

### Analytics Delta
- **Clamping**: 100MB limit (Task 3) ensures that telemetry anomalies or file system resets do not corrupt aggregate usage metrics.
- **Monotonicity**: Returns `0` if `curr < prev` to gracefully handle counter resets.
