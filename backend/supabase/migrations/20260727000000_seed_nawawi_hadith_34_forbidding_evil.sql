-- =============================================================================
-- 40 Hadith Nawawi — Hadith 34: "Forbidding evil is part of faith"
-- Target collection: public.hadith_collections.id = 2  /  position = 34
-- Idempotent guard on (collection, position). All 11 content languages.
-- tafsir_* intentionally left NULL (no commentary provided for this hadith).
-- Arabic cleaned: فلغيره -> فليغيره.
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
  'Forbidding evil is part of faith',
  'Interdire ce qui est blâmable fait partie de la foi',
  'النهي عن المنكر من الإيمان',
  'Das Verbieten des Verwerflichen gehört zum Glauben',
  'Het verbieden van het verwerpelijke hoort bij geloof',
  'Münkeri nehyetmek imandandır',
  'Mencegah kemungkaran sebagian dari iman',
  'برائی سے روکنا ایمان کا حصہ ہے',
  'অন্যায় প্রতিরোধ ঈমানের অংশ',
  'Mencegah kemungkaran sebahagian daripada iman',
  'Запрет порицаемого — часть веры',
  -- arabic_text
  'عَنْ أَبِي سَعِيدٍ الْخُدْرِيِّ رَضِيَ اللَّهُ عَنْهُ قَالَ: سَمِعْتُ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ يَقُولُ: «مَنْ رَأَى مِنْكُمْ مُنْكَرًا فَلْيُغَيِّرْهُ بِيَدِهِ، فَإِنْ لَمْ يَسْتَطِعْ فَبِلِسَانِهِ، فَإِنْ لَمْ يَسْتَطِعْ فَبِقَلْبِهِ، وَذَلِكَ أَضْعَفُ الْإِيمَانِ»',
  -- transcription
  'ʿan Abī Saʿīdin al-Khudriyyi raḍiya Llāhu ʿanhu qāla: samiʿtu Rasūla Llāhi ṣalla Llāhu ʿalayhi wa-sallama yaqūlu: man raʾā minkum munkaran fa-l-yughayyirhu bi-yadihi, fa-in lam yastaṭiʿ fa-bi-lisānihi, fa-in lam yastaṭiʿ fa-bi-qalbihi, wa-dhālika aḍʿafu l-īmāni.',
  'ʿan Abî Saʿîdin al-Khoudriyyi (radia Llâhou ʿanhou) qâla : samiʿtou Rassôla Llâhi (salla Llâhou ʿalayhi wa sallam) yaqôlou : man raʾâ minkoum mounkaran fa-l-youghayyirhou bi-yadihi, fa-in lam yastatiʿ fa-bi-lisânihi, fa-in lam yastatiʿ fa-bi-qalbihi, wa dhâlika adʿafou l-îmâni.',
  'ʿan Abī Saʿīdin al-Chudrijji (radiya Llāhu ʿanhu) qāla: samiʿtu Rasūla Llāhi (salla Llāhu ʿalaihi wa-sallam) jaqūlu: man raʾā minkum munkaran fa-l-jughajjirhu bi-jadihi, fa-in lam jastatiʿ fa-bi-lisānihi, fa-in lam jastatiʿ fa-bi-qalbihi, wa-dhālika adʿafu l-īmāni.',
  'ʿan Abie Saʿiedin al-Choedrijji (radia Llaahoe ʿanhoe) qaala: samiʿtoe Rasoela Llaahi (salla Llaahoe ʿalaihi wa-sallam) jaqoeloe: man raʾaa minkoem moenkaran fa-l-joeghajjirhoe bi-jadihi, fa-in lam jastatiʿ fa-bi-lisaanihi, fa-in lam jastatiʿ fa-bi-qalbihi, wa-dhaalika adʿafoe l-iemaani.',
  'an Ebû Saʿîd el-Hudrî''den (radıyallâhu anh) rivayetle dedi ki: Resûlullah''ın (s.a.v.) şöyle dediğini işittim: sizden kim bir münker (kötülük) görürse onu eliyle değiştirsin; buna gücü yetmezse diliyle; ona da gücü yetmezse kalbiyle (buğzetsin), işte bu imanın en zayıfıdır.',
  'an Abi Saʿid al-Khudri (radhiyallahu ʿanhu) berkata: aku mendengar Rasulullah (shallallahu ʿalaihi wa sallam) bersabda: barangsiapa di antara kalian melihat suatu kemungkaran, hendaklah ia mengubahnya dengan tangannya; jika tidak mampu, maka dengan lidahnya; jika tidak mampu, maka dengan hatinya, dan itulah selemah-lemah iman.',
  'ابو سعید الخدری رضی اللہ عنہ سے روایت ہے، انہوں نے کہا: میں نے رسول اللہ صلی اللہ علیہ وسلم کو فرماتے سنا: تم میں سے جو کوئی برائی دیکھے تو اسے اپنے ہاتھ سے بدل دے؛ اگر اس کی طاقت نہ ہو تو اپنی زبان سے؛ اگر اس کی بھی طاقت نہ ہو تو اپنے دل سے، اور یہ ایمان کا سب سے کمزور درجہ ہے۔',
  'আবু সাঈদ আল-খুদরী (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, তিনি বলেন: আমি রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম)-কে বলতে শুনেছি: তোমাদের মধ্যে যে কেউ কোনো অন্যায় (মুনকার) দেখে, সে যেন তা তার হাত দিয়ে পরিবর্তন করে; যদি সক্ষম না হয়, তবে তার জিহ্বা দিয়ে; যদি তাতেও সক্ষম না হয়, তবে তার অন্তর দিয়ে, আর এটি ঈমানের সবচেয়ে দুর্বল স্তর।',
  'an Abi Saʿid al-Khudri (radhiallahu ʿanhu) berkata: aku mendengar Rasulullah (sallallahu ʿalaihi wa sallam) bersabda: sesiapa antara kamu yang melihat sesuatu kemungkaran, hendaklah dia mengubahnya dengan tangannya; jika tidak mampu, maka dengan lidahnya; jika tidak mampu, maka dengan hatinya, dan itulah selemah-lemah iman.',
  'От Аби Саида аль-Худри (да будет доволен им Аллах) передаётся: я слышал, как Посланник Аллаха ﷺ говорил: кто из вас увидит порицаемое, пусть изменит его своей рукой; если не сможет, то языком; а если не сможет, то сердцем (возненавидит его), и это — самая слабая (степень) веры.',
  -- translation
  'On the authority of Abu Saʿid al-Khudri (may Allah be pleased with him), who said: I heard the Messenger of Allah ﷺ say: "Whoever of you sees an evil (munkar), let him change it with his hand; if he is unable, then with his tongue; and if he is unable, then with his heart — and that is the weakest of faith."',
  'D''après Abû Saʿîd al-Khudrî (qu''Allah l''agrée), qui a dit : J''ai entendu l''Envoyé d''Allah ﷺ dire : « Quiconque parmi vous voit un acte blâmable (munkar), qu''il le corrige de sa main ; s''il n''en est pas capable, alors de sa langue ; et s''il n''en est pas capable, alors de son cœur — et c''est là le degré le plus faible de la foi. »',
  'Nach Abu Saʿid al-Khudri (möge Allah mit ihm zufrieden sein), der sagte: Ich hörte den Gesandten Allahs ﷺ sagen: „Wer von euch etwas Verwerfliches (Munkar) sieht, der ändere es mit seiner Hand; wenn er nicht dazu imstande ist, dann mit seiner Zunge; und wenn er nicht dazu imstande ist, dann mit seinem Herzen — und das ist der schwächste Glaube."',
  'Op gezag van Abu Saʿid al-Khudri (moge Allah tevreden met hem zijn), die zei: Ik hoorde de Boodschapper van Allah ﷺ zeggen: „Wie van jullie iets verwerpelijks (munkar) ziet, laat hem het veranderen met zijn hand; als hij niet in staat is, dan met zijn tong; en als hij niet in staat is, dan met zijn hart — en dat is het zwakste geloof."',
  'Ebû Saʿîd el-Hudrî''den (Allah ondan razı olsun) rivayet edildiğine göre şöyle dedi: Resûlullah''ın ﷺ şöyle buyurduğunu işittim: „Sizden kim bir münker (kötülük) görürse onu eliyle değiştirsin; buna gücü yetmezse diliyle; ona da gücü yetmezse kalbiyle — işte bu imanın en zayıfıdır."',
  'Dari Abu Saʿid al-Khudri (semoga Allah meridhainya), ia berkata: Aku mendengar Rasulullah ﷺ bersabda: "Barangsiapa di antara kalian melihat suatu kemungkaran, hendaklah ia mengubahnya dengan tangannya; jika tidak mampu, maka dengan lidahnya; jika tidak mampu, maka dengan hatinya — dan itulah selemah-lemah iman."',
  'ابو سعید الخدری رضی اللہ عنہ سے روایت ہے: میں نے رسول اللہ ﷺ کو فرماتے سنا: ”تم میں سے جو کوئی برائی دیکھے تو اسے اپنے ہاتھ سے بدل دے؛ اگر طاقت نہ ہو تو اپنی زبان سے؛ اگر اس کی بھی طاقت نہ ہو تو اپنے دل سے — اور یہ ایمان کا سب سے کمزور درجہ ہے۔“',
  'আবু সাঈদ আল-খুদরী (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত: আমি রাসূলুল্লাহ ﷺ-কে বলতে শুনেছি: "তোমাদের মধ্যে যে কেউ কোনো অন্যায় (মুনকার) দেখে, সে যেন তা তার হাত দিয়ে পরিবর্তন করে; যদি সক্ষম না হয়, তবে তার জিহ্বা দিয়ে; যদি তাতেও সক্ষম না হয়, তবে তার অন্তর দিয়ে — আর এটি ঈমানের সবচেয়ে দুর্বল স্তর।"',
  'Daripada Abu Saʿid al-Khudri (semoga Allah meredainya), dia berkata: Aku mendengar Rasulullah ﷺ bersabda: "Sesiapa antara kamu yang melihat sesuatu kemungkaran, hendaklah dia mengubahnya dengan tangannya; jika tidak mampu, maka dengan lidahnya; jika tidak mampu, maka dengan hatinya — dan itulah selemah-lemah iman."',
  'Со слов Абу Саида аль-Худри (да будет доволен им Аллах), который сказал: Я слышал, как Посланник Аллаха ﷺ говорил: «Кто из вас увидит порицаемое (мункар), пусть изменит его своей рукой; если не сможет, то языком; а если не сможет, то сердцем — и это самая слабая (степень) веры».',
  -- reference
  'Sahih — reported by Muslim (no. 49), Abu Dawud (no. 1140, 4340), at-Tirmidhi (no. 2172), an-Nasaʾi (8/111-112), Ibn Majah (no. 1275, 4013), and Ahmad (3/10, 20, 49, 52-54, 92)',
  'Hadith authentique rapporté par Muslim (n°49), Abû Dâwûd (n°1140, 4340), at-Tirmidhî (n°2172), an-Nasâʾî (8/111-112), Ibn Mâja (n°1275, 4013) et Ahmad (3/10, 20, 49, 52-54, 92)',
  'حديث صحيح، رواه مسلم (رقم ٤٩) وأبو داود (رقم ١١٤٠، ٤٣٤٠) والترمذي (رقم ٢١٧٢) والنسائي (٨/١١١-١١٢) وابن ماجه (رقم ١٢٧٥، ٤٠١٣) وأحمد (٣/١٠، ٢٠، ٤٩، ٥٢-٥٤، ٩٢)',
  'Sahih — überliefert von Muslim (Nr. 49), Abu Dawud (Nr. 1140, 4340), at-Tirmidhi (Nr. 2172), an-Nasaʾi (8/111-112), Ibn Madscha (Nr. 1275, 4013) und Ahmad (3/10, 20, 49, 52-54, 92)',
  'Sahih — overgeleverd door Muslim (nr. 49), Abu Dawud (nr. 1140, 4340), at-Tirmidhi (nr. 2172), an-Nasaʾi (8/111-112), Ibn Madja (nr. 1275, 4013) en Ahmad (3/10, 20, 49, 52-54, 92)',
  'Sahih — Müslim (no. 49), Ebû Dâvûd (no. 1140, 4340), Tirmizî (no. 2172), Nesâî (8/111-112), İbn Mâce (no. 1275, 4013) ve Ahmed (3/10, 20, 49, 52-54, 92) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Muslim (no. 49), Abu Dawud (no. 1140, 4340), at-Tirmidzi (no. 2172), an-Nasaʾi (8/111-112), Ibnu Majah (no. 1275, 4013), dan Ahmad (3/10, 20, 49, 52-54, 92)',
  'صحیح حدیث، اسے مسلم (نمبر ۴۹)، ابو داود (نمبر ۱۱۴۰، ۴۳۴۰)، ترمذی (نمبر ۲۱۷۲)، نسائی (۸/۱۱۱-۱۱۲)، ابن ماجہ (نمبر ۱۲۷۵، ۴۰۱۳) اور احمد (۳/۱۰، ۲۰، ۴۹، ۵۲-۵۴، ۹۲) نے روایت کیا',
  'সহীহ হাদীস — মুসলিম (নং ৪৯), আবু দাউদ (নং ১১৪০, ৪৩৪০), তিরমিযী (নং ২১৭২), নাসাঈ (৮/১১১-১১২), ইবনে মাজাহ (নং ১২৭৫, ৪০১৩) ও আহমাদ (৩/১০, ২০, ৪৯, ৫২-৫৪, ৯২) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Muslim (no. 49), Abu Dawud (no. 1140, 4340), at-Tirmizi (no. 2172), an-Nasaʾi (8/111-112), Ibnu Majah (no. 1275, 4013), dan Ahmad (3/10, 20, 49, 52-54, 92)',
  'Достоверный хадис, передали Муслим (№ 49), Абу Давуд (№ 1140, 4340), ат-Тирмизи (№ 2172), ан-Насаи (8/111-112), Ибн Маджа (№ 1275, 4013) и Ахмад (3/10, 20, 49, 52-54, 92)',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2023/01/Hadith-34-Nawawi-Psalmodie-Arabe.mp3',
  5,
  34
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 34
);
