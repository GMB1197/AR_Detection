import 'package:flutter/material.dart';
import '../models/painting_model.dart';

class PaintingCard extends StatelessWidget {
  final PaintingModel painting;
  final VoidCallback onTap;

  const PaintingCard({
    super.key,
    required this.painting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immagine del quadro danneggiato
            Expanded(
              flex: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    painting.damagedImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Badge "Danneggiato"
                  // Positioned(
                  //   top: 8,
                  //   right: 8,
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 6,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.orange.withValues(alpha: 0.9),
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     child: const Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(
                  //           Icons.warning_rounded,
                  //           size: 16,
                  //           color: Colors.white,
                  //         ),
                  //         SizedBox(width: 4),
                  //         Text(
                  //           'Danneggiato',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            // Informazioni del quadro
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      painting.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      painting.artist,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      painting.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(  // Raggruppa icona e testo
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Scansiona',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}