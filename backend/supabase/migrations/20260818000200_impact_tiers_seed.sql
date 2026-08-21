-- =============================================================================
-- Payments V2 (3/3): seed — donation tiers + gallery for the demo project
-- "Feed palestinian families" (matches the design mock).
-- Idempotent: skips rows that already exist.
-- =============================================================================

-- Gallery (3 images → carousel with dots).
update public.impact_projects
   set images = array[
     'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=1200&q=80',
     'https://images.unsplash.com/photo-1593113646773-028c64a8f1b8?w=1200&q=80',
     'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=1200&q=80'
   ]
 where title_en = 'Feed palestinian families'
   and cardinality(images) <= 1;

-- "Your donation provides"
insert into public.impact_project_tiers (
  impact_project_id, amount, position,
  title_en, title_fr, title_ar,
  subtitle_en, subtitle_fr, subtitle_ar
)
select p.id, t.amount, t.position,
       t.title_en, t.title_fr, t.title_ar,
       t.subtitle_en, t.subtitle_fr, t.subtitle_ar
from public.impact_projects p
cross join (values
  (10::numeric, 0,
   'Daily food parcel', 'Colis alimentaire quotidien', 'طرد غذائي يومي',
   'Feeds a family of 5 for 1 day', 'Nourrit une famille de 5 pendant 1 jour', 'يطعم عائلة من 5 أفراد ليوم واحد'),
  (25::numeric, 1,
   'Clean water supply', 'Accès à l''eau potable', 'إمداد بالمياه النظيفة',
   '7-day water access for a family', '7 jours d''eau pour une famille', 'مياه لمدة 7 أيام لعائلة'),
  (50::numeric, 2,
   'Medical aid kit', 'Kit d''aide médicale', 'حقيبة إسعافات طبية',
   'Essential supplies for one person', 'Fournitures essentielles pour une personne', 'مستلزمات أساسية لشخص واحد'),
  (100::numeric, 3,
   'Emergency shelter', 'Abri d''urgence', 'مأوى طارئ',
   'Tent + bedding for a family', 'Tente + literie pour une famille', 'خيمة + فراش لعائلة')
) as t(amount, position, title_en, title_fr, title_ar, subtitle_en, subtitle_fr, subtitle_ar)
where p.title_en = 'Feed palestinian families'
  and not exists (
    select 1 from public.impact_project_tiers x
     where x.impact_project_id = p.id and x.title_en = t.title_en
  );
