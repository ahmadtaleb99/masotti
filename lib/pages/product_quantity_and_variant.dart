import 'package:flutter/material.dart';
import '../assets/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';

class ProductQuantityAndVariant extends StatefulWidget {
  final String id;
  final String? nameEn;
  final String? nameAr;
  final String? price;
  final String salesPrice;
  final List? dropDownVariants;
  final Map<dynamic, dynamic>? variants;
  final String? selectedSize;
  final String? selectedColor;
  final GlobalKey<ScaffoldState> scaffoldKey;

  ProductQuantityAndVariant({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.salesPrice,
    required this.dropDownVariants,
    required this.variants,
    this.selectedColor,
    this.selectedSize,
    required this.scaffoldKey,
  });

  @override
  State<StatefulWidget> createState() => ProductQuantityAndVariantState();
}

class ProductQuantityAndVariantState extends State<ProductQuantityAndVariant> {
  bool arabicLanguage = false;
  int itemCount = 1;
  String? selectedSize;
  String? selectedColor;
  String? selectedVariant;
  List<String> colors = [];
  List<String> sizes = [];

  GlobalKey _sizesDropdownButtonKey = GlobalKey<FormState>();
  GlobalKey _colorsDropdownButtonKey = GlobalKey<FormState>();


  void openDropdown(GlobalKey _dropdownButtonKey) {
    GestureDetector? detector;
    void searchForGestureDetector(BuildContext element) {
      element.visitChildElements((element) {
        if (element.widget != null && element.widget is GestureDetector) {
          detector = element.widget as GestureDetector?;
          // return false;

        } else {
          searchForGestureDetector(element);
        }

        // return true;
      });
    }

    searchForGestureDetector(_dropdownButtonKey.currentContext!);
    assert(detector != null);

    detector!.onTap!();
  }

  @override
  void initState() {
    selectedSize = widget.selectedSize;
    selectedColor = widget.selectedColor;
    if (selectedSize != null) getSizeColors(selectedSize);
    getVariantIndex();
    super.initState();
  }

  addProductToCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? productsIDs =
        prefs.getStringList(Constants.keyProductsIDsInCart);
    List<String>? productsQuantities =
        prefs.getStringList(Constants.keyProductsQuantitiesInCart);
    List<String?>? productsVariants =
        prefs.getStringList(Constants.keyProductsVariantsInCart);
    int itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart) ?? 0;

    if (productsIDs == null) {
      productsIDs = [];
      productsQuantities = [];
      productsVariants = [];
    }
    productsIDs.add(widget.id);
    productsQuantities!.add(itemCount.toString());
    productsVariants!.add(selectedVariant);
    itemsInCart++;

    prefs.setStringList(Constants.keyProductsIDsInCart, productsIDs);
    prefs.setStringList(
        Constants.keyProductsQuantitiesInCart, productsQuantities);
    prefs.setStringList(Constants.keyProductsVariantsInCart, productsVariants as List<String>);
    prefs.setInt(Constants.keyNumberOfItemsInCart, itemsInCart);

    Navigator.pop(context);

    setState(() {});
  }

  getSizeColors(String? sizeValue) {
    selectedVariant = null;
    colors.clear();
    for (int variantIndex = 0;
    variantIndex < widget.variants!.length;
    variantIndex++) {
      for (int colorIndex = 0;
      colorIndex <
          widget.variants!.values
              .elementAt(variantIndex)
              .length;
      colorIndex++) {
        String color = widget.variants!.values
            .elementAt(variantIndex)[colorIndex]['color']
            .toString();
        String size =
        widget.variants!.keys.elementAt(variantIndex).toString();
        if (!colors.contains(color) && sizeValue == size) {
          colors.add(color);
        }
      }
    }
  }

  getVariantIndex() {
    for (int variantIndex = 0;
        variantIndex < widget.dropDownVariants!.length;
        variantIndex++) {
      if (widget.dropDownVariants!.elementAt(variantIndex)['color'] == selectedColor &&
          widget.dropDownVariants!.elementAt(variantIndex)['size'] == selectedSize) {
        selectedVariant =
            widget.dropDownVariants!.elementAt(variantIndex)['id'].toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double colorSizeContainerWidth = containerWidth / 100 * 14;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;

    for (int variantIndex = 0;
        variantIndex < widget.dropDownVariants!.length;
        variantIndex++) {
      String size = widget.dropDownVariants!.elementAt(variantIndex)['size'].toString();
      if (!sizes.contains(size)) {
        sizes.add(size);
      }
    }

    return Container(
      padding: EdgeInsets.all(Constants.padding),
      color: Constants.whiteColor,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: Constants.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: AutoSizeText(
                    arabicLanguage
                        ? widget.nameAr!.toUpperCase()
                        : widget.nameEn!.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Constants.redColor),
                    maxFontSize: Constants.fontSize,
                    minFontSize: Constants.fontSize - 2,
                    maxLines: 1,
                  ),
                ),
                Container(
                  width: containerWidth / 2,
                  child: AutoSizeText(
                    (widget.salesPrice != 'null'
                            ? widget.salesPrice
                            : widget.price)! +
                        'Currency'.tr(),
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxFontSize: Constants.fontSize,
                    minFontSize: Constants.fontSize - 2,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: Constants.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => openDropdown(_sizesDropdownButtonKey),
                    child: Container(
                      height: containerWidth / 9,
                      margin: arabicLanguage
                          ? EdgeInsets.only(left: Constants.padding)
                          : EdgeInsets.only(right: Constants.padding),
                      padding: EdgeInsets.symmetric(
                          horizontal: Constants.halfPadding, vertical: 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(Constants.borderRadius * 2)),
                          color: Constants.whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[400]!,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AutoSizeText(
                              "Size".tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              minFontSize: Constants.fontSize - 2,
                              maxFontSize: Constants.fontSize,
                              maxLines: 1,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  key: _sizesDropdownButtonKey,
                              iconSize: 30,
                              icon: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(5),
                                child: Icon(
                                  MyFlutterApp.group_218,
                                  size: 8,
                                  color: Constants.redColor,
                                ),
                              ),
                              style: TextStyle(color: Constants.redColor),
                              isExpanded: true,
                              iconEnabledColor: Constants.redColor,
                              hint: Align(
                                alignment: arabicLanguage
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: AutoSizeText(
                                  'ــ',
                                  style: TextStyle(
                                      color: Constants.redColor,
                                      fontWeight: FontWeight.bold),
                                  maxFontSize: Constants.fontSize,
                                  minFontSize: Constants.fontSize - 2,
                                ),
                              ),
                              value: selectedSize,
                              items: sizes.map((size) {
                                return DropdownMenuItem<String>(
                                    value: size.toString(),
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      color: Colors.transparent,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: 60,
                                              height: 30,
                                              alignment: arabicLanguage
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              child: AutoSizeText(
                                                size,
                                                style: TextStyle(
                                                    color: Constants.redColor,
                                                    fontWeight: FontWeight.bold),
                                                minFontSize:
                                                    Constants.fontSize - 2,
                                                maxFontSize: Constants.fontSize,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedColor = null;
                                  getSizeColors(value);
                                  selectedSize = value;
                                });
                              },
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => openDropdown(_colorsDropdownButtonKey),
                    child: Container(
                      height: containerWidth / 9,
                      margin: arabicLanguage
                          ? EdgeInsets.only(right: Constants.padding)
                          : EdgeInsets.only(left: Constants.padding),
                      padding: EdgeInsets.symmetric(
                          horizontal: Constants.halfPadding, vertical: 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(Constants.borderRadius * 2)),
                          color: Constants.whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[400]!,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AutoSizeText(
                              "Color".tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              minFontSize: Constants.fontSize - 2,
                              maxFontSize: Constants.fontSize,
                              maxLines: 1,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonHideUnderline(
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              Constants.borderRadius)),
                                    ),
                                    child: DropdownButton<String>(
                                      key: _colorsDropdownButtonKey,
                                      iconSize: 30,
                                      icon: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(5),
                                        child: Icon(
                                          MyFlutterApp.group_218,
                                          size: 8,
                                          color: Constants.redColor,
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Constants.identityColor),
                                      isExpanded: true,
                                      iconEnabledColor: Constants.identityColor,
                                      hint: Align(
                                        alignment: arabicLanguage
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: AutoSizeText(
                                          'ــ',
                                          style: TextStyle(
                                              color: Constants.redColor,
                                              fontWeight: FontWeight.bold),
                                          maxFontSize: Constants.fontSize,
                                          minFontSize: Constants.fontSize - 2,
                                        ),
                                      ),
                                      value: selectedColor,
                                      items: colors.map((color) {
                                        return DropdownMenuItem<String>(
                                            value: color.toString(),
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 5),
                                                      width: 30,
                                                      height: 30,
                                                      alignment: arabicLanguage
                                                          ? Alignment.centerLeft
                                                          : Alignment.centerRight,
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            child: Icon(
                                                                Icons
                                                                    .brightness_1,
                                                                size: 26,
                                                                color: Colors
                                                                    .grey[400]),
                                                          ),
                                                          Icon(
                                                            Icons.brightness_1,
                                                            size: 25,
                                                            color: Color(
                                                                int.parse('0xFF' +
                                                                    color)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ));
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedColor = value;
                                          getVariantIndex();
                                        });
                                      },
                                    ))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              AutoSizeText(
                'Quantity'.tr(),
                style: TextStyle(
                    color: Constants.identityColor,
                    fontWeight: FontWeight.bold),
                maxFontSize: Constants.fontSize,
                minFontSize: Constants.fontSize - 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  itemCount != 1
                      ? IconButton(
                          icon: Icon(
                            Icons.remove,
                            color: Constants.identityColor,
                            size: 20,
                          ),
                          onPressed: () => setState(() => itemCount--),
                        )
                      : Container(
                          width: 50,
                        ),
                  Container(
                    alignment: Alignment.center,
                    height: colorSizeContainerWidth / 2,
                    padding: EdgeInsets.symmetric(
                        horizontal: 15, vertical: Constants.padding / 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(Constants.borderRadius)),
                        color: Constants.identityColor),
                    child: AutoSizeText(
                      itemCount.toString(),
                      style: TextStyle(
                          color: Constants.whiteColor,
                          fontWeight: FontWeight.bold),
                      maxFontSize: Constants.fontSize,
                      minFontSize: Constants.fontSize - 2,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Constants.identityColor,
                      size: 20,
                    ),
                    onPressed: () => setState(() => itemCount++),
                  )
                ],
              )
            ],
          ),
          Container(
            padding: EdgeInsets.only(
                top: Constants.doublePadding + Constants.padding,
                right: Constants.doublePadding,
                left: Constants.doublePadding),
            child: Divider(
              color: Constants.redColor,
              thickness: 2,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: Constants.padding),
            alignment: Alignment.center,
            child: ButtonTheme(
              minWidth: containerWidth / 3,
              child: RaisedButton(
                  padding: EdgeInsets.symmetric(
                      vertical: Constants.buttonsVerticalPadding),
                  color: Constants.redColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Constants.borderRadius)),
                  child: AutoSizeText(
                    'Confirm'.tr(),
                    style: TextStyle(
                        color: Constants.whiteColor,
                        fontWeight: FontWeight.bold),
                    maxFontSize: Constants.fontSize + 2,
                    minFontSize: Constants.fontSize,
                  ),
                  onPressed: selectedVariant == null
                      ? null
                      : () {
                          addProductToCart();
                          final snackBar = SnackBar(
                            content: Container(
                                height: 80,
                                child: Center(
                                  child: AutoSizeText(
                                    'The product has been added to the cart'
                                        .tr(),
                                    style: TextStyle(
                                      color: Constants.whiteColor,
                                      fontFamily: 'Tajawal',
                                    ),
                                    maxFontSize: Constants.fontSize - 4,
                                    minFontSize: Constants.fontSize - 6,
                                  ),
                                )),
                            duration: Duration(seconds: 2),
                            backgroundColor: Constants.identityColor,
                          );
                          widget.scaffoldKey.currentState!
                              .showSnackBar(snackBar);
                        }),
            ),
          )
        ],
      ),
    );
  }
}
