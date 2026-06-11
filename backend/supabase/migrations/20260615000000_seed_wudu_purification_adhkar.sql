-- =============================================================================
-- Seed: "Hygiene & Wudu" category -> "Wudu & Purification" subcategory + 6 adhkars
--
-- Source: user-provided translation sheet (wudu_purification_translations.csv).
--
-- Localization mirrors 20260611000000_seed_morning_adhkar.sql and
-- 20260614000000_seed_waking_up_adhkar.sql:
--   * arabic_text      – exact source text
--   * translation_*    – en, fr, de, nl, tr, id, ur, bn, ms, ru (from the sheet)
--   * transcription_*  – Latin transliteration in VALUES; fanned out to every
--                        Latin-script column (step 4b) + dedicated ur/bn/ru
--                        native-script transcription (step 4d)
--   * when_*           – per-adhkar context phrase, localised to every language
--                        directly in VALUES
--   * reference_*      – en/fr/ar in VALUES; de/nl/tr/id/ms via step 4c and
--                        ur/bn/ru via step 4d
--
-- Idempotent: category / subcategory inserted only if missing; adhkars inserted
-- only when the subcategory has none yet.
--
-- REVIEW NOTE: hadith references and the ur/bn/ru phonetic transcriptions were
-- not part of the source sheet — they follow the standard Hisnul-Muslim
-- attributions and should be reviewed by a qualified native speaker before
-- production use.
-- =============================================================================

-- ── 1) Category: Hygiene & Wudu ──────────────────────────────────────────────
insert into public.adhkar_categories
  (title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  'Hygiene & Wudu', 'Hygiène et ablutions', 'النظافة والوضوء', 'Hygiene & Wudu',
  'Hygiëne & wudu', 'Hijyen & Abdest', 'Kebersihan & Wudhu', 'صفائی اور وضو',
  'পরিচ্ছন্নতা ও ওযু', 'Kebersihan & Wuduk', 'Гигиена и вуду', 2
where not exists (
  select 1 from public.adhkar_categories where title_en = 'Hygiene & Wudu'
);

-- ── 2) Subcategory: Wudu & Purification ──────────────────────────────────────
-- No recommended time window (performed before each prayer / as needed).
insert into public.adhkar_subcategories
  (adhkar_category_id, title_en, title_fr, title_ar, title_de, title_nl, title_tr,
   title_id, title_ur, title_bn, title_ms, title_ru, position)
select
  c.id, 'Wudu & Purification', 'Ablutions et purification', 'الوضوء والطهارة',
  'Wudu & Reinigung', 'Wudu & reiniging', 'Abdest & Temizlik', 'Wudhu & Penyucian',
  'وضو اور طہارت', 'ওযু ও পবিত্রতা', 'Wuduk & Penyucian', 'Вуду (омовение) и очищение',
  1
from public.adhkar_categories c
where c.title_en = 'Hygiene & Wudu'
  and not exists (
    select 1 from public.adhkar_subcategories s
    where s.title_en = 'Wudu & Purification' and s.adhkar_category_id = c.id
  );

