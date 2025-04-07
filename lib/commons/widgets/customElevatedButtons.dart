import 'package:flutter/material.dart';

class customButtons extends StatelessWidget {
  final Color bcolor;
  final String child;
  final Color fcolor;
  final Function? onPressed;
  const customButtons({
    required this.bcolor,
    required this.child,
    required this.fcolor,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bcolor,
        foregroundColor: fcolor,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed as void Function()?,
      child: Text(child.toUpperCase()),
    );
  }
}
