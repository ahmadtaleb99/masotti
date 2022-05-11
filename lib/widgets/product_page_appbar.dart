import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:masotti/widgets/carousel_widget.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../models/product.dart';
import 'package:photo_view/photo_view.dart';
import '../constants.dart';

class ProductPageAppBarWidget extends StatefulWidget
    implements PreferredSizeWidget {
  final double? height;
  final Product? product;
  final IconData? icon;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  ProductPageAppBarWidget(
      {this.height, this.product, this.icon, this.scaffoldKey});

  @override
  Size get preferredSize => Size(double.infinity, this.height!);

  @override
  State<StatefulWidget> createState() => ProductPageAppBarWidgetState();
}

class ProductPageAppBarWidgetState extends State<ProductPageAppBarWidget> {
  late bool arabicLanguage;
  int firstImage = 0;
  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    print( widget.product!.images.toString());
    _pageController = PageController(initialPage: firstImage);
    Radius radius = Radius.circular(Constants.borderRadius);
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    BorderRadius borderRadius = arabicLanguage
        ? BorderRadius.only(bottomLeft: radius, topLeft: radius)
        : BorderRadius.only(bottomRight: radius, topRight: radius);
    double containerWidth = MediaQuery.of(context).size.width;

    return Container(
      height: widget.height! - 10,
      child: Stack(
        children: <Widget>[
          Container(
            width: containerWidth,
            height: widget.height! - 10,
            margin: EdgeInsets.only(bottom: Constants.padding),
            child:  CarouselSliderWidget(images: widget.product!.images!.map((e) => e['path']).toList()!,
              onImageTap: (index){
                showDialog(
                    context: context,
                    builder: (context) {
                      firstImage = index;
                      _pageController =
                          PageController(initialPage: firstImage);
                      return Container(
                        color: Colors.black,
                        child: PhotoViewGallery.builder(
                          pageController: _pageController,
                          builder: (BuildContext context, int index) {
                            return PhotoViewGalleryPageOptions(
                              imageProvider: NetworkImage(
                                Constants.apiFilesUrl +
                                    widget.product!.images![index]['path'],
                              ),
                              initialScale: PhotoViewComputedScale.contained,
                              heroAttributes: PhotoViewHeroAttributes(
                                  tag: widget.product!.images![index]['id']),
                            );
                          },
                          itemCount: widget.product!.images!.length,
                          loadingBuilder: (context, event) => Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
                              value: event == null
                                  ? 0
                                  : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!,
                            ),
                          ),
                        ),
                      );
                    });
              },
             ),
          ),
          Align(
            alignment: arabicLanguage ? Alignment.topRight : Alignment.topLeft,
            child: Container(
                width: 60,
                height: 40,
                margin: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                    borderRadius: borderRadius, color: Constants.whiteColor),
                child: IconButton(
                  icon: SvgPicture.asset(
                    Constants.sideMenuImage,
                  ),
                  color: Constants.identityColor,
                  onPressed: () => widget.scaffoldKey!.currentState!.openDrawer(),
                )),
          ),
        ],
      ),
    );
  }
}


//
// Swiper(
// loop: widget.product!.images!.length == 1 ? false : true,
// itemCount: widget.product!.images!.length,
// itemBuilder: (context, index) {
// return Container(
// child: GestureDetector(
// onTap: () => showDialog(
// context: context,
// builder: (context) {
// firstImage = index;
// _pageController =
// PageController(initialPage: firstImage);
// return Container(
// color: Colors.black,
// child: PhotoViewGallery.builder(
// pageController: _pageController,
// builder: (BuildContext context, int index) {
// return PhotoViewGalleryPageOptions(
// imageProvider: NetworkImage(
// Constants.apiFilesUrl +
// widget.product!.images![index]['path'],
// ),
// initialScale: PhotoViewComputedScale.contained,
// heroAttributes: PhotoViewHeroAttributes(
// tag: widget.product!.images![index]['id']),
// );
// },
// itemCount: widget.product!.images!.length,
// loadingBuilder: (context, event) => Center(
// child: CircularProgressIndicator(
// backgroundColor: Colors.grey,
// valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
// value: event == null
// ? 0
//     : event.cumulativeBytesLoaded /
// event.expectedTotalBytes!,
// ),
// ),
// ),
// );
// }),
// child: Image.network(
// Constants.apiFilesUrl +
// widget.product!.images![index]['path'],
// fit: BoxFit.fill,
// loadingBuilder: (context, child, loadingProgress) {
// if (loadingProgress == null) {
// return child;
// }
// return Center(
// child: CircularProgressIndicator(
// backgroundColor: Colors.grey,
// valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
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
// widget.product!.images!.length,
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
// )