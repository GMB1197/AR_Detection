import '../models/painting_model.dart';

class PaintingsData {
  static const List<PaintingModel> paintings = [
    PaintingModel(
      id: 'painting-1',
      title: 'Adorazione dei Pastori',
      artist: 'Gherardo delle Notti',
      description: 'Opera d\'arte sacra del periodo barocco',
      damagedImagePath: 'assets/painting-1-damaged.png',
      restoredImagePath: 'assets/painting-1-restored-optimized.png',
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
      restoredImagePath: 'assets/painting-3-restored-optimized.jpg',
      referenceImageName: 'painting-3-damaged',
      widthRatio: 1.0,
      heightRatio: 1.0,
    ),

    PaintingModel(
      id: 'painting-4',
      title: 'Madonna della Trinità',
      artist: 'Cimabue',
      description: 'Maestà con angeli, appare nell\'altare della chiesa',
      damagedImagePath: 'assets/painting-4-overlay.png',
      restoredImagePath: 'assets/trinita_1.png',
      referenceImageName: 'painting-4',
      widthRatio: 3.0,
      heightRatio: 3.0,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.000,
    ),

    PaintingModel(
      id: 'painting-5',
      title: 'Madonna col Bambino',
      artist: 'Filippo Lippi',
      description: 'Scansiona per rivelare il disegno preparatorio',
      damagedImagePath: 'assets/painting-5.png',
      restoredImagePath: 'assets/lippi_madonna_disegno.png',
      referenceImageName: 'painting-5',
      widthRatio: 1.20,
      heightRatio: 0.93,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.001,
    ),

    PaintingModel(
      id: 'painting-6',
      title: 'Annunciazione',
      artist: 'Sandro Botticelli',
      description: 'Scansiona lo spazio centrale per vedere i pannelli completi',
      damagedImagePath: 'assets/painting-6.png',
      restoredImagePath: 'assets/botticelli_annunciazione_over.png',
      referenceImageName: 'painting-6',
      widthRatio: 2.90,
      heightRatio: 4.40,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.000,
    ),

    PaintingModel(
      id: 'painting-7',
      title: 'Battaglia di San Romano',
      artist: 'Paolo Uccello',
      description: 'Scansiona lo spazio centrale per vedere la battaglia completa',
      damagedImagePath: 'assets/painting-7.png',
      restoredImagePath: 'assets/sanromano_over.png',
      referenceImageName: 'painting-7',
      widthRatio: 2.90,
      heightRatio: 4.10,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.000,
    ),

    PaintingModel(
      id: 'painting-8',
      title: 'Ritratto di Papa Leone X',
      artist: 'Raffaello Sanzio',
      description: 'Inquadra per scoprire la storia di questo capolavoro',
      damagedImagePath: 'assets/painting-8.png',
      restoredImagePath: 'assets/painting-8.png',
      referenceImageName: 'painting-8',
      widthRatio: 1.0,
      heightRatio: 1.35,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.001,
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