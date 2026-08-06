import "package:dio/dio.dart";

/// No-op on platforms without `dart:io` (web).
void applyProxy(Dio dio, String? proxyUrl) {}
