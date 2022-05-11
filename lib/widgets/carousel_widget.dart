import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:masotti/constants.dart';
import 'package:masotti/pages/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarouselSliderWidget extends StatefulWidget {
  List<dynamic> images;
  void Function(int index)? onImageTap;
  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();

  CarouselSliderWidget({
    required this.images,

    this.onImageTap,
  });
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    print(widget.images.first.toString());

    return Stack(
      children: [
        CarouselSlider(
            items: List.generate(
              widget.images.length,
              (index) => GestureDetector(
                onTap: (){
                          widget.onImageTap!(index);
                },
                child: Image.network(
                  Constants.apiFilesUrl + widget.images[index],
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Constants.redColor),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null),
                    );
                  },
                ),
              ),
            ),
            options: CarouselOptions(
              viewportFraction: 1,
              initialPage: 0,
              height: double.infinity,
              enableInfiniteScroll: widget.images.length > 1 ?  true : false,
              reverse: false,
              autoPlay: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              scrollDirection: Axis.horizontal,
            )),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          bottom: -250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => SizedBox(
                width: 25,
                height: 3,
                child: _current == index
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.white),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.white54),
                        ),
                      ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

