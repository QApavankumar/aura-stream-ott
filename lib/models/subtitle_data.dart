/// Timed subtitle cue — a single line of text with start/end timestamps.
class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
  });

  /// Returns `true` when [position] falls within this cue's time range.
  bool isActive(Duration position) =>
      position >= start && position < end;
}

// ---------------------------------------------------------------------------
// Continuous subtitle tracks for OTT testing.
// Seamlessly loops so subtitles display continuously throughout any movie.
// ---------------------------------------------------------------------------

/// Telugu subtitles
const List<SubtitleCue> teluguSubtitles = [
  SubtitleCue(start: Duration(seconds: 0), end: Duration(seconds: 5), text: '[ ఆరా స్ట్రీమ్ • తెలుగు ఉపశీర్షికలు ]'),
  SubtitleCue(start: Duration(seconds: 5), end: Duration(seconds: 10), text: 'సినిమా ప్రారంభమైంది... సిద్ధంగా ఉండండి.'),
  SubtitleCue(start: Duration(seconds: 10), end: Duration(seconds: 15), text: 'అనంతమైన శూన్యం మన ముందు విస్తరించి ఉంది.'),
  SubtitleCue(start: Duration(seconds: 15), end: Duration(seconds: 20), text: 'కమాండర్, అన్ని వ్యవస్థలు పనిచేస్తున్నాయి.'),
  SubtitleCue(start: Duration(seconds: 20), end: Duration(seconds: 25), text: 'వార్ప్ సీక్వెన్స్ ప్రారంభం: 3... 2... 1...'),
  SubtitleCue(start: Duration(seconds: 25), end: Duration(seconds: 30), text: 'మనం విజయవంతంగా హైపర్‌స్పేస్‌లోకి ప్రవేశించాము.'),
  SubtitleCue(start: Duration(seconds: 30), end: Duration(seconds: 35), text: 'సమీపంలో ఉన్న కొత్త ప్రాంతాల కోసం అన్వేషణ.'),
  SubtitleCue(start: Duration(seconds: 35), end: Duration(seconds: 40), text: 'ఎడమ వైపున వింత శక్తి సంకేతం గుర్తించబడింది.'),
  SubtitleCue(start: Duration(seconds: 40), end: Duration(seconds: 46), text: '"జాగ్రత్తగా ఉండండి. అక్కడ ఏముందో ఎవరికీ తెలియదు."'),
  SubtitleCue(start: Duration(seconds: 46), end: Duration(seconds: 52), text: 'ఈ సిగ్నల్ ఒక శక్తివంతమైన కేంద్రం నుండి వస్తోంది.'),
  SubtitleCue(start: Duration(seconds: 52), end: Duration(seconds: 58), text: 'ఆ సంకేతాన్ని పసిగట్టేందుకు దిశ మారుస్తున్నాం.'),
  SubtitleCue(start: Duration(seconds: 58), end: Duration(seconds: 64), text: 'షీల్డ్స్ ఆన్ చేయండి — అంతా సిద్ధం చేసుకోండి!'),
  SubtitleCue(start: Duration(seconds: 64), end: Duration(seconds: 70), text: 'హెచ్చరిక: గురుత్వాకర్షణ శక్తి పెరుగుతోంది!'),
  SubtitleCue(start: Duration(seconds: 70), end: Duration(seconds: 76), text: 'మనం ముందుకు సాగుతున్నాం. ఇంజిన్లు ఫుల్ పవర్!'),
  SubtitleCue(start: Duration(seconds: 76), end: Duration(seconds: 82), text: 'రక్షణ వ్యవస్థ 87 శాతం స్థిరంగా ఉంది.'),
  SubtitleCue(start: Duration(seconds: 82), end: Duration(seconds: 88), text: '"ఇది మన ప్రపంచాన్ని పూర్తిగా మార్చబోతోంది."'),
  SubtitleCue(start: Duration(seconds: 88), end: Duration(seconds: 94), text: 'డేటా స్ట్రీమ్ అందింది. డీకోడింగ్ జరుగుతోంది.'),
  SubtitleCue(start: Duration(seconds: 94), end: Duration(seconds: 100), text: 'సందేశం: "మీరు ఒంటరిగా లేరు."'),
  SubtitleCue(start: Duration(seconds: 100), end: Duration(seconds: 106), text: 'కంట్రోల్ రూమ్‌తో కమ్యూనికేషన్ ప్రారంభించండి.'),
  SubtitleCue(start: Duration(seconds: 106), end: Duration(seconds: 114), text: '"మేము గమ్యాన్ని విజయవంతంగా చేరుకున్నాము!"'),
  SubtitleCue(start: Duration(seconds: 114), end: Duration(seconds: 120), text: '[ ఆరా స్ట్రీమ్ • సినిమా కొనసాగుతోంది ]'),
];

