import 'package:cric_live/features/signup_view/signup_model.dart';
import 'package:cric_live/services/auth/auth_service.dart';
import 'package:cric_live/utils/import_exports.dart';
import 'package:image_picker/image_picker.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  // Text Editing Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State for password visibility
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  // State for gender selection
  var gender = "male".obs;

  // State for profile image
  var profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    // Dispose all controllers
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void onGenderChanged(String? value) {
    if (value != null) {
      gender.value = value;
    }
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  /// Validates the form, sends the data to the AuthService, and handles the response.
  Future<void> signUp() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;

      SignupModel model = SignupModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        gender: gender.value,
        profilePhoto: profileImage.value?.path,
      );

      AuthService _service = AuthService();
      await _service.signup(model);
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
