import 'package:cric_live/common_widgets/loader.dart';
import 'package:cric_live/utils/import_exports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.deepOrange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Success Icon
                    _buildSuccessIcon(),
                    SizedBox(height: 32.h),

                    // Header Card
                    _buildHeaderCard(),
                    SizedBox(height: 32.h),

                    // Password Form Card
                    _buildPasswordFormCard(),
                    SizedBox(height: 24.h),

                    // Reset Password Button
                    _buildResetPasswordButton(),
                    SizedBox(height: 20.h),

                    // Back to Login Link
                    _buildBackToLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      height: 100.h,
      width: 100.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(Icons.check_circle_outline, size: 50.sp, color: Colors.white),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Create New Password',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: Colors.deepOrange.shade600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Your identity has been verified! Set your new password to complete the reset process.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordFormCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // New Password Field
          _buildPasswordField(
            controller: controller.newPasswordController,
            label: 'New Password',
            obscureText: controller.isNewPasswordHidden,
            onToggleVisibility: controller.toggleNewPasswordVisibility,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),

          // Confirm Password Field
          _buildPasswordField(
            controller: controller.confirmPasswordController,
            label: 'Confirm Password',
            obscureText: controller.isConfirmPasswordHidden,
            onToggleVisibility: controller.toggleConfirmPasswordVisibility,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != controller.newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Password Requirements
          _buildPasswordRequirements(),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required RxBool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(
        () => TextFormField(
          controller: controller,
          obscureText: obscureText.value,
          style: GoogleFonts.nunito(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.nunito(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.lock_outline,
                color: Colors.deepOrange.shade600,
                size: 20.sp,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: onToggleVisibility,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          _buildRequirementItem('At least 6 characters long'),
          _buildRequirementItem('Include uppercase and lowercase letters'),
          _buildRequirementItem('Include at least one number'),
          _buildRequirementItem('Include at least one special character'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.sp,
            color: Colors.blue.shade600,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              requirement,
              style: GoogleFonts.nunito(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade600],
          ),
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          child:
              controller.isLoading.value
                  ? GetLoader()
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Reset Password',
                        style: GoogleFonts.nunito(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.deepOrange.shade600,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => Get.offAllNamed(NAV_LOGIN),
            child: Text(
              "Back to Login",
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
