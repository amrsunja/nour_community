-- =============================================================================
-- Impact projects: schema top-up + seed data
--   * adds impact_projects.donors_count (display-only "X people have donated")
--   * seeds the V1 categories, a verified partner org, one test project and
--     its field stories
-- Idempotent: safe to re-run (guards on title / NOT EXISTS).
-- =============================================================================

-- ── Schema top-up ────────────────────────────────────────────────────────────
alter table public.impact_projects
  add column if not exists donors_count int not null default 0
    check (donors_count >= 0);

-- ── Categories (Urgent, Water, Education, Mosque) ────────────────────────────
insert into public.project_categories (title_en, title_fr, title_ar, position)
select v.title_en, v.title_fr, v.title_ar, v.position
from (values
  ('Urgent',    'Urgent',    'عاجل',   1),
  ('Water',     'Eau',       'ماء',    2),
  ('Education', 'Éducation', 'تعليم',  3),
  ('Mosque',    'Mosquée',   'مسجد',   4)
) as v(title_en, title_fr, title_ar, position)
where not exists (
  select 1 from public.project_categories c where c.title_en = v.title_en
);

-- ── Partner organization ─────────────────────────────────────────────────────
insert into public.partner_organizations (name_en, name_fr, name_ar, is_verified)
select 'Islamic Organization', 'Organisation Islamique', 'منظمة إسلامية', true
where not exists (
  select 1 from public.partner_organizations o where o.name_en = 'Islamic Organization'
);

-- ── Test project: "Feed palestinian families" (Urgent) ───────────────────────
insert into public.impact_projects (
  organization_id, project_category_id,
  title_en, title_fr, title_ar,
  subtitle_en, subtitle_fr, subtitle_ar,
  description_en, description_fr, description_ar,
  cover_image_url,
  required_amount, collected_amount, currency,
  donors_count, eligible_for_zakat, is_active, position
)
select
  o.id, c.id,
  'Feed palestinian families', 'Nourrir les familles palestiniennes', 'إطعام العائلات الفلسطينية',
  'Food, water and medical aid for displaced families',
  'Nourriture, eau et aide médicale pour les familles déplacées',
  'طعام وماء ومساعدات طبية للعائلات النازحة',
  'More than 1.9 million people have been displaced in Gaza, with severe shortages of food, clean water and medical supplies. Your donation funds emergency aid kits delivered directly to families through verified local partners on the ground. Every contribution is tracked and reported so you can see the real impact of your sadaqah.',
  'Plus de 1,9 million de personnes ont été déplacées à Gaza, avec de graves pénuries de nourriture, d''eau potable et de fournitures médicales. Votre don finance des kits d''aide d''urgence livrés directement aux familles par des partenaires locaux vérifiés sur le terrain. Chaque contribution est suivie et rapportée afin que vous puissiez voir l''impact réel de votre sadaqah.',
  'تم تهجير أكثر من 1.9 مليون شخص في غزة، مع نقص حاد في الغذاء والماء النظيف والإمدادات الطبية. يموّل تبرعك أطقم إغاثة طارئة تُسلَّم مباشرة إلى العائلات عبر شركاء محليين موثوقين على الأرض.',
  'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=1200&q=80',
  50000, 12400, 'EUR',
  12000, false, true, 1
from public.partner_organizations o
cross join public.project_categories c
where o.name_en = 'Islamic Organization'
  and c.title_en = 'Urgent'
  and not exists (
    select 1 from public.impact_projects p where p.title_en = 'Feed palestinian families'
  );

-- ── Field stories (newest first is enforced client-side via created_at desc) ──
insert into public.project_stories (
  impact_project_id, title_en, title_fr, title_ar,
  description_en, description_fr, description_ar, images, created_at
)
select p.id, s.title_en, s.title_fr, s.title_ar,
       s.description_en, s.description_fr, s.description_ar,
       s.images, s.created_at
from public.impact_projects p
cross join (values
  (
    '2500 food parcels distributed this week',
    '2500 colis alimentaires distribués cette semaine',
    'توزيع 2500 طرد غذائي هذا الأسبوع',
    'Our team on the ground delivered emergency food supplies to families in northern Gaza, prioritizing households with children and elderly.',
    'Notre équipe sur le terrain a livré des vivres d''urgence aux familles du nord de Gaza, en priorisant les foyers avec enfants et personnes âgées.',
    'قام فريقنا على الأرض بتسليم إمدادات غذائية طارئة للعائلات في شمال غزة، مع إعطاء الأولوية للأسر التي لديها أطفال وكبار السن.',
    array['https://images.unsplash.com/photo-1593113646773-028c64a8f1b8?w=1200&q=80'],
    now() - interval '3 days'
  ),
  (
    'Medical aid kits arrived at Al-Shifa',
    'Des kits médicaux sont arrivés à Al-Shifa',
    'وصول أطقم طبية إلى مستشفى الشفاء',
    '147 emergency kits with antibiotics, bandages and basic supplies were delivered to medical staff.',
    '147 kits d''urgence contenant des antibiotiques, des bandages et des fournitures de base ont été livrés au personnel médical.',
    'تم تسليم 147 طقمًا طارئًا تحتوي على مضادات حيوية وضمادات ومستلزمات أساسية للطاقم الطبي.',
    array['https://images.unsplash.com/photo-1584515933487-779824d29309?w=1200&q=80'],
    now() - interval '7 days'
  ),
  (
    'First wave of volunteers deployed',
    'Premier déploiement de bénévoles',
    'نشر الموجة الأولى من المتطوعين',
    '28 trained volunteers from Islamic Organization joined our local partners on the ground.',
    '28 bénévoles formés de l''Organisation Islamique ont rejoint nos partenaires locaux sur le terrain.',
    'انضم 28 متطوعًا مدربًا من المنظمة الإسلامية إلى شركائنا المحليين على الأرض.',
    array['https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=1200&q=80'],
    now() - interval '14 days'
  )
) as s(title_en, title_fr, title_ar, description_en, description_fr, description_ar, images, created_at)
where p.title_en = 'Feed palestinian families'
  and not exists (
    select 1 from public.project_stories st
    where st.impact_project_id = p.id and st.title_en = s.title_en
  );
