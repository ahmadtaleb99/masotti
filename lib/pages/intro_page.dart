import 'package:flutter/material.dart';
import '../constants.dart';
import './home_page.dart';

class IntroPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> with SingleTickerProviderStateMixin{

  late AnimationController animationController;
  Animation? animation;
  bool skipped = false;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: Duration(
        seconds: 3
      ),
      vsync: this
    );

    animation = Tween(
      begin: 1.0,
      end: 0.0
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn
      )
    );

    animationController.forward();

    Future.delayed(
      Duration(
        seconds: 4
      ),
      () => skipped ? null : Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()
      ))
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - (Constants.padding * 4);
    double imageWidth = MediaQuery.of(context).size.width - (Constants.padding * 6);
    double imageHeight = imageWidth * 47.2 / 100;
    return GestureDetector(
      onTap: () {
        setState(() => skipped = true);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()
        ));
      },
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child){
          return Scaffold(
            backgroundColor: Constants.whiteColor,
            body: Container(
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: containerWidth,
                        height: containerWidth,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/intro.png'),
                            fit: BoxFit.fill
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: animationController.drive(CurveTween(
                        curve: Curves.easeIn
                      )),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: imageWidth,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo.png')
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      )
    );
  }
}