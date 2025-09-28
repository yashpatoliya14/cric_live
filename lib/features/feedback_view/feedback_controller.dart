import 'package:cric_live/features/feedback_view/feedback_repo.dart';
import 'package:cric_live/utils/import_exports.dart';

class FeedbackController extends GetxController {
  final FeedbackRepository repository;
  FeedbackController({required this.repository});

  // Text editing controllers for the form fields
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final feedbackController = TextEditingController();

  // Observable to track loading state
  final isLoading = false.obs;

  @override
  void onClose() {
    // Dispose controllers to free up resources
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    feedbackController.dispose();
    super.onClose();
  }


  /// Validates form inputs and submits feedback to the repository.
  Future<void> submitFeedback() async {
    // Enhanced Validation with better UX
    final validationError = _validateForm();
    if (validationError != null) {
      _showErrorSnackbar('Validation Error', validationError);
      return;
    }

    isLoading.value = true;

    try {
      // Data to be sent to the API as form data.
      // The map type is now explicitly Map<String, String>.
      final Map<String, String> feedbackData = {
        'AppName': 'CricLive', // Your actual app name
        'VersionNo': '1.0.0', // Your app version
        'Platform': GetPlatform.isAndroid ? 'Android' : (GetPlatform.isIOS ? 'iOS' : 'Unknown'),
        'PersonName': nameController.text.trim(),
        'Mobile': mobileController.text.trim(),
        'Email': emailController.text.trim(),
        'Message': feedbackController.text.trim(),
        'Remarks': 'Submitted via CricLive mobile app', // Optional remarks
      };

      final bool success = await repository.postFeedback(feedbackData);

      if (success) {
        // Show enhanced success dialog
        _showSuccessDialog();
        // Form will be cleared after dialog is dismissed
      } else {
        _showErrorSnackbar(
          'Submission Failed',
          'Unable to send your feedback. Please check your connection and try again.',
        );
      }
    } catch (e) {
      _showErrorSnackbar(
        'Unexpected Error',
        'Something went wrong. Please try again later.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Enhanced form validation with specific error messages
  String? _validateForm() {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final feedback = feedbackController.text.trim();

    if (name.isEmpty) {
      return 'Please enter your name';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (mobile.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (mobile.length < 10) {
      return 'Please enter a valid mobile number';
    }
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email address';
    }
    if (feedback.isEmpty) {
      return 'Please share your feedback with us';
    }
    if (feedback.length < 10) {
      return 'Please provide more detailed feedback (at least 10 characters)';
    }

    return null;
  }

  /// Show theme-consistent error snackbar
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      borderRadius: 12,
      margin: EdgeInsets.all(16.w),
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  /// Show theme-consistent success dialog
  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation/Icon
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 20.h),
              
              // Success Title
              Text(
                'Feedback Sent Successfully!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              SizedBox(height: 12.h),
              
              // Success Message
              Text(
                'Thank you for your valuable feedback! We\'ll review it and work on making CricLive even better.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24.h),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _performClearForm(); // Clear form after successful submission
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_cricket, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Continue',
                        style: GoogleFonts.nunito(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Enhanced clear form with confirmation
  void clearForm() {
    // Check if any field has content before clearing
    final hasContent = nameController.text.isNotEmpty ||
        mobileController.text.isNotEmpty ||
        emailController.text.isNotEmpty ||
        feedbackController.text.isNotEmpty;

    if (hasContent) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade600,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Clear Form?',
                style: GoogleFonts.nunito(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to clear all entered information? This action cannot be undone.',
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _performClearForm();
              },
              child: Text(
                'Clear',
                style: GoogleFonts.nunito(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      _performClearForm();
    }
  }

  /// Actually clear the form fields
  void _performClearForm() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    feedbackController.clear();

    Get.snackbar(
      'Form Cleared',
      'All fields have been cleared successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      borderRadius: 12,
      margin: EdgeInsets.all(16.w),
      duration: const Duration(seconds: 2),
    );
  }
}
