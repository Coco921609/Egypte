import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// HISTOIRE — 5 000+ ans, année par année
//
// Une carte par année clé, de l'unification (vers 3100 av. J.-C.)
// à aujourd'hui. Glisse les cartes, déplace la frise ou touche une
// époque pour voyager dans le temps.
// Aucun texte tronqué : tous les mots restent entiers (pas de « … »).
// ==========================================

class _Ev {
  final int year; // négatif = avant J.-C.
  final bool circa;
  final List<String> fr;
  final List<String> en;
  final List<String> ar;

  /// « À voir aujourd'hui » : [fr, en, ar], facultatif.
  final List<String>? where;
  const _Ev(this.year, this.circa, this.fr, this.en, this.ar, {this.where});

  List<String> pick(String lang) => lang == 'ar' ? ar : (lang == 'en' ? en : fr);

  String? whereFor(String lang) {
    final List<String>? w = where;
    if (w == null) return null;
    return lang == 'ar' ? w[2] : (lang == 'en' ? w[1] : w[0]);
  }
}

const List<_Ev> _events = <_Ev>[
  _Ev(
    -3100,
    true,
    <String>[
      "Unification de l'Égypte",
      "Narmer, souvent associé à Ménès, unit la Haute et la Basse-Égypte : l'âge pharaonique commence.",
    ],
    <String>[
      'Unification of Egypt',
      'Narmer, often identified with Menes, joins Upper and Lower Egypt and the pharaonic age begins.',
    ],
    <String>[
      'توحيد مصر',
      'يوحّد نارمر، الذي يُطابَق غالباً مع مينا، الوجهين القبلي والبحري، وتبدأ بذلك الحقبة الفرعونية.',
    ],
  ),
  _Ev(
    -2650,
    true,
    <String>[
      'La pyramide à degrés de Djéser',
      "L'architecte Imhotep bâtit à Saqqarah le premier grand monument en pierre taillée : la pyramide à degrés.",
    ],
    <String>[
      "Djoser's Step Pyramid",
      'The architect Imhotep builds the first great stone monument at Saqqara: the Step Pyramid.',
    ],
    <String>[
      'هرم زوسر المدرّج',
      'يبني المهندس إمحتب في سقارة أول صرح كبير من الحجر المنحوت: الهرم المدرّج.',
    ],
    where: <String>["Saqqarah, au sud du Caire", "Saqqara, south of Cairo", "سقارة، جنوب القاهرة"],
  ),
  _Ev(
    -2600,
    true,
    <String>[
      "Snéfrou et les pyramides de Dahchour",
      "Snéfrou fait bâtir la pyramide rhomboïdale puis la pyramide rouge, souvent considérée comme la première vraie pyramide lisse.",
    ],
    <String>[
      "Sneferu and the Dahshur pyramids",
      "Sneferu builds the Bent Pyramid and then the Red Pyramid, often considered the first true smooth-sided pyramid.",
    ],
    <String>[
      "سنفرو وأهرامات دهشور",
      "يبني سنفرو الهرم المنحني ثم الهرم الأحمر الذي يُعدّ غالباً أول هرم حقيقي أملس الجوانب.",
    ],
    where: <String>["Dahchour, au sud de Saqqarah", "Dahshur, south of Saqqara", "دهشور، جنوب سقارة"],
  ),
  _Ev(
    -2560,
    true,
    <String>[
      'La Grande Pyramide',
      "Khéops fait élever la Grande Pyramide de Gizeh, qui restera la plus haute construction du monde pendant environ 3 800 ans.",
    ],
    <String>[
      'The Great Pyramid',
      'Khufu raises the Great Pyramid at Giza, which will remain the tallest structure in the world for about 3,800 years.',
    ],
    <String>[
      'الهرم الأكبر',
      'يأمر خوفو ببناء الهرم الأكبر في الجيزة، وسيبقى أعلى بناء في العالم نحو 3800 عام.',
    ],
    where: <String>["Plateau de Gizeh", "Giza Plateau", "هضبة الجيزة"],
  ),
  _Ev(
    -2500,
    true,
    <String>[
      "Le Grand Sphinx",
      "Sculpté dans la roche du plateau de Gizeh, il est généralement attribué au règne de Khéphren.",
    ],
    <String>[
      "The Great Sphinx",
      "Carved from the bedrock of the Giza Plateau, it is generally attributed to the reign of Khafre.",
    ],
    <String>[
      "أبو الهول",
      "نُحت من صخر هضبة الجيزة، وينسب عادةً إلى عهد خفرع.",
    ],
    where: <String>["Plateau de Gizeh", "Giza Plateau", "هضبة الجيزة"],
  ),
  _Ev(
    -2180,
    true,
    <String>[
      "Fin de l'Ancien Empire",
      "Le pouvoir central s'affaiblit et le pays se divise en provinces rivales.",
    ],
    <String>[
      "End of the Old Kingdom",
      "Central power weakens and the country splits into rival provinces.",
    ],
    <String>[
      "نهاية الدولة القديمة",
      "تضعف السلطة المركزية وتنقسم البلاد إلى أقاليم متنافسة.",
    ],
  ),
  _Ev(
    -2055,
    true,
    <String>[
      'Réunification par Montouhotep II',
      "Montouhotep II réunifie le pays depuis Thèbes et ouvre le Moyen Empire.",
    ],
    <String>[
      'Reunification under Mentuhotep II',
      'Mentuhotep II reunites the country from Thebes and opens the Middle Kingdom.',
    ],
    <String>[
      'إعادة التوحيد على يد منتوحتب الثاني',
      'يعيد منتوحتب الثاني توحيد البلاد انطلاقاً من طيبة ويفتتح عصر الدولة الوسطى.',
    ],
  ),
  _Ev(
    -1650,
    true,
    <String>[
      'Les Hyksos dans le Delta',
      "Des souverains d'origine levantine s'installent dans le Delta et dominent le nord du pays.",
    ],
    <String>[
      'The Hyksos in the Delta',
      'Rulers of Levantine origin settle in the Delta and control northern Egypt.',
    ],
    <String>[
      'الهكسوس في الدلتا',
      'يستقر حكّام من أصل شامي في الدلتا ويسيطرون على شمال البلاد.',
    ],
  ),
  _Ev(
    -1550,
    true,
    <String>[
      'Ahmosis chasse les Hyksos',
      "Ahmosis expulse les Hyksos et fonde le Nouvel Empire, âge d'or de la puissance égyptienne.",
    ],
    <String>[
      'Ahmose drives out the Hyksos',
      "Ahmose expels the Hyksos and founds the New Kingdom, the golden age of Egypt's power.",
    ],
    <String>[
      'أحمس يطرد الهكسوس',
      'يطرد أحمس الهكسوس ويؤسس الدولة الحديثة، العصر الذهبي لقوة مصر.',
    ],
  ),
  _Ev(
    -1479,
    true,
    <String>[
      'Hatchepsout devient pharaon',
      "Elle règne comme pharaon pendant une vingtaine d'années et fait bâtir son temple de Deir el-Bahari.",
    ],
    <String>[
      'Hatshepsut becomes pharaoh',
      'She rules as pharaoh for about twenty years and has her temple built at Deir el-Bahari.',
    ],
    <String>[
      'حتشبسوت تتولى العرش',
      'تحكم بلقب فرعون نحو عشرين عاماً وتشيّد معبدها في الدير البحري.',
    ],
    where: <String>["Temple de Deir el-Bahari, Louxor", "Temple of Deir el-Bahari, Luxor", "معبد الدير البحري، الأقصر"],
  ),
  _Ev(
    -1353,
    true,
    <String>[
      "Akhenaton et le dieu Aton",
      "Akhenaton fonde une nouvelle capitale, Akhetaton (Amarna), et impose le culte d'Aton.",
    ],
    <String>[
      'Akhenaten and the god Aten',
      'Akhenaten founds a new capital, Akhetaten (Amarna), and imposes the worship of Aten.',
    ],
    <String>[
      'إخناتون والإله آتون',
      'يؤسس إخناتون عاصمة جديدة هي أخيتاتون (تل العمارنة) ويفرض عبادة آتون.',
    ],
    where: <String>["Tell el-Amarna, en Moyenne-Égypte", "Tell el-Amarna, Middle Egypt", "تل العمارنة، مصر الوسطى"],
  ),
  _Ev(
    -1323,
    true,
    <String>[
      'Mort de Toutânkhamon',
      "Le jeune roi meurt vers 18 ou 19 ans ; sa tombe, presque intacte, sera retrouvée en 1922.",
    ],
    <String>[
      'Death of Tutankhamun',
      'The young king dies at about 18 or 19; his almost intact tomb will be found in 1922.',
    ],
    <String>[
      'وفاة توت عنخ آمون',
      'يموت الملك الشاب في نحو الثامنة عشرة أو التاسعة عشرة، وسيُكتشف قبره شبه سليم عام 1922.',
    ],
    where: <String>["Vallée des Rois, Louxor", "Valley of the Kings, Luxor", "وادي الملوك، الأقصر"],
  ),
  _Ev(
    -1274,
    true,
    <String>[
      'Bataille de Qadesh',
      "Ramsès II affronte les Hittites ; quelques années plus tard, l'un des plus anciens traités de paix écrits connus est conclu.",
    ],
    <String>[
      'Battle of Kadesh',
      'Ramesses II fights the Hittites; a few years later, one of the oldest known written peace treaties is concluded.',
    ],
    <String>[
      'معركة قادش',
      'يواجه رمسيس الثاني الحيثيين، وبعد سنوات يُبرم أحد أقدم معاهدات السلام المكتوبة المعروفة.',
    ],
    where: <String>["Ramesséum, Louxor, et Abou Simbel", "The Ramesseum in Luxor, and Abu Simbel", "الرامسيوم بالأقصر وأبو سمبل"],
  ),
  _Ev(
    -1264,
    true,
    <String>[
      "Les temples d'Abou Simbel",
      "Ramsès II fait creuser dans la falaise deux temples, l'un pour lui-même, l'autre pour son épouse Néfertari.",
    ],
    <String>[
      "The temples of Abu Simbel",
      "Ramesses II has two temples cut into the cliff, one for himself and one for his wife Nefertari.",
    ],
    <String>[
      "معبدا أبو سمبل",
      "يأمر رمسيس الثاني بنحت معبدين في الجرف، أحدهما له والآخر لزوجته نفرتاري.",
    ],
    where: <String>["Abou Simbel, au sud d'Assouan", "Abu Simbel, south of Aswan", "أبو سمبل، جنوب أسوان"],
  ),
  _Ev(
    -1177,
    true,
    <String>[
      "Les Peuples de la mer",
      "Ramsès III repousse les Peuples de la mer lors d'une grande bataille près du Delta.",
    ],
    <String>[
      "The Sea Peoples",
      "Ramesses III repels the Sea Peoples in a great battle near the Delta.",
    ],
    <String>[
      "شعوب البحر",
      "يصدّ رمسيس الثالث شعوب البحر في معركة كبرى قرب الدلتا.",
    ],
  ),
  _Ev(
    -1070,
    true,
    <String>[
      'Fin du Nouvel Empire',
      'Le pouvoir se partage entre le nord et les prêtres de Thèbes, au sud.',
    ],
    <String>[
      'End of the New Kingdom',
      'Power is split between the north and the priests of Thebes in the south.',
    ],
    <String>[
      'نهاية الدولة الحديثة',
      'ينقسم الحكم بين الشمال وكهنة طيبة في الجنوب.',
    ],
  ),
  _Ev(
    -945,
    true,
    <String>[
      'Chéchonq Ier',
      "Un chef d'origine libyenne fonde la XXIIᵉ dynastie.",
    ],
    <String>[
      'Shoshenq I',
      'A chief of Libyan origin founds the 22nd dynasty.',
    ],
    <String>[
      'شيشنق الأول',
      'يؤسس زعيم من أصل ليبي الأسرة الثانية والعشرين.',
    ],
  ),
  _Ev(
    -728,
    true,
    <String>[
      'Les pharaons de Koush',
      "Le roi koushite Piânkhy, venu de Nubie, conquiert l'Égypte : la XXVᵉ dynastie commence.",
    ],
    <String>[
      'The pharaohs of Kush',
      'The Kushite king Piye, from Nubia, conquers Egypt and the 25th dynasty begins.',
    ],
    <String>[
      'ملوك كوش',
      'يغزو الملك الكوشي بعنخي مصر وتبدأ الأسرة الخامسة والعشرون.',
    ],
  ),
  _Ev(
    -671,
    false,
    <String>[
      'Invasion assyrienne',
      'Assarhaddon prend Memphis et chasse les rois koushites du nord du pays.',
    ],
    <String>[
      'Assyrian invasion',
      'Esarhaddon takes Memphis and drives the Kushite kings out of the north.',
    ],
    <String>[
      'الغزو الآشوري',
      'يستولي آسرحدون على منف ويطرد الملوك الكوشيين من الشمال.',
    ],
  ),
  _Ev(
    -525,
    false,
    <String>[
      'Conquête perse',
      "Cambyse II bat l'armée égyptienne à Péluse : l'Égypte devient une satrapie perse.",
    ],
    <String>[
      'Persian conquest',
      'Cambyses II defeats the Egyptian army at Pelusium and Egypt becomes a Persian satrapy.',
    ],
    <String>[
      'الفتح الفارسي',
      'يهزم قمبيز الثاني الجيش المصري في بيلوزيوم فتصبح مصر ولاية فارسية.',
    ],
  ),
  _Ev(
    -331,
    false,
    <String>[
      'Alexandre fonde Alexandrie',
      "Accueilli en libérateur, Alexandre le Grand fonde sur la côte la ville qui portera son nom.",
    ],
    <String>[
      'Alexander founds Alexandria',
      'Welcomed as a liberator, Alexander the Great founds on the coast the city that will bear his name.',
    ],
    <String>[
      'الإسكندر يؤسس الإسكندرية',
      'يستقبله المصريون كمحرّر، ويؤسس الإسكندر الأكبر على الساحل المدينة التي ستحمل اسمه.',
    ],
    where: <String>["Bibliotheca Alexandrina, Alexandrie", "Bibliotheca Alexandrina, Alexandria", "مكتبة الإسكندرية"],
  ),
  _Ev(
    -305,
    false,
    <String>[
      'Ptolémée Ier devient roi',
      "Après la mort d'Alexandre, son général fonde la dynastie lagide, qui durera près de trois siècles.",
    ],
    <String>[
      'Ptolemy I becomes king',
      "After Alexander's death, his general founds the Ptolemaic dynasty, which will last nearly three centuries.",
    ],
    <String>[
      'بطليموس الأول ملكاً',
      'بعد وفاة الإسكندر يؤسس قائده الأسرة البطلمية التي ستدوم نحو ثلاثة قرون.',
    ],
  ),
  _Ev(
    -280,
    true,
    <String>[
      "Le phare d'Alexandrie",
      "Élevé sous les premiers Ptolémées, il devient l'une des Sept Merveilles du monde antique.",
    ],
    <String>[
      "The Pharos of Alexandria",
      "Raised under the first Ptolemies, it becomes one of the Seven Wonders of the Ancient World.",
    ],
    <String>[
      "منارة الإسكندرية",
      "تُشيَّد في عهد أوائل البطالمة وتصبح إحدى عجائب الدنيا السبع في العالم القديم.",
    ],
    where: <String>["Alexandrie : fort de Qaïtbay, bâti à son emplacement", "Alexandria: the Qaitbay Citadel, built on its site", "الإسكندرية: قلعة قايتباي المقامة في موقعها"],
  ),
  _Ev(
    -196,
    false,
    <String>[
      'Le décret de Memphis',
      'Il est gravé en trois écritures sur ce qui sera plus tard la pierre de Rosette.',
    ],
    <String>[
      'The Memphis decree',
      'It is carved in three scripts on what will later be known as the Rosetta Stone.',
    ],
    <String>[
      'مرسوم منف',
      'يُنقش بثلاث كتابات على ما سيُعرف لاحقاً بحجر رشيد.',
    ],
  ),
  _Ev(
    -51,
    false,
    <String>[
      "Cléopâtre monte sur le trône",
      "À 18 ans, Cléopâtre VII devient reine, d'abord aux côtés de son frère Ptolémée XIII.",
    ],
    <String>[
      "Cleopatra takes the throne",
      "At 18, Cleopatra VII becomes queen, at first alongside her brother Ptolemy XIII.",
    ],
    <String>[
      "كليوباترا تعتلي العرش",
      "في الثامنة عشرة تصبح كليوباترا السابعة ملكة، في البداية إلى جانب أخيها بطليموس الثالث عشر.",
    ],
  ),
  _Ev(
    -30,
    false,
    <String>[
      'Mort de Cléopâtre VII',
      "Après Actium, la dernière reine lagide meurt et l'Égypte devient une province romaine.",
    ],
    <String>[
      'Death of Cleopatra VII',
      'After Actium, the last Ptolemaic queen dies and Egypt becomes a Roman province.',
    ],
    <String>[
      'وفاة كليوباترا السابعة',
      'بعد أكتيوم تموت آخر ملكات البطالمة وتصبح مصر ولاية رومانية.',
    ],
  ),
  _Ev(
    391,
    false,
    <String>[
      'Fermeture des temples païens',
      "L'empereur Théodose Ier interdit les cultes païens : le culte des anciens dieux s'éteint peu à peu.",
    ],
    <String>[
      'Pagan temples closed',
      'Emperor Theodosius I bans pagan worship and the cult of the old gods slowly fades.',
    ],
    <String>[
      'إغلاق المعابد الوثنية',
      'يحظر الإمبراطور ثيودوسيوس الأول العبادات الوثنية فتخبو عبادة الآلهة القديمة تدريجياً.',
    ],
  ),
  _Ev(
    451,
    false,
    <String>[
      'Concile de Chalcédoine',
      "L'Église copte orthodoxe en rejette les décisions et suit sa propre voie.",
    ],
    <String>[
      'Council of Chalcedon',
      'The Coptic Orthodox Church rejects its decisions and follows its own path.',
    ],
    <String>[
      'مجمع خلقيدونية',
      'ترفض الكنيسة القبطية الأرثوذكسية قراراته وتمضي في طريقها الخاص.',
    ],
  ),
  _Ev(
    641,
    false,
    <String>[
      'Conquête arabe',
      "Amr ibn al-As prend Alexandrie et fonde Fostat, première capitale islamique de l'Égypte.",
    ],
    <String>[
      'Arab conquest',
      "Amr ibn al-As takes Alexandria and founds Fustat, Egypt's first Islamic capital.",
    ],
    <String>[
      'الفتح العربي',
      'يستولي عمرو بن العاص على الإسكندرية ويؤسس الفسطاط، أول عاصمة إسلامية لمصر.',
    ],
    where: <String>["Mosquée d'Amr ibn al-As, Vieux Caire", "Mosque of Amr ibn al-As, Old Cairo", "جامع عمرو بن العاص، القاهرة القديمة"],
  ),
  _Ev(
    879,
    false,
    <String>[
      "Mosquée d'Ibn Touloun",
      "Ahmad ibn Touloun, gouverneur devenu souverain autonome, achève la grande mosquée qui porte son nom.",
    ],
    <String>[
      "Ibn Tulun Mosque",
      "Ahmad ibn Tulun, a governor turned autonomous ruler, completes the great mosque that bears his name.",
    ],
    <String>[
      "جامع ابن طولون",
      "يُتمّ أحمد بن طولون، الوالي الذي استقلّ بالحكم، الجامع الكبير الذي يحمل اسمه.",
    ],
    where: <String>["Mosquée d'Ibn Touloun, Le Caire", "Ibn Tulun Mosque, Cairo", "جامع ابن طولون، القاهرة"],
  ),
  _Ev(
    969,
    false,
    <String>[
      'Fondation du Caire',
      'Les Fatimides fondent Al-Qahira, la Victorieuse, près de Fostat.',
    ],
    <String>[
      'Foundation of Cairo',
      'The Fatimids found Al-Qahira, the Victorious, near Fustat.',
    ],
    <String>[
      'تأسيس القاهرة',
      'يؤسس الفاطميون القاهرة بالقرب من الفسطاط.',
    ],
    where: <String>["Portes Bab Zuweila et Bab al-Futuh", "Gates of Bab Zuweila and Bab al-Futuh", "بابا زويلة والفتوح"],
  ),
  _Ev(
    970,
    false,
    <String>[
      "Fondation d'Al-Azhar",
      "La mosquée d'Al-Azhar est construite ; elle deviendra l'une des plus anciennes universités du monde.",
    ],
    <String>[
      'Al-Azhar is founded',
      'The Al-Azhar mosque is built; it will become one of the oldest universities in the world.',
    ],
    <String>[
      'تأسيس الأزهر',
      'يُبنى الجامع الأزهر، وسيصبح من أقدم الجامعات في العالم.',
    ],
    where: <String>["Mosquée d'Al-Azhar, Le Caire", "Al-Azhar Mosque, Cairo", "الجامع الأزهر، القاهرة"],
  ),
  _Ev(
    1171,
    false,
    <String>[
      'Saladin',
      'Saladin met fin au califat fatimide et fonde la dynastie ayyoubide.',
    ],
    <String>[
      'Saladin',
      'Saladin ends the Fatimid caliphate and founds the Ayyubid dynasty.',
    ],
    <String>[
      'صلاح الدين',
      'ينهي صلاح الدين الخلافة الفاطمية ويؤسس الدولة الأيوبية.',
    ],
  ),
  _Ev(
    1176,
    false,
    <String>[
      "La citadelle du Caire",
      "Saladin fait commencer la construction de la citadelle qui dominera la ville pendant des siècles.",
    ],
    <String>[
      "The Cairo Citadel",
      "Saladin begins building the citadel that will dominate the city for centuries.",
    ],
    <String>[
      "قلعة القاهرة",
      "يبدأ صلاح الدين بناء القلعة التي ستهيمن على المدينة لقرون.",
    ],
    where: <String>["Citadelle de Saladin, Le Caire", "Citadel of Saladin, Cairo", "قلعة صلاح الدين، القاهرة"],
  ),
  _Ev(
    1250,
    false,
    <String>[
      'Les Mamelouks au pouvoir',
      'Une dynastie de soldats affranchis prend le pouvoir et gouvernera pendant plus de deux siècles et demi.',
    ],
    <String>[
      'The Mamluks take power',
      'A dynasty of freed soldiers takes power and will rule for more than two and a half centuries.',
    ],
    <String>[
      'المماليك في الحكم',
      'تتولى الحكم سلالة من الجنود المماليك وتحكم أكثر من قرنين ونصف.',
    ],
  ),
  _Ev(
    1260,
    false,
    <String>[
      'Bataille d\'Aïn Djalout',
      "Les Mamelouks arrêtent l'avancée mongole en Palestine.",
    ],
    <String>[
      'Battle of Ain Jalut',
      'The Mamluks halt the Mongol advance in Palestine.',
    ],
    <String>[
      'معركة عين جالوت',
      'يوقف المماليك التقدّم المغولي في فلسطين.',
    ],
  ),
  _Ev(
    1356,
    false,
    <String>[
      "Mosquée-madrasa du sultan Hassan",
      "Les travaux commencent pour l'un des plus grands monuments mamelouks du Caire.",
    ],
    <String>[
      "Sultan Hassan Mosque-Madrasa",
      "Work begins on one of the largest Mamluk monuments of Cairo.",
    ],
    <String>[
      "مسجد ومدرسة السلطان حسن",
      "يبدأ العمل في أحد أكبر الآثار المملوكية في القاهرة.",
    ],
    where: <String>["Mosquée du sultan Hassan, Le Caire", "Sultan Hassan Mosque, Cairo", "مسجد السلطان حسن، القاهرة"],
  ),
  _Ev(
    1517,
    false,
    <String>[
      'Conquête ottomane',
      "Le sultan Sélim Ier entre au Caire : l'Égypte devient une province ottomane.",
    ],
    <String>[
      'Ottoman conquest',
      'Sultan Selim I enters Cairo and Egypt becomes an Ottoman province.',
    ],
    <String>[
      'الفتح العثماني',
      'يدخل السلطان سليم الأول القاهرة وتصبح مصر ولاية عثمانية.',
    ],
  ),
  _Ev(
    1798,
    false,
    <String>[
      'Expédition de Bonaparte',
      "Napoléon débarque avec des savants ; la Description de l'Égypte lancera l'égyptologie moderne.",
    ],
    <String>[
      "Bonaparte's expedition",
      "Napoleon lands with scholars; the Description de l'Égypte will launch modern Egyptology.",
    ],
    <String>[
      'حملة بونابرت',
      'ينزل نابليون ومعه علماء، وسيطلق كتاب «وصف مصر» علم المصريات الحديث.',
    ],
  ),
  _Ev(
    1799,
    false,
    <String>[
      'La pierre de Rosette',
      "Des soldats français découvrent la stèle trilingue près de Rachid.",
    ],
    <String>[
      'The Rosetta Stone',
      'French soldiers discover the trilingual stele near Rashid.',
    ],
    <String>[
      'حجر رشيد',
      'يعثر جنود فرنسيون على اللوح ثلاثي الكتابة قرب رشيد.',
    ],
  ),
  _Ev(
    1805,
    false,
    <String>[
      'Mehmet Ali',
      'Mehmet Ali devient gouverneur et lance la modernisation du pays.',
    ],
    <String>[
      'Muhammad Ali',
      'Muhammad Ali becomes governor and launches the modernisation of the country.',
    ],
    <String>[
      'محمد علي',
      'يصبح محمد علي والياً على مصر ويطلق تحديث البلاد.',
    ],
    where: <String>["Mosquée de Mohamed Ali, citadelle du Caire", "Muhammad Ali Mosque, Cairo Citadel", "مسجد محمد علي، قلعة القاهرة"],
  ),
  _Ev(
    1822,
    false,
    <String>[
      'Champollion',
      'Jean-François Champollion annonce le déchiffrement des hiéroglyphes.',
    ],
    <String>[
      'Champollion',
      'Jean-François Champollion announces the decipherment of the hieroglyphs.',
    ],
    <String>[
      'شامبوليون',
      'يعلن جان فرانسوا شامبوليون فك رموز الهيروغليفية.',
    ],
  ),
  _Ev(
    1859,
    false,
    <String>[
      "Début du creusement du canal",
      "Ferdinand de Lesseps lance les travaux du canal de Suez, qui dureront dix ans.",
    ],
    <String>[
      "Work on the canal begins",
      "Ferdinand de Lesseps starts digging the Suez Canal, a project that will take ten years.",
    ],
    <String>[
      "بدء حفر القناة",
      "يطلق فرديناند دي ليسبس أعمال حفر قناة السويس التي ستستغرق عشر سنوات.",
    ],
  ),
  _Ev(
    1869,
    false,
    <String>[
      'Inauguration du canal de Suez',
      "Le canal relie la Méditerranée à la mer Rouge et raccourcit la route maritime entre l'Europe et l'Asie.",
    ],
    <String>[
      'The Suez Canal opens',
      'The canal links the Mediterranean to the Red Sea and shortens the sea route between Europe and Asia.',
    ],
    <String>[
      'افتتاح قناة السويس',
      'تربط القناة البحر المتوسط بالبحر الأحمر وتختصر الطريق البحري بين أوروبا وآسيا.',
    ],
    where: <String>["Port-Saïd et Ismaïlia", "Port Said and Ismailia", "بورسعيد والإسماعيلية"],
  ),
  _Ev(
    1882,
    false,
    <String>[
      'Occupation britannique',
      'Les troupes britanniques occupent le pays après la bataille de Tell el-Kébir.',
    ],
    <String>[
      'British occupation',
      'British troops occupy the country after the battle of Tel el-Kebir.',
    ],
    <String>[
      'الاحتلال البريطاني',
      'تحتل القوات البريطانية البلاد بعد معركة التل الكبير.',
    ],
  ),
  _Ev(
    1902,
    false,
    <String>[
      "Le Musée égyptien du Caire",
      "Le bâtiment de la place Tahrir ouvre ses portes pour abriter les antiquités du pays.",
    ],
    <String>[
      "The Egyptian Museum in Cairo",
      "The Tahrir Square building opens its doors to house the country's antiquities.",
    ],
    <String>[
      "المتحف المصري بالقاهرة",
      "يفتح مبنى ميدان التحرير أبوابه ليضم آثار البلاد.",
    ],
    where: <String>["Place Tahrir, Le Caire", "Tahrir Square, Cairo", "ميدان التحرير، القاهرة"],
  ),
  _Ev(
    1922,
    false,
    <String>[
      'Indépendance',
      "Le Royaume-Uni déclare l'Égypte indépendante, tout en se réservant plusieurs domaines.",
    ],
    <String>[
      'Independence',
      'The United Kingdom declares Egypt independent while reserving several areas for itself.',
    ],
    <String>[
      'الاستقلال',
      'تعلن بريطانيا استقلال مصر مع احتفاظها بعدة مجالات.',
    ],
  ),
  _Ev(
    1922,
    false,
    <String>[
      'La tombe de Toutânkhamon',
      "Howard Carter découvre l'entrée de la tombe dans la Vallée des Rois.",
    ],
    <String>[
      "Tutankhamun's tomb",
      'Howard Carter finds the entrance to the tomb in the Valley of the Kings.',
    ],
    <String>[
      'مقبرة توت عنخ آمون',
      'يكتشف هوارد كارتر مدخل المقبرة في وادي الملوك.',
    ],
  ),
  _Ev(
    1952,
    false,
    <String>[
      'Révolution du 23 juillet',
      'Les Officiers libres renversent la monarchie ; la république est proclamée en 1953.',
    ],
    <String>[
      'The 23 July Revolution',
      'The Free Officers overthrow the monarchy; the republic is proclaimed in 1953.',
    ],
    <String>[
      'ثورة 23 يوليو',
      'يطيح الضباط الأحرار بالملكية، وتُعلن الجمهورية عام 1953.',
    ],
  ),
  _Ev(
    1956,
    false,
    <String>[
      'Nationalisation du canal',
      'Nasser nationalise le canal de Suez.',
    ],
    <String>[
      'Nationalisation of the canal',
      'Nasser nationalises the Suez Canal.',
    ],
    <String>[
      'تأميم القناة',
      'يؤمّم عبد الناصر قناة السويس.',
    ],
  ),
  _Ev(
    1970,
    false,
    <String>[
      "Haut barrage d'Assouan",
      'Achevé en 1970, il régule la crue du Nil et crée le lac Nasser.',
    ],
    <String>[
      'Aswan High Dam',
      'Completed in 1970, it regulates the Nile flood and creates Lake Nasser.',
    ],
    <String>[
      'السد العالي',
      'اكتمل بناؤه عام 1970، وينظّم فيضان النيل وينشئ بحيرة ناصر.',
    ],
    where: <String>["Assouan et lac Nasser", "Aswan and Lake Nasser", "أسوان وبحيرة ناصر"],
  ),
  _Ev(
    1973,
    false,
    <String>[
      "Guerre d'octobre",
      "L'armée égyptienne franchit le canal de Suez au début de la guerre d'octobre 1973.",
    ],
    <String>[
      "The October War",
      "The Egyptian army crosses the Suez Canal at the start of the October 1973 war.",
    ],
    <String>[
      "حرب أكتوبر",
      "يعبر الجيش المصري قناة السويس في بداية حرب أكتوبر 1973.",
    ],
  ),
  _Ev(
    1975,
    false,
    <String>[
      "Réouverture du canal de Suez",
      "Fermé depuis la guerre de 1967, le canal rouvre à la navigation le 5 juin 1975.",
    ],
    <String>[
      "The Suez Canal reopens",
      "Closed since the 1967 war, the canal reopens to shipping on 5 June 1975.",
    ],
    <String>[
      "إعادة افتتاح قناة السويس",
      "بعد إغلاقها منذ حرب 1967، تعود القناة إلى الملاحة في 5 يونيو 1975.",
    ],
  ),
  _Ev(
    1979,
    false,
    <String>[
      "Traité de paix avec Israël",
      "L'Égypte est le premier pays arabe à signer la paix avec Israël.",
    ],
    <String>[
      'Peace treaty with Israel',
      'Egypt becomes the first Arab country to sign peace with Israel.',
    ],
    <String>[
      'معاهدة السلام مع إسرائيل',
      'مصر أول دولة عربية توقّع السلام مع إسرائيل.',
    ],
  ),
  _Ev(
    2011,
    false,
    <String>[
      'Révolution du 25 janvier',
      'Des manifestations massives mettent fin à trente ans de présidence de Hosni Moubarak.',
    ],
    <String>[
      'The 25 January Revolution',
      "Mass protests end thirty years of Hosni Mubarak's presidency.",
    ],
    <String>[
      'ثورة 25 يناير',
      'تنهي احتجاجات حاشدة ثلاثين عاماً من حكم حسني مبارك.',
    ],
  ),
  _Ev(
    2015,
    false,
    <String>[
      "Le nouveau canal de Suez",
      "Une nouvelle voie parallèle et l'élargissement de plusieurs tronçons sont inaugurés pour fluidifier le trafic.",
    ],
    <String>[
      "The New Suez Canal",
      "A new parallel channel and widened stretches are inaugurated to ease traffic.",
    ],
    <String>[
      "قناة السويس الجديدة",
      "افتتاح مجرى موازٍ جديد وتوسعة عدة أجزاء من القناة لتسهيل حركة الملاحة.",
    ],
  ),
  _Ev(
    2021,
    false,
    <String>[
      "Parade d'or des pharaons",
      "Vingt-deux momies royales traversent Le Caire jusqu'au Musée national de la civilisation égyptienne.",
    ],
    <String>[
      "Pharaohs' Golden Parade",
      'Twenty-two royal mummies cross Cairo to the National Museum of Egyptian Civilization.',
    ],
    <String>[
      'موكب المومياوات الملكية',
      'تعبر 22 مومياء ملكية القاهرة إلى المتحف القومي للحضارة المصرية.',
    ],
    where: <String>["Musée national de la civilisation égyptienne, Fostat", "National Museum of Egyptian Civilization, Fustat", "المتحف القومي للحضارة المصرية، الفسطاط"],
  ),
  _Ev(
    2021,
    false,
    <String>[
      "L'Ever Given bloque le canal",
      "Échoué en travers du canal, le porte-conteneurs interrompt la navigation pendant près d'une semaine.",
    ],
    <String>[
      "The Ever Given blocks the canal",
      "Stuck across the canal, the container ship halts traffic for almost a week.",
    ],
    <String>[
      "السفينة إيفر غيفن تغلق القناة",
      "تجنح سفينة الحاويات عرضياً في القناة وتعطّل الملاحة قرابة أسبوع.",
    ],
  ),
  _Ev(
    2025,
    false,
    <String>[
      "Ouverture du Grand Musée égyptien",
      "Près des pyramides de Gizeh, le plus grand musée du monde consacré à une seule civilisation est inauguré le 1er novembre.",
    ],
    <String>[
      "The Grand Egyptian Museum opens",
      "Near the Giza pyramids, the world's largest museum devoted to a single civilisation is inaugurated on 1 November.",
    ],
    <String>[
      "افتتاح المتحف المصري الكبير",
      "قرب أهرامات الجيزة، يُفتتح رسمياً في الأول من نوفمبر أكبر متحف في العالم مخصص لحضارة واحدة.",
    ],
    where: <String>["Près des pyramides de Gizeh", "Next to the Giza pyramids", "بجوار أهرامات الجيزة"],
  ),
];

