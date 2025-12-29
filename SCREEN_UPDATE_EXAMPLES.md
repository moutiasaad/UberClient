# Screen Update Examples

This document shows you exactly how to update your UI screens to use the new API integration.

---

## Example 1: OTP Screen - Add API Verification

### Current Code (lib/view/otp/otp_screen.dart)

Around line 115-125, you'll find the verify button. Currently it just navigates without API call.

### ❌ OLD CODE (needs updating):
```dart
CommonButton(
  onTap: () {
    Get.to(() => CreateProfileScreen());
  },
  buttonText: AppStrings.verify,
)
```

### ✅ NEW CODE (with API integration):
```dart
Obx(() => otpController.isLoading.value
    ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      )
    : CommonButton(
        onTap: () async {
          await otpController.verifyOtp();
        },
        buttonText: AppStrings.verify,
      )
)
```

**What changed:**
- Wrapped button in `Obx()` to react to loading state
- Shows loading spinner when verifying
- Calls `await otpController.verifyOtp()` which handles the API call
- Navigation happens automatically in controller after success

---

## Example 2: GetStarted Screen - Phone Number Submission

### File: lib/view/lets_get_started/lets_get_started_screen.dart

### ❌ OLD CODE:
```dart
CommonButton(
  onTap: () {
    Get.to(() => OtpScreen());
  },
  buttonText: AppStrings.letsGetStarted,
)
```

### ✅ NEW CODE:
```dart
Obx(() => controller.isLoading.value
    ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      )
    : CommonButton(
        onTap: () async {
          await controller.sendPhoneNumber();
        },
        buttonText: AppStrings.letsGetStarted,
      )
)
```

---

## Example 3: CreateProfile Screen - Complete Registration

### File: lib/view/create_profile/create_profile_screen.dart

Find the continue/submit button and update it:

### ❌ OLD CODE:
```dart
CommonButton(
  onTap: () {
    Get.to(() => LocationPermissionScreen());
  },
  buttonText: AppStrings.continue1,
)
```

### ✅ NEW CODE:
```dart
// First, add text controllers to the screen
final CreateProfileController controller = Get.put(CreateProfileController());

// Add TextFields for name, email, referral code
TextField(
  controller: controller.nameController,
  decoration: InputDecoration(
    labelText: 'Full Name',
    hintText: 'Enter your name',
  ),
)

TextField(
  controller: controller.emailController,
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)

TextField(
  controller: controller.referralCodeController,
  decoration: InputDecoration(
    labelText: 'Referral Code (Optional)',
    hintText: 'Enter referral code',
  ),
)

// Update button
Obx(() => controller.isLoading.value
    ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      )
    : CommonButton(
        onTap: () async {
          await controller.completeRegistration();
        },
        buttonText: AppStrings.continue1,
      )
)
```

---

## Example 4: BookRide Screen - Calculate Fare and Book

### File: lib/view/book_ride/book_ride_screen.dart

### Display Calculated Fare:
```dart
Obx(() {
  final fareData = controller.fareData.value;

  if (controller.isLoadingFare.value) {
    return const CircularProgressIndicator();
  }

  if (fareData != null) {
    return Column(
      children: [
        Text('Distance: ${fareData.distance.toStringAsFixed(2)} km'),
        Text('Duration: ${fareData.duration} mins'),
        Text('Base Fare: \$${fareData.baseFare.toStringAsFixed(2)}'),
        Text('Distance Fare: \$${fareData.distanceFare.toStringAsFixed(2)}'),
        if (fareData.discountAmount != null)
          Text('Discount: -\$${fareData.discountAmount!.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.green)),
        const Divider(),
        Text(
          'Total: \$${fareData.totalFare.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  return const Text('Select pickup and dropoff to see fare');
})
```

### Book Button:
```dart
Obx(() => controller.isBookingRide.value
    ? const CircularProgressIndicator()
    : CommonButton(
        onTap: () async {
          await controller.bookRide();
        },
        buttonText: 'Book Ride',
      )
)
```

---

## Example 5: MyRides Screen - Display Ride History

