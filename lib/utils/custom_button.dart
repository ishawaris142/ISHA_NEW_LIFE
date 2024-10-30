// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  double? height;
  double? width;
  Color? color;
  Decoration? decoration;
  Widget? child;
  TextStyle? textStyle;
  EdgeInsetsGeometry? padding;
  EdgeInsetsGeometry? margin;
  Function()? onTap;
   CustomButton({super.key,this.height,this.width,this.color,this.decoration,
   this.child,this.textStyle,this.padding,this.margin,this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
           height: height,
           width: width,
           padding: padding,
           margin: margin,
           decoration: decoration,
           child: child,
      ),
    );
  }
}