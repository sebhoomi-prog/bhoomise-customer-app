class AppConstants {
  AppConstants._();

  static const defaultApiBaseUrl = 'https://bhoomise.tech';

  /// Production deploys routes under `/api/api/...` (not `/api/...`).
  static const apiPrefix = '/api/api';

  static const authSendOtp = '$apiPrefix/auth/send-otp';
  static const authVerifyOtp = '$apiPrefix/auth/verify-otp';
  /// Older environments that only mount a single `/api` prefix.
  static const authSendOtpLegacy = '/api/auth/send-otp';
  static const authVerifyOtpLegacy = '/api/auth/verify-otp';
  static const me = '$apiPrefix/me';
  static const products = '$apiPrefix/products';
  static const coupons = '$apiPrefix/coupons';
  static const stores = '$apiPrefix/stores';
  static const orders = '$apiPrefix/orders';
  static const listingSubmissions = '$apiPrefix/listing-submissions';
  static const appDocs = '$apiPrefix/app';
  static const adminPhones = '$apiPrefix/admin-phones';
  static const fast2SmsWebhook = '$apiPrefix/webhooks/fast2sms/delivery-report';

  static const headerAccept = 'Accept';
  static const headerAuthorization = 'Authorization';
  static const bearerPrefix = 'Bearer';
  static const valueApplicationJson = 'application/json';

  static const localeEnglish = 'en';
  static const localeHindi = 'hi';
  static const themeLight = 'light';
  static const themeDark = 'dark';
}

/// Backend selection for data sources.
enum BackendType {
  /// SharedPreferences-backed auth, profile, addresses; optional mock fixtures.
  local,

  /// REST API when a base URL is configured.
  api,
}

/// Backend configuration for API vs local/mock data sources.
class BackendConfig {
  BackendConfig._();

  /// When non-empty, ApiClient is registered and REST data sources may be used.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: AppConstants.defaultApiBaseUrl,
  );

  /// True when a live API base URL is configured.
  static bool get hasRestApi => apiBaseUrl.trim().isNotEmpty;

  /// Bundled mock fixtures when hasRestApi is false.
  static bool get useMockApiAssets => !hasRestApi;

  static BackendType current = BackendType.local;
}
