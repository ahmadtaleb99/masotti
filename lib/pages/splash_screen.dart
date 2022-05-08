import 'package:flutter/material.dart';

import '../constants.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController rotationController;
  Animation? animation;
  bool skipped = false;

  bool doTransition = true;

  @override
  void initState() {
    super.initState();

    rotationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: 1),
        upperBound: 0.5,
        reverseDuration: Duration(seconds: 1));

    rotationController.forward(from: 0.0);

    Future.delayed(Duration(milliseconds: 1300), () {
      rotationController.reverse(from: 0.3);
      doTransition = true;
      setState(() {});
    });

    Future.delayed(Duration(microseconds: 1), () {
      setState(() {
        doTransition = false;
      });
    });

    Future.delayed(
        Duration(seconds: 3),
        () => skipped
            ? null
            : Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage())));
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    double containerHeight = MediaQuery.of(context).size.height;
    double imageWidth =
        MediaQuery.of(context).size.width * 62.47 / 100;
    double imageHeight = imageWidth * 47.2 / 100;

    return GestureDetector(
      onTap: () {
        setState(() => skipped = true);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      },
      child: Scaffold(
        backgroundColor: Constants.whiteColor,
        body: Container(
          width: containerWidth,
          height: containerHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/intro_background4.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      width: containerWidth,
                      height: containerHeight * 38.93 / 100,
                      top: doTransition
                          ? 0
                          : (containerHeight * 38.93 / 100) / 2,
                      left: doTransition ? 0 : -containerWidth / 2,
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: containerWidth,
                          height: containerHeight * 38.93 / 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/red_triangle.png'),
                                fit: BoxFit.fill),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: containerWidth * 18.7 / 100),
                        width: 10,
                        height: containerHeight * 31.5 / 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/top_line.png'),
                              fit: BoxFit.fill),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.3).animate(rotationController),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: containerWidth * 75.4 / 100,
                    height: containerWidth * 75.4 / 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/circle.png'),
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: imageWidth,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/red_logo.png')),
                  ),
                ),
                // ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      width: containerWidth,
                      height: containerHeight * 38.93 / 100,
                      bottom: doTransition
                          ? 0
                          : (containerHeight * 38.93 / 100) / 2,
                      right: doTransition ? 0 : -containerWidth / 2,
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: containerWidth,
                          height: containerHeight * 38.93 / 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/grey_triangle.png'),
                                fit: BoxFit.fill),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 70),
                        width: 10,
                        height: containerHeight * 31.5 / 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('assets/images/bottom_line.png'),
                              fit: BoxFit.fill),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
