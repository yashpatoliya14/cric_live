import 'package:cric_live/utils/import_exports.dart';
import 'feedback_controller.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedbackController controller = Get.find<FeedbackController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CommonAppHeader(
        title: "Feedback",
        subtitle: "Help us improve your cricket experience",
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                Get.dialog(
                  _buildHelpDialog(),
                  barrierDismissible: true,
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimationLimiter(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.h,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Welcome Card
                  _buildWelcomeCard(),
                  SizedBox(height: 20.h),
                  
                  // Form Card
                  _buildFormCard(controller),
                  
                  SizedBox(height: 24.h),
                  
                  // Action Buttons
                  _buildActionButtons(controller),
                  
                  SizedBox(height: 20.h),
                  
                  // Footer Info
                  _buildFooterInfo(),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.shade400,
            Colors.deepOrange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.sports_cricket,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We Value Your Opinion!',
                  style: GoogleFonts.nunito(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your feedback helps us create the best cricket scoring experience.',
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(FeedbackController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your experience',
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.deepOrange.shade700,
            ),
          ),
          SizedBox(height: 20.h),
          
          // Name Input Field
          _buildTextField(
            controller: controller.nameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: 16.h),

          // Mobile Number Input Field
          _buildTextField(
            controller: controller.mobileController,
            labelText: 'Mobile Number',
            hintText: 'Enter your mobile number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16.h),

          // Email Input Field
          _buildTextField(
            controller: controller.emailController,
            labelText: 'Email Address',
            hintText: 'Enter your email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16.h),

          // Feedback Message Input Field
          _buildTextField(
            controller: controller.feedbackController,
            labelText: 'Your Feedback',
            hintText: 'Share your thoughts, suggestions, or report any issues...',
            icon: Icons.message_outlined,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: GoogleFonts.nunito(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          icon, 
          color: Colors.deepOrange.shade400,
          size: 22.sp,
        ),
        labelStyle: GoogleFonts.nunito(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: maxLines > 1 ? 16.h : 12.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.deepOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButtons(FeedbackController controller) {
    return Obx(() => Column(
      children: [
        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: controller.isLoading.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Sending Feedback...',
                        style: GoogleFonts.nunito(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Submit Feedback',
                        style: GoogleFonts.nunito(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 12.h),
        
        // Clear Button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: OutlinedButton(
            onPressed: controller.isLoading.value ? null : controller.clearForm,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.deepOrange.shade300),
              foregroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.clear_all_rounded, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Clear Form',
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.deepOrange.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.deepOrange.shade600,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Why we collect feedback',
                style: GoogleFonts.nunito(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Your feedback helps us improve CricLive features, fix bugs, and create new tools for better cricket scoring and management experience.',
            style: GoogleFonts.nunito(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: Colors.deepOrange.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Row(
        children: [
          Icon(Icons.help, color: Colors.deepOrange, size: 24.sp),
          SizedBox(width: 8.w),
          Text(
            'Feedback Tips',
            style: GoogleFonts.nunito(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.deepOrange.shade700,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipItem('🐛', 'Report bugs or issues you encountered'),
          _buildTipItem('💡', 'Suggest new features or improvements'),
          _buildTipItem('⭐', 'Share what you love about the app'),
          _buildTipItem('📱', 'Mention your device and app version'),
          _buildTipItem('📝', 'Be specific and descriptive'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Got it!',
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.deepOrange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
