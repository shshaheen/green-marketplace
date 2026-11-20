import '../error/exceptions.dart';

/// Pagination block returned by list endpoints.
class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    page: json.readInt('page'),
    limit: json.readInt('limit'),
    total: json.readInt('total'),
    totalPages: json.readInt('totalPages'),
  );

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
}

/// Successful response envelope: `{ "success": true, "data": …, "meta"?: … }`.
class ApiResponse<T> {
  const ApiResponse({required this.data, this.meta});

  /// Parses the envelope; `parseData` converts the raw `data` value.
  factory ApiResponse.fromJson(Object? body, T Function(Object? data) parseData) {
    final json = asJsonMap(body, 'response body');
    if (json['success'] != true) {
      throw const ParseException('Expected a successful response envelope');
    }
    final meta = json['meta'];
    return ApiResponse(
      data: parseData(json['data']),
      meta: meta == null ? null : PaginationMeta.fromJson(asJsonMap(meta, 'meta')),
    );
  }

  final T data;
  final PaginationMeta? meta;
}

/// A per-field validation problem, e.g. `{ "field": "body.email", "message": "…" }`.
class ApiFieldError {
  const ApiFieldError({required this.message, this.field});

  factory ApiFieldError.fromJson(Map<String, dynamic> json) => ApiFieldError(
    field: json['field'] as String?,
    message: json['message'] as String? ?? 'Invalid value',
  );

  /// Backend field path; request-part prefixes (`body.`, `query.`) are stripped.
  final String? field;
  final String message;

  String? get fieldName => field?.replaceFirst(RegExp(r'^(body|query|params)\.'), '');
}

/// Error response envelope: `{ "success": false, "error": { code, message, details? } }`.
class ApiErrorBody {
  const ApiErrorBody({required this.code, required this.message, this.details = const []});

  /// Returns null when the body is not a recognisable error envelope.
  static ApiErrorBody? tryParse(Object? body) {
    if (body is! Map) return null;
    final error = body['error'];
    if (error is! Map) return null;
    final details = error['details'];
    return ApiErrorBody(
      code: error['code'] as String? ?? 'UNKNOWN',
      message: error['message'] as String? ?? 'Something went wrong',
      details: details is List
          ? details
                .whereType<Map<dynamic, dynamic>>()
                .map((d) => ApiFieldError.fromJson(Map<String, dynamic>.from(d)))
                .toList(growable: false)
          : const [],
    );
  }

  final String code;
  final String message;
  final List<ApiFieldError> details;
}

/// Casts a decoded JSON value to a map or throws [ParseException].
Map<String, dynamic> asJsonMap(Object? value, String what) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw ParseException('Expected an object for $what');
}

/// Casts a decoded JSON value to a list of maps or throws [ParseException].
List<Map<String, dynamic>> asJsonList(Object? value, String what) {
  if (value is! List) throw ParseException('Expected a list for $what');
  return value.map((item) => asJsonMap(item, '$what item')).toList(growable: false);
}

/// Typed readers that throw [ParseException] instead of failing with a cast error.
extension JsonRead on Map<String, dynamic> {
  String readString(String key) {
    final value = this[key];
    if (value is String) return value;
    throw ParseException('Expected "$key" to be a string');
  }

  String? readStringOrNull(String key) {
    final value = this[key];
    if (value == null || value is String) return value as String?;
    throw ParseException('Expected "$key" to be a string or null');
  }

  int readInt(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    throw ParseException('Expected "$key" to be an integer');
  }

  int? readIntOrNull(String key) => this[key] == null ? null : readInt(key);

  double? readDoubleOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw ParseException('Expected "$key" to be a number');
  }

  bool readBool(String key) {
    final value = this[key];
    if (value is bool) return value;
    throw ParseException('Expected "$key" to be a boolean');
  }

  DateTime readDate(String key) {
    final value = readString(key);
    return DateTime.tryParse(value)?.toLocal() ??
        (throw ParseException('Expected "$key" to be a date'));
  }

  DateTime? readDateOrNull(String key) => this[key] == null ? null : readDate(key);

  Map<String, dynamic> readMap(String key) => asJsonMap(this[key], key);

  Map<String, dynamic>? readMapOrNull(String key) =>
      this[key] == null ? null : asJsonMap(this[key], key);

  List<Map<String, dynamic>> readList(String key) => asJsonList(this[key] ?? const [], key);

  List<String> readStringList(String key) {
    final value = this[key] ?? const [];
    if (value is List && value.every((item) => item is String)) {
      return List<String>.unmodifiable(value);
    }
    throw ParseException('Expected "$key" to be a list of strings');
  }
}
