-- =============================================================================
-- 40 Hadith Nawawi — Hadith 39: "Pardon for error, forgetfulness, and coercion"
-- Target collection: public.hadith_collections.id = 2  /  position = 39
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
  'No blame for error, forgetfulness, or coercion',
  'Pas de gêne dans la religion',
  'التجاوز عن المخطئ والناسي والمكره',
  'Verzeihung für Irrtum, Vergessen und Zwang',
  'Geen blaam voor fout, vergetelheid of dwang',
  'Hata, unutma ve zorlamanın bağışlanması',
  'Pemaafan atas kekeliruan, lupa, dan paksaan',
  'خطا، بھول اور جبر کی معافی',
  'ভুল, বিস্মৃতি ও বাধ্যতার ক্ষমা',
  'Pemaafan atas kesilapan, lupa, dan paksaan',
  'Прощение ошибки, забывчивости и принуждения',
  -- arabic_text
  'عَنِ ابْنِ عَبَّاسٍ رَضِيَ اللَّهُ عَنْهُمَا أَنَّ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ قَالَ: «إِنَّ اللَّهَ تَجَاوَزَ لِي عَنْ أُمَّتِي الْخَطَأَ وَالنِّسْيَانَ وَمَا اسْتُكْرِهُوا عَلَيْهِ»',
  -- transcription
  'ʿani bni ʿAbbāsin raḍiya Llāhu ʿanhumā anna Rasūla Llāhi ṣalla Llāhu ʿalayhi wa-sallama qāla: inna Llāha tajāwaza lī ʿan ummatī l-khaṭaʾa wa-n-nisyāna wa-mā stukrihū ʿalayhi.',
  'ʿani bni ʿAbbâsin (radia Llâhou ʿanhoumâ) anna Rassôla Llâhi (salla Llâhou ʿalayhi wa sallam) qâla : inna Llâha tajâwaza lî ʿan oummatî l-khataʾa wa n-nisyâna wa mâ stoukrihô ʿalayhi.',
  'ʿani bni ʿAbbāsin (radiya Llāhu ʿanhumā) anna Rasūla Llāhi (salla Llāhu ʿalaihi wa-sallam) qāla: inna Llāha tadschāwaza lī ʿan ummatī l-chataʾa wa-n-nisjāna wa-mā stukrihū ʿalaihi.',
  'ʿani bni ʿAbbaasin (radia Llaahoe ʿanhoemaa) anna Rasoela Llaahi (salla Llaahoe ʿalaihi wa-sallam) qaala: inna Llaaha tadzjaawaza lie ʿan oemmatie l-chataʾa wa-n-nisjaana wa-maa stoekrihoe ʿalaihi.',
  'an İbn Abbâs''tan (radıyallâhu anhümâ) rivayetle Resûlullah (s.a.v.) şöyle buyurdu: şüphesiz Allah, benim hatırıma ümmetimden hatayı, unutmayı ve zorlandıkları şeyi affetti (bağışladı).',
  'an Ibni ʿAbbas (radhiyallahu ʿanhuma) bahwa Rasulullah (shallallahu ʿalaihi wa sallam) bersabda: sesungguhnya Allah memaafkan dariku (untuk) umatku: kekeliruan, lupa, dan apa yang mereka dipaksa atasnya.',
  'ابن عباس رضی اللہ عنہما سے روایت ہے کہ رسول اللہ صلی اللہ علیہ وسلم نے فرمایا: بے شک اللہ نے میری خاطر میری امت سے خطا، بھول اور اس چیز کو معاف کر دیا جس پر انہیں مجبور کیا جائے۔',
  'ইবনে আব্বাস (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত যে রাসূলুল্লাহ (সাল্লাল্লাহু আলাইহি ওয়া সাল্লাম) বলেছেন: নিশ্চয়ই আল্লাহ আমার উম্মতের পক্ষ থেকে আমার জন্য ভুল, বিস্মৃতি এবং যার প্রতি তাদের বাধ্য করা হয় তা ক্ষমা করে দিয়েছেন।',
  'an Ibni ʿAbbas (radhiallahu ʿanhuma) bahawa Rasulullah (sallallahu ʿalaihi wa sallam) bersabda: sesungguhnya Allah memaafkan daripadaku (untuk) umatku: kesilapan, lupa, dan apa yang mereka dipaksa atasnya.',
  'От Ибн Аббаса (да будет доволен Аллах ими обоими) передаётся, что Посланник Аллаха ﷺ сказал: поистине, Аллах простил ради меня моей общине ошибку, забывчивость и то, к чему их принудили.',
  -- translation
  'On the authority of Ibn ʿAbbas (may Allah be pleased with them both), the Messenger of Allah ﷺ said: "Indeed Allah has pardoned for me, on behalf of my community, error, forgetfulness, and that which they are coerced into doing."',
  'D''après Ibn ʿAbbâs (qu''Allah les agrée tous deux), l''Envoyé d''Allah ﷺ a dit : « En ma faveur, Allah a absous de ma communauté l''erreur, l''oubli et ce qu''ils font sous la contrainte. »',
  'Nach Ibn ʿAbbas (möge Allah mit beiden zufrieden sein) sagte der Gesandte Allahs ﷺ: „Wahrlich, Allah hat mir zuliebe meiner Gemeinschaft den Irrtum, das Vergessen und das, wozu sie gezwungen werden, verziehen."',
  'Op gezag van Ibn ʿAbbas (moge Allah tevreden met hen beiden zijn) zei de Boodschapper van Allah ﷺ: „Voorwaar, Allah heeft mij ten gunste van mijn gemeenschap de fout, de vergetelheid en datgene waartoe zij gedwongen worden, vergeven."',
  'İbn Abbâs''tan (Allah her ikisinden de razı olsun) rivayet edildiğine göre Resûlullah ﷺ şöyle buyurdu: „Şüphesiz Allah, benim hatırıma ümmetimden hatayı, unutmayı ve zorlandıkları şeyi affetti."',
  'Dari Ibnu ʿAbbas (semoga Allah meridhai keduanya), Rasulullah ﷺ bersabda: "Sesungguhnya Allah memaafkan dariku (untuk) umatku: kekeliruan, lupa, dan apa yang mereka dipaksa atasnya."',
  'ابن عباس رضی اللہ عنہما سے روایت ہے کہ رسول اللہ ﷺ نے فرمایا: ”بے شک اللہ نے میری خاطر میری امت سے خطا، بھول اور اس چیز کو معاف کر دیا جس پر انہیں مجبور کیا جائے۔“',
  'ইবনে আব্বাস (রাদিয়াল্লাহু আনহুমা) থেকে বর্ণিত, রাসূলুল্লাহ ﷺ বলেছেন: "নিশ্চয়ই আল্লাহ আমার উম্মতের পক্ষ থেকে আমার জন্য ভুল, বিস্মৃতি এবং যার প্রতি তাদের বাধ্য করা হয় তা ক্ষমা করে দিয়েছেন।"',
  'Daripada Ibnu ʿAbbas (semoga Allah meredai keduanya), Rasulullah ﷺ bersabda: "Sesungguhnya Allah memaafkan daripadaku (untuk) umatku: kesilapan, lupa, dan apa yang mereka dipaksa atasnya."',
  'Со слов Ибн Аббаса (да будет доволен Аллах ими обоими) Посланник Аллаха ﷺ сказал: «Поистине, Аллах ради меня простил моей общине ошибку, забывчивость и то, к чему их принудили».',
  -- reference
  'Sahih — reported by Ibn Majah (no. 2045), ad-Daraqutni (4/170), al-Bayhaqi (7/356), and al-Hakim (2/198); graded sahih by al-Albani in al-Irwaʾ (no. 82)',
  'Hadith authentique rapporté par Ibn Mâja (n°2045), ad-Dâraqutnî (4/170), al-Bayhaqî (7/356) et al-Hâkim (2/198) ; déclaré sahih par al-Albânî dans al-Irwâʾ (n°82)',
  'حديث صحيح، رواه ابن ماجه (رقم ٢٠٤٥) والدارقطني (٤/١٧٠) والبيهقي (٧/٣٥٦) والحاكم (٢/١٩٨)، وصححه الألباني في الإرواء (رقم ٨٢)',
  'Sahih — überliefert von Ibn Madscha (Nr. 2045), ad-Daraqutni (4/170), al-Bayhaqi (7/356) und al-Hakim (2/198); von al-Albani in al-Irwaʾ (Nr. 82) als sahih eingestuft',
  'Sahih — overgeleverd door Ibn Madja (nr. 2045), ad-Daraqutni (4/170), al-Bayhaqi (7/356) en al-Hakim (2/198); door al-Albani in al-Irwaʾ (nr. 82) als sahih beoordeeld',
  'Sahih — İbn Mâce (no. 2045), Dârekutnî (4/170), Beyhakî (7/356) ve Hâkim (2/198) rivayet etmiştir; Elbânî el-İrvâ''da (no. 82) sahih demiştir',
  'Hadis sahih, diriwayatkan oleh Ibnu Majah (no. 2045), ad-Daraquthni (4/170), al-Baihaqi (7/356), dan al-Hakim (2/198); dinilai sahih oleh al-Albani dalam al-Irwaʾ (no. 82)',
  'صحیح حدیث، اسے ابن ماجہ (نمبر ۲۰۴۵)، دارقطنی (۴/۱۷۰)، بیہقی (۷/۳۵۶) اور حاکم (۲/۱۹۸) نے روایت کیا؛ البانی نے الارواء (نمبر ۸۲) میں صحیح کہا',
  'সহীহ হাদীস — ইবনে মাজাহ (নং ২০৪৫), দারাকুতনী (৪/১৭০), বায়হাকী (৭/৩৫৬) ও হাকিম (২/১৯৮) বর্ণনা করেছেন; আলবানী আল-ইরওয়ায় (নং ৮২) সহীহ বলেছেন',
  'Hadis sahih, diriwayatkan oleh Ibnu Majah (no. 2045), ad-Daraqutni (4/170), al-Baihaqi (7/356), dan al-Hakim (2/198); dinilai sahih oleh al-Albani dalam al-Irwaʾ (no. 82)',
  'Достоверный хадис, передали Ибн Маджа (№ 2045), ад-Даракутни (4/170), аль-Байхаки (7/356) и аль-Хаким (2/198); аль-Альбани в «аль-Ирва» (№ 82) назвал его достоверным',
  -- audio_url, ajr, position
  'https://www.40-hadith-nawawi.com/wp-content/uploads/2023/01/Hadith-39-Nawawi-Psalmodie-Arabe.mp3',
  5,
  39
where not exists (
  select 1 from public.hadiths
  where hadith_collection_id = 2 and position = 39
);
