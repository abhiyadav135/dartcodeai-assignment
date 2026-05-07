import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main(List<String> args) async {
  final taskIndex = args.indexOf('--task');
  final textIndex = args.indexOf('--text');

  if (taskIndex == -1 || textIndex == -1) {
    print('Usage: dart run bin/dartcodeai.dart --task <infer|embed> --text "input"');
    exit(1);
  }

  final task = args[taskIndex + 1];
  final text = args[textIndex + 1];

  if (task == 'embed') {
    await runEmbeddingComparison(text);
  } else {
    await runInference(text);
  }
}

Future<void> runInference(String text) async {
  // Task 2: Quota Enforcement Check
  // Dummy values for predicted tokens and current usage for demo
  const predictedPrompt = 100;
  const predictedComp = 100;
  const currentUsage = 500;
  const maxTokens = 2000;

  if (!canProcess(predictedPrompt, predictedComp, currentUsage, maxTokens)) {
    print(jsonEncode({'status': 429, 'error': 'Quota exceeded or token limit hit'}));
    return;
  }

  final result = {
    'status': 200,
    'output': 'This is a stub inference result for: $text'
  };
  print(jsonEncode(result));
}

Future<void> runEmbeddingComparison(String raw) async {
  final parts = raw.split('|');
  if (parts.length != 2) {
    print(jsonEncode({'status': 400, 'error': 'Invalid input: expected docA|docB'}));
    return;
  }
  final docA = parts[0].trim();
  final docB = parts[1].trim();

  // Task 2: Quota Enforcement Check (Treating each doc as a prompt)
  if (!canProcess(256, 0, 1000, 5000)) {
    print(jsonEncode({'status': 429, 'error': 'Quota exceeded'}));
    return;
  }

  final t0 = DateTime.now().millisecondsSinceEpoch;
  try {
    // Task 1: Parallel Fetching
    final results = await Future.wait([
      fetchEmbedding(docA),
      fetchEmbedding(docB),
    ]).timeout(Duration(seconds: 30));

    final embeddingA = results[0];
    final embeddingB = results[1];
    final latencyMs = DateTime.now().millisecondsSinceEpoch - t0;

    final similarity = cosineSimilarity(embeddingA, embeddingB);

    final output = {
      'status': 200,
      'latency_ms': latencyMs,
      'vector_dim': embeddingA.length,
      'similarity_score': double.parse(similarity.toStringAsFixed(6)),
    };

    print(jsonEncode(output));
  } catch (e) {
    print(jsonEncode({
      'status': 500,
      'error': e.toString(),
    }));
  }
}

Future<List<double>> fetchEmbedding(String text) async {
  final url = Platform.environment['ENDPOINT_URL'];
  final apiKey = Platform.environment['API_KEY'];

  if (url == null || url.isEmpty) {
    throw Exception('ENDPOINT_URL not set');
  }

  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse(url)).timeout(Duration(seconds: 10));
    request.headers.set('Content-Type', 'application/json');
    if (apiKey != null && apiKey.isNotEmpty) {
      request.headers.set('Authorization', 'Bearer $apiKey');
    }
    request.write(jsonEncode({'inputs': text}));
    final response = await request.close().timeout(Duration(seconds: 10));
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 400) {
      throw Exception('Embedding request failed: ${response.statusCode} $body');
    }

    final parsed = jsonDecode(body);
    if (parsed is Map && parsed.containsKey('embeddings')) {
      return (parsed['embeddings'] as List).map((e) => (e as num).toDouble()).toList();
    } else if (parsed is List) {
      // Handle HuggingFace Feature Extraction format
      if (parsed.first is List) {
         // Some models return nested lists [ [ [emb] ] ]
         return (parsed.first as List).map((e) => (e as num).toDouble()).toList();
      }
      return parsed.map((e) => (e as num).toDouble()).toList();
    } else {
      throw Exception('Unexpected embedding response format');
    }
  } finally {
    client.close();
  }
}

double cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length) {
    throw Exception('Vector dimension mismatch: ${a.length} vs ${b.length}');
  }
  double dot = 0;
  double na = 0;
  double nb = 0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  if (na == 0 || nb == 0) return 0.0;
  return dot / (sqrt(na) * sqrt(nb));
}

// Task 2 — Implement Correct Quota Enforcement Logic
bool canProcess(
  int predictedPromptTokens,
  int predictedCompletionTokens,
  int currentUsage,
  int maxTokens
) {
  // Reject if prompt > 512
  if (predictedPromptTokens > 512) return false;
  // Reject if completion > 512
  if (predictedCompletionTokens > 512) return false;
  // Reject if total + usage > max
  if (predictedPromptTokens + predictedCompletionTokens + currentUsage > maxTokens) {
    return false;
  }
  return true;
}
