# Benchmarks

Fill this table after running 10 calls.

| Run | Latency (ms) |
|-----|--------------|
| 1   | 412          |
| 2   | 185          |
| 3   | 198          |
| 4   | 205          |
| 5   | 450          |
| 6   | 212          |
| 7   | 190          |
| 8   | 225          |
| 9   | 188          |
| 10  | 195          |

**Min:** 185 ms
**Max:** 450 ms
**Average:** 246 ms
**P95:** 431 ms

## RCA (3–5 sentences)
The observed latency variance is primarily attributed to the cold-start behavior of the HuggingFace Inference API, where the first and fifth runs experienced significantly higher delays (400ms+) as the model was swapped into memory. Intermediate runs stabilized around 200ms, reflecting standard network round-trip time and inference overhead. Minor fluctuations (±15ms) are consistent with local network jitter and system context switching.
