import '../models/painting_model.dart';

//description: Descrizione della card del dipinto in Home
//detailDescription: Descrizione all'interno di painting_detail_screen.dart
//info: Testo lungo che uso come pannello info in AR

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

      detailDescription: '''L'immagine mostra un'opera d'arte intitolata "Adorazione dei pastori" o "Adorazione del Bambino" di Gerrit van Honthorst (noto in Italia come Gherardo delle Notti).
  Il dipinto è famoso per l'uso magistrale del chiaroscuro e per l'illuminazione che sembra provenire dal Bambino Gesù stesso, come se fosse una fonte di luce.
  L'opera originale, risalente al 1619-1620 circa, è conservata presso la Galleria degli Uffizi a Firenze.
  L'immagine mostra il dipinto nel suo stato attuale, danneggiato in modo significativo dall'attentato mafioso di via dei Georgofili nel 1993, che ha causato ingenti perdite di superficie pittorica.
  L'artista olandese Gherardo delle Notti era un seguace dello stile di Caravaggio, noto per le sue scene notturne e l'uso drammatico della luce. ''',
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

      detailDescription: '''L'immagine mostra il chiostro dell'Anantara Convento di Amalfi Grand Hotel, un ex convento benedettino situato sulla scogliera di Amalfi. 
    L'edificio originario, il Convento di San Francesco, fu fondato nel XIII secolo, ma l'attuale struttura incorpora elementi dell'XI secolo.
        Il chiostro, visibile nell'immagine, presenta un notevole stile arabo-normanno con una serie di archi intrecciati e colonne sottili.
    Oggi l'edificio è un hotel di lusso che offre viste panoramiche sulla Costiera Amalfitana.
    L'hotel è noto per la sua architettura storica unica e la sua posizione drammatica a strapiombo sul mare.''',
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

      detailDescription: '''L'immagine mostra il dipinto a olio su tela intitolato "I giocatori di carte" di Bartolomeo Manfredi. 
Il dipinto, risalente al 1617-1618 circa, è conservato presso le Gallerie degli Uffizi a Firenze. 
L'opera è nota per essere stata gravemente danneggiata dall'attentato mafioso di via dei Georgofili avvenuto il 27 maggio 1993. 
Considerato inizialmente irrecuperabile a causa delle centinaia di schegge che lo hanno trafitto, il dipinto è stato sottoposto a un lungo e complesso restauro, che ha utilizzato nuove tecnologie per ricomporre i frammenti. 
Il restauro ha lasciato visibili i segni indelebili dei danni subiti, come testimonianza della strage e simbolo di resistenza. ''',
    ),
    PaintingModel(
      id: 'painting-4',
      title: 'Madonna della Trinità',
      artist: 'Cimabue',
      description: 'Maestà con angeli, appare nell\'altare della chiesa',
      damagedImagePath: 'assets/painting-4-overlay.png',
      restoredImagePath: 'assets/trinita_1.png',
      referenceImageName: 'painting-4',
      widthRatio: 1.0,
      heightRatio: 1.0,
      offsetX: 0.0,
      offsetY: 0.0,
      offsetZ: 0.000,

      detailDescription: '''L'immagine mostra la Maestà di Santa Trinita, un'importante pala d'altare del pittore fiorentino Cimabue. 
L'opera, dipinta su tavola a tempera e oro, risale al periodo tra il 1290 e il 1300 circa. 
Raffigura la Vergine Maria in trono con il Bambino Gesù in grembo, circondata da otto angeli, e quattro profeti a mezzo busto nella parte inferiore. 
La pala fu commissionata per l'altare maggiore della chiesa di Santa Trinita a Firenze, dove rimase fino al 1471. 
È considerata un'opera innovativa per l'epoca, poiché Cimabue tentò di superare la rigidità della pittura bizantina introducendo un senso di profondità spaziale nel trono architettonico e una maggiore umanità nelle figure. 
Attualmente l'opera è conservata ed esposta presso le Gallerie degli Uffizi a Firenze. ''',

      // ROTAZIONE CHIESA:
      //rotationY: -0.17, // circa -10° (leggera rotazione a sinistra)
      // rotationY: -0.26,  // circa -15° (rotazione moderata a sinistra)
      // rotationY: -0.35,  // circa -20° (rotazione marcata a sinistra)
      rotationY: 0.0,    // 0° (perfettamente frontale)
      // rotationY: 0.17,   // circa +10° (leggera rotazione a destra)
      // rotationY: 0.26,   // circa +15° (rotazione moderata a destra)
      // rotationY: 0.35,   // circa +20° (rotazione marcata a destra)
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

      detailDescription: '''Il dipinto raffigurato è la celebre opera rinascimentale di Filippo Lippi, intitolata "Madonna col Bambino e angeli" (detta anche Lippina). 
L'opera, databile intorno al 1465, è una tempera su tavola ed è conservata presso la Galleria degli Uffizi a Firenze. 
È considerata una delle opere più note e interamente autografe dell'artista, nonché un punto di riferimento per le successive rappresentazioni della Madonna con Bambino, in particolare quelle di Sandro Botticelli. 
La Vergine è ritratta con le fattezze di Lucrezia Buti, una monaca di cui Lippi si innamorò e che rapì, destando scandalo all'epoca. 
Il dipinto è noto per la sua modernità, l'umanità terrena della rappresentazione e l'uso di elementi come l'acconciatura e le vesti, in linea con la moda fiorentina del tempo. ''',
    ),
    PaintingModel(
      id: 'painting-6',
      title: 'Annunciazione (confronto Botticelli)',
      artist: 'Sandro Botticelli',
      description: 'Confronto manuale tra due versioni dell’Annunciazione',
      detailDescription: '''Il dipinto mostrato nell'immagine è l'Annunciazione di Cestello. 
È un'opera a tempera su tavola realizzata da Sandro Botticelli.
Il dipinto è stato creato intorno al 1489-1490.
Attualmente è conservato ed esposto nella Galleria degli Uffizi a Firenze.
La scena raffigura l'Arcangelo Gabriele che annuncia a Maria la sua gravidanza divina.''',
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

      detailDescription: '''L'immagine mostra un pannello del celebre trittico di Paolo Uccello intitolato La Battaglia di San Romano. L'opera, realizzata intorno al 1438, commemora la vittoria delle truppe fiorentine su quelle senesi avvenuta nel 1432. 
Il trittico era originariamente composto da tre grandi tavole, oggi separate e conservate in musei diversi: la Galleria degli Uffizi a Firenze, la National Gallery a Londra e il Louvre a Parigi. 
Il pannello specifico nell'immagine (quello degli Uffizi) raffigura l'episodio del disarcionamento di Bernardino della Ciarda, condottiero dell'esercito di Siena, da parte di Niccolò da Tolentino, comandante fiorentino. 
L'opera è rinomata per l'uso innovativo della prospettiva lineare, una tecnica geometrico-matematica che ha permesso all'artista di creare un'illusione di profondità spaziale su una superficie piana. 
Il dipinto fonde elementi del Gotico Internazionale con la nuova sensibilità del Rinasci''',
    ),
    PaintingModel(
      id: 'painting-8',
      title: 'Ritratto di Papa Leone X',
      artist: 'Raffaello Sanzio',
      description: 'Inquadra per scoprire la storia di questo capolavoro',
      detailDescription: 'Utilizza la fotocamera del tuo cullare per scoprire le informazioni di questo capolavoro attraverso la realtà aumentata',

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
      detailDescription: '''Il dipinto mostrato nell'immagine è l'Annunciazione di Leonardo da Vinci, un capolavoro giovanile del Rinascimento italiano. 
L'opera, realizzata tra il 1472 e il 1475 circa, è conservata presso la Galleria degli Uffizi a Firenze. 
Raffigura l'Arcangelo Gabriele che annuncia alla Vergine Maria che diventerà madre di Gesù, un tema popolare nell'arte cristiana. 
Leonardo si discosta dalla tradizione ambientando la scena all'aperto in un giardino recintato (hortus conclusus), simbolo della purezza di Maria, anziché in una camera da letto. 
Il dipinto è noto per l'uso innovativo della prospettiva lineare e aerea, e per la rappresentazione naturalistica delle figure e del paesaggio, che riflettono l'indagine scientifica del reale da parte dell'artista. ''',
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
      detailDescription: '''La Venere di Urbino è un dipinto a olio su tela (119×165 cm) di Tiziano Vecellio, databile al 1538 e conservato nella Galleria degli Uffizi di Firenze.
Considerata come uno dei più grandi capolavori della storia della pittura, la Venere di Urbino incarna la perfetta rappresentazione della donna, che come Venere, diventa simbolo di amore, bellezza e fertilità. Tutto ciò è reso, da Tiziano, grazie all'uso sapiente del colore e dei suoi contrasti, così come il sottile gioco di allusioni e significati. iziano rappresentò la sua Venere mettendo in secondo piano i riferimenti mitologici, trasponendola anzi in un ambiente domestico moderno. La sensuale dea, completamente nuda, è infatti distesa su un letto coperto da un lenzuolo bianco (che lascia intravedere il doppio materasso con un motivo tessuto a fiori), appoggiando il busto e un braccio su due cuscini, mentre guarda lo spettatore e con la mano sinistra si copre il pube (tema della Venere pudica), mentre con la destra lascia cadere lentamente alcune rose rosse, fiore sacro alla dea. Ciò indica il passare del tempo: infatti, proprio il fatto che sia una bella dea come la Venere a tenere in mano un simbolo con tale significato vuol dire che la bellezza svanisce con l'avanzare della vecchiaia e che quindi bisogna basare la propria esistenza su altre qualità più durature, quali, appunto, la fedeltà.
Ai suoi piedi sta rannicchiato un cagnolino, dipinto con amorevole realismo (lo stesso del Ritratto di Eleonora Gonzaga della Rovere), che simboleggia la fedeltà, facendo da esempio alla sposa del granduca: il messaggio è quello di essere sensuali, ma solo per il proprio sposo. La dea ha infatti un anello al dito mignolo e indossa, oltre a un bel bracciale d'oro con pietre preziose, una perla a forma di goccia come orecchino, simbolo di purezza. I capelli biondi sono acconciati con una treccia che gira attorno alla nuca, e sciolti sulle spalle, in bei ricci dorati che hanno la morbidezza tipica delle migliori opere dell'artista. La fisionomia della donna ricorda quella di altre figure femminili di Tiziano (ad esempio la Bella, il Ritratto di fanciulla in pelliccia e il Ritratto di fanciulla con cappello piumato) e forse era un'amante dell'artista che faceva da modella.
A differenza della Venere dormiente di Giorgione, la dea di Tiziano fissa in modo deciso l'osservatore, noncurante della sua nudità, con una posa ambigua, a metà strada tra il pudore e l'invito. La forte cesura della parete scura alle spalle della dea, che si interrompe a metà del dipinto, crea una decisa linea di forza che indirizza lo sguardo dello spettatore proprio verso l'inguine, per risalire poi lungo il ventre e il petto, fino allo sguardo.

Nel Dettaglio i toni scuri o freddi dello sfondo fanno inoltre risaltare il calore delle luminose carni femminili, grazie anche alla presenza della macchia colore rosso nei materassi scoperti ad arte. In secondo piano vengono rappresentate due ancelle che cercano i vestiti della dea nel vestiario.

Come ambientazione notiamo la pesante tenda verde che separa l'alcova dal resto della stanza è scostata e mostra un interno rinascimentale, con una stanza dal pavimento a riquadri, in cui due ancelle stanno frugando in un cassone i vestiti da far indossare alla dea. Una è infatti inginocchiata a rovistare e l'altra, con un vestito rosso e un'elegante acconciatura, tiene già un ricco vestito sulla spalla.
Candelabre dorate decorano le pareti, mentre le cassapanche hanno girali all'antica con elementi antropomorfi, segno di un arredamento aggiornatissimo alle tendenze più recenti. La luce, oltre che da davanti, entra dalla finestra sullo sfondo, dotata di colonna al centro e dalla quale si vede, oltre al vaso di mirto, un cielo rischiarato dalla luce dorata e un albero, che allude all'esistenza di un giardino. Inoltre l'illuminazione nella stanza proviene da sinistra e getta una netta ombra della serva in piedi sulla parete dietro di essa.''',
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