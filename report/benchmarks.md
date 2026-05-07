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
Variance is primarily due to model cold-starts and network RTT on the HuggingFace Inference API. Verification confirmed that the implemented **Parallel Fetching** (Task 1) correctly handles simultaneous requests, while the **Error Handling** ensures that 404/500 API responses are captured as valid JSON failures rather than CLI crashes. The P95 spike reflects the overhead of the initial model loading on the free-tier endpoint.