/// English subtitles
const List<SubtitleCue> englishSubtitles = [
  SubtitleCue(start: Duration(seconds: 0), end: Duration(seconds: 5), text: '[ AURA STREAM • English Subtitles ]'),
  SubtitleCue(start: Duration(seconds: 5), end: Duration(seconds: 10), text: 'Welcome to the neural streaming frontier.'),
  SubtitleCue(start: Duration(seconds: 10), end: Duration(seconds: 15), text: 'The void stretches endlessly before us.'),
  SubtitleCue(start: Duration(seconds: 15), end: Duration(seconds: 20), text: 'Commander, all systems are operational.'),
  SubtitleCue(start: Duration(seconds: 20), end: Duration(seconds: 25), text: 'Initiating warp sequence in 3… 2… 1…'),
  SubtitleCue(start: Duration(seconds: 25), end: Duration(seconds: 30), text: 'We have successfully entered hyperspace.'),
  SubtitleCue(start: Duration(seconds: 30), end: Duration(seconds: 35), text: 'Scanning for uncharted coordinates nearby.'),
  SubtitleCue(start: Duration(seconds: 35), end: Duration(seconds: 40), text: 'Energy signature detected on the port side.'),
  SubtitleCue(start: Duration(seconds: 40), end: Duration(seconds: 46), text: '"Stay alert. We don\'t know what\'s out there."'),
  SubtitleCue(start: Duration(seconds: 46), end: Duration(seconds: 52), text: 'The signal is coming from a dying star system.'),
  SubtitleCue(start: Duration(seconds: 52), end: Duration(seconds: 58), text: 'Adjusting course to intercept the anomaly.'),
  SubtitleCue(start: Duration(seconds: 58), end: Duration(seconds: 64), text: 'Shields at maximum — brace for turbulence.'),
  SubtitleCue(start: Duration(seconds: 64), end: Duration(seconds: 70), text: 'Warning: gravitational distortion ahead.'),
  SubtitleCue(start: Duration(seconds: 70), end: Duration(seconds: 76), text: 'We\'re moving in. Engines to full power!'),
  SubtitleCue(start: Duration(seconds: 76), end: Duration(seconds: 82), text: 'Hull integrity holding steady at 87 percent.'),
  SubtitleCue(start: Duration(seconds: 82), end: Duration(seconds: 88), text: '"This could change everything we know."'),
  SubtitleCue(start: Duration(seconds: 88), end: Duration(seconds: 94), text: 'Encrypted data stream received. Decrypting now.'),
  SubtitleCue(start: Duration(seconds: 94), end: Duration(seconds: 100), text: 'Incoming transmission: "You are not alone."'),
  SubtitleCue(start: Duration(seconds: 100), end: Duration(seconds: 106), text: 'Open a direct frequency to fleet command.'),
  SubtitleCue(start: Duration(seconds: 106), end: Duration(seconds: 114), text: '"Fleet command, this is Odyssey One. Target acquired."'),
  SubtitleCue(start: Duration(seconds: 114), end: Duration(seconds: 120), text: '[ AURA STREAM • Stream continuing... ]'),
];

