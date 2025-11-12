import '../models/painting_model.dart';

class PaintingsData {
  static final List<PaintingModel> paintings = [
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
      title: 'Annunciazione (confronto Botticelli)',
      artist: 'Sandro Botticelli',
      description: 'Confronto manuale tra due versioni dell’Annunciazione',
      referenceImageName: 'painting-6',

      // Usa un asset ESISTENTE anche per questi due campi (evita path inesistenti)
      damagedImagePath: 'assets/painting-6.png',
      restoredImagePath: 'assets/Botticelli_annunciazione_del_Metropolitan.jpg',

      // Geometria/offset: riusa i tuoi default (regola se serve)
      widthRatio: 1.0,
      heightRatio: 1.0,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.0,

      // Immagini di confronto per la transizione manuale (come painting-10)
      alternateImages: [
        {
          'title': 'Annunciazione – Metropolitan Museum of Art',
          'path': 'assets/Botticelli_annunciazione_del_Metropolitan.jpg',
          'source': 'The Metropolitan Museum of Art, New York',
          'info': '''Il dipinto è l'"Annunciazione" di Sandro Botticelli, realizzata con tempera su tavola intorno al 1485. Si trova nella collezione del Metropolitan Museum of Art di New York.
L'opera raffigura l'Arcangelo Gabriele che annuncia alla Vergine Maria l'imminente nascita di Gesù Cristo.
La scena è ambientata in un interno architettonico, con una prospettiva monocentrica che crea un'illusione di profondità.
Una fila di colonne al centro divide lo spazio occupato dall'angelo da quello della camera da letto della Vergine.
L'angelo tiene in mano un giglio bianco, simbolo di purezza.
Questo piccolo quadro fu quasi certamente commissionato per la devozione privata.''',
        },
        {
          'title': 'Annunciazione – Glasgow (ca. 1490)',
          'path': 'assets/AnnunciazioneBotticelli-1490_glasgow.jpg',
          'source': 'Kelvingrove Art Gallery and Museum, Glasgow',
          'info': '''Il dipinto mostrato nell'immagine è l'Annunciazione (nota anche come Annunciazione di Glasgow), un'opera a tempera su tavola di Sandro Botticelli, realizzata intorno al 1490.
L'opera raffigura l'Arcangelo Gabriele che annuncia alla Vergine Maria che concepirà il figlio di Dio.
È conservata nella Kelvingrove Art Gallery and Museum di Glasgow, in Scozia.
Il dipinto è noto per il suo uso della prospettiva, sebbene un'analisi dettagliata riveli che la griglia prospettica non è perfettamente corretta, suggerendo un artificio prospettico da parte dell'artista.
La scena è ambientata in un elegante, ma spoglio, palazzo rinascimentale, con un giardino visibile sullo sfondo.''',
        },
      ],

      secondaryOverlayPath: null,
      hasInteractiveHotspots: false,
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
      info: '''L'opera, realizzata nel 1518, ritrae al centro Papa Leone X, al secolo Giovanni de' Medici, seduto tra i suoi cugini cardinali Giulio de' Medici (futuro Papa Clemente VII) e Luigi de' Rossi.

• Il dipinto è noto per l'uso magistrale del colore, in particolare le varie sfumature di rosso, e per l'attenzione ai dettagli, come il riflesso della stanza sul pomello della sedia papale.
• Il papa è raffigurato con una lente d'ingrandimento in mano, un dettaglio che allude alla sua miopia, mentre si appoggia a un libro miniato.
• Il ritratto fu commissionato per essere inviato a Firenze in occasione delle nozze del nipote del papa, Lorenzo duca di Urbino, con Madeleine de La Tour d'Auvergne.
• L'opera originale è conservata presso le Gallerie degli Uffizi a Firenze, ma ne esistono diverse copie, tra cui una di Andrea del Sarto esposta al Museo di Capodimonte a Napoli.''',
      damagedImagePath: 'assets/painting-8.png',
      restoredImagePath: 'assets/painting-8.png',
      referenceImageName: 'painting-8',
      widthRatio: 1.0,
      heightRatio: 1.35,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.001,
    ),

