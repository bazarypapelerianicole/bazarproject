import 'dart:io';

import 'package:bazarnicole/Presentation/Services/google_drive_backup_service.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:flutter/material.dart';

InputDecoration modernInput({
  required String label,
  String? hint,
  String? prefix,
  String? suffix,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefix,
    suffixText: suffix,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: AppColors.lightWhite,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
    ),
    labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
    hintStyle: TextStyle(color: Colors.grey.shade400),
  );
}

Widget formSection({required String title, required List<Widget> children}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 12),
      ...children,
    ],
  );
}

bool isLocalImagePath(String value) =>
    value.contains('/') || value.contains('\\') || value.startsWith('file:');

Widget imagePreview(
  String value, {
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) => isLocalImagePath(value)
    ? Image.file(
        File(value),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      )
    : Image.network(
        GoogleDriveBackupService.publicImageUrl(value),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );

Widget imagePlaceholder() {
  return Container(
    color: AppColors.lightWhite,
    child: Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 40,
        color: Colors.grey.shade300,
      ),
    ),
  );
}
