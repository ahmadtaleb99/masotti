import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../constants.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class FAQWidget extends StatefulWidget {
  final String id;
  final String? questionEn;
  final String? questionAr;
  final String? answerEn;
  final String? answerAr;
  bool checked;

  FAQWidget(
      {required this.id,
      required this.questionEn,
      required this.questionAr,
      required this.answerEn,
      required this.answerAr,
      required this.checked});

  @override
  _FAQWidgetState createState() => _FAQWidgetState();
}

class _FAQWidgetState extends State<FAQWidget> with TickerProviderStateMixin {
  ExpandableController controller = ExpandableController();
  late AnimationController rotationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rotationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
        upperBound: 0.5,
        reverseDuration: Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerHeight = containerWidth / 10 * 4;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.borderRadius))),
            elevation: 5,

            child: ExpandablePanel(
              controller: controller,
              collapsed: Container(),
              theme: const ExpandableThemeData(
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapHeaderToExpand: false,
                hasIcon: false,
              ),
              header: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: Constants.halfPadding,
                        horizontal: Constants.padding),
                    margin: EdgeInsets.only(top: containerHeight / 6.5),
                    child: Container(
                      margin:
                          EdgeInsets.only(bottom: 5, top: containerHeight / 5 + Constants.halfPadding),
                      child: AutoSizeText(
                        arabicLanguage ? widget.questionAr! : widget.questionEn!,
                        style: TextStyle(
                          color: Constants.identityColor,
                        ),
                        minFontSize: Constants.fontSize - 4,
                        maxFontSize: Constants.fontSize - 2,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: InkWell(
                      onTap: () {
                        widget.checked = !widget.checked;
                        setState(() {
                          controller.expanded = widget.checked;
                        });
                        if (widget.checked) {
                          rotationController.forward(from: 0.0);
                        } else {
                          rotationController.reverse(from: 1.0);
                        }
                      },
                      child: Container(
                        width: containerWidth - Constants.halfPadding + 2,
                        height: containerHeight / 3,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(Constants.borderRadius),
                                topRight: Radius.circular(Constants.borderRadius)),
                            color: Constants.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[400]!,
                                blurRadius: 6,
                                offset: Offset(0, 0),
                              )
                            ]),
                        child: ListTile(
                          trailing: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(rotationController),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: widget.checked
                                    ? Constants.redColor
                                    : Constants.identityColor,
                                size: 35,
                              ),
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          title: Container(
                            padding: EdgeInsets.only(
                                left: Constants.halfPadding,
                                right: Constants.halfPadding),
                            child: AutoSizeText(
                              "Question ".tr() + widget.id,
                              style: TextStyle(
                                  color: Constants.identityColor,
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                              minFontSize: Constants.fontSize -
                                  (devicePixelRatio > 1.2 ? 2 : 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              expanded: Container(
                padding: EdgeInsets.symmetric(horizontal: Constants.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: Constants.identityColor,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: Constants.halfPadding),
                      child: AutoSizeText(
                        "Answer".tr(),
                        style: TextStyle(
                            color: Constants.redColor,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1),
                        maxLines: 2,
                        minFontSize: Constants.fontSize -
                            (devicePixelRatio > 1.2 ? 2 : 0),
                      ),
                    ),
                    Html(
                      data: arabicLanguage ? widget.answerAr! : widget.answerEn!,
                    ),
                  ],
                ),
              ),
            ),
          )
        ]);
  }
}
