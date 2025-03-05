import 'package:flutter/material.dart';
import 'package:oishi/utils/constants.dart';

class ErrorPage extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onReload;

  const ErrorPage({
    Key? key,
    required this.errorMessage,
    required this.onReload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImage.error.path), // Ensure this path is correct
            const SizedBox(height: 20),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onReload,
              child: const Text(
                'اعادة تحميل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
