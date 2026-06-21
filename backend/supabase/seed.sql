-- =============================================================================
-- Nour Community :: V1 seed data
-- Run via: supabase db reset (re-applies migrations + this file in local dev)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Dhikrs (V1 list)
-- -----------------------------------------------------------------------------
insert into public.dhikrs
  (arabic_text, transcription_en, transcription_fr, translation_en, translation_fr, min_count, ajr)
values
  ('سُبْحَانَ اللَّهِ',         'SubhanAllah',    'SubhanAllah',    'Glory be to Allah',                                  'Gloire à Allah',                                  33, 5),
  ('الْحَمْدُ لِلَّهِ',         'Alhamdulilah',   'Alhamdulilah',   'All praise is due to Allah',                         'Toute louange est à Allah',                       33, 5),
  ('اللَّهُ أَكْبَرُ',          'Allahu Akbar',   'Allahu Akbar',   'Allah is the Greatest',                              'Allah est le plus Grand',                         33, 5),
  ('لَا إِلَٰهَ إِلَّا اللَّهُ', 'La ilaha illallah','La ilaha illallah','There is no deity but Allah',                   'Il n''y a de divinité qu''Allah',                 33, 7),
  ('أَسْتَغْفِرُ اللَّهَ',      'Astaghfirullah', 'Astaghfirullah', 'I seek forgiveness from Allah',                      'Je demande pardon à Allah',                       33, 7),
  ('حَسْبُنَا اللَّهُ',         'Hasbunallah',    'Hasbunallah',    'Allah is sufficient for us',                         'Allah nous suffit',                               33, 5),
  ('لَا حَوْلَ وَلَا قُوَّةَ',  'La hawla wa la quwwata','La hawla wa la quwwata','There is no power nor strength except with Allah','Il n''y a de force ni de puissance qu''en Allah',33, 5)
on conflict do nothing;

-- -----------------------------------------------------------------------------
-- Adhkar categories + subcategories (V1 tree)
-- -----------------------------------------------------------------------------
with cat_insert as (
  insert into public.adhkar_categories (title_en, title_fr, title_ar, position)
  values
    ('Daily routine',  'Routine quotidienne', 'الروتين اليومي', 1),
    ('Hygiene & Wudu', 'Hygiène et Wudu',     'النظافة والوضوء', 2),
    ('Around salah',   'Autour de la salat',  'حول الصلاة',     3),
    ('In daily life',  'Dans la vie quotidienne', 'في الحياة اليومية', 4),
    ('Hard moments',   'Moments difficiles',  'الأوقات الصعبة', 5),
    ('By intention',   'Par intention',       'بحسب النية',     6)
  on conflict do nothing
  returning id, title_en
)
select 1;

-- Subcategories
insert into public.adhkar_subcategories (adhkar_category_id, title_en, title_fr, title_ar, position)
select c.id, s.title_en, s.title_fr, s.title_ar, s.position
from public.adhkar_categories c
join (values
  ('Daily routine', 'Morning adhkar',     'Adhkar du matin',    'أذكار الصباح',          1),
  ('Daily routine', 'Evening adhkar',     'Adhkar du soir',     'أذكار المساء',          2),
  ('Daily routine', 'Before sleep',       'Avant de dormir',    'قبل النوم',             3),
  ('Daily routine', 'When waking up',     'Au réveil',          'عند الاستيقاظ',         4),
  ('Hygiene & Wudu','Wudu & purification','Wudu et purification','الوضوء والطهارة',     1),
  ('Hygiene & Wudu','Clothing',           'Habillement',        'اللباس',                2),
  ('Around salah',  'Adhan & call to prayer','Adhan et appel à la prière','الأذان والإقامة',1),
  ('Around salah',  'Mosque',             'Mosquée',            'المسجد',                2),
  ('Around salah',  'After salah',        'Après la salat',     'بعد الصلاة',            3),
  ('In daily life', 'Eating & drinking',  'Manger et boire',    'الأكل والشرب',          1),
  ('In daily life', 'Entering & leaving home','Entrer et sortir de la maison','دخول وخروج المنزل',2),
  ('In daily life', 'Travel & transit',   'Voyage et déplacements','السفر والتنقل',     3),
  ('Hard moments',  'Anxiety, fear & sadness','Anxiété, peur et tristesse','القلق والخوف والحزن',1),
  ('Hard moments',  'Health & illness',   'Santé et maladie',   'الصحة والمرض',          2),
  ('By intention',  'Istighfar',          'Istighfar',          'الاستغفار',             1),
  ('By intention',  'Protection',         'Protection',         'الحماية',               2),
  ('By intention',  'Gratitude',          'Gratitude',          'الشكر',                 3),
  ('By intention',  'Knowledge',          'Connaissance',       'العلم',                 4)
) as s(parent, title_en, title_fr, title_ar, position)
  on c.title_en = s.parent
