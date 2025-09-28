import 'package:cric_live/common_widgets/loader.dart';
import 'package:cric_live/utils/import_exports.dart';

import 'signup_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo
                    _buildAppLogo(),
                    SizedBox(height: 20.h),

                    // Welcome Card
                    _buildWelcomeCard(),
                    SizedBox(height: 24.h),

                    // Form Card
                    _buildSignUpFormCard(),
                    SizedBox(height: 20.h),

                    // Login Link
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      height: 80.h,
      width: 80.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(Icons.sports_cricket, size: 40.sp, color: Colors.white),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Join CricLive!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: Colors.deepOrange.shade600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Create your account and start your cricket journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSignUpFormCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name Fields Row
          Row(
            children: [
              Expanded(
                child: _buildCustomTextField(
                  controller: controller.firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCustomTextField(
                  controller: controller.lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Email Field
          _buildCustomTextField(
            controller: controller.emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v!.isEmpty) return 'Email is required';
              if (!GetUtils.isEmail(v)) return 'Enter a valid email';
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Gender Selection
          _buildGenderSection(),
          SizedBox(height: 16.h),

          // Password Field
          Obx(
            () => _buildCustomTextField(
              controller: controller.passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: controller.isPasswordHidden.value,
              onToggleVisibility: controller.togglePasswordVisibility,
              validator: (v) {
                if (v!.isEmpty) return 'Password is required';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Confirm Password Field
          Obx(
            () => _buildCustomTextField(
              controller: controller.confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: controller.isConfirmPasswordHidden.value,
              onToggleVisibility: controller.toggleConfirmPasswordVisibility,
              validator: (v) {
                if (v!.isEmpty) return 'Please confirm password';
                if (v != controller.passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
          ),
          SizedBox(height: 24.h),

          // Sign Up Button
          _buildSignUpButton(),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText ?? false,
        style: GoogleFonts.nunito(fontSize: 14.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(10.w),
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.deepOrange.shade600, size: 18.sp),
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      (obscureText ?? false)
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                      size: 20.sp,
                    ),
                    onPressed: onToggleVisibility,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: GoogleFonts.nunito(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.onGenderChanged('male'),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            controller.gender.value == 'male'
                                ? Colors.deepOrange.shade100
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color:
                              controller.gender.value == 'male'
                                  ? Colors.deepOrange.shade300
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male,
                            color:
                                controller.gender.value == 'male'
                                    ? Colors.deepOrange.shade600
                                    : Colors.grey.shade600,
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Male',
                            style: GoogleFonts.nunito(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  controller.gender.value == 'male'
                                      ? Colors.deepOrange.shade600
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.onGenderChanged('female'),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            controller.gender.value == 'female'
                                ? Colors.deepOrange.shade100
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color:
                              controller.gender.value == 'female'
                                  ? Colors.deepOrange.shade300
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female,
                            color:
                                controller.gender.value == 'female'
                                    ? Colors.deepOrange.shade600
                                    : Colors.grey.shade600,
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Female',
                            style: GoogleFonts.nunito(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  controller.gender.value == 'female'
                                      ? Colors.deepOrange.shade600
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
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
          onPressed: controller.signUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          child:
              controller.isLoading.value == true
                  ? GetLoader()
                  : Text(
                    'Create Account',
                    style: GoogleFonts.nunito(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
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
          Text(
            "Already have an account? ",
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          GestureDetector(
            onTap: () => Get.offNamed(NAV_LOGIN),
            child: Text(
              "Sign In",
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