### File: lib/view/my_rides/my_rides_screen.dart

### Add to onInit or initState:
```dart
@override
void initState() {
  super.initState();
  final controller = Get.put(MyRidesController());
  controller.fetchRideHistory();
  controller.fetchActiveRide();
}
```

### Display Rides:
```dart
final MyRidesController controller = Get.find();

Obx(() {
  if (controller.isLoadingRides.value) {
    return const Center(child: CircularProgressIndicator());
  }

  final rides = controller.filteredRides;

  if (rides.isEmpty) {
    return const Center(
      child: Text('No rides found'),
    );
  }

  return ListView.builder(
    itemCount: rides.length,
    itemBuilder: (context, index) {
      final ride = rides[index];

      return Card(
        child: ListTile(
          title: Text(ride.dropoffAddress),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${ride.pickupAddress}'),
              Text('Fare: \$${ride.totalFare.toStringAsFixed(2)}'),
              Text('Status: ${ride.status.toUpperCase()}'),
              Text('Date: ${_formatDate(ride.createdAt)}'),
            ],
          ),
          trailing: _buildStatusChip(ride.status),
          onTap: () {
            // Navigate to ride details
            Get.to(() => RideDetailsScreen(ride: ride));
          },
        ),
      );
    },
  );
})

// Helper method
Widget _buildStatusChip(String status) {
  Color color;
  if (status == 'completed') color = Colors.green;
  else if (status == 'cancelled') color = Colors.red;
  else color = Colors.orange;

  return Chip(
    label: Text(status.toUpperCase()),
    backgroundColor: color.withOpacity(0.2),
    labelStyle: TextStyle(color: color),
  );
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
```

