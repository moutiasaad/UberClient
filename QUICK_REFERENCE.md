# 📋 Quick Reference Card

## 🔗 API Base URL
```dart
https://tshl-driver.store/api/v1
```

## 📁 File Locations

| What | Where |
|------|-------|
| API Client | `lib/api/client/api_client.dart` |
| API Constants | `lib/api/constants/api_constants.dart` |
| Services | `lib/api/services/*.dart` |
| Models | `lib/models/*.dart` |
| Controllers | `lib/controllers/*.dart` |

---

## 🎯 Common Tasks

### Register a New User
```dart
final controller = Get.put(CreateProfileController());
await controller.completeRegistration();
```

### Login
```dart
final authService = AuthService();
final response = await authService.loginCustomer(
  phoneOrEmail: '+966500000000',
  password: 'password123',
);
```

### Calculate Ride Fare
```dart
final controller = Get.put(BookRideController());
controller.setLocations(
  pickLat: 24.7136, pickLng: 46.6753, pickAddress: "Address 1",
  dropLat: 24.7236, dropLng: 46.6853, dropAddress: "Address 2",
);
await controller.calculateFare();
```

### Book a Ride
```dart
await controller.bookRide();
```

### Get Ride History
```dart
final controller = Get.put(MyRidesController());
await controller.fetchRideHistory();
```

### Update Profile
```dart
final controller = Get.put(ProfileController());
controller.nameController.text = "New Name";
await controller.updateProfile();
```

### Logout
```dart
final controller = Get.put(ProfileController());
await controller.logout();
```

---

## 🎨 UI Pattern

```dart
// 1. Import controller
final controller = Get.put(YourController());

// 2. Reactive UI
Obx(() => controller.isLoading.value
    ? CircularProgressIndicator()
    : CommonButton(
        onTap: () => controller.method(),
        buttonText: 'Submit',
      )
)
```

---

## 🔍 Available Services

| Service | Methods |
|---------|---------|
| **AuthService** | `registerCustomer`, `verifyOtp`, `loginCustomer`, `forgotPassword`, `resetPassword`, `logout` |
| **ProfileService** | `getProfile`, `updateProfile`, `uploadProfileImage`, `updateFcmToken` |
| **RideService** | `calculateFare`, `requestRide`, `getActiveRide`, `getRideDetails`, `getRideHistory`, `cancelRide`, `rateRide` |
| **NotificationService** | `getNotifications`, `markAsRead`, `markAllAsRead` |
| **PointsService** | `getPoints` |
| **CouponService** | `validateCoupon` |
| **SettingsService** | `getSettings` |

---

## 📦 Models Available

- `UserModel` - User/customer data
- `AuthResponseModel` - Login/register responses
- `DriverModel` - Driver information
- `RideModel` - Ride details
- `FareModel` - Fare calculation
- `NotificationModel` - Notifications
- `PointsModel` - Loyalty points
- `CouponModel` - Promo codes
- `AppSettingsModel` - App configuration

---

## ⚡ Quick Snippets

### Show Loading
```dart
Obx(() => controller.isLoading.value
    ? CircularProgressIndicator()
    : YourWidget()
)
```

### Handle Empty List
```dart
Obx(() {
  if (controller.items.isEmpty) {
    return Center(child: Text('No items'));
  }
  return ListView.builder(...);
})
```

### Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: () => controller.fetchData(),
  child: YourList(),
)
```

### Error Display
```dart
if (e is ApiException) {
  Fluttertoast.showToast(msg: e.message);
}
```

---

## 🚨 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Controller not found" | Use `Get.put()` before `Get.find()` |
| "Token expired" | User needs to login again |
| Obx not updating | Use `.obs` variables |
| Navigation not working | Set up named routes or use `Get.to()` |
| API timeout | Check internet, increase timeout |

---

## 📚 Documentation

1. **API_INTEGRATION_GUIDE.md** - Full technical guide
2. **SCREEN_UPDATE_EXAMPLES.md** - UI update examples
3. **README_API_INTEGRATION.md** - Project overview

---

## ✅ Integration Checklist

- [x] API infrastructure
- [x] Data models
- [x] API services
- [x] Controller updates
- [ ] UI screen updates
- [ ] Real-time features
- [ ] Payment integration
- [ ] FCM notifications
- [ ] Testing

---

## 🎯 Priority Tasks

1. Update OtpScreen to call `verifyOtp()`
2. Update GetStartedScreen to call `sendPhoneNumber()`
3. Update CreateProfileScreen to call `completeRegistration()`
4. Update BookRideScreen to display fare and call `bookRide()`
5. Update MyRidesScreen to show real data
6. Update ProfileScreen to show user data

---

**Need Help?** Check the full documentation files!
