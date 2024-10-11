import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  final String title;
  final String subscription;
  final String imagePath;
  final VoidCallback onPressed;

  const ImageButton({
    Key? key,
    required this.title,
    required this.subscription,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFf4f4f5),
        padding: const EdgeInsets.all(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        elevation: 3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text 부분
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subscription,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 이미지 부분
          Image.asset(
            imagePath,
            height: 50,
            width: 50,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
