import 'package:cric_live/common_widgets/custom_snackbar.dart';
import 'package:cric_live/features/login_view/login_model.dart';
import 'package:cric_live/features/otp_screen/otp_screen_model.dart';
import 'package:cric_live/features/signup_view/signup_model.dart';
import 'package:cric_live/services/api_services/api_services.dart';
import 'package:cric_live/services/auth/token_model.dart';
import 'package:cric_live/utils/import_exports.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  late ApiServices _apiServices;
  AuthService() {
    _apiServices = ApiServices();
  }
  Future<void> signup(SignupModel data) async {
    try {
      dynamic res = await _apiServices.post(
        "/CL_Users/CreateUser",
        data.toJson(),
      );
      Map<String, dynamic> result =
          jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        dynamic resOfOtp = await _apiServices.post(
          "/CL_Users/SendOtp",
          data.email,
        );
        Map<String, dynamic> resultOfOtp =
            jsonDecode(res.body) as Map<String, dynamic>;

        if (resOfOtp.statusCode == 200) {
          getSnackBar(
            title: "Check Your Email For Verification",
            message: resultOfOtp["message"],
          );

          //move to otp page
          Get.toNamed(NAV_OTP_SCREEN, arguments: {"email": data.email});
        } else if (resOfOtp.statusCode == 500) {
          getSnackBar(
            title: "Failed To Send Otp",
            message: resultOfOtp["message"],
          );
        } else {
          throw Exception("Error from send to otp at signup function");
        }
      } else if (res.statusCode == 400) {
        getSnackBar(title: "Sign up Failed", message: result["message"]);
      } else if (res.statusCode == 500) {
        getSnackBar(title: "Server Error", message: result["message"]);
      } else {
        throw Exception("Sign up error from signup function");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> login(LoginModel data) async {
    try {
      Response res = await _apiServices.post("/CL_Users/Login", data.toJson());
      Map<String, dynamic> result =
          jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final prefs = Get.find<SharedPreferences>();
        prefs.setString("token", result["token"]);
        getSnackBar(title: "Login Successful", message: result["message"]);
        Get.toNamed(NAV_DASHBOARD_PAGE);
      } else if (res.statusCode == 400) {
        getSnackBar(title: "Login Failed", message: result["message"]);
      } else if (res.statusCode == 500) {
        getSnackBar(title: "Server Error", message: result["message"]);
      } else {
        throw Exception("Error at verify otp function");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp(OtpModel model) async {
    try {
      dynamic res = await _apiServices.post(
        "/CL_Users/VerifyOtp",
        model.toJson(),
      );

      Map<String, dynamic> result =
          jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        getSnackBar(
          title: "Otp Verification Success",
          message: result["message"],
        );
        Get.toNamed(NAV_DASHBOARD_PAGE);
      } else if (res.statusCode == 400) {
        getSnackBar(
          title: "Otp Verification Failed",
          message: result["message"],
        );
      } else if (res.statusCode == 500) {
        getSnackBar(title: "Server Error", message: result["message"]);
      } else {
        throw Exception("Error at verify otp function");
      }
    } catch (e) {
      rethrow;
    }
  }

  bool jwtTokenValid(String token) {
    // Check if token expired
    return JwtDecoder.isExpired(token);
  }

  TokenModel? fetchInfoFromToken() {
   try{

    final prefs = Get.find<SharedPreferences>();
    String? token = prefs.getString("token");

    if(token == null){
      throw Exception("Token not found");
    }

    if(JwtDecoder.isExpired(token)){
      logout();
    }else{
      Map<String,dynamic> data = JwtDecoder.decode(token);
      return TokenModel.fromJson(data);
    }
   }catch(e){
     log('''::::fetchInfoFromToken:::::$e''');
   }
  }

  /// Logout
  void logout(){
    final SharedPreferences prefs = Get.find<SharedPreferences>();
    prefs.remove("token");
    Get.toNamed(NAV_LOGIN);
  }
}
