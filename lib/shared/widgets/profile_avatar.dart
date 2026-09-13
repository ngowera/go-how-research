import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? image;
  final double radius;
  const ProfileAvatar(
      {super.key, required this.name, this.image, this.radius = 24});
  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    try {
      if (image?.startsWith('data:image/') == true)
        provider = MemoryImage(base64Decode(image!.split(',').last));
      else if (image?.startsWith('https://') == true)
        provider = NetworkImage(image!);
    } catch (_) {}
    return CircleAvatar(
        radius: radius,
        backgroundImage: provider,
        child: provider == null
            ? Text(name.trim().isEmpty
                ? 'R'
                : name.trim().substring(0, 1).toUpperCase())
            : null);
  }
}
