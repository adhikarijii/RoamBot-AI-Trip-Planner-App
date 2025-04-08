import 'package:flutter/material.dart';

class customButtons extends StatelessWidget {
  final Color bcolor;
  final BorderSide side;
  final String child;
  final Color fcolor;
  final Function? onPressed;
  const customButtons({
    required this.bcolor,
    required this.side,
    required this.child,
    required this.fcolor,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        side: side,
        backgroundColor: bcolor,
        foregroundColor: fcolor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed as void Function()?,
      child: Text(child.toUpperCase()),
    );
  }
}
