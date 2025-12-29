# Prime Taxi API Integration Guide

## Overview
This document outlines the complete API integration that has been implemented for the Prime Taxi Flutter UI Kit, connecting it to the ride-hailing backend API at `https://tshl-driver.store/api/v1`.

---

## What Has Been Implemented

### 1. API Infrastructure ✓

#### API Client (`lib/api/client/api_client.dart`)
- HTTP client with automatic token management
- Request/response interceptors
- Error handling and exception management
- Support for GET, POST, PUT, DELETE, and multipart requests
- Automatic retry and session management

#### API Constants (`lib/api/constants/api_constants.dart`)
- Centralized endpoint definitions
- Storage key constants
- Base URL configuration

### 2. Data Models ✓

All API response models created in `lib/models/`:

- **UserModel** - Customer profile data
- **AuthResponseModel** - Authentication responses
- **DriverModel** - Driver information
- **RideModel** - Ride details with status helpers
- **FareModel** - Fare calculation data
- **NotificationModel** - Push notifications
- **PointsModel** - Loyalty points system
- **CouponModel** - Discount coupons with validation
- **AppSettingsModel** - App configuration

### 3. API Services ✓

Complete service classes in `lib/api/services/`:

#### AuthService
- `registerCustomer()` - Register new customer
- `verifyOtp()` - Verify phone number
- `loginCustomer()` - Email/phone login
- `forgotPassword()` - Password recovery
- `resetPassword()` - Reset password with OTP
- `logout()` - End session

#### ProfileService
- `getProfile()` - Fetch user profile
- `updateProfile()` - Update profile info
- `uploadProfileImage()` - Upload profile photo
- `updateFcmToken()` - Update notification token

#### RideService
- `calculateFare()` - Get fare estimate
- `requestRide()` - Book a new ride
- `getActiveRide()` - Get current active ride
- `getRideDetails()` - Get specific ride info
- `getRideHistory()` - Get past rides
- `cancelRide()` - Cancel a ride
- `rateRide()` - Rate completed ride

#### SettingsService
- `getSettings()` - Fetch app configuration

#### NotificationService
- `getNotifications()` - Fetch notifications
- `markAsRead()` - Mark notification read
- `markAllAsRead()` - Mark all as read

#### PointsService
- `getPoints()` - Get points balance and history

#### CouponService
- `validateCoupon()` - Validate promo code

### 4. Updated Controllers ✓

#### GetStartedController
- Phone number validation
- Navigate to OTP screen
- Country code selection
- Loading states

#### OtpController
- OTP verification with API
- Auto-resend functionality
- Timer management
- Navigate to profile creation

#### CreateProfileController
- Complete registration
- Profile creation with validation
- Gender selection
- Referral code support
- Navigate to home after success

#### BookRideController
- **Calculate fare** from API
- **Book ride** with real-time data
- Set pickup/dropoff locations
- Apply promo codes
- Select payment method
- Loading states for operations

#### MyRidesController
- **Fetch ride history** from API
- **Get active ride** status
- Filter rides (all/active/cancelled/completed)
- **Cancel ride** with reason
- **Rate ride** after completion
- Map integration for ride tracking

#### ProfileController
- **Fetch profile** on load
- **Update profile** information
- **Upload profile image**
- **Logout** functionality
- Real-time data sync

---

## API Endpoints Integrated

### Authentication Endpoints
```
POST /auth/customer/register
POST /auth/customer/verify-otp
POST /auth/customer/login
POST /auth/customer/forgot-password
POST /auth/customer/reset-password
```

### Profile Endpoints
```
GET    /customer/profile
PUT    /customer/profile
POST   /customer/profile/image
PUT    /customer/fcm-token
POST   /customer/logout
```

### Ride Endpoints
```
POST   /customer/rides/calculate-fare
POST   /customer/rides/request
GET    /customer/rides/active
GET    /customer/rides/{id}
GET    /customer/rides/history
POST   /customer/rides/{id}/cancel
POST   /customer/rides/{id}/rate
```

### Additional Endpoints
```
GET    /settings
GET    /customer/points
POST   /customer/coupons/validate
GET    /customer/notifications
POST   /customer/notifications/read/{id}
POST   /customer/notifications/read-all
```

---

## How to Use the Integration

### 1. Authentication Flow

```dart
// In GetStartedController
final controller = Get.put(GetStartedController());
await controller.sendPhoneNumber();

// In OtpController
final otpController = Get.put(OtpController());
await otpController.verifyOtp();

// In CreateProfileController
final profileController = Get.put(CreateProfileController());
await profileController.completeRegistration();
```

### 2. Booking a Ride

```dart
// In BookRideController
final bookController = Get.put(BookRideController());

// Set locations
bookController.setLocations(
  pickLat: 24.7136,
  pickLng: 46.6753,
  pickAddress: "King Fahd Road",
  dropLat: 24.7236,
  dropLng: 46.6853,
  dropAddress: "Olaya Street",
);

// Calculate fare (happens automatically)
await bookController.calculateFare();

// Book ride
await bookController.bookRide();
```

### 3. Managing Rides

