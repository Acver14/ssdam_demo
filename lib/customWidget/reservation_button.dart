import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/src/button.dart';
import 'package:ssdam_demo/style/customColor.dart';

class ReservationButton extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final bool darkMode;
  final double borderRadius;
  final VoidCallback onPressed;
  final Color splashColor;
  final Color color;

  ReservationButton(
      {this.onPressed,
      this.text,
      this.textStyle,
      this.splashColor,
      this.darkMode = false,
      this.color = COLOR_SSDAM,
      this.borderRadius = defaultBorderRadius,
      Key key})
      : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
        child: RaisedButton(
            color: this.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            splashColor: splashColor,
            onPressed: this.onPressed,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
              child: Text(
                text,
                style: textStyle ?? TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            )
        )
    );
  }
}
