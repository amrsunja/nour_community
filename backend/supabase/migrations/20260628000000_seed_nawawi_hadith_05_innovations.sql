-- =============================================================================
-- 40 Hadith Nawawi — Hadith 5: "Rejecting innovations" (al-bidʿah)
-- Target collection: public.hadith_collections.id = 2  /  position = 5
-- Idempotent guard on (collection, position). All 11 content languages.
-- Arabic source cleaned: isnad order restored, Muslim variant included.
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
  'Rejecting innovations',
  'Le rejet des innovations',
  'إبطال المنكرات والبدع',
  'Die Zurückweisung von Neuerungen',
  'De afwijzing van innovaties',
  'Bidatlerin reddedilmesi',
  'Menolak perkara baru (bidah)',
  'بدعات کا رد',
  'বিদআত প্রত্যাখ্যান',
  'Menolak perkara bidaah',
  'Отвержение нововведений',
  -- arabic_text (cleaned, with Muslim variant)
  'عَنْ أُمِّ الْمُؤْمِنِينَ أُمِّ عَبْدِ اللَّهِ عَائِشَةَ رَضِيَ اللَّهُ عَنْهَا قَالَتْ: قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: «مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ مِنْهُ فَهُوَ رَدٌّ». رَوَاهُ الْبُخَارِيُّ وَمُسْلِمٌ. وَفِي رِوَايَةٍ لِمُسْلِمٍ: «مَنْ عَمِلَ عَمَلًا لَيْسَ عَلَيْهِ أَمْرُنَا فَهُوَ رَدٌّ»',
  -- transcription
  'ʿan ummi l-muʾminīna ummi ʿAbdi Llāhi ʿĀʾishata raḍiya Llāhu ʿanhā qālat: qāla Rasūlu Llāhi ṣalla Llāhu ʿalayhi wa-sallama: man aḥdatha fī amrinā hādhā mā laysa minhu fa-huwa radd. rawāhu l-Bukhāriyyu wa-Muslimun. wa-fī riwāyatin li-Muslimin: man ʿamila ʿamalan laysa ʿalayhi amrunā fa-huwa radd.',
  'ʿan oummi l-mouʾminîna oummi ʿAbdi Llâhi ʿÂʾichata (radia Llâhou ʿanhâ) qâlat : qâla Rassôlou Llâhi (salla Llâhou ʿalayhi wa sallam) : man ahdatha fî amrinâ hâdhâ mâ laysa minhou fa-houwa radd. rawâhou l-Boukhâriyyou wa Mouslimoun. wa fî riwâyatin li-Mouslimin : man ʿamila ʿamalan laysa ʿalayhi amrounâ fa-houwa radd.',
  'ʿan ummi l-muʾminīna ummi ʿAbdi Llāhi ʿĀʾischata (radiya Llāhu ʿanhā) qālat: qāla Rasūlu Llāhi (salla Llāhu ʿalaihi wa-sallam): man ahdatha fī amrinā hādhā mā laisa minhu fa-huwa radd. rawāhu l-Buchārijju wa-Muslimun. wa-fī riwājatin li-Muslimin: man ʿamila ʿamalan laisa ʿalaihi amrunā fa-huwa radd.',
  'ʿan oemmi l-moeʾminiena oemmi ʿAbdi Llaahi ʿAaʾisjata (radia Llaahoe ʿanhaa) qaalat: qaala Rasoeloe Llaahi (salla Llaahoe ʿalaihi wa-sallam): man ahdatha fie amrinaa haadhaa maa laisa minhoe fa-hoewa radd. rawaahoe l-Boechaarijjoe wa-Moeslimoen. wa-fie riwaajatin li-Moeslimin: man ʿamila ʿamalan laisa ʿalaihi amroenaa fa-hoewa radd.',
  'mü''minlerin annesi, Abdullah''ın annesi Âişe''den (radıyallâhu anhâ) rivayetle dedi ki: Resûlullah (s.a.v.) şöyle buyurdu: men ahdese fî emrinâ hâzâ mâ leyse minhu fe-huve redd. Buhârî ve Müslim rivayet etti. Müslim''in bir rivayetinde: men amile amelen leyse aleyhi emrunâ fe-huve redd.',
  'ʿan ummil-muʾminīn ummi ʿAbdillāh ʿĀʾisyah (radhiyallāhu ʿanhā) berkata: Rasulullah (shallallāhu ʿalaihi wa sallam) bersabda: man ahdatsa fī amrinā hādzā mā laisa minhu fahuwa radd. Diriwayatkan oleh Al-Bukhari dan Muslim. Dalam riwayat Muslim: man ʿamila ʿamalan laisa ʿalaihi amrunā fahuwa radd.',
  'ام المومنین ام عبد اللہ عائشہ رضی اللہ عنہا سے روایت ہے، انہوں نے کہا: رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: مَن اَحدَثَ فی اَمرِنا ہٰذا ما لَیسَ مِنہُ فَہُوَ رَدّ۔ اسے بخاری اور مسلم نے روایت کیا۔ مسلم کی ایک روایت میں ہے: مَن عَمِلَ عَمَلًا لَیسَ عَلَیہِ اَمرُنا فَہُوَ رَدّ۔',
  'উম্মুল মুমিনীন উম্মে আবদিল্লাহ আয়েশা (রাদিয়াল্লাহু আনহা) থেকে বর্ণিত, তিনি বলেন: রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: মান আহদাসা ফী আমরিনা হাযা মা লাইসা মিনহু ফাহুয়া রাদ্দ। বুখারী ও মুসলিম এটি বর্ণনা করেছেন। মুসলিমের এক বর্ণনায়: মান আমিলা আমালান লাইসা আলাইহি আমরুনা ফাহুয়া রাদ্দ।',
  'ʿan ummil-muʾminīn ummi ʿAbdillāh ʿĀʾisyah (radhiallāhu ʿanhā) berkata: Rasulullah (sallallāhu ʿalaihi wa sallam) bersabda: man ahdatsa fī amrinā hādzā mā laisa minhu fahuwa radd. Diriwayatkan oleh Al-Bukhari dan Muslim. Dalam riwayat Muslim: man ʿamila ʿamalan laisa ʿalaihi amrunā fahuwa radd.',
  'Ан умми ль-муʾминина умми Абдиллях Аиши (да будет доволен ею Аллах) сказала: Посланник Аллаха ﷺ сказал: ман ахдаса фи амрина хаза ма ляйса минху фа-хува радд. Передали аль-Бухари и Муслим. В версии Муслима: ман амиля амалян ляйса аляйхи амруна фа-хува радд.',
  -- translation
  'On the authority of the Mother of the Believers, Umm ʿAbd Allah ʿAisha (may Allah be pleased with her), the Messenger of Allah ﷺ said: "Whoever introduces into this affair of ours something that is not part of it, it is rejected." And in the version of Muslim: "Whoever performs a deed that is not in accordance with our affair, it is rejected."',
  'D''après la mère des croyants Umm ʿAbd Allah ʿAïcha (qu''Allah l''agrée), l''Envoyé d''Allah ﷺ a dit : « Quiconque introduit dans notre affaire (la religion) une chose nouvelle qui n''en fait pas partie, celle-ci est rejetée. » Et dans la version de Muslim : « Celui qui accomplit un acte qui n''est pas conforme à notre affaire, son acte est rejeté. »',
  'Nach der Mutter der Gläubigen, Umm ʿAbd Allah ʿAischa (möge Allah mit ihr zufrieden sein), sagte der Gesandte Allahs ﷺ: „Wer in diese unsere Angelegenheit etwas einführt, das nicht dazugehört, der wird zurückgewiesen." Und in der Überlieferung Muslims: „Wer eine Tat verrichtet, die nicht unserer Angelegenheit entspricht, der wird zurückgewiesen."',
  'Op gezag van de moeder der gelovigen, Umm ʿAbd Allah ʿAisha (moge Allah tevreden met haar zijn), zei de Boodschapper van Allah ﷺ: „Wie in deze zaak van ons iets invoert dat er geen deel van uitmaakt, dat wordt verworpen." En in de overlevering van Muslim: „Wie een daad verricht die niet in overeenstemming is met onze zaak, dat wordt verworpen."',
  'Mü''minlerin annesi Ümmü Abdillâh Âişe''den (Allah ondan razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Kim bizim bu işimizde (dinimizde) ondan olmayan bir şey ortaya çıkarırsa, o reddedilir." Müslim''in rivayetinde ise: „Kim bizim işimize uygun olmayan bir amel işlerse, o reddedilir."',
  'Dari Ummul Mukminin Ummu Abdillah Aisyah (semoga Allah meridhainya), Rasulullah ﷺ bersabda: "Barangsiapa mengada-adakan dalam urusan kami ini (agama) sesuatu yang bukan darinya, maka ia tertolak." Dan dalam riwayat Muslim: "Barangsiapa melakukan suatu amal yang tidak sesuai dengan urusan kami, maka ia tertolak."',
  'ام المومنین ام عبد اللہ عائشہ رضی اللہ عنہا سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”جو شخص ہمارے اس دین میں کوئی ایسی نئی چیز ایجاد کرے جو اس میں سے نہیں، تو وہ مردود ہے۔“ اور مسلم کی روایت میں ہے: ”جو شخص کوئی ایسا عمل کرے جس پر ہمارا حکم نہیں، تو وہ مردود ہے۔“',
  'উম্মুল মুমিনীন উম্মে আবদিল্লাহ আয়েশা (রাদিয়াল্লাহু আনহা) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "যে ব্যক্তি আমাদের এই দ্বীনের মধ্যে এমন কিছু নতুন উদ্ভাবন করে যা তার অন্তর্ভুক্ত নয়, তা প্রত্যাখ্যাত।" আর মুসলিমের বর্ণনায়: "যে ব্যক্তি এমন আমল করে যা আমাদের নির্দেশের অনুরূপ নয়, তা প্রত্যাখ্যাত।"',
  'Daripada Ummul Mukminin Ummu Abdillah Aisyah (semoga Allah meredainya), Rasulullah ﷺ bersabda: "Sesiapa yang mengada-adakan dalam urusan kami ini (agama) sesuatu yang bukan daripadanya, maka ia tertolak." Dan dalam riwayat Muslim: "Sesiapa yang melakukan sesuatu amalan yang tidak menepati urusan kami, maka ia tertolak."',
  'Со слов матери верующих Умм ʿАбдиллях ʿАиши (да будет доволен ею Аллах) Посланник Аллаха ﷺ сказал: «Кто внесёт в это наше дело (религию) то, что не относится к нему, — это будет отвергнуто». А в версии Муслима: «Кто совершит деяние, не соответствующее нашему делу, — это будет отвергнуто».',
  -- reference
  'Sahih — reported by Al-Bukhari (5/301, no. 2697) and Muslim (3/1343)',
  'Hadith authentique rapporté par Al-Bukhari (5/301, n°2697) et Muslim (3/1343)',
  'حديث صحيح، رواه البخاري (٥/٣٠١) (رقم ٢٦٩٧) ومسلم (٣/١٣٤٣)',
  'Sahih — überliefert von Al-Bukhari (5/301, Nr. 2697) und Muslim (3/1343)',
  'Sahih — overgeleverd door Al-Bukhari (5/301, nr. 2697) en Muslim (3/1343)',
  'Sahih — Buhârî (5/301, no. 2697) ve Müslim (3/1343) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (5/301, no. 2697) dan Muslim (3/1343)',
  'صحیح حدیث، اسے بخاری (۵/۳۰۱، نمبر ۲۶۹۷) اور مسلم (۳/۱۳۴۳) نے روایت کیا',
  'সহীহ হাদীস — বুখারী (৫/৩০১, নং ২৬৯৭) ও মুসলিম (৩/১৩৪৩) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (5/301, no. 2697) dan Muslim (3/1343)',
  'Достоверный хадис, передали аль-Бухари (5/301, № 2697) и Муслим (3/1343)',
  -- tafsir
  'Some scholars said that this hadith is the scale for the outward aspect of deeds, while the hadith at the beginning of this treatise ("Actions are but by intentions") is the scale for the inward aspect of deeds; for every deed comprises an intention and an outward form:\n• The outward form is the apparent aspect of the deed.\n• The intention is the inner aspect of the deed.',
  'Des savants ont dit que ce hadith est la balance du côté apparent des actes, tandis que le hadith placé au début de cet opuscule (« Les actes ne valent que par les intentions ») est la balance du côté profond des actes ; car l''acte comporte une intention et un aspect :\n• L''aspect est le côté apparent de l''acte.\n• L''intention est le côté profond de l''acte.',
  'قال بعض العلماء إن هذا الحديث ميزان الأعمال من جهة الظاهر، والحديث الذي في أول هذا الكتاب («إنما الأعمال بالنيات») ميزان الأعمال من جهة الباطن؛ لأن العمل يتضمن نية وصورة:\n• الصورة هي ظاهر العمل.\n• النية هي باطن العمل.',
  'Manche Gelehrte sagten, dass dieser Hadith die Waage für den äußeren Aspekt der Taten ist, während der Hadith am Anfang dieser Abhandlung („Die Taten zählen nur entsprechend den Absichten") die Waage für den inneren Aspekt der Taten ist; denn jede Tat umfasst eine Absicht und eine Gestalt:\n• Die Gestalt ist der äußere Aspekt der Tat.\n• Die Absicht ist der innere Aspekt der Tat.',
  'Sommige geleerden zeiden dat deze hadith de weegschaal is voor het uiterlijke aspect van de daden, terwijl de hadith aan het begin van dit werk („Daden worden slechts beoordeeld naar de intenties") de weegschaal is voor het innerlijke aspect van de daden; want elke daad omvat een intentie en een vorm:\n• De vorm is het uiterlijke aspect van de daad.\n• De intentie is het innerlijke aspect van de daad.',
  'Bazı âlimler dediler ki: bu hadis, amellerin zâhirî yönünün ölçüsüdür; bu kitabın başındaki hadis ise („Ameller ancak niyetlere göredir") amellerin bâtınî yönünün ölçüsüdür; zira amel bir niyet ve bir sûret içerir:\n• Sûret, amelin zâhir (görünen) yönüdür.\n• Niyet, amelin bâtın (iç) yönüdür.',
  'Sebagian ulama berkata bahwa hadis ini adalah timbangan amal dari sisi lahir, sedangkan hadis di awal kitab ini ("Sesungguhnya setiap amal tergantung pada niatnya") adalah timbangan amal dari sisi batin; karena amal mengandung niat dan bentuk:\n• Bentuk adalah sisi lahir dari amal.\n• Niat adalah sisi batin dari amal.',
  'بعض علماء نے کہا ہے کہ یہ حدیث اعمال کے ظاہری پہلو کی میزان ہے، اور اس کتاب کے شروع والی حدیث (”اعمال کا دارومدار نیتوں پر ہے“) اعمال کے باطنی پہلو کی میزان ہے؛ کیونکہ ہر عمل نیت اور صورت پر مشتمل ہوتا ہے:\n• صورت عمل کا ظاہری پہلو ہے۔\n• نیت عمل کا باطنی پہلو ہے۔',
  'কিছু আলেম বলেছেন যে এই হাদীসটি আমলের প্রকাশ্য দিকের মানদণ্ড, আর এই গ্রন্থের শুরুর হাদীসটি ("কাজের ফলাফল নিয়তের উপর নির্ভরশীল") আমলের অভ্যন্তরীণ দিকের মানদণ্ড; কারণ প্রতিটি আমল একটি নিয়ত ও একটি রূপ ধারণ করে:\n• রূপ হলো আমলের প্রকাশ্য দিক।\n• নিয়ত হলো আমলের অভ্যন্তরীণ দিক।',
  'Sebahagian ulama berkata bahawa hadis ini ialah neraca amal dari sudut zahir, manakala hadis di awal kitab ini ("Sesungguhnya setiap amalan bergantung pada niat") ialah neraca amal dari sudut batin; kerana setiap amal mengandungi niat dan bentuk:\n• Bentuk ialah sudut zahir bagi amal.\n• Niat ialah sudut batin bagi amal.',
  'Некоторые учёные сказали, что этот хадис — мера внешней стороны деяний, тогда как хадис в начале этого труда («Поистине, дела оцениваются по намерениям») — мера внутренней стороны деяний; ибо каждое деяние заключает в себе намерение и форму:\n• Форма — это внешняя сторона деяния.\n• Намерение — это внутренняя сторона деяния.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-5-Nawawi-Psalmodie-Arabe.mp3',
  5,
  5
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 5
);