// ───────────────────────── Époques ─────────────────────────

class _Era {
  final String id;
  final int from; // année de début (incluse)
  final Map<String, String> label;
  const _Era(this.id, this.from, this.label);
}

const List<_Era> _eras = <_Era>[
  _Era('old', -3200, <String, String>{
    'fr': 'Origines & Ancien Empire',
    'en': 'Origins & Old Kingdom',
    'ar': 'النشأة والدولة القديمة',
  }),
  _Era('middle', -2055, <String, String>{
    'fr': 'Moyen Empire & Hyksos',
    'en': 'Middle Kingdom & Hyksos',
    'ar': 'الدولة الوسطى والهكسوس',
  }),
  _Era('new', -1550, <String, String>{
    'fr': 'Nouvel Empire',
    'en': 'New Kingdom',
    'ar': 'الدولة الحديثة',
  }),
  _Era('late', -1070, <String, String>{
    'fr': 'Basse époque',
    'en': 'Late Period',
    'ar': 'العصر المتأخر',
  }),
  _Era('greco', -332, <String, String>{
    'fr': 'Gréco-romaine & byzantine',
    'en': 'Greco-Roman & Byzantine',
    'ar': 'العصر اليوناني الروماني والبيزنطي',
  }),
  _Era('islamic', 641, <String, String>{
    'fr': 'Égypte islamique',
    'en': 'Islamic Egypt',
    'ar': 'مصر الإسلامية',
  }),
  _Era('modern', 1798, <String, String>{
    'fr': 'Époque moderne',
    'en': 'Modern era',
    'ar': 'العصر الحديث',
  }),
];