-- ── 3) Adhkars ───────────────────────────────────────────────────────────────
insert into public.adhkars (
  adhkar_subcategory_id,
  arabic_text,
  transcription_en,
  translation_en, translation_fr, translation_de, translation_nl, translation_tr,
  translation_id, translation_ur, translation_bn, translation_ms, translation_ru,
  when_en, when_fr, when_ar, when_de, when_nl, when_tr, when_id, when_ms, when_ur,
  when_bn, when_ru,
  reference_en, reference_fr, reference_ar,
  min_count, ajr
)
select s.id, v.*
from public.adhkar_subcategories s
cross join (
  values
  -- ═══════════════════════ 1. Before entering the lavatory ══════════════════
  (
    'بِسْمِ اللّٰهِ ، اَللّٰهُمَّ إِنِّيْ أَعُوْذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ.',
    'Bismi-llāh, allāhumma innī aʿūdhu bika mina-l-khubuthi wa-l-khabā''ith.',
    'In the Name of Allah. O Allah, I seek Your protection from the male and female devils.',
    'Au nom d''Allah. Ô Allah, je cherche Ta protection contre les démons mâles et femelles.',
    'Im Namen Allahs. O Allah, ich suche Zuflucht bei Dir vor den männlichen und weiblichen Teufeln.',
    'In de naam van Allah. O Allah, ik zoek bescherming bij U tegen de mannelijke en vrouwelijke duivels.',
    'Allah''ın adıyla. Allah''ım! Erkek ve dişi şeytanlardan (bütün kötülüklerden) Sana sığınırım.',
    'Dengan nama Allah. Ya Allah, sesungguhnya aku berlindung kepada-Mu dari godaan setan laki-laki dan setan perempuan.',
    'اللہ کے نام کے ساتھ۔ اے اللہ! میں خبیث جنوں اور جنیوں سے تیری پناہ مانگتا ہوں۔',
    'আল্লাহর নামে। হে আল্লাহ! আমি আপনার কাছে পুরুষ ও নারী শয়তানের অনিষ্ট থেকে আশ্রয় চাচ্ছি।',
    'Dengan nama Allah. Ya Allah, sesungguhnya aku berlindung kepada-Mu daripada gangguan syaitan jantan dan syaitan betina.',
    'С именем Аллаха. О Аллах, поистине, я прибегаю к Тебе за защитой от порочных джиннов мужского и женского пола.',
    'Before entering the lavatory', 'Avant d''entrer aux toilettes', 'قبل دخول الخلاء',
    'Vor dem Betreten der Toilette', 'Voor het betreden van het toilet',
    'Tuvalete girmeden önce', 'Sebelum masuk ke kamar kecil',
    'Sebelum masuk ke tandas', 'بیت الخلاء میں داخل ہونے سے پہلے',
    'শৌচাগারে প্রবেশের আগে', 'Перед входом в туалет',
    'Bukhārī 142, Muslim 375', 'Bukhārī 142, Muslim 375', 'صحيح البخاري ١٤٢، صحيح مسلم ٣٧٥',
    1::smallint, 5::smallint
  ),
  -- ═══════════════════ 2. After coming out of the lavatory ══════════════════
  (
    'غُفْرَانَكَ.',
    'Ghufrānak.',
    'I seek Your forgiveness.',
    'Je demande Ton pardon.',
    'Ich bitte Dich um Vergebung.',
    'Ik vraag U om vergeving.',
    'Bağışlamanı dilerim.',
    'Aku memohon ampunan-Mu.',
    'میں تجھ سے بخشش مانگتا ہوں۔',
    'আমি আপনার ক্ষমা প্রার্থনা করছি।',
    'Aku memohon keampunan-Mu.',
    'Прошу Твоего прощения.',
    'After coming out of the lavatory', 'En sortant des toilettes', 'بعد الخروج من الخلاء',
    'Nach dem Verlassen der Toilette', 'Na het verlaten van het toilet',
    'Tuvaletten çıktıktan sonra', 'Setelah keluar dari kamar kecil',
    'Selepas keluar dari tandas', 'بیت الخلاء سے نکلنے کے بعد',
    'শৌচাগার থেকে বের হওয়ার পর', 'После выхода из туалета',
    'Abū Dāwūd 30', 'Abū Dāwūd 30', 'سنن أبي داود ٣٠',
    1::smallint, 5::smallint
  ),
  -- ════════════════════════════ 3. Before wudu ══════════════════════════════
  (
    'بِسْمِ اللّٰهِ.',
    'Bismi-llāh.',
    'In the Name of Allah.',
    'Au nom d''Allah.',
    'Im Namen Allahs.',
    'In de naam van Allah.',
    'Allah''ın adıyla.',
    'Dengan nama Allah.',
    'اللہ کے نام کے ساتھ۔',
    'আল্লাহর নামে।',
    'Dengan nama Allah.',
    'С именем Аллаха.',
    'Before wudu', 'Avant les ablutions (wudu)', 'قبل الوضوء',
    'Vor dem Wudu', 'Voor de wudu',
    'Abdesten önce', 'Sebelum wudhu',
    'Sebelum wuduk', 'وضو سے پہلے',
    'ওযুর আগে', 'Перед омовением (вуду)',
    'Abū Dāwūd 101', 'Abū Dāwūd 101', 'سنن أبي داود ١٠١',
    1::smallint, 5::smallint
  ),
  -- ═════════════════ 4. When passing fingers through the beard ══════════════
  (
    'هَـٰكَذَا أَمَرَنِيْ رَبِّيْ عَزَّ وَجَلَّ.',
    'Hākadhā amaranī Rabbī ʿazza wa jall.',
    'This is what I have been ordered to do by my Lord.',
    'C''est ce que mon Seigneur m''a ordonné de faire.',
    'Dies ist, was mir von meinem Herrn befohlen wurde.',
    'Dit is wat mij is opgedragen door mijn Heer.',
    'Rabbim azze ve celle bana böyle yapmamı emretti.',
    'Beginilah yang diperintahkan oleh Tuhanku Azza wa Jalla kepadaku.',
    'مجھے میرے رب عزوجل نے اسی طرح کرنے کا حکم دیا ہے۔',
    'আমার প্রতিপালক (আজযা ওয়া জাল) আমাকে এমনই নির্দেশ দিয়েছেন।',
    'Beginilah yang telah diperintahkan kepadaku oleh Tuhanku Azza wa Jalla.',
    'Так повелел мне мой Господь.',
    'When passing fingers through the beard (during wudu)',
    'En passant les doigts dans la barbe (pendant les ablutions)', 'عند تخليل اللحية',
    'Beim Durchkämmen des Bartes mit den Fingern', 'Bij het door de baard halen van de vingers',
    'Sakalı parmaklarla hilallerken', 'Ketika menyela-nyela jenggot',
    'Ketika menyelati janggut', 'وضو میں داڑھی کا خلال کرتے وقت',
    'ওযুতে দাড়ি খিলাল করার সময়', 'При прочёсывании бороды пальцами (во время омовения)',
    'Abū Dāwūd 145', 'Abū Dāwūd 145', 'سنن أبي داود ١٤٥',
    1::smallint, 5::smallint
  ),
  -- ══════════════════════ 5. After completing wudu #1 ═══════════════════════
  (
    'أَشْهَدُ أَنْ لَّا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ ورَسُوْلُهُ ، اَللّٰهُمَّ اجْعَلْنِيْ مِنَ التَّوَّابِيْنَ ، وَاجْعَلْنِيْ مِنَ المُتَطَهِّرِيْنَ.',
    'Ashhadu an lā ilāha illa-llāhu waḥdahū lā sharīka lah, wa ashhadu anna Muḥammadan ʿabduhū wa rasūluh. Allāhumma-jʿalnī mina-t-tawwābīn, wa-jʿalnī mina-l-mutaṭahhirīn.',
    'I bear witness that there is no god but Allah. He is Alone and He has no partner whatsoever. And I bear witness that Muhammad ﷺ is His slave and His Messenger. O Allah, make me amongst the repentant, and make me amongst those who purify themselves.',
    'Je témoigne qu''il n''y a de divinité d''autre qu''Allah, Seul et sans aucun associé. Et je témoigne que Muhammad ﷺ est Son serviteur et Son Messager. Ô Allah, place-moi parmi ceux qui se repentent et place-moi parmi ceux qui se purifient.',
    'Ich bezeuge, dass es keinen Gott gibt außer Allah. Er ist allein und Er hat keinen Partner. Und ich bezeuge, dass Muhammad ﷺ Sein Diener und Sein Gesandter ist. O Allah, mache mich zu den Reuevollen und mache mich zu denen, die sich reinigen.',
    'Ik getuig dat er geen god is dan Allah. Hij is de Enige en Hij heeft geen enkele partner. En ik getuig dat Muhammad ﷺ Zijn dienaar en Zijn Boodschapper is. O Allah, laat mij behoren tot degenen die berouw tonen, en laat mij behoren tot degenen die zich reinigen.',
    'Şehadet ederim ki Allah''tan başka hiçbir ilah yoktur. O tektir, ortağı yoktur. Yine şehadet ederim ki Muhammed ﷺ O''nun kulu ve Elçisidir. Allah''ım! Beni tövbe edenlerden ve çokça temizlenenlerden eyle.',
    'Aku bersaksi bahwa tidak ada tuhan yang berhak disembah selain Allah, Yang Maha Esa dan tidak ada sekutu bagi-Nya. Dan aku bersaksi bahwa Muhammad ﷺ adalah hamba dan Utusan-Nya. Ya Allah, jadikanlah aku termasuk orang-orang yang bertaubat, dan jadikanlah aku termasuk orang-orang yang menyucikan diri.',
    'میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔ اور میں گواہی دیتا ہوں کہ محمد ﷺ اس کے بندے اور اس کے رسول ہیں۔ اے اللہ! مجھے توبہ کرنے والوں میں بنا دے اور مجھے پاکیزگی اختیار کرنے والوں میں شامل کر دے۔',
    'আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো উপাস্য নেই, তিনি একক, তাঁর কোনো শরিক নেই। আমি আরও সাক্ষ্য দিচ্ছি যে, মুহাম্মদ ﷺ তাঁর বান্দা ও রাসুল। হে আল্লাহ! আপনি আমাকে তাওবাকারীদের অন্তর্ভুক্ত করুন এবং পবিত্রতা অর্জনকারীদের অন্তর্ভুক্ত করুন।',
    'Aku bersaksi bahawa tiada tuhan yang berhak disembah melainkan Allah, Yang Maha Esa dan tiada sekutu bagi-Nya. Dan aku bersaksi bahawa Muhammad ﷺ adalah hamba dan Utusan-Nya. Ya Allah, jadikanlah aku dalam kalangan orang yang bertaubat, dan jadikanlah aku dalam kalangan orang yang menyucikan diri.',
    'Свидетельствую, что нет божества, достойного поклонения, кроме одного лишь Аллаха, у Которого нет сотоварища. И свидетельствую, что Мухаммад ﷺ — Его раб и Его посланник. О Аллах, причисли меня к кающимся и причисли меня к очищающимся.',
    'After completing wudu', 'Après avoir terminé les ablutions', 'بعد الفراغ من الوضوء',
    'Nach Abschluss des Wudu', 'Na het voltooien van de wudu',
    'Abdesti tamamladıktan sonra', 'Setelah selesai berwudhu',
    'Selepas selesai berwuduk', 'وضو مکمل کرنے کے بعد',
    'ওযু সম্পন্ন করার পর', 'После завершения омовения',
    'Muslim 234, Tirmidhī 55', 'Muslim 234, Tirmidhī 55', 'صحيح مسلم ٢٣٤، سنن الترمذي ٥٥',
    1::smallint, 5::smallint
  ),
  -- ══════════════════════ 6. After completing wudu #2 ═══════════════════════
  (
    'سُبْحَانَكَ اللّٰهُمَّ وَبِحَمْدِكَ ، أَشْهَدُ أَنْ لَّا إِلٰهَ إِلَّا أَنْتَ ، أَسْتَغْفِرُكَ وأَتُوْبُ إِلَيْكَ.',
    'Subḥānaka-llāhumma wa bi-ḥamdik, ashhadu an lā ilāha illā ant, astaghfiruka wa atūbu ilayk.',
    'You are free from imperfection, O Allah, and all praise is to You. I bear witness that there is no god but You. I seek Your forgiveness and turn to You in repentance.',
    'Gloire et louange à Toi, ô Allah. Je témoigne qu''il n''y a de divinité que Toi. Je demande Ton pardon et je me repens à Toi.',
    'Gepriesen seist Du, o Allah, und alles Lob gebührt Dir. Ich bezeuge, dass es keinen Gott gibt außer Dir. Ich bitte Dich um Vergebung und wende mich Dir in Reue zu.',
    'U bent vrij van imperfecties, o Allah, en alle lof toekomt aan U. Ik getuig dat er geen god is dan U. Ik zoek Uw vergeving en keer in berouw tot U.',
    'Allah''ım! Seni eksik sıfatlardan tenzih eder, hamdimi Sana sunarım. Senden başka hiçbir ilah olmadığına şehadet ederim. Senden bağışlanma diler ve Sana tövbe ederim.',
    'Maha Suci Engkau, ya Allah, dan segala puji bagi-Mu. Aku bersaksi bahwa tidak ada tuhan yang berhak disembah selain Engkau. Aku memohon ampunan-Mu dan bertaubat kepada-Mu.',
    'اے اللہ! تو ہر عیب سے پاک ہے اور تمام تعریفیں تیرے ہی لیے ہیں۔ میں گواہی دیتا ہوں کہ تیرے سوا کوئی معبود نہیں۔ میں تجھ سے مغفرت کا طلب گار ہوں اور تیری بارگاہ میں توبہ کرتا ہوں۔',
    'হে আল্লাহ! আপনার প্রশংসাসহ আপনার পবিত্রতা ঘোষণা করছি। আমি সাক্ষ্য দিচ্ছি যে, আপনি ছাড়া কোনো উপাস্য নেই। আমি আপনার কাছে ক্ষমা প্রার্থনা করছি এবং আপনার দিকেই তাওবা করে ফিরে আসছি।',
    'Maha Suci Engkau, ya Allah, dan segala puji bagi-Mu. Aku bersaksi bahawa tiada tuhan yang berhak disembah melainkan Engkau. Aku memohon ampunan-Mu dan aku bertaubat kepada-Mu.',
    'Пречист Ты, о Аллах, и хвала Тебе. Свидетельствую, что нет божества, достойного поклонения, кроме Тебя. Прошу Тебя о прощении и приношу Тебе свое покаяние.',
    'After completing wudu', 'Après avoir terminé les ablutions', 'بعد الفراغ من الوضوء',
    'Nach Abschluss des Wudu', 'Na het voltooien van de wudu',
    'Abdesti tamamladıktan sonra', 'Setelah selesai berwudhu',
    'Selepas selesai berwuduk', 'وضو مکمل کرنے کے بعد',
    'ওযু সম্পন্ন করার পর', 'После завершения омовения',
    'Nasā''ī, ʿAmal al-Yawm wa-l-Layla 81', 'Nasā''ī, ʿAmal al-Yawm wa-l-Layla 81',
    'سنن النسائي، عمل اليوم والليلة ٨١',
    1::smallint, 5::smallint
  )
) as v(
  arabic_text,
  transcription_en,
  translation_en, translation_fr, translation_de, translation_nl, translation_tr,
  translation_id, translation_ur, translation_bn, translation_ms, translation_ru,
  when_en, when_fr, when_ar, when_de, when_nl, when_tr, when_id, when_ms, when_ur,
  when_bn, when_ru,
  reference_en, reference_fr, reference_ar,
  min_count, ajr
)
where s.title_en = 'Wudu & Purification'
  and not exists (
    select 1 from public.adhkars a where a.adhkar_subcategory_id = s.id
  );

