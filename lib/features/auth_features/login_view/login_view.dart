import 'package:cric_live/utils/import_exports.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                    // Cricket Ball Icon with Animation
                    _buildAppLogo(),
                    SizedBox(height: 24.h),

                    // Welcome Card
                    _buildWelcomeCard(context),
                    SizedBox(height: 32.h),

                    // Login Form Card
                    _buildLoginCard(context),
                    SizedBox(height: 24.h),

                    // Sign Up Link
                    _buildSignUpLink(),
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
      height: 120.h,
      width: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(Icons.sports_cricket, size: 60.sp, color: Colors.white),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
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
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.deepOrange.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Sign in to continue your cricket journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
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
          // Email Field
          _buildEmailField(),
          SizedBox(height: 20.h),

          // Password Field
          _buildPasswordField(),
          SizedBox(height: 16.h),

          // Forgot Password
          _buildForgotPasswordLink(),
          SizedBox(height: 28.h),

          // Login Button
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.nunito(fontSize: 16.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: 'Email Address',
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
              Icons.email_outlined,
              color: Colors.deepOrange.shade600,
              size: 20.sp,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!GetUtils.isEmail(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(
        () => TextFormField(
          controller: controller.passwordController,
          obscureText: controller.isPasswordHidden.value,
          style: GoogleFonts.nunito(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: 'Password',
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
                controller.isPasswordHidden.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: controller.forgotPassword,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.deepOrange.shade600,
        ),
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
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
          onPressed: controller.login,
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
                    'Sign In',
                    style: GoogleFonts.nunito(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: GoogleFonts.nunito(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.offNamed(NAV_SIGNUP);
            },
            child: Text(
              "Sign Up",
              style: GoogleFonts.nunito(
                fontSize: 15.sp,
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
