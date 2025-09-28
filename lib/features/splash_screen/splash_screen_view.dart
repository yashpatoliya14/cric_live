import 'package:cric_live/utils/import_exports.dart';

class SplashScreenView extends StatelessWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashScreenController());
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFFF5722), // Simple solid color background
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              const Icon(
                Icons.sports_cricket,
                size: 100,
                color: Colors.white,
              ),
              
              const SizedBox(height: 30),
              
              // App Name
              Text(
                'CRIC LIVE',
                style: GoogleFonts.nunito(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Simple Loading Indicator
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              
              const SizedBox(height: 20),
              
              // Loading Text
              Obx(() => Text(
                controller.loadingText.value,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