    // Iconografia con stencil cliccabili
    PaintingModel(
      id: 'painting-9',
      title: 'L\'Annunciazione',
      artist: 'Leonardo da Vinci',
      description: 'Tocca gli stencil per scoprire i disegni preparatori',
      damagedImagePath: 'assets/painting-9.png',
      restoredImagePath: 'assets/leonardo_annunciazione_stencil.png',
      referenceImageName: 'painting-9',
      // Per allineamento perfetto al marker: tieni 1:1
      widthRatio: 1.00,
      heightRatio: 1.00,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.0,

      hasInteractiveHotspots: true,
      hotspots: [
        {
          'id': 0,
          'x': -0.20, // Sposta in orizzontale
          'y': 0.01,  // Sposta in verticale
          'wPct': 0.12,  // Larghezza
          'hPct': 0.15,  // Altezza
          'title': 'Studio preparatorio dell\'Angelo',
          'description':
          'Studi approfonditi delle pieghe del vestito dell\'angelo. Leonardo applicava tecniche di chiaroscuro per rendere il tessuto realistico. Ogni piega era attentamente pianificata per creare un senso di movimento e naturalezza.',
        },
        {
          'id': 1,
          'x': 0.20,   // Sposta in orizzontale
          'y': -0.10,   // Sposta in verticale
          'wPct': 0.16,  // Larghezza
          'hPct': 0.25,  // Altezza
          'title': 'Studio preparatorio della Madonna',
          'description':
          'Disegni preparatori della figura della Madonna. Leonardo studiò attentamente la postura, l\'espressione e il panneggio del mantello. I suoi disegni rivelano l\'attenzione ai dettagli anatomici e alla composizione armoniosa della scena.',
        },
      ],
      detailImagePaths: [
        'assets/leonardo_detail_horse_overlay.png',   // 0 (Angelo)
        'assets/leonardo_detail_drapery_overlay.png', // 1 (Madonna)
      ],
    ),

    // Confronto tra le Veneri con transizione manuale
    PaintingModel(
      id: 'painting-10',
      title: 'Venere di Urbino',
      artist: 'Tiziano Vecellio',
      description: 'Confronto manuale con le Veneri di Giorgione e Manet',
      damagedImagePath: 'assets/painting-10.png',
      restoredImagePath: 'assets/venere_giorgione.png',
      referenceImageName: 'painting-10',
      widthRatio: 1.00,
      heightRatio: 1.00,
      offsetX: 0.00,
      offsetY: 0.00,
      offsetZ: 0.000,

      // Immagini alternative con tutte le proprietà
      alternateImages: [
        {
          'path': 'assets/venere_giorgione.png',
          'widthRatio': 0.95,
          'heightRatio': 1.45,
          'offsetX': 0.00,
          'offsetY': 0.00,
          'offsetZ': 0.000,
          'title': 'Giorgione - Venere dormiente',
          'source': 'Gemäldegalerie Alte Meister, Dresda',
          'info': '''Il dipinto mostrato nell'immagine è la Venere dormiente (nota anche come Venere di Dresda), un'opera d'arte iconica del Rinascimento italiano.
Dettagli del Dipinto
Artista Principale: Giorgione (Giorgio Barbarelli da Castelfranco).
Completamento: Si ritiene ampiamente che l'allievo e collaboratore di Giorgione, Tiziano Vecellio, abbia completato il paesaggio e il cielo dopo la morte prematura di Giorgione nel 1510.
Data: Circa 1508-1510.
Tecnica: Olio su tela.
Dimensioni: 108,5 cm × 175 cm.
Ubicazione: Attualmente è conservato nella Gemäldegalerie Alte Meister (Pinacoteca dei Maestri Antichi) a Dresda, Germania.
Significato e Influenza
La Venere dormiente è considerata un'opera fondamentale nella storia dell'arte occidentale per diversi motivi:
È il primo nudo femminile reclinato su larga scala conosciuto nella pittura occidentale dal tempo dell'antichità romana.
Ha stabilito il genere del nudo mitologico-pastorale erotico, influenzando generazioni di artisti.
La composizione armoniosa tra la figura umana e il paesaggio circostante fu un'innovazione significativa.
Il dipinto ha ispirato numerose opere successive, tra cui la famosa Venere di Urbino di Tiziano, la Venere Rokeby di Velázquez, la Maja desnuda di Goya e l'Olympia di Manet.
Originariamente, il dipinto includeva una figura di Cupido seduto ai piedi di Venere, che fu successivamente coperta nel XIX secolo.''',
        },
        {
          'path': 'assets/venere_manet.png',
          'widthRatio': 0.95,
          'heightRatio': 1.35,
          'offsetX': 0.00,
          'offsetY': 0.00,
          'offsetZ': 0.000,
          'title': 'Manet - Olympia',
          'source': 'Musée d\'Orsay, Parigi',
          'info': '''L'immagine mostra il celebre dipinto "Olympia" di Édouard Manet.
Titolo: Olympia
Artista: Édouard Manet
Data: 1863
Tecnica: Olio su tela
Ubicazione attuale: Museo d'Orsay, Parigi
Il dipinto suscitò grande scandalo al Salon di Parigi del 1865 a causa del suo realismo e della rappresentazione di una prostituta, un soggetto non idealizzato e privo di giustificazioni mitologiche o storiche, che guardava lo spettatore con uno sguardo diretto e audace. L'opera è considerata un'icona dell'arte moderna.''',
        },
      ],
    ),
  ];

  static PaintingModel? getPaintingById(String id) {
    try {
      return paintings.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static PaintingModel? getPaintingByReferenceName(String referenceName) {
    try {
      return paintings.firstWhere((p) => p.referenceImageName == referenceName);
    } catch (_) {
      return null;
    }
  }
}