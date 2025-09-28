import 'package:cric_live/utils/import_exports.dart';

class ForgotPasswordEmailView extends GetView<ForgotPasswordEmailController> {
  const ForgotPasswordEmailView({super.key});

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
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildBackButton(),
                    ),
                    SizedBox(height: 24.h),

                    // Forgot Password Icon
                    _buildForgotPasswordIcon(),
                    SizedBox(height: 32.h),

                    // Header Card
                    _buildHeaderCard(),
                    SizedBox(height: 32.h),

                    // Email Input Card
                    _buildEmailInputCard(),
                    SizedBox(height: 24.h),

                    // Send Code Button
                    _buildSendCodeButton(),
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

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: Colors.deepOrange.shade600,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordIcon() {
    return Container(
      height: 100.h,
      width: 100.w,
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
      child: Icon(Icons.lock_reset, size: 50.sp, color: Colors.white),
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
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: Colors.deepOrange.shade600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'No worries! Enter your email address and we\'ll send you a verification code to reset your password.',
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

  Widget _buildEmailInputCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Address',
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12.h),
          _buildEmailField(),
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
          hintText: 'Enter your email address',
          hintStyle: GoogleFonts.nunito(
            color: Colors.grey.shade500,
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
            return 'Please enter your email address';
          }
          if (!GetUtils.isEmail(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSendCodeButton() {
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
          onPressed: controller.sendVerificationCode,
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
                      Icon(
                        Icons.send_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Send Verification Code',
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
          Text(
            "Remember your password? ",
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
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
