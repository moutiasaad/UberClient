class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://tshl-driver.store/api/v1';

  // Settings
  static const String settings = '/settings';

  // Customer Auth Endpoints
  // NEW: Email-based authentication (recommended)
  static const String customerEmailAuth = '/auth/customer/auth'; // Step 1: Send OTP
  static const String customerVerifyOtp = '/auth/customer/verify-otp'; // Step 2: Verify OTP (supports email)

  // OLD: Kept for backward compatibility
  static const String customerRegister = '/auth/customer/register';
  static const String customerLogin = '/auth/customer/login';
  static const String customerForgotPassword = '/auth/customer/forgot-password';
  static const String customerResetPassword = '/auth/customer/reset-password';

  // Customer Profile Endpoints
  static const String customerProfile = '/customer/profile';
  static const String customerProfileImage = '/customer/profile/image';
  static const String customerFcmToken = '/customer/fcm-token';
  static const String customerLogout = '/customer/logout';

  // Customer Rides Endpoints
  static const String calculateFare = '/customer/rides/calculate-fare';
  static const String requestRide = '/customer/rides/request';
  static const String activeRide = '/customer/rides/active';
  static const String rideDetails = '/customer/rides'; // + /{id}
  static const String rideHistory = '/customer/rides/history';
  static const String cancelRide = '/customer/rides'; // + /{id}/cancel
  static const String rateRide = '/customer/rides'; // + /{id}/rate

  // Customer Points
  static const String customerPoints = '/customer/points';

  // Customer Coupons
  static const String validateCoupon = '/customer/coupons/validate';

  // Customer Notifications
  static const String customerNotifications = '/customer/notifications';
  static const String markNotificationRead = '/customer/notifications/read'; // + /{id}
  static const String markAllNotificationsRead = '/customer/notifications/read-all';

  // Driver Auth Endpoints (for viewing driver info)
  static const String driverRegister = '/auth/driver/register';
  static const String driverLogin = '/auth/driver/login';
  static const String driverSendOtp = '/auth/driver/send-otp';
  static const String driverVerifyOtp = '/auth/driver/verify-otp';

  // Driver Profile Endpoints
  static const String driverProfile = '/driver/profile';
  static const String driverVehicle = '/driver/vehicle';
  static const String driverFcmToken = '/driver/fcm-token';
  static const String driverLogout = '/driver/logout';

  // Driver Status Endpoints
  static const String driverGoOnline = '/driver/go-online';
  static const String driverGoOffline = '/driver/go-offline';
  static const String driverUpdateLocation = '/driver/location';

  // Driver Rides Endpoints
  static const String driverPendingRides = '/driver/rides/pending';
  static const String driverAcceptRide = '/driver/rides'; // + /{id}/accept
  static const String driverRejectRide = '/driver/rides'; // + /{id}/reject
  static const String driverUpdateRideStatus = '/driver/rides'; // + /{id}/status
  static const String driverCancelRide = '/driver/rides'; // + /{id}/cancel
  static const String driverActiveRide = '/driver/rides/active';
  static const String driverRideHistory = '/driver/rides/history';

  // Driver Wallet Endpoints
  static const String driverWallet = '/driver/wallet';
  static const String driverTransactions = '/driver/wallet/transactions';
  static const String driverWithdraw = '/driver/wallet/withdraw';
  static const String driverWithdrawals = '/driver/wallet/withdrawals';

  // Driver Ratings
  static const String driverRatings = '/driver/ratings';

  // Driver Notifications
  static const String driverNotifications = '/driver/notifications';
  static const String driverMessages = '/driver/messages';
  static const String markDriverMessageRead = '/driver/messages/read'; // + /{id}

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
  static const String languageKey = 'language';
  static const String isLoggedInKey = 'is_logged_in';
}
