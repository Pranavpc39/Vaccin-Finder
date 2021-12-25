import 'package:flutter/material.dart';
import '../Constants/constants.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 20.0,
      backgroundColor: Colors.indigo[400],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(kAppBarRadius),
          bottomRight: Radius.circular(kAppBarRadius),
        ),
      ),
      flexibleSpace: Center(
        child: Container(
            child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Vaccine Finder',
              textStyle: const TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w900,
              ),
              speed: const Duration(milliseconds: 200),
            ),
          ],
          repeatForever: false,
          totalRepeatCount: 10,
          pause: const Duration(milliseconds: 500),
          displayFullTextOnTap: true,
        )),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kAppBarSize);
}