on conflict do nothing;

-- -----------------------------------------------------------------------------
-- Hadith collections starter
-- -----------------------------------------------------------------------------
insert into public.hadith_collections
  (title_en, title_fr, title_ar, description_en, description_fr, description_ar, position)
values
  ('40 Hadith Nawawi', '40 Hadith de Nawawi', 'الأربعون النووية',
   'Imam An-Nawawi | The essential 40', 'Imam An-Nawawi | Les 40 essentiels', 'الإمام النووي | الأربعون الأساسية', 1),
  ('Sahih al-Bukhari', 'Sahih al-Boukhari',   'صحيح البخاري',
   'Compilation by Imam al-Bukhari', 'Compilation par l''Imam al-Boukhari', 'تجميع الإمام البخاري', 2),
  ('Sahih Muslim',     'Sahih Muslim',        'صحيح مسلم',
   'Compilation by Imam Muslim', 'Compilation par l''Imam Muslim', 'تجميع الإمام مسلم', 3)
on conflict do nothing;

-- -----------------------------------------------------------------------------
-- 40 Hadith Nawawi — starter hadiths (the most well-known of the collection).
-- Resolves the collection id by title so it stays decoupled from serial ids.
-- -----------------------------------------------------------------------------
insert into public.hadiths (
  hadith_collection_id,
  title_en, title_fr, title_ar,
  description_en, description_fr, description_ar,
  arabic_text,
  translation_en, translation_fr,
  reference_en, reference_fr, reference_ar,
  position
)
select c.id, s.title_en, s.title_fr, s.title_ar,
       s.description_en, s.description_fr, s.description_ar,
       s.arabic_text, s.translation_en, s.translation_fr,
       s.reference_en, s.reference_fr, s.reference_ar, s.position
