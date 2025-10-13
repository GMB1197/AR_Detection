/// Modello dati che rappresenta un dipinto da restaurare
class PaintingModel {
  /// Identificatore univoco del quadro
  final String id;

  /// Titolo del quadro
  final String title;

  /// Nome dell'artista
  final String artist;

  /// Descrizione breve del quadro
  final String description;

  /// Percorso dell'immagine danneggiata (per la UI)
  final String damagedImagePath;

  /// Percorso dell'immagine restaurata (per l'overlay AR)
  final String restoredImagePath;

  /// Nome della reference image in Xcode (deve corrispondere!)
  final String referenceImageName;

  /// Rapporto larghezza per il piano AR
  final double widthRatio;

  /// Rapporto altezza per il piano AR
  final double heightRatio;

  const PaintingModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.damagedImagePath,
    required this.restoredImagePath,
    required this.referenceImageName,
    this.widthRatio = 1.44,
    this.heightRatio = 0.94,
  });

  /// Converte il modello in JSON (utile per salvare preferenze in futuro)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'description': description,
      'damagedImagePath': damagedImagePath,
      'restoredImagePath': restoredImagePath,
      'referenceImageName': referenceImageName,
      'widthRatio': widthRatio,
      'heightRatio': heightRatio,
    };
  }

  /// Crea un modello da JSON (utile per caricare da file/database)
  factory PaintingModel.fromJson(Map<String, dynamic> json) {
    return PaintingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      description: json['description'] as String,
      damagedImagePath: json['damagedImagePath'] as String,
      restoredImagePath: json['restoredImagePath'] as String,
      referenceImageName: json['referenceImageName'] as String,
      widthRatio: (json['widthRatio'] as num?)?.toDouble() ?? 1.44,
      heightRatio: (json['heightRatio'] as num?)?.toDouble() ?? 0.94,
    );
  }

  /// Crea una copia del modello con alcuni campi modificati
  PaintingModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? description,
    String? damagedImagePath,
    String? restoredImagePath,
    String? referenceImageName,
    double? widthRatio,
    double? heightRatio,
  }) {
    return PaintingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      description: description ?? this.description,
      damagedImagePath: damagedImagePath ?? this.damagedImagePath,
      restoredImagePath: restoredImagePath ?? this.restoredImagePath,
      referenceImageName: referenceImageName ?? this.referenceImageName,
      widthRatio: widthRatio ?? this.widthRatio,
      heightRatio: heightRatio ?? this.heightRatio,
    );
  }

  @override
  String toString() {
    return 'PaintingModel(id: $id, title: $title, artist: $artist)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaintingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}