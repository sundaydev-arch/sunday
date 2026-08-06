import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/config.dart";
import "../core/di.dart";
import "contact_validation.dart";
import "http_client_stub.dart"
    if (dart.library.io) "http_client_io.dart"
    as http_client;

sealed class ContactSubmitResult {
  const ContactSubmitResult();
}

class ContactSubmitOk extends ContactSubmitResult {
  const ContactSubmitOk();
}

class ContactSubmitQueued extends ContactSubmitResult {
  const ContactSubmitQueued();
}

class ContactSubmitErr extends ContactSubmitResult {
  const ContactSubmitErr({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final ContactValidationError? code;
}

final contactApiProvider = Provider<ContactApi>((ref) => getIt<ContactApi>());

class ContactApi {
  ContactApi({Dio? dio, String? baseUrl, String? proxyUrl})
    : _dio =
          dio ??
          _createDio(
            baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
            proxyUrl: proxyUrl ?? AppConfig.httpsProxy,
          );

  final Dio _dio;

  static Dio _createDio({required String baseUrl, String? proxyUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 25),
        headers: const {"Content-Type": "application/json"},
      ),
    );
    http_client.applyProxy(dio, proxyUrl);
    return dio;
  }

  Future<ContactSubmitResult> submit(ContactPayload payload) => _post(payload);

  Future<ContactSubmitResult> _post(ContactPayload payload) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        "/api/contact",
        data: payload.toJson(),
      );
      if (response.statusCode == 200) {
        return const ContactSubmitOk();
      }
      return ContactSubmitErr(
        message:
            _extractError(response.data) ?? "Couldn't send. Please try again.",
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final serverError = _extractError(body);

      if (status == 429) {
        return ContactSubmitErr(
          message: serverError ?? contactErrorMessages["rate_limited"]!,
          statusCode: status,
          code: "rate_limited",
        );
      }
      if (status == 400) {
        final code = _matchValidationCode(serverError);
        return ContactSubmitErr(
          message:
              serverError ??
              contactErrorMessages[code] ??
              contactErrorMessages["invalid_body"]!,
          statusCode: status,
          code: code,
        );
      }
      if (status == 503) {
        return ContactSubmitErr(
          message: serverError ?? "Contact form is temporarily unavailable.",
          statusCode: status,
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const ContactSubmitErr(message: "network");
      }
      return ContactSubmitErr(
        message: serverError ?? "Couldn't send. Please try again.",
        statusCode: status,
      );
    }
  }

  ContactValidationError? _matchValidationCode(String? message) {
    if (message == null) return "invalid_body";
    for (final entry in contactErrorMessages.entries) {
      if (entry.value == message) return entry.key;
    }
    if (message.toLowerCase().contains("captcha")) {
      return message.toLowerCase().contains("complete")
          ? "captcha_required"
          : "captcha_failed";
    }
    return "invalid_body";
  }

  String? _extractError(dynamic data) {
    if (data is Map && data["error"] is String) {
      return data["error"] as String;
    }
    return null;
  }
}
