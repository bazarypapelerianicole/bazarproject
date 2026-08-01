import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:flutter/material.dart';

class AddProductButton extends StatelessWidget {
  const AddProductButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.whiteOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
          minimumSize: const Size(48, 48),
        ),
        onPressed: onPressed,
        child: const Icon(Icons.add, size: 20, color: AppColors.primaryLogo),
      ),
    );
  }
}