/// Hindi subtitles
const List<SubtitleCue> hindiSubtitles = [
  SubtitleCue(start: Duration(seconds: 0), end: Duration(seconds: 5), text: '[ ऑरा स्ट्रीम • हिंदी उपशीर्षक ]'),
  SubtitleCue(start: Duration(seconds: 5), end: Duration(seconds: 10), text: 'न्यूरल स्ट्रीमिंग फ्रंटियर में आपका स्वागत है।'),
  SubtitleCue(start: Duration(seconds: 10), end: Duration(seconds: 15), text: 'शून्य हमारे सामने अंतहीन फैला है।'),
  SubtitleCue(start: Duration(seconds: 15), end: Duration(seconds: 20), text: 'कमांडर, सभी सिस्टम सक्रिय हैं।'),
  SubtitleCue(start: Duration(seconds: 20), end: Duration(seconds: 25), text: 'वार्प सीक्वेंस शुरू: 3… 2… 1…'),
  SubtitleCue(start: Duration(seconds: 25), end: Duration(seconds: 30), text: 'हम सफलतापूर्वक हाइपरस्पेस में आ चुके हैं।'),
  SubtitleCue(start: Duration(seconds: 30), end: Duration(seconds: 35), text: 'अज्ञात ग्रहों की खोज शुरू हो गई है।'),
  SubtitleCue(start: Duration(seconds: 35), end: Duration(seconds: 40), text: 'बाईं ओर असामान्य ऊर्जा का पता चला है।'),
  SubtitleCue(start: Duration(seconds: 40), end: Duration(seconds: 46), text: '"सतर्क रहें। हमें नहीं पता वहाँ क्या है।"'),
  SubtitleCue(start: Duration(seconds: 46), end: Duration(seconds: 52), text: 'यह सिग्नल एक रहस्यमयी केंद्र से आ रहा है।'),
  SubtitleCue(start: Duration(seconds: 52), end: Duration(seconds: 58), text: 'हम उस दिशा में बढ़ रहे हैं।'),
  SubtitleCue(start: Duration(seconds: 58), end: Duration(seconds: 64), text: 'शील्ड्स अधिकतम पर रखें!'),
  SubtitleCue(start: Duration(seconds: 64), end: Duration(seconds: 70), text: 'चेतावनी: गुरुत्वाकर्षण खिंचाव बढ़ रहा है!'),
  SubtitleCue(start: Duration(seconds: 70), end: Duration(seconds: 76), text: 'इंजन पूरी शक्ति पर! आगे बढ़ें!'),
  SubtitleCue(start: Duration(seconds: 76), end: Duration(seconds: 82), text: 'सुरक्षा प्रणाली 87 प्रतिशत सुरक्षित है।'),
  SubtitleCue(start: Duration(seconds: 82), end: Duration(seconds: 88), text: '"यह सब कुछ बदलने वाला है।"'),
  SubtitleCue(start: Duration(seconds: 88), end: Duration(seconds: 94), text: 'डेटा संदेश प्राप्त हुआ। डिकोड हो रहा है।'),
  SubtitleCue(start: Duration(seconds: 94), end: Duration(seconds: 100), text: 'संदेश: "आप अकेले नहीं हैं।"'),
  SubtitleCue(start: Duration(seconds: 100), end: Duration(seconds: 106), text: 'कंट्रोल रूम से संपर्क स्थापित करें।'),
  SubtitleCue(start: Duration(seconds: 106), end: Duration(seconds: 114), text: '"मिशन सफल रहा! हम पहुंच गए हैं।"'),
  SubtitleCue(start: Duration(seconds: 114), end: Duration(seconds: 120), text: '[ ऑरा स्ट्रीम • प्रसारण जारी है ]'),
];

