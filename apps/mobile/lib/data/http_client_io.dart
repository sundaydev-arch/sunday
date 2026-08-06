import "dart:io";

import "package:dio/dio.dart";
import "package:dio/io.dart";

/// Route Dio through an HTTP(S) proxy when configured (China / corporate nets).
void applyProxy(Dio dio, String? proxyUrl) {
  final raw = proxyUrl?.trim();
  if (raw == null || raw.isEmpty) return;

  final uri = Uri.tryParse(raw);
  if (uri == null || uri.host.isEmpty || uri.port <= 0) return;

  final proxyHost = "${uri.host}:${uri.port}";

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.findProxy = (url) => "PROXY $proxyHost";
      return client;
    },
  );
}
