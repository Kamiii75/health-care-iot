import 'package:flutter/material.dart';

import '../utilities/constants.dart';
import '../utilities/size_config.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    required this.text,
    required this.press,
  }) : super(key: key);
  final String text;
  final Function() press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(56.0),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: SelectedBorder(),
          backgroundColor: MaterialStateProperty.all(kPrimaryLightColor),
        ),
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(19.0),
            color: Theme.of(context).hoverColor,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSins',
          ),
        ),
      ),
    );
  }
}

class SelectedBorder extends RoundedRectangleBorder
    implements MaterialStateOutlinedBorder {
  @override
  OutlinedBorder resolve(Set<MaterialState> states) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    );
  }
}
