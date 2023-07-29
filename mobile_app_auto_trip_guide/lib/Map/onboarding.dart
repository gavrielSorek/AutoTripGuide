import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Map/globals.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd(context) async {
    Globals.appEvents.introCompleted();
    Navigator.of(context).pop();
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    // Save that the intro has done
    await prefs.setBool('introDone', true);
  }
  void _onIntroSkip(context) {
    Globals.appEvents.introSkipped();
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/intro/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(
        color: Color.fromRGBO(47, 46, 65, 1),
        fontFamily: 'Inter',
        fontSize: 24,
        letterSpacing: 0.3499999940395355,
        fontWeight: FontWeight.normal,
        height: 1.1666666666666667);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 4000,
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: const Text(
            'Let\'s go right away!',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "",
          body: "Discover interesting places, along your way.",
          image: Container(
              margin: EdgeInsets.only(top: 100),
              child: _buildImage('intro1.png')),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "",
          body: "Hear stories about your surroundings as you travel.",
          image: Container(
              margin: EdgeInsets.only(top: 100),
              child: _buildImage('intro2.png')),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "",
          body: "Or while driving...",
          image: Container(
              margin: EdgeInsets.only(top: 100),
              child: _buildImage('intro3.png')),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "",
          body: "Turn every travel you make into a memorable experience.",
          image: Container(
              margin: EdgeInsets.only(top: 100),
              child: _buildImage('intro4.png')),
          decoration: pageDecoration,
        )
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroSkip(context), // You can override onSkip callback
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        // activeShape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(25.0)),
        // ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
