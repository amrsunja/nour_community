-- =============================================================================
-- 40 Hadith Nawawi — Hadith 12: "Leaving what does not concern you"
-- Target collection: public.hadith_collections.id = 2  /  position = 12
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
  'Leaving what does not concern you',
  'Délaisser ce qui ne le concerne pas',
  'ترك ما لا يعني المسلم',
  'Das Lassen dessen, was einen nichts angeht',
  'Het laten van wat je niet aangaat',
  'Kendisini ilgilendirmeyeni terk etmek',
  'Meninggalkan yang tidak bermanfaat baginya',
  'لاتعلق چیز کو چھوڑنا',
  'যা তোমার সাথে সম্পর্কহীন তা পরিহার',
  'Meninggalkan yang tidak berkaitan dengannya',
  'Оставление того, что тебя не касается',
  -- arabic_text (cleaned: مل -> ما)
  'عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ قَالَ: قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: «مِنْ حُسْنِ إِسْلَامِ الْمَرْءِ تَرْكُهُ مَا لَا يَعْنِيهِ»',
  -- transcription
  'ʿan Abī Hurayrata raḍiya Llāhu ʿanhu qāla: qāla Rasūlu Llāhi ṣalla Llāhu ʿalayhi wa-sallama: min ḥusni islāmi l-marʾi tarkuhu mā lā yaʿnīhi.',
  'ʿan Abî Hourayrata (radia Llâhou ʿanhou) qâla : qâla Rassôlou Llâhi (salla Llâhou ʿalayhi wa sallam) : min housni islâmi l-marʾi tarkouhou mâ lâ yaʿnîhi.',
  'ʿan Abī Hurairata (radiya Llāhu ʿanhu) qāla: qāla Rasūlu Llāhi (salla Llāhu ʿalaihi wa-sallam): min husni islāmi l-marʾi tarkuhu mā lā jaʿnīhi.',
  'ʿan Abie Hoerairata (radia Llaahoe ʿanhoe) qaala: qaala Rasoeloe Llaahi (salla Llaahoe ʿalaihi wa-sallam): min hoesni islaami l-marʾi tarkoehoe maa laa jaʿniehi.',
  'an Ebû Hüreyre''den (radıyallâhu anh) rivayetle dedi ki: Resûlullah (s.a.v.) şöyle buyurdu: min husni islâmi''l-merʾi terkuhu mâ lâ yaʿnîhi.',
  'ʿan Abī Hurairah (radhiyallāhu ʿanhu) berkata: Rasulullah (shallallāhu ʿalaihi wa sallam) bersabda: min husni islāmil-marʾi tarkuhu mā lā yaʿnīhi.',
  'ابو ہریرہ رضی اللہ عنہ سے روایت ہے، انہوں نے کہا: رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: مِن حُسنِ اِسلامِ المَرءِ تَرکُہُ ما لا یَعنِیہِ۔',
  'আবু হুরায়রা (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, তিনি বলেন: রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: মিন হুসনি ইসলামিল মারই তারকুহু মা লা ইয়ানীহি।',
  'ʿan Abī Hurairah (radhiallāhu ʿanhu) berkata: Rasulullah (sallallāhu ʿalaihi wa sallam) bersabda: min husni islāmil-marʾi tarkuhu mā lā yaʿnīhi.',
  'Ан Аби Хурайра (да будет доволен им Аллах) сказал: сказал Посланник Аллаха ﷺ: мин хусни ислямиль-марʾи таркуху ма ля яʿнихи.',
  -- translation
  'On the authority of Abu Hurayra (may Allah be pleased with him), the Messenger of Allah ﷺ said: "Part of the excellence of a person''s Islam is his leaving what does not concern him."',
  'D''après Abû Hurayra (qu''Allah l''agrée), l''Envoyé d''Allah ﷺ a dit : « Fait partie de la bonne soumission (Islam) de l''homme son abandon de ce qui ne le concerne pas. »',
  'Nach Abu Hurayra (möge Allah mit ihm zufrieden sein) sagte der Gesandte Allahs ﷺ: „Zur Vortrefflichkeit des Islam eines Menschen gehört, dass er lässt, was ihn nichts angeht."',
  'Op gezag van Abu Hurayra (moge Allah tevreden met hem zijn) zei de Boodschapper van Allah ﷺ: „Tot de voortreffelijkheid van iemands islam behoort dat hij laat wat hem niet aangaat."',
  'Ebû Hüreyre''den (Allah ondan razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Kişinin İslâm''ının güzelliğindendir, kendisini ilgilendirmeyen şeyi terk etmesi."',
  'Dari Abu Hurairah (semoga Allah meridhainya), Rasulullah ﷺ bersabda: "Di antara tanda baiknya keislaman seseorang adalah ia meninggalkan apa yang tidak bermanfaat baginya."',
  'ابو ہریرہ رضی اللہ عنہ سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”آدمی کے اچھے اسلام کی نشانیوں میں سے یہ ہے کہ وہ اس چیز کو چھوڑ دے جو اس سے تعلق نہیں رکھتی۔“',
  'আবু হুরায়রা (রাদিয়াল্লাহু আনহু) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "একজন মানুষের ইসলামের সৌন্দর্যের অন্যতম হলো তার এমন বিষয় পরিহার করা যা তার সাথে সম্পর্কহীন।"',
  'Daripada Abu Hurairah (semoga Allah meredainya), Rasulullah ﷺ bersabda: "Antara tanda baiknya keislaman seseorang ialah dia meninggalkan apa yang tidak berkaitan dengannya."',
  'Со слов Абу Хурайры (да будет доволен им Аллах) Посланник Аллаха ﷺ сказал: «Из (признаков) прекрасного ислама человека — оставление им того, что его не касается».',
  -- reference
  'Hasan — reported by at-Tirmidhi (no. 2317), Ibn Majah (no. 3976), Malik in al-Muwatta (2/903), and Ahmad (1/201)',
  'Hadith hasan rapporté par at-Tirmidhî (n°2317), Ibn Mâja (n°3976), Mâlik dans « al-Muwatta » (2/903) et Ahmad (1/201)',
  'حديث حسن، رواه الترمذي (رقم ٢٣١٧) وابن ماجه (رقم ٣٩٧٦) ومالك في الموطأ (٢/٩٠٣) وأحمد (١/٢٠١)',
  'Hasan — überliefert von at-Tirmidhi (Nr. 2317), Ibn Madscha (Nr. 3976), Malik im al-Muwatta (2/903) und Ahmad (1/201)',
  'Hasan — overgeleverd door at-Tirmidhi (nr. 2317), Ibn Madja (nr. 3976), Malik in al-Muwatta (2/903) en Ahmad (1/201)',
  'Hasen — Tirmizî (no. 2317), İbn Mâce (no. 3976), Mâlik el-Muvatta''da (2/903) ve Ahmed (1/201) rivayet etmiştir',
  'Hadis hasan, diriwayatkan oleh at-Tirmidzi (no. 2317), Ibnu Majah (no. 3976), Malik dalam al-Muwatta (2/903), dan Ahmad (1/201)',
  'حسن حدیث، اسے ترمذی (نمبر ۲۳۱۷)، ابن ماجہ (نمبر ۳۹۷۶)، مالک نے الموطأ میں (۲/۹۰۳) اور احمد (۱/۲۰۱) نے روایت کیا',
  'হাসান হাদীস — তিরমিযী (নং ২৩১৭), ইবনে মাজাহ (নং ৩৯৭৬), মালিক আল-মুওয়াত্তায় (২/৯০৩) ও আহমাদ (১/২০১) বর্ণনা করেছেন',
  'Hadis hasan, diriwayatkan oleh at-Tirmizi (no. 2317), Ibnu Majah (no. 3976), Malik dalam al-Muwatta (2/903), dan Ahmad (1/201)',
  'Хороший (хасан) хадис, передали ат-Тирмизи (№ 2317), Ибн Маджа (№ 3976), Малик в «аль-Муватта» (2/903) и Ахмад (1/201)',
  -- tafsir
  'This hadith is a foundation in noble character and sound upbringing: when a person renounces what does not concern him and what is of no interest to him, this proves the excellence of his Islam, and it is also a source of tranquillity for his mind.',
  'Ce hadith est une base dans la noblesse du caractère et l''éducation saine : lorsque l''homme renonce à ce qui ne le concerne pas et à ce qui ne l''intéresse pas, cela prouve la qualité de sa soumission (Islam), et c''est aussi une source de tranquillité pour son esprit.',
  'هذا الحديث أصل في مكارم الأخلاق وحسن التربية: فإن المرء إذا ترك ما لا يعنيه وما لا يهمه، دلّ ذلك على حسن إسلامه، وكان أيضاً سبباً لراحة باله.',
  'Dieser Hadith ist eine Grundlage in der Vortrefflichkeit des Charakters und der gesunden Erziehung: Wenn der Mensch auf das verzichtet, was ihn nichts angeht und was ihn nicht interessiert, so beweist dies die Vortrefflichkeit seines Islam und ist zugleich eine Quelle der Ruhe für seinen Geist.',
  'Deze hadith is een grondslag in de voortreffelijkheid van het karakter en de gezonde opvoeding: wanneer de mens afziet van wat hem niet aangaat en wat hem niet interesseert, bewijst dit de voortreffelijkheid van zijn islam, en het is tevens een bron van rust voor zijn geest.',
  'Bu hadis, güzel ahlak ve sağlam terbiyede bir esastır: kişi kendisini ilgilendirmeyen ve umursamadığı şeyi terk ettiğinde, bu onun İslâm''ının güzelliğine delildir ve aynı zamanda zihninin huzuruna bir sebeptir.',
  'Hadis ini merupakan dasar dalam akhlak mulia dan pendidikan yang baik: apabila seseorang meninggalkan apa yang tidak bermanfaat baginya dan apa yang tidak menjadi urusannya, hal itu membuktikan baiknya keislamannya, dan juga menjadi sumber ketenangan bagi pikirannya.',
  'یہ حدیث مکارمِ اخلاق اور اچھی تربیت میں ایک بنیاد ہے: جب آدمی اس چیز کو چھوڑ دیتا ہے جو اس سے تعلق نہیں رکھتی اور جس میں اس کی دلچسپی نہیں، تو یہ اس کے اچھے اسلام کی دلیل ہے، اور یہ اس کے ذہن کے سکون کا بھی سبب ہے۔',
  'এই হাদীসটি উন্নত চরিত্র ও সুস্থ শিক্ষার একটি ভিত্তি: যখন কোনো ব্যক্তি এমন বিষয় পরিহার করে যা তার সাথে সম্পর্কহীন এবং যাতে তার আগ্রহ নেই, তখন তা তার ইসলামের সৌন্দর্যের প্রমাণ, আর এটি তার মনের প্রশান্তিরও উৎস।',
  'Hadis ini merupakan asas dalam akhlak mulia dan pendidikan yang baik: apabila seseorang meninggalkan apa yang tidak berkaitan dengannya dan apa yang tidak menjadi urusannya, hal itu membuktikan baiknya keislamannya, dan juga menjadi sumber ketenangan bagi fikirannya.',
  'Этот хадис — основа в благородстве нрава и здоровом воспитании: когда человек отказывается от того, что его не касается и что его не интересует, это доказывает превосходство его ислама и в то же время является источником спокойствия для его души.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-12-Nawawi-Psalmodie-Arabe.mp3',
  5,
  12
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 12
);
