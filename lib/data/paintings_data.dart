import '../models/painting_model.dart';

class PaintingsData {
  static const List<PaintingModel> paintings = [
    PaintingModel(
      id: 'painting-1',
      title: 'Adorazione dei Pastori',
      artist: 'Gherardo delle Notti',
      description: 'Opera d\'arte sacra del periodo barocco',
      damagedImagePath: 'assets/painting-1-damaged.png',
      restoredImagePath: 'assets/painting-1-restored.png',
      referenceImageName: 'painting-1-damaged',
      widthRatio: 1.44,
      heightRatio: 0.94,
    ),
    PaintingModel(
      id: 'painting-2',
      title: 'Convento dei Cappuccini',
      artist: 'Autore Sconosciuto',
      description: 'Veduta architettonica storica',
      damagedImagePath: 'assets/painting-2-damaged.png',
      restoredImagePath: 'assets/painting-2-restored.png',
      referenceImageName: 'painting-2-damaged',
      widthRatio: 1.0,
      heightRatio: 1.0,
    ),
    PaintingModel(
      id: 'painting-3',
      title: 'I Giocatori di Carte',
      artist: 'Bartolomeo Manfredi',
      description: 'Opera d\'arte dove sono raffigurati giocatori di carte',
      damagedImagePath: 'assets/painting-3-damaged.png',
      restoredImagePath: 'assets/painting-3-restored.png',
      referenceImageName: 'painting-3-damaged',
      widthRatio: 1.0,
      heightRatio: 1.0,
    ),
  ];

  static PaintingModel? getPaintingById(String id) {
    try {
      return paintings.firstWhere((painting) => painting.id == id);
    } catch (e) {
      return null;
    }
  }

  static PaintingModel? getPaintingByReferenceName(String referenceName) {
    try {
      return paintings.firstWhere(
            (painting) => painting.referenceImageName == referenceName,
      );
    } catch (e) {
      return null;
    }
  }
}