import 'package:flutter/material.dart';
import '../models/painting_model.dart';
import 'ar_view_screen.dart';

class PaintingDetailScreen extends StatelessWidget {
  final PaintingModel painting;

  const PaintingDetailScreen({
    super.key,
    required this.painting,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con immagine
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    painting.damagedImagePath,
                    fit: BoxFit.cover,
                  ),
                  // Gradient per migliore leggibilità
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenuto
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titolo
                        Text(
                          painting.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                        ),
                        const SizedBox(height: 8),

                        // Artista
                        Text(
                          painting.artist,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Divisore
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 24),

                        // Descrizione
                        Text(
                          'Descrizione',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          painting.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.grey[800],
                              ),
                        ),

                        // Info extra se disponibile
                        if (painting.info != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            painting.info!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.grey[800],
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],

                        const SizedBox(height: 40),

                        // Pulsante per iniziare la scansione
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ARViewScreen(
                                    painting: painting,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.camera_alt, size: 24),
                            label: const Text(
                              'Scansiona il Quadro',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
