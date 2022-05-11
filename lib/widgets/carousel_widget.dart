import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:masotti/constants.dart';
import 'package:masotti/pages/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarouselSliderWidget extends StatefulWidget {
  List<String> images;
  List<String>? products;
  int? itemsInCart;
  bool? cartIconExist;
  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();

  CarouselSliderWidget({
    required this.images,
    required this.products,
    required this.itemsInCart,
    required this.cartIconExist,
  });
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(

            items: List.generate(
              widget.images.length,
              (index) => GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductPage(
                                id: widget.products![index],
                              ))).then(
                    (value) => setState(() {
                      widget.itemsInCart =
                          prefs.getInt(Constants.keyNumberOfItemsInCart);
                      widget.cartIconExist =
                          prefs.getString(Constants.keyAccessToken) != null
                              ? true
                              : false;
                    }),
                  );
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
              aspectRatio: 16 / 9,
              viewportFraction: 1,
              initialPage: 0,
              height: double.infinity,

              enableInfiniteScroll: true,
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
              enlargeCenterPage: true,
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














// Swiper(
//
// loop: widget.images!.length == 1 ? false : true,
// itemCount: widget.images!.length,
// itemBuilder: (context, index) {
// return Container(
// child: GestureDetector(
// onTap: () async {
// final prefs =
// await SharedPreferences.getInstance();
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) =>
// ProductPage(
// id: widget.products![
// index],
// ))).then(
// (value) => setState(() {
// widget.itemsInCart = prefs
//     .getInt(Constants.keyNumberOfItemsInCart);
// widget.cartIconExist = prefs.getString(
// Constants.keyAccessToken) !=
// null
// ? true
//     : false;
// }),
// );
// },
// child: Image.network(
// Constants.apiFilesUrl + widget.images![index],
// fit: BoxFit.fill,
// loadingBuilder: (context, child, loadingProgress) {
// if (loadingProgress == null) {
// return child;
// }
// return Center(
// child: CircularProgressIndicator(
// backgroundColor: Colors.grey,
// valueColor: new AlwaysStoppedAnimation<Color>(
// Constants.redColor),
// value: loadingProgress.expectedTotalBytes != null
// ? loadingProgress.cumulativeBytesLoaded /
// loadingProgress.expectedTotalBytes!
//     : null),
// );
// },
// ),
// ));
// },
// autoplay: true,
// pagination: SwiperPagination(
// alignment: Alignment.bottomCenter,
// margin: EdgeInsets.only(top: 10),
// builder: SwiperCustomPagination(
// builder: (BuildContext context, SwiperPluginConfig config) {
// return Container(
// padding: EdgeInsets.only(bottom: 35),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.center,
// children: List.generate(
// widget.images!.length,
// (index) => SizedBox(
// width: 25,
// height: 3,
// child: config.activeIndex == index
// ? Container(
// margin: EdgeInsets.symmetric(horizontal: 3),
// child: DecoratedBox(
// decoration:
// BoxDecoration(color: Colors.white),
// ),
// )
//     : Container(
// margin: EdgeInsets.symmetric(horizontal: 3),
// child: DecoratedBox(
// decoration:
// BoxDecoration(color: Colors.white54),
// ),
// ),
// ),
// ),
// ),
// );
// }),
// ),
// ),
