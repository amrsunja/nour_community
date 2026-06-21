-- =============================================================================
-- 40 Hadith Nawawi — Hadith 33: "The burden of proof is on the claimant"
-- Target collection: public.hadith_collections.id = 2  /  position = 33
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
  'The burden of proof is on the claimant',
  'La preuve incombe au demandeur',
  'البينة على المدعي واليمين على من أنكر',
  'Die Beweislast liegt beim Kläger',
  'De bewijslast rust op de eiser',
  'İspat külfeti davacıya aittir',
  'Bukti dibebankan kepada penuduh',
  'دلیل مدعی پر ہے',
  'প্রমাণের দায়িত্ব দাবিদারের',
  'Bukti dibebankan kepada pendakwa',
  'Бремя доказательства — на истце',
  -- arabic_text
  'عَنِ ابْنِ عَبَّاسٍ رَضِيَ اللَّهُ عَنْهُمَا أَنَّ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ قَالَ: «لَوْ يُعْطَى النَّاسُ بِدَعْوَاهُمْ لَادَّعَى رِجَالٌ أَمْوَالَ قَوْمٍ وَدِمَاءَهُمْ، لَكِنِ الْبَيِّنَةُ عَلَى الْمُدَّعِي، وَالْيَمِينُ عَلَى مَنْ أَنْكَرَ»',
  -- transcription
  'ʿani bni ʿAbbāsin raḍiya Llāhu ʿanhumā anna Rasūla Llāhi ṣalla Llāhu ʿalayhi wa-sallama qāla: law yuʿṭa n-nāsu bi-daʿwāhum la-ddaʿā rijālun amwāla qawmin wa-dimāʾahum, lākini l-bayyinatu ʿala l-muddaʿī, wa-l-yamīnu ʿalā man ankara.',
  'ʿani bni ʿAbbâsin (radia Llâhou ʿanhoumâ) anna Rassôla Llâhi (salla Llâhou ʿalayhi wa sallam) qâla : law youʿta n-nâsou bi-daʿwâhoum la-ddaʿâ rijâloun amwâla qawmin wa dimâʾahoum, lâkini l-bayyinatou ʿala l-mouddaʿî, wa l-yamînou ʿalâ man ankara.',
  'ʿani bni ʿAbbāsin (radiya Llāhu ʿanhumā) anna Rasūla Llāhi (salla Llāhu ʿalaihi wa-sallam) qāla: lau juʿta n-nāsu bi-daʿwāhum la-ddaʿā ridschālun amwāla qaumin wa-dimāʾahum, lākini l-bajjinatu ʿala l-muddaʿī, wa-l-jamīnu ʿalā man ankara.',
  'ʿani bni ʿAbbaasin (radia Llaahoe ʿanhoemaa) anna Rasoela Llaahi (salla Llaahoe ʿalaihi wa-sallam) qaala: lau joeʿta n-naasoe bi-daʿwaahoem la-ddaʿaa ridzjaaloen amwaala qaumin wa-dimaaʾahoem, laakini l-bajjinatoe ʿala l-moeddaʿie, wa-l-jamienoe ʿalaa man ankara.',
  'an İbn Abbâs''tan (radıyallâhu anhümâ) rivayetle Resûlullah (s.a.v.) şöyle buyurdu: eğer insanlara sadece iddialarıyla verilseydi, birtakım kimseler insanların mallarını ve canlarını iddia ederlerdi; ancak ispat (beyyine) davacıya, yemin ise inkâr edene düşer.',
  'an Ibni ʿAbbas (radhiyallahu ʿanhuma) bahwa Rasulullah (shallallahu ʿalaihi wa sallam) bersabda: seandainya manusia diberi (hak) hanya dengan dakwaan mereka, niscaya orang-orang akan mendakwa harta dan darah (jiwa) suatu kaum; akan tetapi bukti (al-bayyinah) dibebankan kepada penuduh, dan sumpah dibebankan kepada yang mengingkari.',
  'ابن عباس رضی اللہ عنہما سے روایت ہے کہ رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: اگر لوگوں کو ان کے محض دعوے پر دے دیا جائے تو کچھ لوگ دوسروں کے مال اور خون کا دعویٰ کرنے لگیں؛ لیکن دلیل (بیّنہ) مدعی پر ہے، اور قسم اس پر ہے جو انکار کرے۔',
  'ইবনে আব্বাস (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত যে রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: যদি মানুষকে কেবল তাদের দাবির ভিত্তিতে দিয়ে দেওয়া হতো, তবে কিছু লোক অন্যদের সম্পদ ও রক্তের (জীবনের) দাবি করত; কিন্তু প্রমাণ (বায়্যিনা) দাবিদারের উপর, আর শপথ অস্বীকারকারীর উপর।',
  'an Ibni ʿAbbas (radhiallahu ʿanhuma) bahawa Rasulullah (sallallahu ʿalaihi wa sallam) bersabda: seandainya manusia diberi (hak) hanya dengan dakwaan mereka, nescaya orang-orang akan mendakwa harta dan darah (nyawa) sesuatu kaum; akan tetapi bukti (al-bayyinah) dibebankan kepada pendakwa, dan sumpah dibebankan kepada yang mengingkari.',
  'От Ибн Аббаса (да будет доволен Аллах ими обоими) передаётся, что Посланник Аллаха ﷺ сказал: если бы людям давали лишь по их притязаниям, то некоторые стали бы притязать на имущество и кровь (жизнь) других; однако доказательство (баййина) — на истце, а клятва — на том, кто отрицает.',
  -- translation
  'On the authority of Ibn ʿAbbas (may Allah be pleased with them both), the Messenger of Allah ﷺ said: "If people were given (whatever they claimed) merely by their claims, some would claim the wealth and the lives of others. But the burden of proof (bayyinah) is upon the claimant, and the oath is upon the one who denies."',
  'D''après Ibn ʿAbbâs (qu''Allah les agrée tous deux), l''Envoyé d''Allah ﷺ a dit : « Si l''on accordait aux gens (ce qu''ils prétendent) sur leurs seules prétentions, certains ne manqueraient pas de revendiquer les biens et la vie d''autrui. Mais la preuve (bayyina) incombe au demandeur, et le serment est imposé à celui qui nie. »',
  'Nach Ibn ʿAbbas (möge Allah mit beiden zufrieden sein) sagte der Gesandte Allahs ﷺ: „Würde den Menschen (was sie behaupten) allein aufgrund ihrer Ansprüche gegeben, so würden manche das Vermögen und das Leben anderer beanspruchen. Doch die Beweislast (Bayyina) liegt beim Kläger, und der Eid obliegt dem, der leugnet."',
  'Op gezag van Ibn ʿAbbas (moge Allah tevreden met hen beiden zijn) zei de Boodschapper van Allah ﷺ: „Als de mensen (wat zij beweren) louter op grond van hun aanspraken zou worden gegeven, zouden sommigen het bezit en het leven van anderen opeisen. Maar de bewijslast (bayyina) rust op de eiser, en de eed rust op degene die ontkent."',
  'İbn Abbâs''tan (Allah her ikisinden de razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Eğer insanlara sadece iddialarıyla verilseydi, birtakım kimseler insanların mallarını ve canlarını iddia ederlerdi. Fakat ispat (beyyine) davacıya, yemin ise inkâr edene düşer."',
  'Dari Ibnu ʿAbbas (semoga Allah meridhai keduanya), Rasulullah ﷺ bersabda: "Seandainya manusia diberi (hak) hanya dengan dakwaan mereka, niscaya orang-orang akan mendakwa harta dan darah (jiwa) suatu kaum. Akan tetapi bukti (al-bayyinah) dibebankan kepada penuduh, dan sumpah dibebankan kepada yang mengingkari."',
  'ابن عباس رضی اللہ عنہما سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”اگر لوگوں کو محض ان کے دعوے پر دے دیا جائے تو کچھ لوگ دوسروں کے مال اور خون (جان) کا دعویٰ کرنے لگیں۔ لیکن دلیل (بیّنہ) مدعی پر ہے، اور قسم اس پر ہے جو انکار کرے۔“',
  'ইবনে আব্বাস (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "যদি মানুষকে কেবল তাদের দাবির ভিত্তিতে দিয়ে দেওয়া হতো, তবে কিছু লোক অন্যদের সম্পদ ও রক্তের (জীবনের) দাবি করত। কিন্তু প্রমাণ (বায়্যিনা) দাবিদারের উপর, আর শপথ অস্বীকারকারীর উপর।"',
  'Daripada Ibnu ʿAbbas (semoga Allah meredai keduanya), Rasulullah ﷺ bersabda: "Seandainya manusia diberi (hak) hanya dengan dakwaan mereka, nescaya orang-orang akan mendakwa harta dan darah (nyawa) sesuatu kaum. Akan tetapi bukti (al-bayyinah) dibebankan kepada pendakwa, dan sumpah dibebankan kepada yang mengingkari."',
  'Со слов Ибн Аббаса (да будет доволен Аллах ими обоими) Посланник Аллаха ﷺ сказал: «Если бы людям давали (то, что они утверждают) лишь по их притязаниям, то некоторые стали бы притязать на имущество и кровь (жизнь) других. Однако доказательство (баййина) лежит на истце, а клятва — на том, кто отрицает».',
  -- reference
  'Sahih — reported by Al-Bukhari (no. 4552), Muslim (no. 1711), al-Bayhaqi (10/252; 5/332), ad-Daraqutni (4/107), and others',
  'Hadith authentique rapporté par Al-Bukhari (n°4552), Muslim (n°1711), al-Bayhaqî (10/252 ; 5/332), ad-Dâraqutnî (4/107) et d''autres',
  'حديث صحيح، رواه البخاري (رقم ٤٥٥٢) ومسلم (رقم ١٧١١) والبيهقي (١٠/٢٥٢؛ ٥/٣٣٢) والدارقطني (٤/١٠٧) وغيرهم',
  'Sahih — überliefert von Al-Bukhari (Nr. 4552), Muslim (Nr. 1711), al-Bayhaqi (10/252; 5/332), ad-Daraqutni (4/107) und anderen',
  'Sahih — overgeleverd door Al-Bukhari (nr. 4552), Muslim (nr. 1711), al-Bayhaqi (10/252; 5/332), ad-Daraqutni (4/107) en anderen',
  'Sahih — Buhârî (no. 4552), Müslim (no. 1711), Beyhakî (10/252; 5/332), Dârekutnî (4/107) ve diğerleri rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (no. 4552), Muslim (no. 1711), al-Baihaqi (10/252; 5/332), ad-Daraquthni (4/107), dan lainnya',
  'صحیح حدیث، اسے بخاری (نمبر ۴۵۵۲)، مسلم (نمبر ۱۷۱۱)، بیہقی (۱۰/۲۵۲؛ ۵/۳۳۲)، دارقطنی (۴/۱۰۷) وغیرہ نے روایت کیا',
  'সহীহ হাদীস — বুখারী (নং ৪৫৫২), মুসলিম (নং ১৭১১), বায়হাকী (১০/২৫২; ৫/৩৩২), দারাকুতনী (৪/১০৭) প্রমুখ বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (no. 4552), Muslim (no. 1711), al-Baihaqi (10/252; 5/332), ad-Daraqutni (4/107), dan lain-lain',
  'Достоверный хадис, передали аль-Бухари (№ 4552), Муслим (№ 1711), аль-Байхаки (10/252; 5/332), ад-Даракутни (4/107) и другие',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2023/01/Hadith-33-Nawawi-Psalmodie-Arabe.mp3',
  5,
  33
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 33
);
