import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'otp_screen_controller.dart';

class OtpScreenView extends GetView<OtpScreenController> {
  const OtpScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),

                // Header Icon
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 40.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(height: 32.h),

                // Title and Description
                Text(
                  'Verification Code',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12.h),

                Text(
                  'We have sent a verification code to',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                Text(
                  controller.maskedEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // OTP Input Fields
                _buildOtpInputFields(context),

                SizedBox(height: 32.h),

                // Timer and Resend
                _buildTimerAndResend(context),

                SizedBox(height: 40.h),

                // Verify Button
                _buildVerifyButton(context),

                SizedBox(height: 20.h),

                // Back to Login
                _buildBackToLogin(context),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInputFields(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) => _buildOtpField(context, index)),
    );
  }

  Widget _buildOtpField(BuildContext context, int index) {
    return Container(
      width: 45.w,
      height: 55.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextFormField(
        controller: controller.otpControllers[index],
        focusNode: controller.otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          controller.onOtpChanged(index, value);
        },
        onTap: () {
          // Clear field on tap for better UX
          controller.otpControllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.otpControllers[index].text.length,
          );
        },
        onFieldSubmitted: (value) {
          if (index == 5 && controller.isOtpComplete) {
            controller.verifyOtp();
          }
        },
      ),
    );
  }

  Widget _buildTimerAndResend(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          if (!controller.canResend.value) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8.w),
                Text(
                  'Resend code in ${controller.timerText}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
                GestureDetector(
                  onTap:
                      controller.isLoading.value ? null : controller.resendOtp,
                  child: Text(
                    'Resend',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed:
              controller.isLoading.value || !controller.isOtpComplete
                  ? null
                  : controller.verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                controller.isOtpComplete
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
            foregroundColor:
                controller.isOtpComplete ? Colors.white : Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: controller.isOtpComplete ? 2 : 0,
          ),
          child:
              controller.isLoading.value
                  ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_back_ios, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            'Back to Login',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontSize: 14.sp,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
