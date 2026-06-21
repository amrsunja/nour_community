-- =============================================================================
-- 40 Hadith Nawawi — Hadith 13: "Loving for your brother what you love for yourself"
-- Target collection: public.hadith_collections.id = 2  /  position = 13
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
  'The completeness of faith',
  'La plénitude de la foi',
  'كمال الإيمان',
  'Die Vollkommenheit des Glaubens',
  'De volkomenheid van het geloof',
  'İmanın kemali',
  'Kesempurnaan iman',
  'ایمان کی تکمیل',
  'ঈমানের পূর্ণতা',
  'Kesempurnaan iman',
  'Совершенство веры',
  -- arabic_text
  'عَنْ أَبِي حَمْزَةَ أَنَسِ بْنِ مَالِكٍ رَضِيَ اللَّهُ عَنْهُ خَادِمِ رَسُولِ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ عَنِ النَّبِيِّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ قَالَ: «لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ»',
  -- transcription
  'ʿan Abī Ḥamzata Anasi bni Mālikin raḍiya Llāhu ʿanhu khādimi Rasūli Llāhi ṣalla Llāhu ʿalayhi wa-sallama ʿani n-Nabiyyi ṣalla Llāhu ʿalayhi wa-sallama qāla: lā yuʾminu aḥadukum ḥattā yuḥibba li-akhīhi mā yuḥibbu li-nafsih.',
  'ʿan Abî Hamzata Anasi bni Mâlikin (radia Llâhou ʿanhou) khâdimi Rassôli Llâhi (salla Llâhou ʿalayhi wa sallam) ʿani n-Nabiyyi (salla Llâhou ʿalayhi wa sallam) qâla : lâ youʾminou ahadoukoum hattâ youhibba li-akhîhi mâ youhibbou li-nafsih.',
  'ʿan Abī Hamzata Anasi bni Mālikin (radiya Llāhu ʿanhu) chādimi Rasūli Llāhi (salla Llāhu ʿalaihi wa-sallam) ʿani n-Nabijji (salla Llāhu ʿalaihi wa-sallam) qāla: lā juʾminu ahadukum hattā juhibba li-achīhi mā juhibbu li-nafsih.',
  'ʿan Abie Hamzata Anasi bni Maalikin (radia Llaahoe ʿanhoe) chaadimi Rasoeli Llaahi (salla Llaahoe ʿalaihi wa-sallam) ʿani n-Nabijji (salla Llaahoe ʿalaihi wa-sallam) qaala: laa joeʾminoe ahadoekoem hattaa joehibba li-achiehi maa joehibboe li-nafsih.',
  'an Ebû Hamza Enes ibn Mâlik''ten (radıyallâhu anh) — Resûlullah''ın (s.a.v.) hizmetçisi — Nebî''den (s.a.v.) rivayetle buyurdu: lâ yuʾminu ehadukum hattâ yuhibbe li-ahîhi mâ yuhibbu li-nefsih.',
  'ʿan Abī Hamzah Anas bin Mālik (radhiyallāhu ʿanhu) pelayan Rasulullah (shallallāhu ʿalaihi wa sallam) dari Nabi (shallallāhu ʿalaihi wa sallam) bersabda: lā yuʾminu ahadukum hattā yuhibba li-akhīhi mā yuhibbu li-nafsih.',
  'ابو حمزہ انس بن مالک رضی اللہ عنہ — جو رسول اللہ صلی اللہ علیہ وسلم کے خادم ہیں — نبی صلی اللہ علیہ وسلم سے روایت کرتے ہیں کہ آپ نے فرمایا: لا یُؤمِنُ اَحَدُکُم حَتّٰی یُحِبَّ لِاَخِیہِ ما یُحِبُّ لِنَفسِہِ۔',
  'আবু হামযা আনাস ইবনে মালিক (রাদিয়াল্লাহু আনহু) — রাসূলুল্লাহ ﷺ-এর খাদেম — নবী ﷺ থেকে বর্ণনা করেন যে তিনি বলেছেন: লা ইউমিনু আহাদুকুম হাত্তা ইউহিব্বা লিআখীহি মা ইউহিব্বু লিনাফসিহ।',
  'ʿan Abī Hamzah Anas bin Mālik (radhiallāhu ʿanhu) pelayan Rasulullah (sallallāhu ʿalaihi wa sallam) daripada Nabi (sallallāhu ʿalaihi wa sallam) bersabda: lā yuʾminu ahadukum hattā yuhibba li-akhīhi mā yuhibbu li-nafsih.',
  'Ан Аби Хамза Анас ибн Малик (да будет доволен им Аллах) — слуга Посланника Аллаха ﷺ — от Пророка ﷺ передал, что он сказал: ля юʾмину ахадукум хатта юхибба ли-ахихи ма юхиббу ли-нафсих.',
  -- translation
  'On the authority of Abu Hamza Anas ibn Malik (may Allah be pleased with him), the servant of the Messenger of Allah ﷺ, the Prophet ﷺ said: "None of you (truly) believes until he loves for his brother what he loves for himself."',
  'D''après Abû Hamza Anas ibn Mâlik (qu''Allah l''agrée), le serviteur de l''Envoyé d''Allah ﷺ, le Prophète ﷺ a dit : « Aucun de vous ne croira (vraiment) jusqu''à ce qu''il aime pour son frère ce qu''il aime pour lui-même. »',
  'Nach Abu Hamza Anas ibn Malik (möge Allah mit ihm zufrieden sein), dem Diener des Gesandten Allahs ﷺ, sagte der Prophet ﷺ: „Keiner von euch glaubt (wahrhaft), bis er für seinen Bruder liebt, was er für sich selbst liebt."',
  'Op gezag van Abu Hamza Anas ibn Malik (moge Allah tevreden met hem zijn), de dienaar van de Boodschapper van Allah ﷺ, zei de Profeet ﷺ: „Niemand van jullie gelooft (waarlijk) totdat hij voor zijn broeder liefheeft wat hij voor zichzelf liefheeft."',
  'Ebû Hamza Enes ibn Mâlik''ten (Allah ondan razı olsun), Resûlullah''ın ﷺ hizmetçisinden rivayetle Peygamber ﷺ şöyle buyurdu: „Sizden biri, kendisi için sevdiğini kardeşi için de sevmedikçe (gerçek anlamda) iman etmiş olmaz."',
  'Dari Abu Hamzah Anas bin Malik (semoga Allah meridhainya), pelayan Rasulullah ﷺ, Nabi ﷺ bersabda: "Tidaklah (sempurna) iman salah seorang dari kalian hingga ia mencintai untuk saudaranya apa yang ia cintai untuk dirinya sendiri."',
  'ابو حمزہ انس بن مالک رضی اللہ عنہ — جو رسول اللہ ﷺ کے خادم ہیں — سے روایت ہے کہ نبی ﷺ نے فرمایا: ”تم میں سے کوئی (کامل) مومن نہیں ہو سکتا جب تک وہ اپنے بھائی کے لیے وہی پسند نہ کرے جو اپنے لیے پسند کرتا ہے۔“',
  'আবু হামযা আনাস ইবনে মালিক (রাদিয়াল্লাহু আনহু) — রাসূলুল্লাহ ﷺ-এর খাদেম — থেকে বর্ণিত, নবী ﷺ বলেছেন: "তোমাদের কেউ (পূর্ণ) মুমিন হবে না যতক্ষণ না সে তার ভাইয়ের জন্য তা-ই পছন্দ করে যা সে নিজের জন্য পছন্দ করে।"',
  'Daripada Abu Hamzah Anas bin Malik (semoga Allah meredainya), pelayan Rasulullah ﷺ, Nabi ﷺ bersabda: "Tidaklah (sempurna) iman seseorang daripada kamu sehingga dia mencintai untuk saudaranya apa yang dia cintai untuk dirinya sendiri."',
  'Со слов Абу Хамзы Анаса ибн Малика (да будет доволен им Аллах), слуги Посланника Аллаха ﷺ, Пророк ﷺ сказал: «Не уверует (по-настоящему) никто из вас, пока не станет желать своему брату того же, чего желает самому себе».',
  -- reference
  'Sahih — reported by Al-Bukhari (1/10, no. 13) and Muslim (no. 71)',
  'Hadith authentique rapporté par Al-Bukhari (1/10, n°13) et Muslim (n°71)',
  'حديث صحيح، رواه البخاري (١/١٠) (رقم ١٣) ومسلم (رقم ٧١)',
  'Sahih — überliefert von Al-Bukhari (1/10, Nr. 13) und Muslim (Nr. 71)',
  'Sahih — overgeleverd door Al-Bukhari (1/10, nr. 13) en Muslim (nr. 71)',
  'Sahih — Buhârî (1/10, no. 13) ve Müslim (no. 71) rivayet etmiştir',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (1/10, no. 13) dan Muslim (no. 71)',
  'صحیح حدیث، اسے بخاری (۱/۱۰، نمبر ۱۳) اور مسلم (نمبر ۷۱) نے روایت کیا',
  'সহীহ হাদীস — বুখারী (১/১০, নং ১৩) ও মুসলিম (নং ৭১) বর্ণনা করেছেন',
  'Hadis sahih, diriwayatkan oleh Al-Bukhari (1/10, no. 13) dan Muslim (no. 71)',
  'Достоверный хадис, передали аль-Бухари (1/10, № 13) и Муслим (№ 71)',
  -- tafsir
  '"None of you (truly) believes…": the faith intended in this passage is complete faith. "…until he loves for his brother…" — that is, his brother in Islam. "…what he loves for himself" — and that applies both in the domain of religion and in the domain of worldly life, for brotherhood in faith consists of loving for one''s brother what one loves for oneself.',
  '« Aucun de vous ne croira (vraiment)… » : la foi désignée dans ce passage est la foi parfaite. « … jusqu''à ce qu''il aime pour son frère » — c''est-à-dire son frère en Islam. « … ce qu''il aime pour lui-même » — et ce, aussi bien dans le domaine de la religion que dans celui de la vie d''ici-bas, car la fraternité dans la foi consiste à aimer pour son frère ce que l''on aime pour soi-même.',
  '«لا يؤمن أحدكم»: الإيمان المراد في هذا الموضع هو الإيمان الكامل. «حتى يحب لأخيه» أي أخيه في الإسلام. «ما يحب لنفسه» وذلك في أمور الدين وأمور الدنيا على حد سواء، فإن الأخوة في الإيمان تقتضي أن يحب المرء لأخيه ما يحب لنفسه.',
  '„Keiner von euch glaubt (wahrhaft)…": der hier gemeinte Glaube ist der vollkommene Glaube. „…bis er für seinen Bruder liebt" — das heißt, seinen Bruder im Islam. „…was er für sich selbst liebt" — und zwar sowohl im Bereich der Religion als auch im Bereich des weltlichen Lebens, denn die Bruderschaft im Glauben besteht darin, für seinen Bruder zu lieben, was man für sich selbst liebt.',
  '„Niemand van jullie gelooft (waarlijk)…": het geloof dat hier bedoeld wordt, is het volkomen geloof. „…totdat hij voor zijn broeder liefheeft" — dat wil zeggen zijn broeder in de islam. „…wat hij voor zichzelf liefheeft" — en dat zowel op het gebied van de religie als op het gebied van het wereldse leven, want de broederschap in het geloof bestaat erin voor zijn broeder lief te hebben wat men voor zichzelf liefheeft.',
  '„Sizden biri (gerçek anlamda) iman etmiş olmaz…": burada kastedilen iman, kâmil (kemale ermiş) imandır. „…kardeşi için sevmedikçe" — yani İslâm''daki kardeşi için. „…kendisi için sevdiğini" — bu, hem din işlerinde hem de dünya işlerinde geçerlidir; zira imandaki kardeşlik, kişinin kendisi için sevdiğini kardeşi için de sevmesini gerektirir.',
  '"Tidaklah (sempurna) iman salah seorang dari kalian…": iman yang dimaksud dalam ungkapan ini adalah iman yang sempurna. "…hingga ia mencintai untuk saudaranya" — yakni saudaranya seislam. "…apa yang ia cintai untuk dirinya sendiri" — dan itu berlaku baik dalam urusan agama maupun urusan dunia, karena persaudaraan dalam iman menuntut seseorang mencintai untuk saudaranya apa yang ia cintai untuk dirinya sendiri.',
  '”تم میں سے کوئی (کامل) مومن نہیں ہو سکتا“: اس مقام پر مراد ایمان، کامل ایمان ہے۔ ”جب تک وہ اپنے بھائی کے لیے پسند نہ کرے“ یعنی اپنے اسلامی بھائی کے لیے۔ ”جو اپنے لیے پسند کرتا ہے“ اور یہ دین کے معاملات اور دنیا کے معاملات دونوں میں یکساں ہے، کیونکہ ایمانی بھائی چارے کا تقاضا یہی ہے کہ آدمی اپنے بھائی کے لیے وہی پسند کرے جو اپنے لیے پسند کرتا ہے۔',
  '"তোমাদের কেউ (পূর্ণ) মুমিন হবে না…": এখানে উদ্দিষ্ট ঈমান হলো পূর্ণাঙ্গ ঈমান। "যতক্ষণ না সে তার ভাইয়ের জন্য পছন্দ করে" — অর্থাৎ তার ইসলামী ভাইয়ের জন্য। "যা সে নিজের জন্য পছন্দ করে" — আর তা দ্বীনের বিষয়েও যেমন, দুনিয়ার বিষয়েও তেমন; কারণ ঈমানি ভ্রাতৃত্বের দাবি হলো মানুষ তার ভাইয়ের জন্য তা-ই পছন্দ করবে যা সে নিজের জন্য পছন্দ করে।',
  '"Tidaklah (sempurna) iman seseorang daripada kamu…": iman yang dimaksudkan dalam ungkapan ini ialah iman yang sempurna. "…sehingga dia mencintai untuk saudaranya" — iaitu saudaranya seislam. "…apa yang dia cintai untuk dirinya sendiri" — dan itu berlaku sama ada dalam urusan agama mahupun urusan dunia, kerana persaudaraan dalam iman menuntut seseorang mencintai untuk saudaranya apa yang dia cintai untuk dirinya sendiri.',
  '«Не уверует (по-настоящему) никто из вас…»: вера, имеющаяся в виду в этом месте, — это совершенная вера. «…пока не станет желать своему брату» — то есть своему брату в исламе. «…того же, чего желает самому себе» — и это касается как дел религии, так и дел мирской жизни, ибо братство в вере требует, чтобы человек желал своему брату того же, чего желает самому себе.',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2022/08/Hadith-13-Nawawi-Psalmodie-Arabe.mp3',
  5,
  13
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 13
);
