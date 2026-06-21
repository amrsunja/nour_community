-- =============================================================================
-- 40 Hadith Nawawi — Hadith 32: "No harm and no reciprocating harm"
-- Target collection: public.hadith_collections.id = 2  /  position = 32
-- Idempotent guard on (collection, position). All 11 content languages.
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
  'No harm and no reciprocating harm',
  'Ne faites pas de mal, et ne rendez pas le mal pour le mal',
  'لا ضرر ولا ضرار',
  'Kein Schaden und keine Schadenszufügung',
  'Geen schade en geen schade toebrengen',
  'Zarar vermek de zararla karşılık vermek de yoktur',
  'Tidak boleh memudaratkan dan tidak boleh dimudaratkan',
  'نہ نقصان پہنچانا، نہ بدلے میں نقصان',
  'ক্ষতি করা যাবে না, পাল্টা ক্ষতিও নয়',
  'Tidak boleh memudaratkan dan tidak boleh dimudaratkan',
  'Нет вреда и нет причинения вреда в ответ',
  -- arabic_text
  'عَنْ أَبِي سَعِيدٍ سَعْدِ بْنِ مَالِكِ بْنِ سِنَانٍ الْخُدْرِيِّ رَضِيَ اللَّهُ عَنْهُ أَنَّ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ قَالَ: «لَا ضَرَرَ وَلَا ضِرَارَ»',
  -- transcription
  'ʿan Abī Saʿīdin Saʿdi bni Māliki bni Sinānin al-Khudriyyi raḍiya Llāhu ʿanhu anna Rasūla Llāhi ṣalla Llāhu ʿalayhi wa-sallama qāla: lā ḍarara wa-lā ḍirāra.',
  'ʿan Abî Saʿîdin Saʿdi bni Mâliki bni Sinânin al-Khoudriyyi (radia Llâhou ʿanhou) anna Rassôla Llâhi (salla Llâhou ʿalayhi wa sallam) qâla : lâ darara wa lâ dirâra.',
  'ʿan Abī Saʿīdin Saʿdi bni Māliki bni Sinānin al-Chudrijji (radiya Llāhu ʿanhu) anna Rasūla Llāhi (salla Llāhu ʿalaihi wa-sallam) qāla: lā darara wa-lā dirāra.',
  'ʿan Abie Saʿiedin Saʿdi bni Maaliki bni Sinaanin al-Choedrijji (radia Llaahoe ʿanhoe) anna Rasoela Llaahi (salla Llaahoe ʿalaihi wa-sallam) qaala: laa darara wa-laa diraara.',
  'an Ebû Saʿîd Saʿd ibn Mâlik ibn Sinân el-Hudrî''den (radıyallâhu anh), Resûlullah''ın (s.a.v.) şöyle buyurduğu rivayet edilmiştir: lâ darara ve lâ dırâr (ne zarar vermek vardır ne de zararla karşılık vermek).',
  'an Abi Saʿid Saʿd bin Malik bin Sinan al-Khudri (radhiyallahu ʿanhu) bahwa Rasulullah (shallallahu ʿalaihi wa sallam) bersabda: lā dharara wa lā dhirar (tidak boleh memudaratkan dan tidak boleh saling memudaratkan).',
  'ابو سعید سعد بن مالک بن سنان الخدری رضی اللہ عنہ سے روایت ہے کہ رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: لا ضَرَرَ وَلا ضِرارَ (نہ نقصان پہنچانا ہے اور نہ بدلے میں نقصان)۔',
  'আবু সাঈদ সাদ ইবনে মালিক ইবনে সিনান আল-খুদরী (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত যে রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: লা দারারা ওয়া লা দিরার (ক্ষতি করা যাবে না, পাল্টা ক্ষতিও নয়)।',
  'an Abi Saʿid Saʿd bin Malik bin Sinan al-Khudri (radhiallahu ʿanhu) bahawa Rasulullah (sallallahu ʿalaihi wa sallam) bersabda: lā dharara wa lā dhirar (tidak boleh memudaratkan dan tidak boleh saling memudaratkan).',
  'От Аби Саида Саада ибн Малика ибн Синана аль-Худри (да будет доволен им Аллах) передаётся, что Посланник Аллаха ﷺ сказал: ля дарара ва ля дирар (нет вреда и нет причинения вреда в ответ).',
  -- translation
  'On the authority of Abu Saʿid Saʿd ibn Malik ibn Sinan al-Khudri (may Allah be pleased with him), the Messenger of Allah ﷺ said: "There should be neither harming (darar) nor reciprocating harm (dirar)."',
  'D''après Abû Saʿîd Saʿd ibn Mâlik ibn Sinân al-Khudrî (qu''Allah l''agrée), l''Envoyé d''Allah ﷺ a dit : « Il n''y a ni préjudice (darar) ni préjudice en retour (dirar). »',
  'Nach Abu Saʿid Saʿd ibn Malik ibn Sinan al-Khudri (möge Allah mit ihm zufrieden sein) sagte der Gesandte Allahs ﷺ: „Es soll weder Schaden (Darar) noch Schadenszufügung als Vergeltung (Dirar) geben."',
  'Op gezag van Abu Saʿid Saʿd ibn Malik ibn Sinan al-Khudri (moge Allah tevreden met hem zijn) zei de Boodschapper van Allah ﷺ: „Er mag noch schade (darar) zijn, noch schade in vergelding (dirar)."',
  'Ebû Saʿîd Saʿd ibn Mâlik ibn Sinân el-Hudrî''den (Allah ondan razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Ne zarar vermek vardır, ne de zararla karşılık vermek."',
  'Dari Abu Saʿid Saʿd bin Malik bin Sinan al-Khudri (semoga Allah meridhainya), Rasulullah ﷺ bersabda: "Tidak boleh memudaratkan dan tidak boleh (membalas dengan) memudaratkan."',
  'ابو سعید سعد بن مالک بن سنان الخدری رضی اللہ عنہ سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”نہ (ابتداءً) کسی کو نقصان پہنچایا جائے اور نہ (بدلے میں) نقصان پہنچایا جائے۔“',
  'আবু সাঈদ সাদ ইবনে মালিক ইবনে সিনান আল-খুদরী (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "ক্ষতি করা যাবে না এবং পাল্টা ক্ষতিও করা যাবে না।"',
  'Daripada Abu Saʿid Saʿd bin Malik bin Sinan al-Khudri (semoga Allah meredainya), Rasulullah ﷺ bersabda: "Tidak boleh memudaratkan dan tidak boleh (membalas dengan) memudaratkan."',
  'Со слов Абу Саида Саада ибн Малика ибн Синана аль-Худри (да будет доволен им Аллах) Посланник Аллаха ﷺ сказал: «Не должно быть ни (причинения) вреда, ни вреда в ответ».',
  -- reference
  'Hasan — reported by Ibn Majah (no. 2340-2341), Ahmad (1/313), al-Bayhaqi (6/69-70, 457), al-Hakim (2/57-58), and others; also by Malik in al-Muwatta as mursal',
  'Hadith hasan rapporté par Ibn Mâja (n°2340-2341), Ahmad (1/313), al-Bayhaqî (6/69-70, 457), al-Hâkim (2/57-58) et d''autres ; également par Mâlik dans al-Muwatta sous forme mursal',
  'حديث حسن، رواه ابن ماجه (رقم ٢٣٤٠-٢٣٤١) وأحمد (١/٣١٣) والبيهقي (٦/٦٩-٧٠، ٤٥٧) والحاكم (٢/٥٧-٥٨) وغيرهم، ورواه مالك في الموطأ مرسلاً',
  'Hasan — überliefert von Ibn Madscha (Nr. 2340-2341), Ahmad (1/313), al-Bayhaqi (6/69-70, 457), al-Hakim (2/57-58) und anderen; auch von Malik im al-Muwatta als mursal',
  'Hasan — overgeleverd door Ibn Madja (nr. 2340-2341), Ahmad (1/313), al-Bayhaqi (6/69-70, 457), al-Hakim (2/57-58) en anderen; ook door Malik in al-Muwatta als mursal',
  'Hasen — İbn Mâce (no. 2340-2341), Ahmed (1/313), Beyhakî (6/69-70, 457), Hâkim (2/57-58) ve diğerleri rivayet etmiştir; ayrıca Mâlik el-Muvatta''da mürsel olarak rivayet etmiştir',
  'Hadis hasan, diriwayatkan oleh Ibnu Majah (no. 2340-2341), Ahmad (1/313), al-Baihaqi (6/69-70, 457), al-Hakim (2/57-58), dan lainnya; juga oleh Malik dalam al-Muwatta secara mursal',
  'حسن حدیث، اسے ابن ماجہ (نمبر ۲۳۴۰-۲۳۴۱)، احمد (۱/۳۱۳)، بیہقی (۶/۶۹-۷۰، ۴۵۷)، حاکم (۲/۵۷-۵۸) وغیرہ نے روایت کیا، اور مالک نے الموطأ میں مرسلاً روایت کیا',
  'হাসান হাদীস — ইবনে মাজাহ (নং ২৩৪০-২৩৪১), আহমাদ (১/৩১৩), বায়হাকী (৬/৬৯-৭০, ৪৫৭), হাকিম (২/৫৭-৫৮) প্রমুখ বর্ণনা করেছেন; মালিকও আল-মুওয়াত্তায় মুরসাল হিসেবে বর্ণনা করেছেন',
  'Hadis hasan, diriwayatkan oleh Ibnu Majah (no. 2340-2341), Ahmad (1/313), al-Baihaqi (6/69-70, 457), al-Hakim (2/57-58), dan lain-lain; juga oleh Malik dalam al-Muwatta secara mursal',
  'Хороший (хасан) хадис, передали Ибн Маджа (№ 2340-2341), Ахмад (1/313), аль-Байхаки (6/69-70, 457), аль-Хаким (2/57-58) и другие; также Малик в «аль-Муватта» в форме мурсаль',
  -- tafsir
  'When a man waters a tree in his house and the water passes over to his neighbour''s property without the first man intending it — perhaps without even being aware of what happened — Islamic law requires him to repair the damage caused by the water once he is informed of it. If the owner of the tree says he did not do it deliberately, he is told nonetheless: even so, all harm is unlawful (and must be remedied).\nAs for deliberate harm (dirar), it is when a man seeks to injure his neighbour. The scholars have indeed derived from this hadith many juristic rules (a foundational principle of Islamic jurisprudence).',
  'Quand un homme arrose un arbre dans sa maison et que l''eau passe chez son voisin sans intention de sa part — peut-être même sans qu''il soit au courant de ce qui s''est passé — la loi islamique exige qu''il répare les dommages causés par l''eau une fois mis au courant. Si le propriétaire de l''arbre dit qu''il ne l''a pas fait volontairement, il lui sera dit malgré tout : même ainsi, tout préjudice est illicite (et doit être réparé).\nQuant au préjudice volontaire (dirar), c''est quand cet homme cherche à nuire à son voisin. Les savants ont d''ailleurs déduit de ce hadith de nombreuses règles jurisprudentielles (c''est un principe fondateur de la jurisprudence islamique).',
  'إذا سقى رجل شجرة في بيته ومرّ الماء إلى جاره دون قصد منه — وربما دون أن يعلم بما حدث — فإن الشريعة الإسلامية تلزمه بإصلاح الضرر الذي سبّبه الماء بمجرد علمه به. وإذا قال صاحب الشجرة إنه لم يفعل ذلك عمداً، يُقال له مع ذلك: ولو كان كذلك، فكل ضرر محرّم (ويجب رفعه).\nوأما الضرار، فهو أن يقصد هذا الرجل الإضرار بجاره. وقد استنبط العلماء من هذا الحديث قواعد فقهية كثيرة (فهو قاعدة أصلية من قواعد الفقه الإسلامي).',
  'Wenn ein Mann einen Baum in seinem Haus bewässert und das Wasser ohne seine Absicht auf das Grundstück seines Nachbarn übertritt — vielleicht ohne dass er überhaupt von dem Vorfall weiß —, verlangt das islamische Recht von ihm, den durch das Wasser verursachten Schaden zu beheben, sobald er davon erfährt. Sagt der Besitzer des Baumes, er habe es nicht absichtlich getan, wird ihm dennoch gesagt: auch dann ist jeder Schaden verboten (und muss behoben werden).\nWas den absichtlichen Schaden (Dirar) betrifft, so ist es, wenn ein Mann seinem Nachbarn zu schaden sucht. Die Gelehrten haben aus diesem Hadith zahlreiche rechtliche Regeln abgeleitet (er ist ein grundlegendes Prinzip der islamischen Rechtswissenschaft).',
  'Wanneer een man een boom in zijn huis water geeft en het water zonder zijn bedoeling overgaat naar het eigendom van zijn buurman — misschien zonder dat hij zelfs maar op de hoogte is van wat er gebeurd is —, vereist het islamitische recht van hem dat hij de door het water veroorzaakte schade herstelt zodra hij ervan op de hoogte is. Zegt de eigenaar van de boom dat hij het niet opzettelijk deed, dan wordt hem niettemin gezegd: ook dan is alle schade verboden (en moet hersteld worden).\nWat de opzettelijke schade (dirar) betreft, dat is wanneer een man zijn buurman tracht te schaden. De geleerden hebben uit deze hadith inderdaad talrijke juridische regels afgeleid (het is een grondbeginsel van de islamitische rechtswetenschap).',
  'Bir adam evindeki bir ağacı sular da su, onun kastı olmadan komşusunun yerine geçerse — belki olup biteni bilmeden bile —, İslâm hukuku, durumu öğrendiğinde suyun yol açtığı zararı gidermesini ona vacip kılar. Ağaç sahibi bunu kasten yapmadığını söylerse, ona yine de denir ki: öyle olsa bile, her zarar haramdır (ve giderilmesi gerekir).\nKasıtlı zarara (dırâr) gelince, bu adamın komşusuna zarar vermeyi kastetmesidir. Nitekim âlimler bu hadisten pek çok fıkhî kaide çıkarmışlardır (bu, İslâm fıkhının temel kaidelerinden biridir).',
  'Apabila seseorang menyiram pohon di rumahnya lalu airnya mengalir ke tempat tetangganya tanpa ia sengaja — bahkan mungkin tanpa ia ketahui apa yang terjadi —, syariat Islam mewajibkannya untuk memperbaiki kerusakan yang ditimbulkan oleh air itu setelah ia mengetahuinya. Jika pemilik pohon berkata bahwa ia tidak melakukannya dengan sengaja, tetap dikatakan kepadanya: sekalipun demikian, setiap kemudaratan adalah haram (dan wajib dihilangkan).\nAdapun memudaratkan dengan sengaja (dhirar), yaitu ketika seseorang bermaksud mencelakai tetangganya. Para ulama telah menyimpulkan dari hadis ini banyak kaidah fikih (ia merupakan kaidah dasar dalam fikih Islam).',
  'جب کوئی شخص اپنے گھر میں کسی درخت کو پانی دے اور پانی بغیر اس کے ارادے کے اس کے پڑوسی کے ہاں چلا جائے — شاید اسے یہ بھی معلوم نہ ہو کہ کیا ہوا —، تو اسلامی شریعت اس بات کا تقاضا کرتی ہے کہ علم ہونے پر وہ پانی سے ہونے والے نقصان کی تلافی کرے۔ اگر درخت کا مالک کہے کہ اس نے جان بوجھ کر نہیں کیا، تو پھر بھی اس سے کہا جائے گا: اگرچہ ایسا ہی ہو، ہر نقصان حرام ہے (اور اسے دور کرنا واجب ہے)۔\nرہا جان بوجھ کر نقصان (ضِرار)، تو یہ ہے کہ یہ شخص اپنے پڑوسی کو نقصان پہنچانے کا ارادہ کرے۔ علماء نے اس حدیث سے بہت سے فقہی قواعد اخذ کیے ہیں (یہ اسلامی فقہ کے بنیادی قواعد میں سے ایک ہے)۔',
  'যখন কোনো ব্যক্তি তার বাড়িতে কোনো গাছে পানি দেয় এবং পানি তার অনিচ্ছায় প্রতিবেশীর জায়গায় চলে যায় — হয়তো সে জানেই না কী ঘটেছে —, তখন ইসলামী শরীয়ত তাকে অবগত হওয়ার পর পানি দ্বারা সৃষ্ট ক্ষতি মেরামত করতে বাধ্য করে। গাছের মালিক যদি বলে যে সে ইচ্ছাকৃতভাবে করেনি, তবুও তাকে বলা হবে: এমন হলেও, প্রতিটি ক্ষতি হারাম (এবং তা দূর করা ওয়াজিব)।\nআর ইচ্ছাকৃত ক্ষতি (দিরার) হলো যখন এই ব্যক্তি তার প্রতিবেশীর ক্ষতি করতে চায়। আলেমগণ প্রকৃতপক্ষে এই হাদীস থেকে বহু ফিকহী নীতি উদ্ভাবন করেছেন (এটি ইসলামী ফিকহের একটি মৌলিক নীতি)।',
  'Apabila seseorang menyiram pokok di rumahnya lalu airnya mengalir ke tempat jirannya tanpa dia sengaja — mungkin tanpa dia ketahui apa yang berlaku —, syariat Islam mewajibkannya memperbaiki kerosakan yang ditimbulkan oleh air itu setelah dia mengetahuinya. Jika pemilik pokok berkata bahawa dia tidak melakukannya dengan sengaja, tetap dikatakan kepadanya: sekalipun demikian, setiap kemudaratan adalah haram (dan wajib dihilangkan).\nAdapun memudaratkan dengan sengaja (dhirar), iaitu ketika seseorang berniat mencelakakan jirannya. Para ulama telah menyimpulkan daripada hadis ini banyak kaedah fiqh (ia merupakan kaedah asas dalam fiqh Islam).',
  'Когда человек поливает дерево в своём дворе, и вода без его намерения переходит во владение соседа — быть может, даже без его осведомлённости о случившемся, — исламский закон обязывает его возместить вред, причинённый водой, как только ему станет известно об этом. Если хозяин дерева скажет, что не сделал этого намеренно, ему всё равно скажут: даже так, всякий вред запретен (и должен быть устранён).\nЧто же касается умышленного вреда (дирар), то это когда человек стремится навредить своему соседу. Учёные вывели из этого хадиса множество правовых правил (это основополагающее правило исламской юриспруденции).',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2023/01/Hadith-32-Nawawi-Psalmodie-Arabe.mp3',
  5,
  32
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 32
);