from public.hadith_collections c
join (values
  (
    'Intentions', 'Les intentions', 'النية',
    'Actions are (judged) by motives…', 'Les actions ne valent que par les intentions…', 'إنما الأعمال بالنيات…',
    'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ لِدُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
    'Actions are but by intention, and every man shall have only that which he intended. So whoever emigrated for Allah and His Messenger, his emigration was for Allah and His Messenger; and whoever emigrated for worldly gain or to marry a woman, his emigration was for that which he emigrated.',
    'Les actions ne valent que par les intentions, et chacun n''a pour lui que ce qu''il a eu l''intention de faire. Celui dont l''émigration est pour Allah et Son Messager, son émigration est pour Allah et Son Messager ; et celui dont l''émigration vise un bien d''ici-bas ou une femme à épouser, son émigration est pour ce vers quoi il a émigré.',
    'Sahih Bukhari 1\nSahih Muslim 1907', 'Sahih Bukhari 1\nSahih Muslim 1907', 'صحيح البخاري ١\nصحيح مسلم ١٩٠٧',
    1
  ),
  (
    'Iman, Islam & Ihsan', 'Iman, Islam et Ihsan', 'الإيمان والإسلام والإحسان',
    'The Hadith of Jibril…', 'Le hadith de Jibril…', 'حديث جبريل…',
    'بَيْنَمَا نَحْنُ جُلُوسٌ عِنْدَ رَسُولِ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ ذَاتَ يَوْمٍ، إِذْ طَلَعَ عَلَيْنَا رَجُلٌ شَدِيدُ بَيَاضِ الثِّيَابِ شَدِيدُ سَوَادِ الشَّعْرِ… فَأَخْبِرْنِي عَنِ الْإِسْلَامِ، وَالْإِيمَانِ، وَالْإِحْسَانِ',
    'One day while we were sitting with the Messenger of Allah ﷺ there came a man with intensely white clothing and very black hair… He said: "Tell me about Islam, Iman and Ihsan." Ihsan is to worship Allah as though you see Him, and though you do not see Him, He surely sees you.',
    'Un jour, alors que nous étions assis auprès du Messager d''Allah ﷺ, un homme aux vêtements d''une blancheur éclatante et aux cheveux très noirs apparut… Il dit : « Renseigne-moi sur l''Islam, l''Iman et l''Ihsan. » L''Ihsan, c''est d''adorer Allah comme si tu Le voyais, car si tu ne Le vois pas, Lui te voit.',
    'Sahih Muslim 8', 'Sahih Muslim 8', 'صحيح مسلم ٨',
    2
  ),
  (
    'Pillars of Islam', 'Les piliers de l''Islam', 'أركان الإسلام',
    'Islam is built upon five…', 'L''Islam est bâti sur cinq…', 'بُني الإسلام على خمس…',
    'بُنِيَ الْإِسْلَامُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلَاةِ، وَإِيتَاءِ الزَّكَاةِ، وَحَجِّ الْبَيْتِ، وَصَوْمِ رَمَضَانَ',
    'Islam is built upon five: the testimony that there is no god but Allah and that Muhammad is the Messenger of Allah, the establishment of prayer, the giving of zakat, the pilgrimage to the House, and fasting in Ramadan.',
    'L''Islam est bâti sur cinq : l''attestation qu''il n''y a de divinité qu''Allah et que Muhammad est le Messager d''Allah, l''accomplissement de la prière, l''acquittement de la zakat, le pèlerinage à la Maison et le jeûne du Ramadan.',
    'Sahih Bukhari 8\nSahih Muslim 16', 'Sahih Bukhari 8\nSahih Muslim 16', 'صحيح البخاري ٨\nصحيح مسلم ١٦',
    3
  ),
  (
    'Rejecting innovation', 'Le rejet de l''innovation', 'رد البدعة',
    'Whoever introduces something…', 'Quiconque introduit quelque chose…', 'من أحدث في أمرنا…',
    'مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ مِنْهُ فَهُوَ رَدٌّ',
    'Whoever introduces into this affair of ours something that is not part of it, it is rejected.',
    'Quiconque introduit dans notre affaire (la religion) ce qui n''en fait pas partie, cela est rejeté.',
    'Sahih Bukhari 2697\nSahih Muslim 1718', 'Sahih Bukhari 2697\nSahih Muslim 1718', 'صحيح البخاري ٢٦٩٧\nصحيح مسلم ١٧١٨',
    5
  ),
  (
    'Halal & Haram', 'Halal et Haram', 'الحلال والحرام',
    'What is lawful is clear…', 'Ce qui est licite est clair…', 'إن الحلال بيّن…',
    'إِنَّ الْحَلَالَ بَيِّنٌ وَإِنَّ الْحَرَامَ بَيِّنٌ، وَبَيْنَهُمَا أُمُورٌ مُشْتَبِهَاتٌ لَا يَعْلَمُهُنَّ كَثِيرٌ مِنَ النَّاسِ',
    'The lawful is clear and the unlawful is clear, and between them are doubtful matters which many people do not know. So whoever guards against the doubtful matters has protected his religion and his honour.',
    'Le licite est clair et l''illicite est clair, et entre les deux il y a des choses douteuses que beaucoup de gens ignorent. Celui qui se garde des choses douteuses préserve sa religion et son honneur.',
    'Sahih Bukhari 52\nSahih Muslim 1599', 'Sahih Bukhari 52\nSahih Muslim 1599', 'صحيح البخاري ٥٢\nصحيح مسلم ١٥٩٩',
    6
  )
) as s(
  title_en, title_fr, title_ar,
  description_en, description_fr, description_ar,
  arabic_text, translation_en, translation_fr,
  reference_en, reference_fr, reference_ar, position
) on true
where c.title_en = '40 Hadith Nawawi'
on conflict do nothing;
