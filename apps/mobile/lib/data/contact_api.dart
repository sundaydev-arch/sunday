import "package:dio/dio.dart";

import "../core/config.dart";
import "contact_validation.dart";

sealed class ContactSubmitResult {
  const ContactSubmitResult();
}

class ContactSubmitOk extends ContactSubmitResult {
  const ContactSubmitOk();
}

class ContactSubmitErr extends ContactSubmitResult {
  const ContactSubmitErr({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final ContactValidationError? code;
}

class ContactApi {
  ContactApi({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {"Content-Type": "application/json"},
            ),
          );

  final Dio _dio;

  Future<ContactSubmitResult> submit(ContactPayload payload) async {
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
        return ContactSubmitErr(
          message: serverError ?? contactErrorMessages["invalid_body"]!,
          statusCode: status,
          code: "invalid_body",
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
          e.type == DioExceptionType.connectionError) {
        return const ContactSubmitErr(message: "network");
      }
      return ContactSubmitErr(
        message: serverError ?? "Couldn't send. Please try again.",
        statusCode: status,
      );
    }
  }

  String? _extractError(dynamic data) {
    if (data is Map && data["error"] is String) {
      return data["error"] as String;
    }
    return null;
  }
}
