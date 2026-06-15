-- =============================================================================
-- 40 Hadith Nawawi — Hadith 41: "The sign of faith (submitting desire to the Sharia)"
-- Target collection: public.hadith_collections.id = 2  /  position = 41
-- Idempotent guard on (collection, position). All 11 content languages.
-- tafsir_* intentionally left NULL (no commentary provided for this hadith).
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
  audio_url, ajr, position
)
select
  2,
  -- title
  'The sign of faith',
  'Le signe de la foi',
  'علامة الإيمان',
  'Das Zeichen des Glaubens',
  'Het teken van geloof',
  'İmanın alâmeti',
  'Tanda iman',
  'ایمان کی علامت',
  'ঈমানের নিদর্শন',
  'Tanda iman',
  'Признак веры',
  -- arabic_text
  'عَنْ أَبِي مُحَمَّدٍ عَبْدِ اللَّهِ بْنِ عَمْرِو بْنِ الْعَاصِ رَضِيَ اللَّهُ عَنْهُمَا قَالَ: قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: «لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يَكُونَ هَوَاهُ تَبَعًا لِمَا جِئْتُ بِهِ»',
  -- transcription
  'ʿan Abī Muḥammadin ʿAbdi Llāhi bni ʿAmri bni l-ʿĀṣi raḍiya Llāhu ʿanhumā qāla: qāla Rasūlu Llāhi ṣalla Llāhu ʿalayhi wa-sallama: lā yuʾminu aḥadukum ḥattā yakūna hawāhu tabaʿan limā jiʾtu bihi.',
  'ʿan Abî Mouhammadin ʿAbdi Llâhi bni ʿAmri bni l-ʿÂsi (radia Llâhou ʿanhoumâ) qâla : qâla Rassôlou Llâhi (salla Llâhou ʿalayhi wa sallam) : lâ youʾminou ahadoukoum hattâ yakôuna hawâhou tabaʿan limâ jiʾtou bihi.',
  'ʿan Abī Muhammadin ʿAbdi Llāhi bni ʿAmri bni l-ʿĀsi (radiya Llāhu ʿanhumā) qāla: qāla Rasūlu Llāhi (salla Llāhu ʿalaihi wa-sallam): lā juʾminu ahadukum hattā jakūna hawāhu tabaʿan limā dschiʾtu bihi.',
  'ʿan Abie Moehammadin ʿAbdi Llaahi bni ʿAmri bni l-ʿAasi (radia Llaahoe ʿanhoemaa) qaala: qaala Rasoeloe Llaahi (salla Llaahoe ʿalaihi wa-sallam): laa joeʾminoe ahadoekoem hattaa jakoena hawaahoe tabaʿan limaa dzjiʾtoe bihi.',
  'an Ebû Muhammed Abdullah ibn Amr ibn el-Âs''tan (radıyallâhu anhümâ) rivayetle dedi ki: Resûlullah (s.a.v.) şöyle buyurdu: sizden biri, hevâsı (arzusu) benim getirdiğime tâbi olmadıkça (gerçek anlamda) iman etmiş olmaz.',
  'an Abi Muhammad ʿAbdillah bin ʿAmr bin al-ʿAsh (radhiyallahu ʿanhuma) berkata: Rasulullah (shallallahu ʿalaihi wa sallam) bersabda: tidaklah (sempurna) iman salah seorang dari kalian hingga hawa nafsunya tunduk mengikuti apa yang aku bawa.',
  'ابو محمد عبد اللہ بن عمرو بن العاص رضی اللہ عنہما سے روایت ہے، انہوں نے کہا: رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: تم میں سے کوئی (کامل) مومن نہیں ہو سکتا جب تک اس کی خواہش اس چیز کے تابع نہ ہو جائے جو میں لے کر آیا ہوں۔',
  'আবু মুহাম্মাদ আবদুল্লাহ ইবনে আমর ইবনুল আস (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত, তিনি বলেন: রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: তোমাদের কেউ (পূর্ণ) মুমিন হবে না যতক্ষণ না তার প্রবৃত্তি আমি যা নিয়ে এসেছি তার অনুগত হয়।',
  'an Abi Muhammad ʿAbdillah bin ʿAmr bin al-ʿAs (radhiallahu ʿanhuma) berkata: Rasulullah (sallallahu ʿalaihi wa sallam) bersabda: tidaklah (sempurna) iman seseorang daripada kamu sehingga hawa nafsunya tunduk mengikuti apa yang aku bawa.',
  'От Аби Мухаммада Абдуллаха ибн Амра ибн аль-Аса (да будет доволен Аллах ими обоими) передаётся, что Посланник Аллаха ﷺ сказал: не уверует (по-настоящему) никто из вас, пока его страсть (хава) не последует за тем, с чем я пришёл.',
  -- translation
  'On the authority of Abu Muhammad ʿAbd Allah ibn ʿAmr ibn al-ʿAs (may Allah be pleased with them both), the Messenger of Allah ﷺ said: "None of you (truly) believes until his desire is subordinate to that which I have brought."',
  'D''après Abû Muhammad ʿAbd Allah ibn ʿAmr ibn al-ʿÂs (qu''Allah les agrée tous deux), l''Envoyé d''Allah ﷺ a dit : « Aucun de vous ne sera (vraiment) croyant tant que ses passions ne se plieront pas à ce que je vous ai apporté. »',
  'Nach Abu Muhammad ʿAbd Allah ibn ʿAmr ibn al-ʿAs (möge Allah mit beiden zufrieden sein) sagte der Gesandte Allahs ﷺ: „Keiner von euch glaubt (wahrhaft), bis sein Begehren dem untergeordnet ist, was ich gebracht habe."',
  'Op gezag van Abu Muhammad ʿAbd Allah ibn ʿAmr ibn al-ʿAs (moge Allah tevreden met hen beiden zijn) zei de Boodschapper van Allah ﷺ: „Niemand van jullie gelooft (waarlijk) totdat zijn verlangen ondergeschikt is aan wat ik heb gebracht."',
  'Ebû Muhammed Abdullah ibn Amr ibn el-Âs''tan (Allah her ikisinden de razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Sizden biri, hevâsı benim getirdiğime tâbi olmadıkça (gerçek anlamda) iman etmiş olmaz."',
  'Dari Abu Muhammad ʿAbdullah bin ʿAmr bin al-ʿAsh (semoga Allah meridhai keduanya), Rasulullah ﷺ bersabda: "Tidaklah (sempurna) iman salah seorang dari kalian hingga hawa nafsunya tunduk mengikuti apa yang aku bawa."',
  'ابو محمد عبد اللہ بن عمرو بن العاص رضی اللہ عنہما سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”تم میں سے کوئی (کامل) مومن نہیں ہو سکتا جب تک اس کی خواہش اس چیز کے تابع نہ ہو جائے جو میں لے کر آیا ہوں۔“',
  'আবু মুহাম্মাদ আবদুল্লাহ ইবনে আমর ইবনুল আস (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "তোমাদের কেউ (পূর্ণ) মুমিন হবে না যতক্ষণ না তার প্রবৃত্তি আমি যা নিয়ে এসেছি তার অনুগত হয়।"',
  'Daripada Abu Muhammad ʿAbdullah bin ʿAmr bin al-ʿAs (semoga Allah meredai keduanya), Rasulullah ﷺ bersabda: "Tidaklah (sempurna) iman seseorang daripada kamu sehingga hawa nafsunya tunduk mengikuti apa yang aku bawa."',
  'Со слов Абу Мухаммада Абдуллаха ибн Амра ибн аль-Аса (да будет доволен Аллах ими обоими) Посланник Аллаха ﷺ сказал: «Не уверует (по-настоящему) никто из вас, пока его страсть не подчинится тому, с чем я пришёл».',
  -- reference
  'Reported by Abu al-Qasim al-Asbahani in Kitab al-Hujja (no. 103), Ibn Battah (no. 279), and al-Baghawi in Sharh as-Sunna (no. 104); some scholars graded it weak (see Ibn Rajab, Jamiʿ al-ʿUlum wa-l-Hikam 2/394, and al-Albani in al-Mishkat no. 167)',
  'Rapporté par Abû al-Qâsim al-Asbahânî dans Kitâb al-Hujja (n°103), Ibn Batta (n°279) et al-Baghawî dans Sharh as-Sunna (n°104) ; certains savants l''ont déclaré faible (voir Ibn Rajab, Jâmiʿ al-ʿUlûm wa-l-Hikam 2/394, et al-Albânî dans al-Mishkât n°167)',
  'رواه أبو القاسم الأصبهاني في كتاب الحجة (رقم ١٠٣) وابن بطة (رقم ٢٧٩) والبغوي في شرح السنة (رقم ١٠٤)، وضعّفه بعض العلماء (انظر ابن رجب في جامع العلوم والحكم ٢/٣٩٤، والألباني في المشكاة رقم ١٦٧)',
  'Überliefert von Abu al-Qasim al-Asbahani in Kitab al-Hujja (Nr. 103), Ibn Battah (Nr. 279) und al-Baghawi in Scharh as-Sunna (Nr. 104); manche Gelehrte stuften ihn als schwach ein (siehe Ibn Radschab, Dschamiʿ al-ʿUlum wa-l-Hikam 2/394, und al-Albani in al-Mischkat Nr. 167)',
  'Overgeleverd door Abu al-Qasim al-Asbahani in Kitab al-Hujja (nr. 103), Ibn Battah (nr. 279) en al-Baghawi in Sharh as-Sunna (nr. 104); sommige geleerden beoordeelden hem als zwak (zie Ibn Rajab, Jamiʿ al-ʿUlum wa-l-Hikam 2/394, en al-Albani in al-Mishkat nr. 167)',
  'Ebü''l-Kâsım el-İsfahânî Kitâbü''l-Hücce''de (no. 103), İbn Batta (no. 279) ve Begavî Şerhü''s-Sünne''de (no. 104) rivayet etmiştir; bazı âlimler zayıf saymıştır (bk. İbn Receb, Câmiu''l-Ulûm ve''l-Hikem 2/394 ve Elbânî el-Mişkât no. 167)',
  'Diriwayatkan oleh Abu al-Qasim al-Ashbahani dalam Kitab al-Hujjah (no. 103), Ibnu Baththah (no. 279), dan al-Baghawi dalam Syarh as-Sunnah (no. 104); sebagian ulama menilainya lemah (lihat Ibnu Rajab, Jamiʿ al-ʿUlum wal-Hikam 2/394, dan al-Albani dalam al-Misykat no. 167)',
  'اسے ابو القاسم الاصبہانی نے کتاب الحجۃ (نمبر ۱۰۳)، ابن بطہ (نمبر ۲۷۹) اور بغوی نے شرح السنۃ (نمبر ۱۰۴) میں روایت کیا؛ بعض علماء نے اسے ضعیف کہا ہے (دیکھیں ابن رجب، جامع العلوم والحکم ۲/۳۹۴، اور البانی المشکاۃ نمبر ۱۶۷)',
  'বর্ণনা করেছেন আবুল কাসিম আল-আসবাহানী কিতাবুল হুজ্জাহতে (নং ১০৩), ইবনে বাত্তা (নং ২৭৯) ও বাগাবী শারহুস সুন্নাহতে (নং ১০৪); কিছু আলেম একে দুর্বল বলেছেন (দেখুন ইবনে রজব, জামিউল উলূম ওয়াল হিকাম ২/৩৯৪, এবং আলবানী আল-মিশকাত নং ১৬৭)',
  'Diriwayatkan oleh Abu al-Qasim al-Ashbahani dalam Kitab al-Hujjah (no. 103), Ibnu Baththah (no. 279), dan al-Baghawi dalam Syarh as-Sunnah (no. 104); sebahagian ulama menilainya lemah (lihat Ibnu Rajab, Jamiʿ al-ʿUlum wal-Hikam 2/394, dan al-Albani dalam al-Misykat no. 167)',
  'Передали Абу аль-Касим аль-Асбахани в «Китаб аль-Худжжа» (№ 103), Ибн Батта (№ 279) и аль-Багави в «Шарх ас-Сунна» (№ 104); часть учёных оценила его как слабый (см. Ибн Раджаб, «Джамиʿ аль-улюм ва-ль-хикам» 2/394, и аль-Альбани в «аль-Мишкат» № 167)',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2023/01/Hadith-41-Nawawi-Psalmodie-Arabe.mp3',
  5,
  41
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 41
);