/// Spanish subtitles
const List<SubtitleCue> spanishSubtitles = [
  SubtitleCue(start: Duration(seconds: 0), end: Duration(seconds: 5), text: '[ AURA STREAM • Subtítulos en español ]'),
  SubtitleCue(start: Duration(seconds: 5), end: Duration(seconds: 10), text: 'Bienvenidos a la frontera neural.'),
  SubtitleCue(start: Duration(seconds: 10), end: Duration(seconds: 15), text: 'El vacío se extiende ante nosotros.'),
  SubtitleCue(start: Duration(seconds: 15), end: Duration(seconds: 20), text: 'Comandante, sistemas operativos.'),
  SubtitleCue(start: Duration(seconds: 20), end: Duration(seconds: 25), text: 'Iniciando secuencia de salto en 3… 2… 1…'),
  SubtitleCue(start: Duration(seconds: 25), end: Duration(seconds: 30), text: 'Hemos entrado en el hiperespacio.'),
  SubtitleCue(start: Duration(seconds: 30), end: Duration(seconds: 35), text: 'Escaneando coordenadas desconocidas.'),
  SubtitleCue(start: Duration(seconds: 35), end: Duration(seconds: 40), text: 'Señal de energía detectada a babor.'),
  SubtitleCue(start: Duration(seconds: 40), end: Duration(seconds: 46), text: '"Alerta máxima. No sabemos qué hay allí."'),
  SubtitleCue(start: Duration(seconds: 46), end: Duration(seconds: 52), text: 'La señal proviene de una estrella lejana.'),
  SubtitleCue(start: Duration(seconds: 52), end: Duration(seconds: 58), text: 'Ajustando curso para interceptar.'),
  SubtitleCue(start: Duration(seconds: 58), end: Duration(seconds: 64), text: 'Escudos activados — resistan el impacto.'),
  SubtitleCue(start: Duration(seconds: 64), end: Duration(seconds: 70), text: 'Advertencia: anomalía gravitacional.'),
  SubtitleCue(start: Duration(seconds: 70), end: Duration(seconds: 76), text: '¡Motores al máximo poder!'),
  SubtitleCue(start: Duration(seconds: 76), end: Duration(seconds: 82), text: 'Integridad del casco al 87 por ciento.'),
  SubtitleCue(start: Duration(seconds: 82), end: Duration(seconds: 88), text: '"Esto cambiará todo para la humanidad."'),
  SubtitleCue(start: Duration(seconds: 88), end: Duration(seconds: 94), text: 'Transmisión cifrada recibida.'),
  SubtitleCue(start: Duration(seconds: 94), end: Duration(seconds: 100), text: 'Mensaje entrante: "No están solos."'),
  SubtitleCue(start: Duration(seconds: 100), end: Duration(seconds: 106), text: 'Abran canal con el comando de flota.'),
  SubtitleCue(start: Duration(seconds: 106), end: Duration(seconds: 114), text: '"Comando, aquí Odyssey Uno. Misión cumplida."'),
  SubtitleCue(start: Duration(seconds: 114), end: Duration(seconds: 120), text: '[ AURA STREAM • Transmisión activa ]'),
];

/// Returns the subtitle cue list for the given language id.
List<SubtitleCue> getSubtitleCuesForTrack(String trackId) {
  switch (trackId) {
    case 'te':
      return teluguSubtitles;
    case 'en':
      return englishSubtitles;
    case 'hi':
      return hindiSubtitles;
    case 'es':
      return spanishSubtitles;
    default:
      return const [];
  }
}

/// Finds the currently active cue at the given playback position.
/// Uses procedural looping so that subtitles continuously display throughout
/// full-length movies (e.g. 2-3 hours) without going blank.
SubtitleCue? getActiveCue(List<SubtitleCue> cues, Duration position) {
  if (cues.isEmpty) return null;

  final totalDurationSec = cues.last.end.inSeconds;
  if (totalDurationSec <= 0) return null;

  // Seamless procedural cycle: allows continuous subtitle display for any duration
  final loopSec = position.inSeconds % totalDurationSec;
  final effectivePosition = Duration(
    seconds: loopSec,
    milliseconds: position.inMilliseconds % 1000,
  );

  for (final cue in cues) {
    if (cue.isActive(effectivePosition)) {
      return cue;
    }
  }

  // Fallback: match nearest active cue
  for (int i = cues.length - 1; i >= 0; i--) {
    if (cues[i].start <= effectivePosition) {
      return cues[i];
    }
  }

  return cues.first;
}
