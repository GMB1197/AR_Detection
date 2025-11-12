import 'dart:io';
import 'package:flutter/material.dart';

class HotspotDetailView extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final VoidCallback onBack;

  const HotspotDetailView({
    super.key,
    required this.title,
    required this.description,
    required this.onBack,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.96),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            if (imageUrl != null)
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.cyan.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(Uri.parse(imageUrl!).path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  description,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
