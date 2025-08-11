import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'modules/screen_home/screen_login/login_screen.dart';



class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "مرحبًا بك في تطبيق شحن الطرود",
          body: "سهولة وسرعة في شحن وتتبع الطرود.",
          image: Image.asset('assets/onbordaing/delivery-truck.png'),
          decoration: const PageDecoration(
            pageColor: Colors.blueAccent,
            bodyTextStyle: TextStyle(fontSize: 18.0, color: Colors.white),
            titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
            imagePadding: EdgeInsets.all(24),
          ),
        ),
        PageViewModel(
          title: "تتبع شحناتك بسهولة",
          body: "تستطيع تتبع حالة الشحنة لحظة بلحظة عبر التطبيق.",
          image: Image.asset('assets/onbordaing/tracking.png'),
          decoration: const PageDecoration(
            pageColor: Colors.greenAccent,
            bodyTextStyle: TextStyle(fontSize: 18.0,

                color: Colors.white),
            titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
            imagePadding: EdgeInsets.all(24),
          ),
        ),
        PageViewModel(
          title: "دفع إلكتروني آمن",
          body: "دفع الشحنات بطريقة آمنة وسريعة عبر التطبيق.",
          image: Image.asset('assets/onbordaing/delivery.png'),
          decoration: const PageDecoration(
            pageColor: Colors.orangeAccent,
            bodyTextStyle: TextStyle(fontSize: 18.0, color: Colors.white),
            titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
            imagePadding: EdgeInsets.all(24),
          ),
        ),
        PageViewModel(

          title: "ابدأ الآن!",
          body: "قم بتسجيل الدخول الآن لتبدأ استخدام التطبيق.",
          image: Container(
              decoration:
              BoxDecoration(
                borderRadius: BorderRadius.circular(16)
              ),child: Image.asset('assets/onbordaing/login.gif')),
          decoration: const PageDecoration(
            pageColor: Colors.purpleAccent,
            bodyTextStyle: TextStyle(fontSize: 18.0, color: Colors.white),
            titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
            imagePadding: EdgeInsets.all(24),
          ),
          footer: ElevatedButton(
            onPressed: () {
              // هنا سيتم تنفيذ الانتقال إلى شاشة تسجيل الدخول أو الصفحة الرئيسية
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },

            child: const Text("ابدأ الآن", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
          ),
        ),
      ],
      onDone: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      onSkip: () {
        // تخطي Onboarding
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      showSkipButton: true,

      skip: const Text('تخطي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
      next: const Icon(Icons.arrow_forward, color: Colors.blue),
      done: const Text('تم', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
      dotsDecorator: DotsDecorator(
        color: Colors.blue,
        activeColor: Colors.blueAccent,
        size: const Size(10.0, 10.0),
        activeSize: const Size(20.0, 10.0),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
    );
  }
}

