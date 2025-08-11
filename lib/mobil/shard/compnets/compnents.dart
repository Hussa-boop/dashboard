import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget defaultButton(
        {required double width,
        double border = 0.0,
        required Color background,
        void Function()? onPress,
        required String textButt,
        TextStyle? style}) =>
    Container(
      width: width,
      decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.all(Radius.circular(border))),
      child: MaterialButton(
        onPressed: onPress,
        child: Text(textButt, style: style),
      ),
    );

Widget defaultFromField(
        { FocusNode? focus,
          TextInputAction? textInputAction
          ,required TextEditingController controller,
        TextInputType type = TextInputType.text,
        required String label,
        required IconData prefix,
        IconData? suffix,
        bool visitPass = false,
        required String? Function(String?) validator,
        void Function(String)? onSubmit,
        void Function(String)? onChange,
          TextDirection TextDire= TextDirection.rtl,
        void Function()? suffixOnPress}) =>
    TextFormField(
      textDirection: TextDire,
      controller: controller,
      focusNode: focus,
      textInputAction:textInputAction ,
      keyboardType: type,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validator,
      obscureText: visitPass,
      decoration: InputDecoration(
          hintText:label ,
          prefixIcon: Icon(prefix),
          suffixIcon: suffix != null
              ? IconButton(
                  onPressed: suffixOnPress,
                  icon: Icon(suffix),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    );