const List<Color> _eraColors = <Color>[
  Color(0xFFC9A24B),
  Color(0xFF4F9D9A),
  Color(0xFFD9822B),
  Color(0xFF7B6CC4),
  Color(0xFF3C8DBC),
  Color(0xFF3FA37A),
  Color(0xFFC9566B),
];

int _eraIndexOf(int year) {
  int idx = 0;
  for (int i = 0; i < _eras.length; i++) {
    if (year >= _eras[i].from) idx = i;
  }
  return idx;
}

const Map<String, Map<String, String>> _ui = <String, Map<String, String>>{
  'fr': <String, String>{
    'title': "5 000+ ans d'histoire",
    'subtitle': 'Année par année',
    'circa': 'vers',
    'bc': 'av. J.-C.',
    'ad': 'apr. J.-C.',
    'hint': 'Glissez les cartes ou la frise pour voyager dans le temps.',
    'prev': 'Précédent',
    'next': 'Suivant',
    'back': 'Retour',
    'see': "À voir aujourd'hui",
  },
  'en': <String, String>{
    'title': '5,000+ years of history',
    'subtitle': 'Year by year',
    'circa': 'c.',
    'bc': 'BCE',
    'ad': 'CE',
    'hint': 'Swipe the cards or the timeline to travel through time.',
    'prev': 'Previous',
    'next': 'Next',
    'back': 'Back',
    'see': 'See it today',
  },
  'ar': <String, String>{
    'title': 'أكثر من 5000 سنة من التاريخ',
    'subtitle': 'سنةً بسنة',
    'circa': 'حوالي',
    'bc': 'ق.م',
    'ad': 'م',
    'hint': 'مرّر البطاقات أو الشريط الزمني للسفر عبر الزمن.',
    'prev': 'السابق',
    'next': 'التالي',
    'back': 'رجوع',
    'see': 'للزيارة اليوم',
  },
};