```dart
// In MyRidesController
final ridesController = Get.put(MyRidesController());

// Fetch history
await ridesController.fetchRideHistory();

// Get active ride
await ridesController.fetchActiveRide();

// Cancel ride
await ridesController.cancelRide(rideId, "Changed plans");

// Rate ride
await ridesController.rateRide(rideId, 5, "Great service!");

// Filter rides
ridesController.rideFilter.value = 'completed';
List<RideModel> completed = ridesController.filteredRides;
```

### 4. Profile Management

```dart
// In ProfileController
final profileController = Get.put(ProfileController());

// Fetch profile
await profileController.fetchProfile();

// Update profile
profileController.nameController.text = "New Name";
profileController.emailController.text = "newemail@example.com";
await profileController.updateProfile();

// Upload image
await profileController.pickImage();
await profileController.uploadProfileImage();

// Logout
await profileController.logout();
```

---

## Loading States

All controllers now have loading states:

```dart
// In UI widgets, wrap with Obx
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  return YourWidget();
})
```

---

## Error Handling

All API calls include comprehensive error handling:

```dart
try {
  await apiCall();
} catch (e) {
  if (e is ApiException) {
    // Handle specific API errors
    Fluttertoast.showToast(msg: e.message);

    // Check for validation errors
    if (e.validationErrors != null) {
      // Handle field-specific errors
    }
  }
}
```

---

## What's Next (Pending Tasks)

### 1. Update UI Screens
You'll need to update the UI screens to use the new controller methods:

#### GetStarted Screen
```dart
// Replace the navigation button with:
CommonButton(
  onTap: () => controller.sendPhoneNumber(),
  buttonText: AppStrings.letsGetStarted,
)
```

#### OTP Screen
```dart
// Replace verify button with:
Obx(() => controller.isLoading.value
  ? CircularProgressIndicator()
  : CommonButton(
      onTap: () => controller.verifyOtp(),
      buttonText: AppStrings.verify,
    )
)
```

#### BookRide Screen
```dart
// Replace book button with:
Obx(() => controller.isBookingRide.value
  ? CircularProgressIndicator()
  : CommonButton(
      onTap: () => controller.bookRide(),
      buttonText: "Book Ride",
    )
)
```

### 2. Real-Time Updates
Implement polling or WebSockets for:
- Active ride status updates
- Driver location tracking
- Ride acceptance notifications

### 3. Named Routes
Set up GetX named routes in `main.dart`:

```dart
GetMaterialApp(
  initialRoute: '/splash',
  getPages: [
    GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/welcome', page: () => WelcomeScreen()),
    GetPage(name: '/get-started', page: () => GetStartedScreen()),
    GetPage(name: '/otp', page: () => OtpScreen()),
    GetPage(name: '/create-profile', page: () => CreateProfileScreen()),
    GetPage(name: '/home', page: () => HomeScreen()),
    GetPage(name: '/book-car', page: () => BookCarScreen()),
    // ... add more routes
  ],
)
```

### 4. FCM Integration
Implement Firebase Cloud Messaging for push notifications:
- Add Firebase to the project
- Update FCM token on login
- Handle notification callbacks

### 5. Payment Integration
Currently supports payment method selection. You'll need to:
- Integrate payment gateway (Stripe, PayPal, etc.)
- Add payment confirmation screens
- Handle payment callbacks

### 6. Testing
- Test complete user journey
- Test error scenarios
- Test offline behavior
- Add unit tests for services

---

## Environment Configuration

Update the base URL if needed in `lib/api/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://tshl-driver.store/api/v1';
```

---

## Security Notes

1. **Token Storage**: Tokens are stored in SharedPreferences. For production, consider using Flutter Secure Storage.

2. **API Keys**: Google Maps API key is hardcoded. Move to environment variables for production.

3. **Password Handling**: Currently uses a default password in CreateProfileController. Implement proper password collection.

4. **SSL Pinning**: Consider implementing SSL pinning for production.

---

## Dependencies Used

All dependencies are already in `pubspec.yaml`:
- `get: ^4.6.6` - State management
- `http: ^1.2.2` - HTTP client
- `shared_preferences: ^2.3.2` - Local storage
- `fluttertoast: ^8.2.12` - User feedback
- `image_picker: ^1.1.2` - Image uploads

---

## Summary

### ✅ Completed
- Full API infrastructure
- All data models
- All service classes
- Authentication flow
- Ride booking system
- Profile management
- Ride history
- Error handling
- Loading states

### ⏳ Remaining
- Update UI screens to use new methods
- Add loading indicators to UI
- Implement real-time ride tracking
- Add payment gateway
- FCM notifications
- Named routes setup
- Comprehensive testing

---

## Getting Started

1. **Test Authentication:**
   - Run the app
   - Enter phone number on GetStarted screen
   - Verify OTP (use test OTP from backend)
   - Complete profile
   - Should navigate to home

2. **Test Ride Booking:**
   - Select pickup and dropoff on map
   - View calculated fare
   - Book ride
   - View in My Rides

3. **Test Profile:**
   - Open profile screen
   - Update name/email
   - Upload image
   - Logout

---

## Support

For issues or questions:
- Check API documentation at backend
- Review error messages in console
- Check network requests in debug mode
- Verify API keys and tokens

---

**Last Updated:** December 23, 2025
**API Version:** v1
**Backend:** https://tshl-driver.store/api/v1
