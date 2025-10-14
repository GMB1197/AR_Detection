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

  /// Offset X per posizionamento custom (in metri, relativo al centro)
  final double offsetX;

  /// Offset Y per posizionamento custom (in metri, relativo al centro)
  final double offsetY;

  /// Offset Z per posizionamento custom (in metri, distanza dalla superficie)
  final double offsetZ;

  /// Path per un secondo overlay (opzionale) - es. dipinto dentro la chiesa
  final String? secondaryOverlayPath;

  /// Ratio per il secondo overlay
  final double? secondaryWidthRatio;
  final double? secondaryHeightRatio;

  /// Offset per il secondo overlay
  final double? secondaryOffsetX;
  final double? secondaryOffsetY;
  final double? secondaryOffsetZ;

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
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.offsetZ = 0.003,
    this.secondaryOverlayPath,
    this.secondaryWidthRatio,
    this.secondaryHeightRatio,
    this.secondaryOffsetX,
    this.secondaryOffsetY,
    this.secondaryOffsetZ,
  });

  /// Converte il modello in JSON
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
      'offsetX': offsetX,
      'offsetY': offsetY,
      'offsetZ': offsetZ,
      'secondaryOverlayPath': secondaryOverlayPath,
      'secondaryWidthRatio': secondaryWidthRatio,
      'secondaryHeightRatio': secondaryHeightRatio,
      'secondaryOffsetX': secondaryOffsetX,
      'secondaryOffsetY': secondaryOffsetY,
      'secondaryOffsetZ': secondaryOffsetZ,
    };
  }

  /// Crea un modello da JSON
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
      offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0.0,
      offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0.0,
      offsetZ: (json['offsetZ'] as num?)?.toDouble() ?? 0.003,
      secondaryOverlayPath: json['secondaryOverlayPath'] as String?,
      secondaryWidthRatio: (json['secondaryWidthRatio'] as num?)?.toDouble(),
      secondaryHeightRatio: (json['secondaryHeightRatio'] as num?)?.toDouble(),
      secondaryOffsetX: (json['secondaryOffsetX'] as num?)?.toDouble(),
      secondaryOffsetY: (json['secondaryOffsetY'] as num?)?.toDouble(),
      secondaryOffsetZ: (json['secondaryOffsetZ'] as num?)?.toDouble(),
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
    double? offsetX,
    double? offsetY,
    double? offsetZ,
    String? secondaryOverlayPath,
    double? secondaryWidthRatio,
    double? secondaryHeightRatio,
    double? secondaryOffsetX,
    double? secondaryOffsetY,
    double? secondaryOffsetZ,
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
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      offsetZ: offsetZ ?? this.offsetZ,
      secondaryOverlayPath: secondaryOverlayPath ?? this.secondaryOverlayPath,
      secondaryWidthRatio: secondaryWidthRatio ?? this.secondaryWidthRatio,
      secondaryHeightRatio: secondaryHeightRatio ?? this.secondaryHeightRatio,
      secondaryOffsetX: secondaryOffsetX ?? this.secondaryOffsetX,
      secondaryOffsetY: secondaryOffsetY ?? this.secondaryOffsetY,
      secondaryOffsetZ: secondaryOffsetZ ?? this.secondaryOffsetZ,
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