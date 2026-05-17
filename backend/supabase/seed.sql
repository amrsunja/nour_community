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
