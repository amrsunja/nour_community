-- =============================================================================
-- 40 Hadith Nawawi — Hadith 40: "Be in this world as a stranger"
-- Target collection: public.hadith_collections.id = 2  /  position = 40
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
  'Be in this world as a stranger',
  'La vie terrestre, champ de l''au-delà',
  'كن في الدنيا كأنك غريب',
  'Sei in dieser Welt wie ein Fremder',
  'Wees in deze wereld als een vreemdeling',
  'Dünyada bir garip gibi ol',
  'Jadilah di dunia seperti orang asing',
  'دنیا میں اجنبی کی طرح رہو',
  'দুনিয়ায় মুসাফিরের মতো থাকো',
  'Jadilah di dunia seperti orang asing',
  'Будь в этом мире как чужестранец',
  -- arabic_text
  'عَنِ ابْنِ عُمَرَ رَضِيَ اللَّهُ عَنْهُمَا قَالَ: أَخَذَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ بِمَنْكِبِي فَقَالَ: «كُنْ فِي الدُّنْيَا كَأَنَّكَ غَرِيبٌ أَوْ عَابِرُ سَبِيلٍ». وَكَانَ ابْنُ عُمَرَ رَضِيَ اللَّهُ عَنْهُمَا يَقُولُ: إِذَا أَمْسَيْتَ فَلَا تَنْتَظِرِ الصَّبَاحَ، وَإِذَا أَصْبَحْتَ فَلَا تَنْتَظِرِ الْمَسَاءَ، وَخُذْ مِنْ صِحَّتِكَ لِمَرَضِكَ، وَمِنْ حَيَاتِكَ لِمَوْتِكَ.',
  -- transcription
  'ʿani bni ʿUmara raḍiya Llāhu ʿanhumā qāla: akhadha Rasūlu Llāhi ṣalla Llāhu ʿalayhi wa-sallama bi-mankibī fa-qāla: kun fi d-dunyā kaʾannaka gharībun aw ʿābiru sabīlin. wa-kāna bnu ʿUmara raḍiya Llāhu ʿanhumā yaqūlu: idhā amsayta fa-lā tantaẓiri ṣ-ṣabāḥa, wa-idhā aṣbaḥta fa-lā tantaẓiri l-masāʾa, wa-khudh min ṣiḥḥatika li-maraḍika, wa-min ḥayātika li-mawtika.',
  'ʿani bni ʿOumar (radia Llâhou ʿanhoumâ) qâla : akhadha Rassôlou Llâhi (salla Llâhou ʿalayhi wa sallam) bi-mankibî fa-qâla : koun fi d-dounyâ kaʾannaka gharîboun aw ʿâbirou sabîlin. wa kâna bnou ʿOumar (radia Llâhou ʿanhoumâ) yaqôulou : idhâ amsayta fa-lâ tantaziri s-sabâha, wa idhâ asbahta fa-lâ tantaziri l-masâʾa, wa khoudh min sihhatika li-maradika, wa min hayâtika li-mawtika.',
  'ʿani bni ʿUmara (radiya Llāhu ʿanhumā) qāla: achadha Rasūlu Llāhi (salla Llāhu ʿalaihi wa-sallam) bi-mankibī fa-qāla: kun fi d-dunjā kaʾannaka gharībun au ʿābiru sabīlin. wa-kāna bnu ʿUmara (radiya Llāhu ʿanhumā) jaqūlu: idhā amsaita fa-lā tantaziri s-sabāha, wa-idhā asbahta fa-lā tantaziri l-masāʾa, wa-chudh min sihhatika li-maradika, wa-min hajātika li-mautika.',
  'ʿani bni ʿOemara (radia Llaahoe ʿanhoemaa) qaala: achadha Rasoeloe Llaahi (salla Llaahoe ʿalaihi wa-sallam) bi-mankibie fa-qaala: koen fi d-doenjaa kaʾannaka gharieboen au ʿaabiroe sabielin. wa-kaana bnoe ʿOemara (radia Llaahoe ʿanhoemaa) jaqoeloe: idhaa amsaita fa-laa tantaziri s-sabaaha, wa-idhaa asbahta fa-laa tantaziri l-masaaʾa, wa-choedh min sihhatika li-maradika, wa-min hajaatika li-mautika.',
  'an İbn Ömer''den (radıyallâhu anhümâ) rivayetle dedi ki: Resûlullah (s.a.v.) omzumdan tuttu ve buyurdu: dünyada bir garip yahut bir yolcu gibi ol. İbn Ömer (radıyallâhu anhümâ) şöyle derdi: akşama erdiğinde sabahı bekleme, sabaha erdiğinde akşamı bekleme; sağlığından hastalığın için, hayatından da ölümün için (azık) al.',
  'an Ibni ʿUmar (radhiyallahu ʿanhuma) berkata: Rasulullah (shallallahu ʿalaihi wa sallam) memegang kedua bahuku lalu bersabda: jadilah engkau di dunia seakan-akan orang asing atau seorang yang sedang menempuh perjalanan. Ibnu Umar (radhiyallahu ʿanhuma) berkata: apabila engkau berada di sore hari, janganlah menunggu pagi; dan apabila engkau berada di pagi hari, janganlah menunggu sore; ambillah dari sehatmu untuk sakitmu, dan dari hidupmu untuk matimu.',
  'ابن عمر رضی اللہ عنہما سے روایت ہے، انہوں نے کہا: رسول اللہ صلی اللہ علیہ وسلم نے میرے کندھے پکڑے اور فرمایا: دنیا میں اس طرح رہو گویا تم اجنبی ہو یا کوئی راہگیر۔ اور ابن عمر رضی اللہ عنہما کہا کرتے تھے: جب تم شام کرو تو صبح کا انتظار نہ کرو، اور جب صبح کرو تو شام کا انتظار نہ کرو؛ اپنی صحت سے اپنی بیماری کے لیے اور اپنی زندگی سے اپنی موت کے لیے (توشہ) لے لو۔',
  'ইবনে উমার (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত, তিনি বলেন: রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) আমার দুই কাঁধ ধরে বললেন: দুনিয়ায় এমনভাবে থাকো যেন তুমি একজন অপরিচিত কিংবা পথিক। আর ইবনে উমার (রাদিয়াল্লাহু আনহুমা) বলতেন: যখন তুমি সন্ধ্যায় উপনীত হও, সকালের প্রতীক্ষা করো না; আর যখন সকালে উপনীত হও, সন্ধ্যার প্রতীক্ষা করো না; তোমার সুস্থতা থেকে তোমার অসুস্থতার জন্য, আর তোমার জীবন থেকে তোমার মৃত্যুর জন্য (পাথেয়) গ্রহণ করো।',
  'an Ibni ʿUmar (radhiallahu ʿanhuma) berkata: Rasulullah (sallallahu ʿalaihi wa sallam) memegang kedua-dua bahuku lalu bersabda: jadilah engkau di dunia seakan-akan orang asing atau seorang yang sedang menempuh perjalanan. Ibnu Umar (radhiallahu ʿanhuma) berkata: apabila engkau berada pada waktu petang, janganlah menunggu pagi; dan apabila engkau berada pada waktu pagi, janganlah menunggu petang; ambillah daripada sihatmu untuk sakitmu, dan daripada hidupmu untuk matimu.',
  'От Ибн Умара (да будет доволен Аллах ими обоими) передаётся: Посланник Аллаха ﷺ взял меня за плечи и сказал: будь в этом мире, словно ты чужестранец или путник. И Ибн Умар (да будет доволен Аллах ими обоими) говорил: когда наступит вечер, не жди утра, а когда наступит утро, не жди вечера; и бери от своего здоровья для своей болезни, и от своей жизни для своей смерти.',
  -- translation
  'On the authority of Ibn ʿUmar (may Allah be pleased with them both), who said: The Messenger of Allah ﷺ took hold of my shoulders and said: "Be in this world as though you were a stranger or a wayfarer." And Ibn ʿUmar (may Allah be pleased with them both) used to say: "When evening comes, do not expect to see the morning; and when morning comes, do not expect to see the evening. Take from your health for your illness, and from your life for your death."',
  'D''après Ibn ʿOmar (qu''Allah les agrée tous deux), qui a dit : L''Envoyé d''Allah ﷺ me saisit par les épaules et dit : « Sois dans ce bas-monde comme un étranger ou quelqu''un de passage. » Et Ibn ʿOmar (qu''Allah les agrée tous deux) disait : « Quand tu es au soir, n''attends pas le matin ; et quand tu es au matin, n''attends pas le soir. Prends de ta santé pour ta maladie, et de ta vie pour ta mort. »',
  'Nach Ibn ʿUmar (möge Allah mit beiden zufrieden sein), der sagte: Der Gesandte Allahs ﷺ ergriff meine Schultern und sagte: „Sei in dieser Welt, als wärst du ein Fremder oder ein Reisender." Und Ibn ʿUmar (möge Allah mit beiden zufrieden sein) pflegte zu sagen: „Wenn der Abend kommt, erwarte nicht den Morgen; und wenn der Morgen kommt, erwarte nicht den Abend. Nimm von deiner Gesundheit für deine Krankheit und von deinem Leben für deinen Tod."',
  'Op gezag van Ibn ʿUmar (moge Allah tevreden met hen beiden zijn), die zei: De Boodschapper van Allah ﷺ greep mij bij de schouders en zei: „Wees in deze wereld alsof je een vreemdeling of een reiziger was." En Ibn ʿUmar (moge Allah tevreden met hen beiden zijn) placht te zeggen: „Wanneer de avond komt, verwacht niet de morgen; en wanneer de morgen komt, verwacht niet de avond. Neem van je gezondheid voor je ziekte, en van je leven voor je dood."',
  'İbn Ömer''den (Allah her ikisinden de razı olsun) rivayet edildiğine göre şöyle dedi: Resûlullah ﷺ omuzlarımdan tuttu ve buyurdu: „Dünyada bir garip yahut bir yolcu gibi ol." İbn Ömer (Allah her ikisinden de razı olsun) şöyle derdi: „Akşama erdiğinde sabahı bekleme; sabaha erdiğinde akşamı bekleme. Sağlığından hastalığın için, hayatından da ölümün için (azık) al."',
  'Dari Ibnu ʿUmar (semoga Allah meridhai keduanya), ia berkata: Rasulullah ﷺ memegang kedua bahuku lalu bersabda: "Jadilah engkau di dunia seakan-akan orang asing atau seorang yang sedang menempuh perjalanan." Dan Ibnu Umar (semoga Allah meridhai keduanya) berkata: "Apabila engkau berada di sore hari, janganlah menunggu pagi; dan apabila engkau berada di pagi hari, janganlah menunggu sore. Ambillah dari sehatmu untuk sakitmu, dan dari hidupmu untuk matimu."',
  'ابن عمر رضی اللہ عنہما سے روایت ہے: رسول اللہ ﷺ نے میرے کندھے پکڑے اور فرمایا: ”دنیا میں اس طرح رہو گویا تم اجنبی ہو یا کوئی راہگیر۔“ اور ابن عمر رضی اللہ عنہما کہا کرتے تھے: ”جب تم شام کرو تو صبح کا انتظار نہ کرو؛ اور جب صبح کرو تو شام کا انتظار نہ کرو۔ اپنی صحت سے اپنی بیماری کے لیے اور اپنی زندگی سے اپنی موت کے لیے (توشہ) لے لو۔“',
  'ইবনে উমার (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত: রাসূলুল্লাহ ﷺ আমার দুই কাঁধ ধরে বললেন: "দুনিয়ায় এমনভাবে থাকো যেন তুমি একজন অপরিচিত কিংবা পথিক।" আর ইবনে উমার (রাদিয়াল্লাহু আনহুমা) বলতেন: "যখন তুমি সন্ধ্যায় উপনীত হও, সকালের প্রতীক্ষা করো না; আর যখন সকালে উপনীত হও, সন্ধ্যার প্রতীক্ষা করো না। তোমার সুস্থতা থেকে তোমার অসুস্থতার জন্য, আর তোমার জীবন থেকে তোমার মৃত্যুর জন্য (পাথেয়) গ্রহণ করো।"',
  'Daripada Ibnu ʿUmar (semoga Allah meredai keduanya), dia berkata: Rasulullah ﷺ memegang kedua-dua bahuku lalu bersabda: "Jadilah engkau di dunia seakan-akan orang asing atau seorang yang sedang menempuh perjalanan." Dan Ibnu Umar (semoga Allah meredai keduanya) berkata: "Apabila engkau berada pada waktu petang, janganlah menunggu pagi; dan apabila engkau berada pada waktu pagi, janganlah menunggu petang. Ambillah daripada sihatmu untuk sakitmu, dan daripada hidupmu untuk matimu."',
  'Со слов Ибн Умара (да будет доволен Аллах ими обоими), который сказал: Посланник Аллаха ﷺ взял меня за плечи и сказал: «Будь в этом мире, словно ты чужестранец или путник». И Ибн Умар (да будет доволен Аллах ими обоими) говорил: «Когда наступит вечер, не жди утра; а когда наступит утро, не жди вечера. И бери от своего здоровья для своей болезни, и от своей жизни для своей смерти».',
  -- reference
  'Sahih — reported by Al-Bukhari (no. 6416)',
  'Hadith authentique rapporté par Al-Bukhari (n°6416)',
  'حديث صحيح، رواه البخاري (رقم ٦٤١٦)',
  'Sahih — überliefert von Al-Bukhari (Nr. 6416)',
  'Sahih — overgeleverd door Al-Bukhari (nr. 6416)',
  'Sahih — Buhârî (no. 6416) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (no. 6416)',
  'صحیح حدیث، اسے بخاری (نمبر ۶۴۱۶) نے روایت کیا',
  'সহীহ হাদীস — বুখারী (নং ৬৪১৬) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (no. 6416)',
  'Достоверный хадис, передал аль-Бухари (№ 6416)',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2023/01/Hadith-40-Nawawi-Psalmodie-Arabe.mp3',
  5,
  40
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 40
);