-- ── Step 4: language fan-out (transliteration + references) ───────────────────

-- 4b) Transliteration is language-neutral Latin, reused for every Latin-script
-- language column.
update public.adhkars a
set
  transcription_fr = a.transcription_en,
  transcription_de = a.transcription_en,
  transcription_nl = a.transcription_en,
  transcription_tr = a.transcription_en,
  transcription_id = a.transcription_en,
  transcription_ms = a.transcription_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Wudu & Purification';

-- 4c) Reference for Latin-script languages: collection names stay romanised.
update public.adhkars a
set
  reference_de = a.reference_en,
  reference_nl = a.reference_en,
  reference_tr = a.reference_en,
  reference_id = a.reference_en,
  reference_ms = a.reference_en
from public.adhkar_subcategories s
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Wudu & Purification';

-- 4d) Native-script transliteration + reference for ur / bn / ru, keyed by the
-- (unique) English reference of each adhkar.
update public.adhkars a
set
  transcription_ur = m.t_ur,
  transcription_bn = m.t_bn,
  transcription_ru = m.t_ru,
  reference_ur = m.r_ur,
  reference_bn = m.r_bn,
  reference_ru = m.r_ru
from public.adhkar_subcategories s,
(values
  -- 1. Before entering the lavatory
  ('Bukhārī 142, Muslim 375',
   'بِسْمِ اللہ، اَللّٰھُمَّ اِنِّیْ اَعُوْذُ بِکَ مِنَ الْخُبُثِ وَالْخَبَائِث۔',
   'বিসমিল্লাহ, আল্লাহুম্মা ইন্নী আঊযু বিকা মিনাল খুবুছি ওয়াল খাবাইছ।',
   'Бисми-Ллях, Аллахумма инни а’узу бика мина-ль-хубуси валь-хабаис.',
   'بخاری 142، مسلم 375', 'বুখারী 142, মুসলিম 375', 'аль-Бухари 142, Муслим 375'),
  -- 2. After coming out of the lavatory
  ('Abū Dāwūd 30',
   'غُفْرَانَک۔',
   'গুফরানাক।',
   'Гуфранак.',
   'ابو داؤد 30', 'আবু দাউদ 30', 'Абу Дауд 30'),
  -- 3. Before wudu
  ('Abū Dāwūd 101',
   'بِسْمِ اللہ۔',
   'বিসমিল্লাহ।',
   'Бисми-Ллях.',
   'ابو داؤد 101', 'আবু দাউদ 101', 'Абу Дауд 101'),
  -- 4. When passing fingers through the beard
  ('Abū Dāwūd 145',
   'ھٰکَذَا اَمَرَنِیْ رَبِّیْ عَزَّ وَجَلَّ۔',
   'হাকাযা আমারানী রাব্বী আযযা ওয়া জাল্লা।',
   'Хаказа амарани Рабби ’азза ва джалль.',
   'ابو داؤد 145', 'আবু দাউদ 145', 'Абу Дауд 145'),
  -- 5. After completing wudu #1
  ('Muslim 234, Tirmidhī 55',
   'اَشْھَدُ اَنْ لَّا اِلٰہَ اِلَّا اللہُ وَحْدَہٗ لَا شَرِیْکَ لَہٗ، وَاَشْھَدُ اَنَّ مُحَمَّدًا عَبْدُہٗ وَرَسُوْلُہٗ، اَللّٰھُمَّ اجْعَلْنِیْ مِنَ التَّوَّابِیْنَ، وَاجْعَلْنِیْ مِنَ الْمُتَطَھِّرِیْن۔',
   'আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়াহদাহূ লা শারীকা লাহ, ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহূ ওয়া রাসূলুহ, আল্লাহুম্মাজআলনী মিনাত তাওয়াবীন, ওয়াজআলনী মিনাল মুতাতাহহিরীন।',
   'Ашхаду ан ля иляха илля-Ллаху вахдаху ля шарика лях, ва ашхаду анна Мухаммадан ’абдуху ва расулюх, Аллахумма-дж’альни мина-т-таввабин, ва-дж’альни мина-ль-мутатаххирин.',
   'مسلم 234، ترمذی 55', 'মুসলিম 234, তিরমিযী 55', 'Муслим 234, ат-Тирмизи 55'),
  -- 6. After completing wudu #2
  ('Nasā''ī, ʿAmal al-Yawm wa-l-Layla 81',
   'سُبْحَانَکَ اللّٰھُمَّ وَبِحَمْدِک، اَشْھَدُ اَنْ لَّا اِلٰہَ اِلَّا اَنْت، اَسْتَغْفِرُکَ وَاَتُوْبُ اِلَیْک۔',
   'সুবহানাকাল্লাহুম্মা ওয়া বিহামদিক, আশহাদু আল্লা ইলাহা ইল্লা আনত, আসতাগফিরুকা ওয়া আতূবু ইলাইক।',
   'Субханака-Ллахумма ва би-хамдик, ашхаду ан ля иляха илля ант, астагфирука ва атубу иляйк.',
   'نسائی، عمل الیوم واللیلۃ 81', 'নাসায়ী, আমালুল ইয়াওম ওয়াল লাইলাহ 81', 'ан-Насаи, ’Амаль аль-Йаум ва-ль-Лайля 81')
) as m(ref_key, t_ur, t_bn, t_ru, r_ur, r_bn, r_ru)
where a.adhkar_subcategory_id = s.id
  and s.title_en = 'Wudu & Purification'
  and a.reference_en = m.ref_key;
