-- =============================================================================
-- 40 Hadith Nawawi — Hadith 15: "Good word, honouring neighbour and guest"
-- Target collection: public.hadith_collections.id = 2  /  position = 15
-- Idempotent guard on (collection, position). All 11 content languages.
-- Arabic source cleaned: ؤن بالله / ؤمن الله -> يؤمن بالله.
-- =============================================================================

insert into public.hadiths (
  hadith_collection_id,
  title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru,
  arabic_text,
  transcription_en, transcription_fr, transcription_de, transcription_nl, transcription_tr,
  transcription_id, transcription_ur, transcription_bn, transcription_ms, transcription_ru,
  translation_en, translation_fr, translation_de, translation_nl, translation_tr,
  translation_id, translation_ur, translation_bn, translation_ms, translation_ru,
  reference_en, reference_fr, reference_ar, reference_de, reference_nl, reference_tr,
  reference_id, reference_ur, reference_bn, reference_ms, reference_ru,
  tafsir_en, tafsir_fr, tafsir_ar, tafsir_de, tafsir_nl, tafsir_tr,
  tafsir_id, tafsir_ur, tafsir_bn, tafsir_ms, tafsir_ru,
  audio_url, ajr, position
)
select
  2,
  -- title
  'Islamic manners',
  'Les vertus islamiques',
  'آداب إسلامية',
  'Islamische Umgangsformen',
  'Islamitische omgangsvormen',
  'İslamî âdâb',
  'Adab-adab Islam',
  'اسلامی آداب',
  'ইসলামী আদব',
  'Adab-adab Islam',
  'Исламские нравы',
  -- arabic_text (cleaned)
  'عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ أَنَّ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ قَالَ: «مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ، وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيُكْرِمْ جَارَهُ، وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيُكْرِمْ ضَيْفَهُ»',
  -- transcription
  'ʿan Abī Hurayrata raḍiya Llāhu ʿanhu anna Rasūla Llāhi ṣalla Llāhu ʿalayhi wa-sallama qāla: man kāna yuʾminu bi-Llāhi wa-l-yawmi l-ākhiri fa-l-yaqul khayran aw li-yaṣmut, wa-man kāna yuʾminu bi-Llāhi wa-l-yawmi l-ākhiri fa-l-yukrim jārahu, wa-man kāna yuʾminu bi-Llāhi wa-l-yawmi l-ākhiri fa-l-yukrim ḍayfahu.',
  'ʿan Abî Hourayrata (radia Llâhou ʿanhou) anna Rassôla Llâhi (salla Llâhou ʿalayhi wa sallam) qâla : man kâna youʾminou bi-Llâhi wa l-yawmi l-âkhiri fa-l-yaqoul khayran aw li-yasmout, wa man kâna youʾminou bi-Llâhi wa l-yawmi l-âkhiri fa-l-youkrim jârahou, wa man kâna youʾminou bi-Llâhi wa l-yawmi l-âkhiri fa-l-youkrim dayfahou.',
  'ʿan Abī Hurairata (radiya Llāhu ʿanhu) anna Rasūla Llāhi (salla Llāhu ʿalaihi wa-sallam) qāla: man kāna juʾminu bi-Llāhi wa-l-jaumi l-āchiri fa-l-jaqul chairan au li-jasmut, wa-man kāna juʾminu bi-Llāhi wa-l-jaumi l-āchiri fa-l-jukrim dscharahu, wa-man kāna juʾminu bi-Llāhi wa-l-jaumi l-āchiri fa-l-jukrim daifahu.',
  'ʿan Abie Hoerairata (radia Llaahoe ʿanhoe) anna Rasoela Llaahi (salla Llaahoe ʿalaihi wa-sallam) qaala: man kaana joeʾminoe bi-Llaahi wa-l-jaumi l-aachiri fa-l-jaqoel chairan au li-jasmoet, wa-man kaana joeʾminoe bi-Llaahi wa-l-jaumi l-aachiri fa-l-joekrim dzjaarahoe, wa-man kaana joeʾminoe bi-Llaahi wa-l-jaumi l-aachiri fa-l-joekrim daifahoe.',
  'an Ebû Hüreyre''den (radıyallâhu anh) rivayetle Resûlullah (s.a.v.) şöyle buyurdu: men kâne yuʾminu bi''llâhi ve''l-yevmi''l-âhiri fe''l-yekul hayran ev li-yasmut, ve men kâne yuʾminu bi''llâhi ve''l-yevmi''l-âhiri fe''l-yukrim câruh, ve men kâne yuʾminu bi''llâhi ve''l-yevmi''l-âhiri fe''l-yukrim dayfeh.',
  'ʿan Abī Hurairah (radhiyallāhu ʿanhu) bahwa Rasulullah (shallallāhu ʿalaihi wa sallam) bersabda: man kāna yuʾminu billāhi wal-yaumil-ākhiri falyaqul khairan au liyashmut, wa man kāna yuʾminu billāhi wal-yaumil-ākhiri falyukrim jārah, wa man kāna yuʾminu billāhi wal-yaumil-ākhiri falyukrim dhaifah.',
  'ابو ہریرہ رضی اللہ عنہ سے روایت ہے کہ رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: مَن کانَ یُؤمِنُ بِاللہِ وَالیَومِ الآخِرِ فَلیَقُل خَیرًا اَو لِیَصمُت، وَمَن کانَ یُؤمِنُ بِاللہِ وَالیَومِ الآخِرِ فَلیُکرِم جارَہُ، وَمَن کانَ یُؤمِنُ بِاللہِ وَالیَومِ الآخِرِ فَلیُکرِم ضَیفَہُ۔',
  'আবু হুরায়রা (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: মান কানা ইউমিনু বিল্লাহি ওয়াল ইয়াওমিল আখিরি ফালইয়াকুল খাইরান আও লিইয়াসমুত, ওয়া মান কানা ইউমিনু বিল্লাহি ওয়াল ইয়াওমিল আখিরি ফালইউকরিম জারাহ, ওয়া মান কানা ইউমিনু বিল্লাহি ওয়াল ইয়াওমিল আখিরি ফালইউকরিম দাইফাহ।',
  'ʿan Abī Hurairah (radhiallāhu ʿanhu) bahawa Rasulullah (sallallāhu ʿalaihi wa sallam) bersabda: man kāna yuʾminu billāhi wal-yaumil-ākhiri falyaqul khairan au liyasmut, wa man kāna yuʾminu billāhi wal-yaumil-ākhiri falyukrim jārah, wa man kāna yuʾminu billāhi wal-yaumil-ākhiri falyukrim dhaifah.',
  'Ан Аби Хурайра (да будет доволен им Аллах), что Посланник Аллаха ﷺ сказал: ман кана юʾмину би-Лляхи валь-яумиль-ахири фаль-якуль хайран ав ли-ясмут, ва ман кана юʾмину би-Лляхи валь-яумиль-ахири фаль-юкрим джараху, ва ман кана юʾмину би-Лляхи валь-яумиль-ахири фаль-юкрим дайфаху.',
  -- translation
  'On the authority of Abu Hurayra (may Allah be pleased with him), the Messenger of Allah ﷺ said: "Whoever believes in Allah and the Last Day, let him say something good or remain silent. Whoever believes in Allah and the Last Day, let him be generous to his neighbour. And whoever believes in Allah and the Last Day, let him be generous to his guest."',
  'D''après Abû Hurayra (qu''Allah l''agrée), l''Envoyé d''Allah ﷺ a dit : « Celui qui croit en Allah et au Jour Dernier, qu''il dise une bonne chose ou qu''il se taise. Celui qui croit en Allah et au Jour Dernier, qu''il soit généreux envers son voisin. Et celui qui croit en Allah et au Jour Dernier, qu''il soit hospitalier envers son hôte. »',
  'Nach Abu Hurayra (möge Allah mit ihm zufrieden sein) sagte der Gesandte Allahs ﷺ: „Wer an Allah und den Jüngsten Tag glaubt, der sage Gutes oder schweige. Wer an Allah und den Jüngsten Tag glaubt, der sei großzügig zu seinem Nachbarn. Und wer an Allah und den Jüngsten Tag glaubt, der sei großzügig zu seinem Gast."',
  'Op gezag van Abu Hurayra (moge Allah tevreden met hem zijn) zei de Boodschapper van Allah ﷺ: „Wie in Allah en de Laatste Dag gelooft, laat hem iets goeds zeggen of zwijgen. Wie in Allah en de Laatste Dag gelooft, laat hem vrijgevig zijn jegens zijn buurman. En wie in Allah en de Laatste Dag gelooft, laat hem vrijgevig zijn jegens zijn gast."',
  'Ebû Hüreyre''den (Allah ondan razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Allah''a ve âhiret gününe iman eden ya hayır söylesin ya da sussun. Allah''a ve âhiret gününe iman eden komşusuna ikram etsin. Allah''a ve âhiret gününe iman eden misafirine ikram etsin."',
  'Dari Abu Hurairah (semoga Allah meridhainya), Rasulullah ﷺ bersabda: "Barangsiapa beriman kepada Allah dan hari akhir, hendaklah ia berkata baik atau diam. Barangsiapa beriman kepada Allah dan hari akhir, hendaklah ia memuliakan tetangganya. Dan barangsiapa beriman kepada Allah dan hari akhir, hendaklah ia memuliakan tamunya."',
  'ابو ہریرہ رضی اللہ عنہ سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”جو اللہ اور یومِ آخرت پر ایمان رکھتا ہے وہ اچھی بات کہے یا خاموش رہے۔ جو اللہ اور یومِ آخرت پر ایمان رکھتا ہے وہ اپنے پڑوسی کی عزت کرے۔ اور جو اللہ اور یومِ آخرت پر ایمان رکھتا ہے وہ اپنے مہمان کی عزت کرے۔“',
  'আবু হুরায়রা (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "যে ব্যক্তি আল্লাহ ও শেষ দিবসে বিশ্বাস করে, সে যেন ভালো কথা বলে অথবা চুপ থাকে। যে ব্যক্তি আল্লাহ ও শেষ দিবসে বিশ্বাস করে, সে যেন তার প্রতিবেশীর সম্মান করে। আর যে ব্যক্তি আল্লাহ ও শেষ দিবসে বিশ্বাস করে, সে যেন তার মেহমানের সম্মান করে।"',
  'Daripada Abu Hurairah (semoga Allah meredainya), Rasulullah ﷺ bersabda: "Sesiapa yang beriman kepada Allah dan hari akhir, hendaklah dia berkata baik atau diam. Sesiapa yang beriman kepada Allah dan hari akhir, hendaklah dia memuliakan jirannya. Dan sesiapa yang beriman kepada Allah dan hari akhir, hendaklah dia memuliakan tetamunya."',
  'Со слов Абу Хурайры (да будет доволен им Аллах) Посланник Аллаха ﷺ сказал: «Кто верует в Аллаха и в Последний день, пусть говорит благое или молчит. Кто верует в Аллаха и в Последний день, пусть оказывает почтение своему соседу. И кто верует в Аллаха и в Последний день, пусть оказывает почтение своему гостю».',
  -- reference
  'Sahih — reported by Al-Bukhari (10/445, no. 6018) and Muslim (1/68)',
  'Hadith authentique rapporté par Al-Bukhari (10/445, n°6018) et Muslim (1/68)',
  'حديث صحيح، رواه البخاري (١٠/٤٤٥) (رقم ٦٠١٨) ومسلم (١/٦٨)',
  'Sahih — überliefert von Al-Bukhari (10/445, Nr. 6018) und Muslim (1/68)',
  'Sahih — overgeleverd door Al-Bukhari (10/445, nr. 6018) en Muslim (1/68)',
  'Sahih — Buhârî (10/445, no. 6018) ve Müslim (1/68) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (10/445, no. 6018) dan Muslim (1/68)',
  'صحیح حدیث، اسے بخاری (۱۰/۴۴۵، نمبر ۶۰۱۸) اور مسلم (۱/۶۸) نے روایت کیا',
  'সহীহ হাদীস — বুখারী (১০/৪৪৫, নং ৬০১৮) ও মুসলিম (১/৬৮) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (10/445, no. 6018) dan Muslim (1/68)',
  'Достоверный хадис, передали аль-Бухари (10/445, № 6018) и Муслим (1/68)',
  -- tafsir
  'This hadith contains obligatory rules of conduct. Showing generosity (ikram) towards the neighbour, for the neighbour has rights over us. The scholars said that if the neighbour is a Muslim and a close relative, he has three rights over us: neighbourliness, Islam, and kinship. If he is a Muslim with no kinship to us, he has two rights. If he is a non-Muslim with no kinship to us, he has one right over us, which is that of neighbourliness. The guest is the one who comes to stay with you in your land while travelling and passing through, so he is a stranger (in need of hospitality). As for the tongue, it is among the most dangerous things against a person, so he must guard his tongue, either by saying good or by keeping silent.',
  'Ce hadith comporte des règles de conduite obligatoires. Faire preuve de générosité (ikrâm) envers le voisin, car celui-ci a des droits sur nous. Les savants ont dit que si le voisin est musulman et un proche parent, il a sur nous trois droits : le voisinage, l''Islam et la parenté. S''il est un musulman sans lien de parenté avec nous, il jouit de deux droits. Si c''est un non-musulman sans lien de parenté, il a sur nous un seul droit, celui du voisinage. L''hôte est celui qui vient s''installer chez toi dans ton pays alors qu''il voyage et est de passage ; il est donc un étranger (qu''il faut accueillir). Quant à la langue, c''est ce qu''il y a de plus dangereux contre l''homme ; il doit donc surveiller sa langue, en disant du bien ou en observant le silence.',
  'يتضمن هذا الحديث آداباً واجبة. ومنها إكرام الجار، فإن للجار علينا حقوقاً. قال العلماء: إن كان الجار مسلماً قريباً فله علينا ثلاثة حقوق: الجوار والإسلام والقرابة. وإن كان مسلماً ليس بينه وبيننا قرابة فله حقان. وإن كان كافراً ليس بينه وبيننا قرابة فله علينا حق واحد، وهو حق الجوار. والضيف هو الذي ينزل عندك في بلدك وهو مسافر عابر سبيل، فهو غريب (يحتاج إلى الإكرام). وأما اللسان فهو من أخطر ما يكون على الإنسان، فعليه أن يحفظ لسانه بأن يقول خيراً أو يصمت.',
  'Dieser Hadith enthält verpflichtende Verhaltensregeln. Dazu gehört, dem Nachbarn gegenüber Großzügigkeit (Ikram) zu zeigen, denn der Nachbar hat Rechte über uns. Die Gelehrten sagten: Ist der Nachbar ein Muslim und ein naher Verwandter, so hat er drei Rechte über uns: Nachbarschaft, Islam und Verwandtschaft. Ist er ein Muslim ohne Verwandtschaft zu uns, so hat er zwei Rechte. Ist er ein Nicht-Muslim ohne Verwandtschaft zu uns, so hat er ein einziges Recht über uns, nämlich das der Nachbarschaft. Der Gast ist derjenige, der bei dir in deinem Land Aufenthalt nimmt, während er reist und durchzieht; er ist also ein Fremder (der der Gastfreundschaft bedarf). Was die Zunge betrifft, so gehört sie zum Gefährlichsten für den Menschen; er muss daher seine Zunge hüten, indem er Gutes sagt oder schweigt.',
  'Deze hadith bevat verplichte gedragsregels. Daartoe behoort het tonen van vrijgevigheid (ikram) jegens de buurman, want de buurman heeft rechten op ons. De geleerden zeiden: is de buurman een moslim en een nauwe verwant, dan heeft hij drie rechten op ons: nabuurschap, islam en verwantschap. Is hij een moslim zonder verwantschap met ons, dan heeft hij twee rechten. Is hij een niet-moslim zonder verwantschap, dan heeft hij één recht op ons, namelijk dat van nabuurschap. De gast is degene die bij jou in jouw land verblijft terwijl hij reist en doortrekt; hij is dus een vreemdeling (die gastvrijheid behoeft). Wat de tong betreft, die behoort tot het gevaarlijkste voor de mens; hij moet dus zijn tong hoeden, door iets goeds te zeggen of te zwijgen.',
  'Bu hadis, yapılması gereken edep kurallarını içerir. Bunlardan biri komşuya ikramda bulunmaktır; zira komşunun bizim üzerimizde hakları vardır. Âlimler dediler ki: komşu Müslüman ve yakın akraba ise, üzerimizde üç hakkı vardır: komşuluk, İslâm ve akrabalık. Bizimle akrabalığı olmayan bir Müslüman ise iki hakkı vardır. Bizimle akrabalığı olmayan bir gayrimüslim ise üzerimizde tek bir hakkı vardır, o da komşuluk hakkıdır. Misafir, yolculuk hâlinde, gelip geçerken senin ülkende yanında konaklayan kimsedir; dolayısıyla o bir gariptir (ikrama muhtaçtır). Dile gelince, o insan için en tehlikeli şeylerdendir; bu yüzden ya hayır söyleyerek ya da susarak dilini korumalıdır.',
  'Hadis ini mengandung adab-adab yang wajib. Di antaranya memuliakan tetangga, karena tetangga memiliki hak-hak atas kita. Para ulama berkata: jika tetangga itu seorang muslim dan kerabat dekat, maka ia memiliki tiga hak atas kita: hak ketetanggaan, hak keislaman, dan hak kekerabatan. Jika ia seorang muslim yang tidak memiliki hubungan kekerabatan dengan kita, maka ia memiliki dua hak. Jika ia seorang non-muslim yang tidak memiliki hubungan kekerabatan, maka ia memiliki satu hak atas kita, yaitu hak ketetanggaan. Tamu adalah orang yang singgah di tempatmu di negerimu sedang ia dalam perjalanan dan sekadar lewat, maka ia adalah orang asing (yang membutuhkan penghormatan). Adapun lisan, ia termasuk perkara yang paling berbahaya bagi manusia, maka hendaklah ia menjaga lisannya dengan mengucapkan kebaikan atau diam.',
  'یہ حدیث واجب آداب پر مشتمل ہے۔ ان میں سے پڑوسی کے ساتھ اکرام کرنا ہے، کیونکہ پڑوسی کے ہم پر حقوق ہیں۔ علماء نے کہا: اگر پڑوسی مسلمان اور قریبی رشتہ دار ہو تو اس کے ہم پر تین حقوق ہیں: پڑوس، اسلام اور قرابت۔ اگر وہ مسلمان ہو لیکن ہمارے ساتھ کوئی رشتہ داری نہ ہو تو اس کے دو حقوق ہیں۔ اگر وہ غیر مسلم ہو اور ہمارے ساتھ کوئی رشتہ داری نہ ہو تو اس کا ہم پر ایک ہی حق ہے، وہ پڑوس کا حق ہے۔ مہمان وہ ہے جو سفر کی حالت میں گزرتے ہوئے تیرے ملک میں تیرے ہاں قیام کرے، پس وہ ایک اجنبی ہے (جو اکرام کا محتاج ہے)۔ رہی زبان تو وہ انسان کے لیے سب سے خطرناک چیزوں میں سے ہے، لہٰذا اسے چاہیے کہ اپنی زبان کی حفاظت کرے، یا تو اچھی بات کہے یا خاموش رہے۔',
  'এই হাদীসটি ওয়াজিব আদব সম্বলিত। তার মধ্যে রয়েছে প্রতিবেশীর প্রতি সম্মান (ইকরাম) প্রদর্শন, কারণ প্রতিবেশীর আমাদের ওপর অধিকার রয়েছে। আলেমগণ বলেছেন: প্রতিবেশী যদি মুসলিম ও নিকটাত্মীয় হয়, তবে আমাদের ওপর তার তিনটি অধিকার: প্রতিবেশিত্ব, ইসলাম ও আত্মীয়তা। যদি সে মুসলিম হয় কিন্তু আমাদের সাথে আত্মীয়তা না থাকে, তবে তার দুটি অধিকার। যদি সে অমুসলিম হয় এবং আমাদের সাথে আত্মীয়তা না থাকে, তবে আমাদের ওপর তার একটি অধিকার, তা হলো প্রতিবেশিত্বের অধিকার। মেহমান হলো সেই ব্যক্তি যে সফরের অবস্থায় পথ অতিক্রমকালে তোমার দেশে তোমার নিকট অবস্থান করে, সুতরাং সে একজন অপরিচিত (যে সম্মানের মুখাপেক্ষী)। আর জিহ্বা, তা মানুষের জন্য সবচেয়ে বিপজ্জনক জিনিসগুলোর অন্তর্ভুক্ত, সুতরাং তার উচিত নিজের জিহ্বা সংযত রাখা, হয় ভালো কথা বলা নয়তো চুপ থাকা।',
  'Hadis ini mengandungi adab-adab yang wajib. Antaranya memuliakan jiran, kerana jiran mempunyai hak-hak ke atas kita. Para ulama berkata: jika jiran itu seorang Muslim dan kerabat dekat, maka dia mempunyai tiga hak ke atas kita: hak kejiranan, hak keislaman, dan hak kekerabatan. Jika dia seorang Muslim yang tiada hubungan kekerabatan dengan kita, maka dia mempunyai dua hak. Jika dia seorang bukan Islam yang tiada hubungan kekerabatan, maka dia mempunyai satu hak ke atas kita, iaitu hak kejiranan. Tetamu ialah orang yang singgah di tempatmu di negerimu sedang dia dalam perjalanan dan sekadar lalu, maka dia ialah orang asing (yang memerlukan penghormatan). Adapun lidah, ia termasuk perkara yang paling berbahaya bagi manusia, maka hendaklah dia menjaga lidahnya dengan mengucapkan kebaikan atau diam.',
  'Этот хадис содержит обязательные правила поведения. Среди них — проявление щедрости (икрам) к соседу, ибо у соседа есть права над нами. Учёные сказали: если сосед — мусульманин и близкий родственник, у него три права над нами: соседство, ислам и родство. Если он мусульманин, не состоящий с нами в родстве, у него два права. Если он немусульманин, не состоящий с нами в родстве, у него одно право над нами — право соседства. Гость — это тот, кто останавливается у тебя в твоей земле, будучи путником и проезжающим, и потому он чужестранец (нуждающийся в гостеприимстве). Что же касается языка, то он среди самого опасного для человека, поэтому он должен оберегать свой язык, говоря благое или храня молчание.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-15-Nawawi-Psalmodie-Arabe.mp3',
  5,
  15
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 15
);