// ───────────────────────── Page ─────────────────────────

class HistoirePage extends StatefulWidget {
  const HistoirePage({super.key});

  @override
  State<HistoirePage> createState() => _HistoirePageState();
}

class _HistoirePageState extends State<HistoirePage> {
  static const Color _paper = Color(0xFF080B12);
  static const Color _card = Color(0xFF121924);
  static const Color _ink = Color(0xFFF2E9D8);
  static const Color _muted = Color(0xFF8D95A5);
  static const Color _line = Color(0xFF253047);
  static const Color _gold = Color(0xFFDFB15B);

  final PageController _pages = PageController(viewportFraction: 0.94);
  String _lang = 'fr';
  int _index = 0;

  bool get _ar => _lang == 'ar';

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _loadLang() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('selected_language');
    if (!mounted) return;
    if (saved != null && _ui.containsKey(saved)) {
      setState(() => _lang = saved);
    }
  }

  String _t(String k) => _ui[_lang]?[k] ?? _ui['fr']![k] ?? k;

  TextStyle _display(double size, {Color? color, double height = 1.15, double spacing = 0}) {
    if (_ar) {
      return GoogleFonts.reemKufi(
        color: color ?? _ink,
        fontSize: size * 0.94,
        fontWeight: FontWeight.w600,
        height: height + 0.25,
      );
    }
    return GoogleFonts.marcellus(
      color: color ?? _ink,
      fontSize: size,
      height: height,
      letterSpacing: spacing,
    );
  }

  TextStyle _text(double size, {Color? color, FontWeight weight = FontWeight.w400, double height = 1.5, double spacing = 0}) {
    if (_ar) {
      return GoogleFonts.cairo(color: color ?? _ink, fontSize: size * 1.06, fontWeight: weight, height: height);
    }
    return GoogleFonts.jost(
      color: color ?? _ink,
      fontSize: size * 1.04,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
    );
  }

  void _goTo(int i) {
    final int target = i.clamp(0, _events.length - 1).toInt();
    HapticFeedback.selectionClick();
    _pages.animateToPage(
      target,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  int _firstOfEra(int eraIdx) {
    for (int i = 0; i < _events.length; i++) {
      if (_eraIndexOf(_events[i].year) == eraIdx) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final _Ev cur = _events[_index];
    final int eraIdx = _eraIndexOf(cur.year);
    final bool isRtl = _ar;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _paper,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _topBar(isRtl),
                const SizedBox(height: 14),
                _eraChips(eraIdx),
                const SizedBox(height: 18),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.66,
                  child: PageView.builder(
                    controller: _pages,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _events.length,
                    onPageChanged: (int i) {
                      HapticFeedback.selectionClick();
                      setState(() => _index = i);
                    },
                    itemBuilder: (BuildContext context, int i) => _eventCard(_events[i], i),
                  ),
                ),
                const SizedBox(height: 8),
                _timeline(),
                SizedBox(height: 10 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(bool isRtl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: _t('back'),
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _ink,
            ),
          ),
          Expanded(
            child: Text(_t('title'), style: _display(21, height: 1.2)),
          ),
          const SizedBox(width: 8),
          Text(
            '${_index + 1} / ${_events.length}',
            style: _text(12, color: _ink, weight: FontWeight.w600, spacing: 1.4, height: 1.2),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  /// Époques : liste verticale juste après le titre ; chaque libellé reste entier sur une ligne.
  Widget _eraChips(int selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < _eras.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _goTo(_firstOfEra(i)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 40,
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: i == selected ? _ink : _card,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: i == selected ? _ink : _line, width: 0.9),
                ),
                child: Text(
                  _eras[i].label[_lang] ?? _eras[i].label['fr']!,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: _text(
                    12.5,
                    color: i == selected ? _card : _ink,
                    weight: i == selected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Grande année : le nombre, puis l'époque (av./apr. J.-C.) en dessous.
  Widget _bigYear(_Ev e) {
    final int abs = e.year.abs();
    final String suffix = e.year < 0 ? _t('bc') : _t('ad');
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (Widget child, Animation<double> a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(a),
          child: child,
        ),
      ),
      child: Padding(
        key: ValueKey<String>('${e.year}-$_index'),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('$abs', style: _display(58, color: _gold, height: 1.0)),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (e.circa)
                      Text(
                        _t('circa'),
                        style: _text(12, color: _muted, height: 1.2),
                      ),
                    Text(
                      suffix,
                      style: _text(14, color: _ink, weight: FontWeight.w600, height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventCard(_Ev e, int i) {
    final List<String> content = e.pick(_lang);
    final int eraIdx = _eraIndexOf(e.year);
    final String? where = e.whereFor(_lang);
    final String eraLabel = _eras[eraIdx].label[_lang] ?? _eras[eraIdx].label['fr']!;
    return AnimatedBuilder(
      animation: _pages,
      builder: (BuildContext context, Widget? child) {
        double page = _index.toDouble();
        if (_pages.hasClients && _pages.position.haveDimensions) {
          page = _pages.page ?? page;
        }
        final double d = (page - i).abs().clamp(0.0, 1.0).toDouble();
        return Transform.scale(
          scale: 1 - 0.05 * d,
          child: Opacity(opacity: 1 - 0.45 * d, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _line, width: 0.9),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double sceneH = (box.maxHeight * 0.36).clamp(150.0, 260.0).toDouble();
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: sceneH,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            RepaintBoundary(
                              child: CustomPaint(painter: _EraScenePainter(eraIdx)),
                            ),
                            PositionedDirectional(
                              start: 22,
                              bottom: 16,
                              child: _yearBadge(e),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: _eraColors[eraIdx], shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    eraLabel,
                                    style: _text(12.5, color: _muted, weight: FontWeight.w600, height: 1.3, spacing: _ar ? 0 : 0.6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(content[0], style: _display(28, height: 1.18)),
                            const SizedBox(height: 14),
                            Text(content[1], style: _text(17.5, color: _ink.withOpacity(0.88), height: 1.65)),
                            if (where != null) ...<Widget>[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _paper,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: _line, width: 0.9),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Icon(Icons.place_rounded, size: 20, color: _gold),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _ar ? _t('see') : _t('see').toUpperCase(),
                                            style: _text(10.5, color: _muted, weight: FontWeight.w600, height: 1.3, spacing: _ar ? 0 : 1.4),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(where, style: _text(14.5, color: _ink, height: 1.45)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Année en grand, posée sur l'illustration de la carte.
  Widget _yearBadge(_Ev e) {
    final String suffix = e.year < 0 ? _t('bc') : _t('ad');
    const List<Shadow> shade = <Shadow>[Shadow(color: Color(0xCC000000), blurRadius: 12)];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('${e.year.abs()}', style: _display(54, color: _gold, height: 1.0).copyWith(shadows: shade)),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (e.circa)
                Text(_t('circa'), style: _text(12, color: _ink, height: 1.2).copyWith(shadows: shade)),
              Text(
                suffix,
                style: _text(14, color: _ink, weight: FontWeight.w600, height: 1.2).copyWith(shadows: shade),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Frise graphique : une bande par époque (largeur selon le nombre d'événements),
  /// un trait par événement. On touche ou on glisse pour voyager dans le temps.
  Widget _timeline() {
    final _Ev first = _events.first;
    final _Ev last = _events.last;
    String edge(_Ev e) => '${e.year.abs()} ${e.year < 0 ? _t('bc') : _t('ad')}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
      child: Column(
        children: <Widget>[
          _EraBar(
            index: _index,
            rtl: _ar,
            onSelect: (int i) {
              if (i != _index) {
                _pages.jumpToPage(i);
                setState(() => _index = i);
              }
            },
          ),
          const SizedBox(height: 2),
          Row(
            children: <Widget>[
              Text(edge(first), style: _text(12, color: _muted, height: 1.2)),
              const Spacer(),
              Text(edge(last), style: _text(12, color: _muted, height: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(String label, IconData icon, VoidCallback onTap, bool enabled) {
    final bool rtl = _ar;
    final bool isPrev = icon == Icons.arrow_back_rounded;
    final IconData shown = rtl ? (isPrev ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded) : icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.35,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _line, width: 0.9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isPrev) ...<Widget>[Icon(shown, size: 16, color: _ink), const SizedBox(width: 8)],
              Flexible(child: Text(label, textAlign: TextAlign.center, style: _text(13.5, weight: FontWeight.w500, height: 1.2))),
              if (!isPrev) ...<Widget>[const SizedBox(width: 8), Icon(shown, size: 16, color: _ink)],
            ],
          ),
        ),
      ),
    );
  }
}


// ───────────────────────── Carte graphique « Histoire » ─────────────────────────
//
// Illustration dessinée en code (aucune photo nécessaire) : ciel étoilé,
// soleil, pyramides, Nil et frise du temps. Utilisée sur la carte de l'accueil.

class HistoireGraphic extends StatelessWidget {
  /// Chemin spécial reconnu par l'accueil à la place d'une photo.
  static const String assetKey = 'graphic:histoire';

  const HistoireGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const RepaintBoundary(child: CustomPaint(painter: _HistoirePainter())),
        Positioned(
          left: 18,
          bottom: 40,
          child: Text(
            '5 000+',
            style: GoogleFonts.marcellus(
              color: const Color(0xFFF2E9D8),
              fontSize: 34,
              height: 1.0,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoirePainter extends CustomPainter {
  const _HistoirePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect full = Offset.zero & size;

    // Ciel
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF0A0F20), Color(0xFF2A2140), Color(0xFF8A5A2E), Color(0xFFE8B25C)],
          stops: <double>[0.0, 0.42, 0.74, 0.80],
        ).createShader(full),
    );

    // Étoiles
    final math.Random rnd = math.Random(7);
    final Paint star = Paint();
    for (int i = 0; i < 46; i++) {
      final double x = rnd.nextDouble() * w;
      final double y = rnd.nextDouble() * h * 0.5;
      star.color = const Color(0xFFF2E9D8).withOpacity(0.25 + rnd.nextDouble() * 0.6);
      canvas.drawCircle(Offset(x, y), 0.6 + rnd.nextDouble() * 1.2, star);
    }

    // Soleil et halo
    final Offset sun = Offset(w * 0.74, h * 0.64);
    final double r = h * 0.13;
    canvas.drawCircle(
      sun,
      r * 3.2,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[const Color(0xFFFFD98A).withOpacity(0.55), const Color(0xFFFFD98A).withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: sun, radius: r * 3.2)),
    );
    canvas.drawCircle(sun, r, Paint()..color = const Color(0xFFFFE3A3));

    // Pyramides : face éclairée et face dans l'ombre
    final double base = h * 0.80;
    void pyramid(double cx, double halfW, double height) {
      final Path left = Path()
        ..moveTo(cx - halfW, base)
        ..lineTo(cx, base - height)
        ..lineTo(cx, base)
        ..close();
      final Path right = Path()
        ..moveTo(cx + halfW, base)
        ..lineTo(cx, base - height)
        ..lineTo(cx, base)
        ..close();
      canvas.drawPath(left, Paint()..color = const Color(0xFF3B2A2E));
      canvas.drawPath(right, Paint()..color = const Color(0xFF1B1420));
    }

    pyramid(w * 0.30, w * 0.20, h * 0.40);
    pyramid(w * 0.56, w * 0.13, h * 0.26);
    pyramid(w * 0.08, w * 0.10, h * 0.18);

    // Sol et Nil
    final Rect ground = Rect.fromLTWH(0, base, w, h - base);
    canvas.drawRect(
      ground,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF241B22), Color(0xFF0D0B12)],
        ).createShader(ground),
    );
    final Path nile = Path()..moveTo(0, h * 0.865);
    for (double x = 0; x <= w; x += 4) {
      nile.lineTo(x, h * 0.865 + math.sin(x / w * math.pi * 6) * 2.2);
    }
    canvas.drawPath(
      nile,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFFE8B25C).withOpacity(0.65),
    );

    // Frise du temps : 12 jalons, le dernier (aujourd'hui) plus grand
    final double ty = h * 0.935;
    final double x0 = w * 0.07;
    final double x1 = w * 0.93;
    canvas.drawLine(
      Offset(x0, ty),
      Offset(x1, ty),
      Paint()
        ..strokeWidth = 1.2
        ..color = const Color(0xFFDFB15B).withOpacity(0.7),
    );
    const int n = 12;
    for (int i = 0; i < n; i++) {
      final double x = x0 + (x1 - x0) * i / (n - 1);
      final bool last = i == n - 1;
      canvas.drawCircle(Offset(x, ty), last ? 4.6 : 2.6, Paint()..color = const Color(0xFFDFB15B));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// ───────────────────────── Frise par époque ─────────────────────────

class _EraBar extends StatelessWidget {
  final int index;
  final bool rtl;
  final ValueChanged<int> onSelect;

  const _EraBar({required this.index, required this.rtl, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double w = c.maxWidth;
        int pick(double dx) {
          double x = dx.clamp(0.0, w).toDouble();
          if (rtl) x = w - x;
          return (x / w * _events.length).floor().clamp(0, _events.length - 1).toInt();
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails d) => onSelect(pick(d.localPosition.dx)),
          onHorizontalDragStart: (DragStartDetails d) => onSelect(pick(d.localPosition.dx)),
          onHorizontalDragUpdate: (DragUpdateDetails d) => onSelect(pick(d.localPosition.dx)),
          child: SizedBox(
            height: 46,
            width: w,
            child: CustomPaint(painter: _EraBarPainter(index, rtl)),
          ),
        );
      },
    );
  }
}

class _EraBarPainter extends CustomPainter {
  final int index;
  final bool rtl;
  const _EraBarPainter(this.index, this.rtl);

  @override
  void paint(Canvas canvas, Size size) {
    final int n = _events.length;
    final double w = size.width;
    double px(double x) => rtl ? w - x : x;

    final List<int> counts = List<int>.filled(_eras.length, 0);
    for (final _Ev e in _events) {
      counts[_eraIndexOf(e.year)]++;
    }
    final int cur = _eraIndexOf(_events[index].year);

    // Bandes d'époque
    const double barTop = 24;
    const double barH = 10;
    int start = 0;
    for (int i = 0; i < _eras.length; i++) {
      if (counts[i] == 0) continue;
      final double x0 = w * start / n + 1.5;
      final double x1 = w * (start + counts[i]) / n - 1.5;
      start += counts[i];
      final double a = px(x0);
      final double b = px(x1);
      final Rect r = Rect.fromLTRB(math.min(a, b), barTop, math.max(a, b), barTop + barH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(5)),
        Paint()..color = _eraColors[i].withOpacity(i == cur ? 1.0 : 0.32),
      );
    }

    // Un trait par événement
    final Paint tick = Paint()..strokeWidth = 1;
    for (int j = 0; j < n; j++) {
      final double x = px(w * (j + 0.5) / n);
      final bool active = j == index;
      tick.color = active ? const Color(0xFFDFB15B) : const Color(0xFFF2E9D8).withOpacity(0.28);
      canvas.drawLine(Offset(x, active ? 6 : 15), Offset(x, barTop - 2), tick);
    }

    // Curseur
    final Offset thumb = Offset(px(w * (index + 0.5) / n), barTop + barH / 2);
    canvas.drawCircle(thumb, 9, Paint()..color = const Color(0xFF080B12));
    canvas.drawCircle(
      thumb,
      9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFFDFB15B),
    );
    canvas.drawCircle(thumb, 3.4, Paint()..color = const Color(0xFFF2E9D8));
  }

  @override
  bool shouldRepaint(covariant _EraBarPainter old) => old.index != index || old.rtl != rtl;
}

// ───────────────────────── Scènes graphiques par époque ─────────────────────────
//
// 0 Ancien Empire : pyramides · 1 Moyen Empire : felouque sur le Nil
// 2 Nouvel Empire : pylône, obélisque, colonnes · 3 Basse époque : ankh
// 4 Gréco-romaine : phare d'Alexandrie · 5 Islamique : dôme et minarets
// 6 Moderne : navire dans le canal de Suez

class _EraScenePainter extends CustomPainter {
  final int era;
  const _EraScenePainter(this.era);

  static const List<List<Color>> _skies = <List<Color>>[
    <Color>[Color(0xFF0A0F20), Color(0xFF2A2140), Color(0xFFE8B25C)],
    <Color>[Color(0xFF07202B), Color(0xFF1F5A63), Color(0xFFF0C27A)],
    <Color>[Color(0xFF1A0F24), Color(0xFF7A3A2E), Color(0xFFF2A65A)],
    <Color>[Color(0xFF0C0A1E), Color(0xFF2B2260), Color(0xFF6B5BC4)],
    <Color>[Color(0xFF06142B), Color(0xFF123B6B), Color(0xFF3F8FD0)],
    <Color>[Color(0xFF071A1C), Color(0xFF0F4C4C), Color(0xFF2FA58E)],
    <Color>[Color(0xFF141026), Color(0xFF8A3F52), Color(0xFFF4A95C)],
  ];

  static const Color _dark = Color(0xFF140E18);
  static const Color _mid = Color(0xFF2E2128);
  static const Color _gold = Color(0xFFDFB15B);
  static const Color _ivory = Color(0xFFF2E9D8);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect full = Offset.zero & size;
    final int e = era.clamp(0, _skies.length - 1).toInt();
    final List<Color> sky = _skies[e];
    final double gy = h * 0.80; // ligne d'horizon

    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[sky[0], sky[1], sky[2]],
          stops: const <double>[0.0, 0.55, 0.80],
        ).createShader(full),
    );

    _stars(canvas, w, h * 0.55, e + 3);

    switch (e) {
      case 0:
        _old(canvas, w, h, gy);
        break;
      case 1:
        _middle(canvas, w, h, gy);
        break;
      case 2:
        _newKingdom(canvas, w, h, gy);
        break;
      case 3:
        _late(canvas, w, h, gy);
        break;
      case 4:
        _greco(canvas, w, h, gy);
        break;
      case 5:
        _islamic(canvas, w, h, gy);
        break;
      default:
        _modern(canvas, w, h, gy);
    }

    // Filet doré en bas de la scène
    canvas.drawRect(
      Rect.fromLTWH(0, h - 2, w, 2),
      Paint()..color = _gold.withOpacity(0.7),
    );
  }

  void _stars(Canvas c, double w, double h, int seed) {
    final math.Random r = math.Random(seed);
    final Paint p = Paint();
    for (int i = 0; i < 34; i++) {
      p.color = _ivory.withOpacity(0.2 + r.nextDouble() * 0.6);
      c.drawCircle(Offset(r.nextDouble() * w, r.nextDouble() * h), 0.5 + r.nextDouble() * 1.1, p);
    }
  }

  void _glow(Canvas c, Offset o, double r, Color core) {
    c.drawCircle(
      o,
      r * 3,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[core.withOpacity(0.5), core.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: o, radius: r * 3)),
    );
    c.drawCircle(o, r, Paint()..color = core);
  }

  void _ground(Canvas c, double w, double h, double gy, {Color top = const Color(0xFF241B22)}) {
    final Rect g = Rect.fromLTWH(0, gy, w, h - gy);
    c.drawRect(
      g,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[top, const Color(0xFF0D0B12)],
        ).createShader(g),
    );
  }

  // 0 · Pyramides
  void _old(Canvas c, double w, double h, double gy) {
    _glow(c, Offset(w * 0.76, gy - h * 0.10), h * 0.12, const Color(0xFFFFE3A3));
    void pyr(double cx, double half, double ht) {
      c.drawPath(
        Path()
          ..moveTo(cx - half, gy)
          ..lineTo(cx, gy - ht)
          ..lineTo(cx, gy)
          ..close(),
        Paint()..color = const Color(0xFF3B2A2E),
      );
      c.drawPath(
        Path()
          ..moveTo(cx + half, gy)
          ..lineTo(cx, gy - ht)
          ..lineTo(cx, gy)
          ..close(),
        Paint()..color = _dark,
      );
    }

    pyr(w * 0.30, w * 0.17, h * 0.62);
    pyr(w * 0.56, w * 0.11, h * 0.40);
    pyr(w * 0.08, w * 0.08, h * 0.26);
    _ground(c, w, h, gy);
  }

  // 1 · Felouque sur le Nil
  void _middle(Canvas c, double w, double h, double gy) {
    _glow(c, Offset(w * 0.2, gy - h * 0.14), h * 0.11, const Color(0xFFFFE3A3));
    final Path dunes = Path()..moveTo(0, gy);
    for (double x = 0; x <= w; x += 6) {
      dunes.lineTo(x, gy - 6 - math.sin(x / w * math.pi * 3 + 0.6) * 7);
    }
    dunes
      ..lineTo(w, gy)
      ..close();
    c.drawPath(dunes, Paint()..color = const Color(0xFF123A40));

    final Rect water = Rect.fromLTWH(0, gy, w, h - gy);
    c.drawRect(
      water,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF2F7F80), Color(0xFF0A2328)],
        ).createShader(water),
    );
    final double cx = w * 0.56;
    // coque
    c.drawPath(
      Path()
        ..moveTo(cx - w * 0.15, gy - 3)
        ..quadraticBezierTo(cx, gy + 13, cx + w * 0.15, gy - 3)
        ..close(),
      Paint()..color = _dark,
    );
    // mât et voiles
    c.drawLine(Offset(cx, gy - 3), Offset(cx, gy - h * 0.55), Paint()..color = _dark..strokeWidth = 2);
    c.drawPath(
      Path()
        ..moveTo(cx - 1, gy - h * 0.55)
        ..lineTo(cx - w * 0.15, gy - 6)
        ..lineTo(cx - 1, gy - 6)
        ..close(),
      Paint()..color = _ivory.withOpacity(0.92),
    );
    c.drawPath(
      Path()
        ..moveTo(cx + 1, gy - h * 0.48)
        ..lineTo(cx + w * 0.10, gy - 6)
        ..lineTo(cx + 1, gy - 6)
        ..close(),
      Paint()..color = _ivory.withOpacity(0.7),
    );
    // reflets
    final Paint ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _gold.withOpacity(0.5);
    for (int i = 0; i < 3; i++) {
      final double y = gy + 10 + i * 7;
      c.drawLine(Offset(w * (0.12 + i * 0.1), y), Offset(w * (0.30 + i * 0.1), y), ripple);
    }
  }

  // 2 · Pylône, obélisque, colonnade
  void _newKingdom(Canvas c, double w, double h, double gy) {
    final double cx = w * 0.5;
    _glow(c, Offset(cx, gy - h * 0.30), h * 0.20, const Color(0xFFFFD48A));
    // pylône : deux tours
    for (final int dir in <int>[-1, 1]) {
      final double inner = cx + dir * w * 0.045;
      final double outer = cx + dir * w * 0.20;
      final double innerTop = cx + dir * w * 0.05;
      final double outerTop = cx + dir * w * 0.17;
      c.drawPath(
        Path()
          ..moveTo(inner, gy)
          ..lineTo(innerTop, gy - h * 0.62)
          ..lineTo(outerTop, gy - h * 0.62)
          ..lineTo(outer, gy)
          ..close(),
        Paint()..color = dir < 0 ? _mid : _dark,
      );
    }
    // obélisque
    final double ox = w * 0.12;
    c.drawPath(
      Path()
        ..moveTo(ox - 5, gy)
        ..lineTo(ox - 3.5, gy - h * 0.66)
        ..lineTo(ox, gy - h * 0.76)
        ..lineTo(ox + 3.5, gy - h * 0.66)
        ..lineTo(ox + 5, gy)
        ..close(),
      Paint()..color = _mid,
    );
    // colonnade
    final Paint col = Paint()..color = _dark;
    for (int i = 0; i < 6; i++) {
      final double x = w * 0.68 + i * w * 0.046;
      c.drawRect(Rect.fromLTWH(x, gy - h * 0.34, 6, h * 0.34), col);
    }
    c.drawRect(Rect.fromLTWH(w * 0.67, gy - h * 0.40, w * 0.26, 6), Paint()..color = _mid);
    _ground(c, w, h, gy);
  }

  // 3 · Ankh
  void _late(Canvas c, double w, double h, double gy) {
    final Offset o = Offset(w * 0.5, h * 0.46);
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _gold.withOpacity(0.22);
    for (int i = 1; i <= 3; i++) {
      c.drawCircle(o, h * (0.28 + i * 0.16), ring);
    }
    final Paint gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = _gold;
    final double loopH = h * 0.30;
    final double loopW = h * 0.22;
    final double top = h * 0.12;
    c.drawOval(Rect.fromLTWH(o.dx - loopW / 2, top, loopW, loopH), gold);
    final double stemTop = top + loopH;
    final double stemBottom = h * 0.86;
    c.drawLine(Offset(o.dx, stemTop), Offset(o.dx, stemBottom), gold);
    c.drawLine(Offset(o.dx - h * 0.19, stemTop + h * 0.10), Offset(o.dx + h * 0.19, stemTop + h * 0.10), gold);
    _ground(c, w, h, gy, top: const Color(0xFF1A1438));
  }

  // 4 · Phare d'Alexandrie
  void _greco(Canvas c, double w, double h, double gy) {
    final double cx = w * 0.5;
    final Rect sea = Rect.fromLTWH(0, gy, w, h - gy);
    c.drawRect(
      sea,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF1F5E9C), Color(0xFF071A33)],
        ).createShader(sea),
    );
    final Offset flame = Offset(cx, gy - h * 0.76);
    // faisceaux
    for (final int dir in <int>[-1, 1]) {
      c.drawPath(
        Path()
          ..moveTo(flame.dx, flame.dy)
          ..lineTo(flame.dx + dir * w * 0.42, flame.dy - h * 0.10)
          ..lineTo(flame.dx + dir * w * 0.42, flame.dy + h * 0.14)
          ..close(),
        Paint()..color = const Color(0xFFFFE3A3).withOpacity(0.16),
      );
    }
    // île
    c.drawOval(Rect.fromCenter(center: Offset(cx, gy), width: w * 0.34, height: h * 0.10), Paint()..color = _dark);
    // tour : base carrée, étage octogonal, lanterne
    c.drawPath(
      Path()
        ..moveTo(cx - w * 0.050, gy - 2)
        ..lineTo(cx - w * 0.038, gy - h * 0.30)
        ..lineTo(cx + w * 0.038, gy - h * 0.30)
        ..lineTo(cx + w * 0.050, gy - 2)
        ..close(),
      Paint()..color = _mid,
    );
    c.drawPath(
      Path()
        ..moveTo(cx - w * 0.034, gy - h * 0.30)
        ..lineTo(cx - w * 0.026, gy - h * 0.52)
        ..lineTo(cx + w * 0.026, gy - h * 0.52)
        ..lineTo(cx + w * 0.034, gy - h * 0.30)
        ..close(),
      Paint()..color = _dark,
    );
    c.drawRect(Rect.fromLTRB(cx - w * 0.016, gy - h * 0.66, cx + w * 0.016, gy - h * 0.52), Paint()..color = _mid);
    _glow(c, flame, h * 0.045, const Color(0xFFFFE3A3));
    // vagues
    final Paint wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _ivory.withOpacity(0.25);
    for (int i = 0; i < 3; i++) {
      final double y = gy + 8 + i * 8;
      final Path p = Path()..moveTo(0, y);
      for (double x = 0; x <= w; x += 4) {
        p.lineTo(x, y + math.sin(x / 14 + i) * 1.6);
      }
      c.drawPath(p, wave);
    }
  }

  // 5 · Dôme et minarets
  void _islamic(Canvas c, double w, double h, double gy) {
    final double cx = w * 0.5;
    // croissant de lune
    final Offset moon = Offset(w * 0.84, h * 0.22);
    final Path crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: moon, radius: h * 0.10)),
      Path()..addOval(Rect.fromCircle(center: moon.translate(h * 0.05, -h * 0.02), radius: h * 0.09)),
    );
    c.drawPath(crescent, Paint()..color = const Color(0xFFFFE3A3));
    // minarets
    for (final int dir in <int>[-1, 1]) {
      final double mx = cx + dir * w * 0.22;
      c.drawRect(Rect.fromLTRB(mx - 4.5, gy - h * 0.60, mx + 4.5, gy), Paint()..color = _dark);
      c.drawRect(Rect.fromLTRB(mx - 8, gy - h * 0.42, mx + 8, gy - h * 0.42 + 4), Paint()..color = _mid);
      c.drawPath(
        Path()
          ..moveTo(mx - 6, gy - h * 0.60)
          ..lineTo(mx, gy - h * 0.82)
          ..lineTo(mx + 6, gy - h * 0.60)
          ..close(),
        Paint()..color = _dark,
      );
    }
    // salle et dôme
    final double bodyW = w * 0.24;
    c.drawRect(Rect.fromLTWH(cx - bodyW / 2, gy - h * 0.20, bodyW, h * 0.20), Paint()..color = _mid);
    c.drawPath(
      Path()..addArc(Rect.fromCenter(center: Offset(cx, gy - h * 0.20), width: bodyW * 0.92, height: h * 0.50), math.pi, math.pi),
      Paint()..color = _dark,
    );
    c.drawLine(Offset(cx, gy - h * 0.45), Offset(cx, gy - h * 0.56), Paint()..color = _gold..strokeWidth = 1.6);
    c.drawCircle(Offset(cx, gy - h * 0.57), 2.4, Paint()..color = _gold);
    // fenêtres éclairées
    final Paint win = Paint()..color = const Color(0xFFFFD48A).withOpacity(0.85);
    for (int i = 0; i < 4; i++) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - bodyW * 0.36 + i * bodyW * 0.24, gy - h * 0.15, 5, 9),
          const Radius.circular(2.5),
        ),
        win,
      );
    }
    _ground(c, w, h, gy, top: const Color(0xFF10231F));
  }

  // 6 · Navire dans le canal
  void _modern(Canvas c, double w, double h, double gy) {
    final double cx = w * 0.5;
    final double hz = h * 0.56; // horizon plus haut : le canal fuit vers le fond
    _glow(c, Offset(cx, hz), h * 0.12, const Color(0xFFFFD48A));
    // rives
    final Paint sand = Paint()..color = const Color(0xFF3A2A2C);
    c.drawPath(
      Path()
        ..moveTo(0, hz)
        ..lineTo(cx - w * 0.04, hz)
        ..lineTo(cx - w * 0.30, h)
        ..lineTo(0, h)
        ..close(),
      sand,
    );
    c.drawPath(
      Path()
        ..moveTo(w, hz)
        ..lineTo(cx + w * 0.04, hz)
        ..lineTo(cx + w * 0.30, h)
        ..lineTo(w, h)
        ..close(),
      sand,
    );
    // eau
    final Rect canal = Rect.fromLTWH(cx - w * 0.30, hz, w * 0.60, h - hz);
    c.drawPath(
      Path()
        ..moveTo(cx - w * 0.04, hz)
        ..lineTo(cx + w * 0.04, hz)
        ..lineTo(cx + w * 0.30, h)
        ..lineTo(cx - w * 0.30, h)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFF0A860), Color(0xFF3A3F6B)],
        ).createShader(canal),
    );
    // navire : coque, conteneurs, passerelle
    final double sy = h * 0.74;
    final double sw = w * 0.30;
    c.drawPath(
      Path()
        ..moveTo(cx - sw / 2, sy)
        ..lineTo(cx + sw / 2 + 8, sy)
        ..lineTo(cx + sw / 2 - 4, sy + h * 0.10)
        ..lineTo(cx - sw / 2 + 4, sy + h * 0.10)
        ..close(),
      Paint()..color = _dark,
    );
    const List<Color> boxes = <Color>[Color(0xFFC9566B), Color(0xFFDFB15B), Color(0xFF4F9D9A), Color(0xFFD9822B)];
    for (int row = 0; row < 2; row++) {
      for (int i = 0; i < 7; i++) {
        c.drawRect(
          Rect.fromLTWH(cx - sw / 2 + 4 + i * (sw * 0.105), sy - (row + 1) * 7, sw * 0.095, 6),
          Paint()..color = boxes[(i + row * 2) % boxes.length],
        );
      }
    }
    c.drawRect(Rect.fromLTWH(cx + sw / 2 - 18, sy - 22, 14, 22), Paint()..color = _ivory.withOpacity(0.9));
    c.drawRect(Rect.fromLTWH(cx + sw / 2 - 16, sy - 19, 10, 3), Paint()..color = _dark);
  }

  @override
  bool shouldRepaint(covariant _EraScenePainter old) => old.era != era;
}