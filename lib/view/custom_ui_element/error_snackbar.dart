import 'package:flutter/material.dart';

errorSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      backgroundColor: Colors.red,
      content: Text("Something went wrong. Please try again later"),
    ),
  );
}
