import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/customFontSize.dart';
import 'package:roambot/commons/widgets/custom_elevated_buttons.dart';

class customConfirmationBox {
  static void show({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressedYes,
    // required VoidCallback? onPressedNo,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Icon(Icons.error_outline, size: 60, color: Colors.red),
          content: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: customFontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: customButtons(
                    bcolor: Colors.red,
                    child: "No",
                    fcolor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: customButtons(
                    bcolor: const Color(0xFF3B86F5),
                    child: "Yes",
                    fcolor: Colors.white,
                    onPressed: onPressedYes,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