### Add Filter Buttons:
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    FilterChip(
      label: const Text('All'),
      selected: controller.rideFilter.value == 'all',
      onSelected: (_) => controller.rideFilter.value = 'all',
    ),
    FilterChip(
      label: const Text('Active'),
      selected: controller.rideFilter.value == 'active',
      onSelected: (_) => controller.rideFilter.value = 'active',
    ),
    FilterChip(
      label: const Text('Completed'),
      selected: controller.rideFilter.value == 'completed',
      onSelected: (_) => controller.rideFilter.value = 'completed',
    ),
    FilterChip(
      label: const Text('Cancelled'),
      selected: controller.rideFilter.value == 'cancelled',
      onSelected: (_) => controller.rideFilter.value = 'cancelled',
    ),
  ],
)
```

---

## Example 6: Profile Screen - Update Profile

### File: lib/view/profile/profile_screen.dart

### Update Profile Button:
```dart
Obx(() => controller.isLoading.value
    ? const CircularProgressIndicator()
    : CommonButton(
        onTap: () async {
          await controller.updateProfile();
        },
        buttonText: 'Update Profile',
      )
)
```

### Upload Image Button:
```dart
Obx(() => controller.isUploadingImage.value
    ? const CircularProgressIndicator()
    : ElevatedButton(
        onPressed: () async {
          await controller.pickImage();
          if (controller.imagePath.value.isNotEmpty) {
            await controller.uploadProfileImage();
          }
        },
        child: const Text('Upload Photo'),
      )
)
```

### Display Profile Data:
```dart
Obx(() {
  final user = controller.userData.value;

  if (user == null) {
    return const Center(child: CircularProgressIndicator());
  }

  return Column(
    children: [
      // Profile Image
      CircleAvatar(
        radius: 50,
        backgroundImage: user.image != null
            ? NetworkImage(user.image!)
            : null,
        child: user.image == null
            ? const Icon(Icons.person, size: 50)
            : null,
      ),

      // Name
      Text(
        user.name,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Email
      Text(user.email ?? 'No email'),

      // Phone
      Text(user.phone),

      // Points
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Loyalty Points'),
              Text(
                '${user.points}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
})
```

### Logout Button:
```dart
ElevatedButton.icon(
  onPressed: () async {
    // Show confirmation dialog
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.logout();
    }
  },
  icon: const Icon(Icons.logout),
  label: const Text('Logout'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
  ),
)
```

---

## Example 7: Cancel Ride

### File: lib/view/my_rides/my_rides_active_details_screen.dart

```dart
final MyRidesController controller = Get.find();

// Cancel button
ElevatedButton(
  onPressed: () async {
    // Show reason dialog
    final TextEditingController reasonController = TextEditingController();

    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text('Cancel Ride'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Cancellation Reason',
            hintText: 'Why are you cancelling?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: reasonController.text),
            child: const Text('Cancel Ride'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm != null && confirm.isNotEmpty) {
      await controller.cancelRide(rideId, confirm);
    }
  },
  child: const Text('Cancel Ride'),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
)
```

---

## Example 8: Rate Ride

### File: lib/view/book_ride/mood_screen.dart

```dart
final MyRidesController controller = Get.find();
final RxDouble rating = 0.0.obs;
final TextEditingController commentController = TextEditingController();

// Rating widget
RatingBar.builder(
  initialRating: 0,
  minRating: 1,
  direction: Axis.horizontal,
  itemCount: 5,
  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
  itemBuilder: (context, _) => const Icon(
    Icons.star,
    color: Colors.amber,
  ),
  onRatingUpdate: (value) {
    rating.value = value;
  },
)

// Comment field
TextField(
  controller: commentController,
  decoration: const InputDecoration(
    labelText: 'Comment (Optional)',
    hintText: 'Share your experience...',
  ),
  maxLines: 3,
)

// Submit button
CommonButton(
  onTap: () async {
    if (rating.value == 0) {
      Fluttertoast.showToast(msg: 'Please select a rating');
      return;
    }

    await controller.rateRide(
      rideId,
      rating.value.toInt(),
      commentController.text.trim().isEmpty
          ? null
          : commentController.text.trim(),
    );

    // Navigate back to home
    Get.offAllNamed('/home');
  },
  buttonText: 'Submit Rating',
)
```

---

## Common Patterns

### 1. Show Loading Indicator
```dart
Obx(() => controller.isLoading.value
    ? const CircularProgressIndicator()
    : YourWidget()
)
```

### 2. Handle Empty States
```dart
Obx(() {
  if (controller.isLoading.value) {
    return const CircularProgressIndicator();
  }

  if (controller.data.isEmpty) {
    return const Center(child: Text('No data available'));
  }

  return YourListWidget();
})
```

### 3. Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    await controller.fetchData();
  },
  child: YourListWidget(),
)
```

### 4. Error Handling in UI
```dart
Obx(() {
  if (controller.error.value.isNotEmpty) {
    return Center(
      child: Column(
        children: [
          Text(controller.error.value),
          ElevatedButton(
            onPressed: () => controller.retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  return YourWidget();
})
```

---

## Quick Checklist for Each Screen

When updating a screen:

- [ ] Import the controller
- [ ] Wrap button with `Obx()` for loading state
- [ ] Replace `Get.to()` with `await controller.method()`
- [ ] Add `CircularProgressIndicator` for loading
- [ ] Use controller's reactive variables (`.value`)
- [ ] Add error handling if needed
- [ ] Test the flow end-to-end

---

## Testing Your Updates

After updating a screen:

1. **Run the app**
2. **Navigate to the screen**
3. **Trigger the action** (button click)
4. **Check these:**
   - [ ] Loading indicator shows
   - [ ] API call succeeds/fails appropriately
   - [ ] Success message appears (toast)
   - [ ] Navigation happens correctly
   - [ ] Error messages show for failures
   - [ ] Data updates in UI

---

## Common Issues and Solutions

### Issue: Controller not found
```dart
// Make sure to initialize controller in screen
final controller = Get.put(YourController());
// Or if already initialized
final controller = Get.find<YourController>();
```

### Issue: Obx not updating
```dart
// Make sure you're using .obs variables
RxBool isLoading = false.obs; // Correct
bool isLoading = false; // Wrong - won't trigger Obx update
```

### Issue: Navigation not working
```dart
// Make sure you've set up named routes in main.dart
// Or use Get.to() instead of Get.toNamed()
```

---

This guide should help you update all screens to use the new API integration!
