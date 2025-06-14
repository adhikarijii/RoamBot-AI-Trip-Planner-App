import 'package:flutter/material.dart';

class customButtons extends StatelessWidget {
  final Color bcolor;
  final dynamic child;
  final Color fcolor;
  final VoidCallback? onPressed;
  final bool isClicked;
  const customButtons({
    required this.bcolor,
    required this.child,
    required this.fcolor,
    required this.onPressed,
    this.isClicked = false,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bcolor,
        foregroundColor: fcolor,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: isClicked ? null : onPressed,
      child:
          isClicked
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Text(child.toUpperCase()),
    );
  }
}
