import 'package:cric_live/common_widgets/loader.dart';
import 'package:cric_live/utils/import_exports.dart';

import 'signup_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 32.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Join the CricLive community!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildProfileImagePicker(),
                  SizedBox(height: 24.h),
                  TextFormField(
                    controller: controller.firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator:
                        (v) => v!.isEmpty ? 'First name is required' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: controller.lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator:
                        (v) => v!.isEmpty ? 'Last name is required' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) {
                      if (v!.isEmpty) return 'Email is required';
                      if (!GetUtils.isEmail(v)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildGenderPicker(theme),
                  SizedBox(height: 16.h),
                  Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      obscureText: controller.isPasswordHidden.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return 'Password is required';
                        if (v.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.isConfirmPasswordHidden.value,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return 'Please confirm your password';
                        if (v != controller.passwordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.signUp,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child:
                          controller.isLoading.value == true
                              ? GetLoader()
                              : Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: controller.pickProfileImage,
        child: Obx(
          () => Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    controller.profileImage.value != null
                        ? FileImage(controller.profileImage.value!)
                        : null,
                child:
                    controller.profileImage.value == null
                        ? Icon(
                          Icons.person,
                          size: 50.r,
                          color: Colors.grey.shade400,
                        )
                        : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 16.r),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderPicker(ThemeData theme) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Male'),
              value: 'male',
              groupValue: controller.gender.value,
              onChanged: controller.onGenderChanged,
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Female'),
              value: 'female',
              groupValue: controller.gender.value,
              onChanged: controller.onGenderChanged,
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () => Get.offNamed(NAV_LOGIN),
          child: const Text('Login'),
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.deepOrange,
          ),
        ),
      ],
    );
  }
}
