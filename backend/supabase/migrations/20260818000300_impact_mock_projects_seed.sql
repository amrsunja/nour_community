-- =============================================================================
-- Mock impact projects for testing the V2 donation flow.
-- 5 projects across the 4 categories, 2 partner orgs, galleries, tiers and
-- field stories. Idempotent (guards on title_en). Uses Unsplash images.
-- Remove or deactivate (is_active = false) before going live.
-- =============================================================================

-- ── Second partner org (unverified, to test the "Verified" badge absence) ────
insert into public.partner_organizations (name_en, name_fr, name_ar, is_verified, avatar_url)
select 'Nour Relief Foundation', 'Fondation Nour Relief', 'مؤسسة نور للإغاثة', false,
       'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=200&q=80'
where not exists (
  select 1 from public.partner_organizations o where o.name_en = 'Nour Relief Foundation'
);

update public.partner_organizations
   set avatar_url = 'https://images.unsplash.com/photo-1519817650390-64a93db51149?w=200&q=80'
 where name_en = 'Islamic Organization' and avatar_url is null;

-- ── Projects ─────────────────────────────────────────────────────────────────
insert into public.impact_projects (
  organization_id, project_category_id,
  title_en, title_fr, title_ar,
  subtitle_en, subtitle_fr, subtitle_ar,
  description_en, description_fr, description_ar,
  cover_image_url, images, preset_amounts,
  required_amount, collected_amount, currency,
  donors_count, eligible_for_zakat, is_active, position
)
select o.id, c.id,
       v.title_en, v.title_fr, v.title_ar,
       v.subtitle_en, v.subtitle_fr, v.subtitle_ar,
       v.description_en, v.description_fr, v.description_ar,
       v.images[1], v.images, v.presets,
       v.required_amount, v.collected_amount, 'EUR',
       v.donors_count, v.zakat, true, v.position
from (values
  (
    'Islamic Organization', 'Water',
    'Clean water wells in Somalia', 'Puits d''eau potable en Somalie', 'آبار مياه نظيفة في الصومال',
    'Solar-powered wells for 12 villages', 'Puits solaires pour 12 villages', 'آبار تعمل بالطاقة الشمسية لـ 12 قرية',
    'Recurring drought leaves thousands of families walking hours for unsafe water. Each well serves around 400 people with clean water for over 20 years, is maintained by a trained local committee and equipped with a solar pump. Sadaqa jariya at its purest.',
    'Les sécheresses à répétition obligent des milliers de familles à marcher des heures pour une eau insalubre. Chaque puits alimente environ 400 personnes en eau potable pendant plus de 20 ans, entretenu par un comité local formé et équipé d''une pompe solaire. Une sadaqa jariya par excellence.',
    'يجبر الجفاف المتكرر آلاف العائلات على المشي لساعات للحصول على مياه غير آمنة. يخدم كل بئر نحو 400 شخص بمياه نظيفة لأكثر من 20 عامًا، وتتم صيانته من قبل لجنة محلية مدربة ومزوّد بمضخة شمسية. صدقة جارية بأبهى صورها.',
    array[
      'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=1200&q=80',
      'https://images.unsplash.com/photo-1594398901394-4e34939a4fd0?w=1200&q=80'
    ]::text[],
    array[15,30,60,120]::int[],
    36000::numeric, 21850::numeric, 1930, true, 2
  ),
  (
    'Nour Relief Foundation', 'Education',
    'School kits for orphans in Senegal', 'Kits scolaires pour orphelins au Sénégal', 'حقائب مدرسية للأيتام في السنغال',
    'Books, uniforms and a hot meal for a full year', 'Livres, uniformes et un repas chaud pour une année', 'كتب وزي مدرسي ووجبة ساخنة لعام كامل',
    'Orphaned children in the Kaolack region drop out of school because families cannot afford supplies. A yearly kit covers books, notebooks, a uniform, shoes and a daily hot lunch at school. Local teachers report the attendance of sponsored children reaches 96%.',
    'Les orphelins de la région de Kaolack quittent l''école faute de moyens pour les fournitures. Un kit annuel couvre les livres, les cahiers, l''uniforme, les chaussures et un déjeuner chaud quotidien. Les enseignants locaux constatent 96% d''assiduité chez les enfants parrainés.',
    'يترك الأيتام في منطقة كاولاك المدرسة لعدم قدرة الأسر على شراء المستلزمات. تغطي الحقيبة السنوية الكتب والدفاتر والزي والأحذية ووجبة غداء ساخنة يوميًا. يفيد المعلمون بأن حضور الأطفال المكفولين يصل إلى 96%.',
    array[
      'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=1200&q=80',
      'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&q=80',
      'https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?w=1200&q=80'
    ]::text[],
    array[10,25,50,100]::int[],
    18000::numeric, 4320::numeric, 412, true, 3
  ),
  (
    'Islamic Organization', 'Mosque',
    'Rebuild the village mosque in Bosnia', 'Reconstruire la mosquée du village en Bosnie', 'إعادة بناء مسجد القرية في البوسنة',
    'Roof, heating and a small madrasa room', 'Toit, chauffage et une petite salle de madrasa', 'سقف وتدفئة وغرفة صغيرة للمدرسة',
    'The only mosque of a mountain village near Srebrenica has been closed since its roof collapsed under snow. The project rebuilds the roof, installs heating for winter prayers and adds a classroom for weekend Quran lessons for 40 children.',
    'La seule mosquée d''un village de montagne près de Srebrenica est fermée depuis que son toit s''est effondré sous la neige. Le projet reconstruit le toit, installe le chauffage pour les prières d''hiver et ajoute une salle pour les cours de Coran du week-end de 40 enfants.',
    'المسجد الوحيد في قرية جبلية قرب سربرنيتسا مغلق منذ انهيار سقفه تحت الثلج. يعيد المشروع بناء السقف ويركّب التدفئة لصلوات الشتاء ويضيف قاعة لدروس القرآن في عطلة نهاية الأسبوع لـ 40 طفلًا.',
    array[
      'https://images.unsplash.com/photo-1564769625905-50e93615e769?w=1200&q=80',
      'https://images.unsplash.com/photo-1519817650390-64a93db51149?w=1200&q=80'
    ]::text[],
    array[20,50,100,250]::int[],
    45000::numeric, 38900::numeric, 2210, false, 4
  ),
  (
    'Nour Relief Foundation', 'Urgent',
    'Emergency shelter after the Morocco earthquake', 'Abris d''urgence après le séisme au Maroc', 'مأوى طارئ بعد زلزال المغرب',
    'Winterised tents and blankets for the High Atlas', 'Tentes hivernales et couvertures pour le Haut Atlas', 'خيام شتوية وبطانيات للأطلس الكبير',
    'Families in remote Atlas villages are still living in makeshift shelters. Winterised tents, thermal blankets and heating kits are delivered by mule where roads are cut. Distribution is documented village by village and shared here.',
    'Des familles de villages reculés de l''Atlas vivent encore dans des abris de fortune. Tentes hivernales, couvertures thermiques et kits de chauffage sont acheminés à dos de mulet là où les routes sont coupées. La distribution est documentée village par village et partagée ici.',
    'لا تزال عائلات في قرى الأطلس النائية تعيش في ملاجئ مؤقتة. تُنقل الخيام الشتوية والبطانيات الحرارية وأطقم التدفئة على البغال حيث الطرق مقطوعة. يُوثَّق التوزيع قرية بقرية ويُشارك هنا.',
    array[
      'https://images.unsplash.com/photo-1600096194534-95cf5ece04cf?w=1200&q=80',
      'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=1200&q=80'
    ]::text[],
    array[10,50,100,150]::int[],
    25000::numeric, 9875::numeric, 987, true, 5
  ),
  (
    'Islamic Organization', 'Water',
    'Water filters for flooded Pakistan villages', 'Filtres à eau pour les villages inondés du Pakistan', 'مرشحات مياه للقرى المنكوبة بالفيضانات في باكستان',
    'One filter = safe water for a family of 6', 'Un filtre = eau saine pour une famille de 6', 'مرشح واحد = مياه آمنة لعائلة من 6 أفراد',
    'After the floods, waterborne diseases are the main threat to children in Sindh. Household ceramic filters remove 99.9% of bacteria, last five years and need no electricity. Health workers train each family on use and maintenance.',
    'Après les inondations, les maladies hydriques sont la principale menace pour les enfants du Sind. Les filtres céramiques domestiques éliminent 99,9% des bactéries, durent cinq ans et n''ont pas besoin d''électricité. Des agents de santé forment chaque famille.',
    'بعد الفيضانات، تُعدّ الأمراض المنقولة بالمياه التهديد الرئيسي للأطفال في السند. تزيل المرشحات الخزفية المنزلية 99.9% من البكتيريا وتدوم خمس سنوات ولا تحتاج إلى كهرباء. يدرّب العاملون الصحيون كل أسرة على الاستخدام والصيانة.',
    array[
      'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?w=1200&q=80'
    ]::text[],
    array[12,24,60,120]::int[],
    12000::numeric, 11640::numeric, 1540, true, 6
  )
) as v(org_name, cat_name, title_en, title_fr, title_ar, subtitle_en, subtitle_fr, subtitle_ar,
       description_en, description_fr, description_ar, images, presets,
       required_amount, collected_amount, donors_count, zakat, position)
join public.partner_organizations o on o.name_en = v.org_name
join public.project_categories c on c.title_en = v.cat_name
where not exists (
  select 1 from public.impact_projects p where p.title_en = v.title_en
);

-- ── Tiers ("Your donation provides") ─────────────────────────────────────────
insert into public.impact_project_tiers (
  impact_project_id, amount, position, title_en, title_fr, title_ar, subtitle_en, subtitle_fr, subtitle_ar
)
select p.id, t.amount, t.position, t.title_en, t.title_fr, t.title_ar, t.subtitle_en, t.subtitle_fr, t.subtitle_ar
from (values
  -- Somalia wells
  ('Clean water wells in Somalia', 15::numeric, 0, 'Water for one person', 'De l''eau pour une personne', 'ماء لشخص واحد', '20 years of clean water', '20 ans d''eau potable', '20 عامًا من المياه النظيفة'),
  ('Clean water wells in Somalia', 60::numeric, 1, 'Water for a family', 'De l''eau pour une famille', 'ماء لعائلة', 'Family of 4, for 20 years', 'Famille de 4, pendant 20 ans', 'عائلة من 4 أفراد لمدة 20 عامًا'),
  ('Clean water wells in Somalia', 3000::numeric, 2, 'A full well', 'Un puits complet', 'بئر كامل', 'Solar pump + committee training', 'Pompe solaire + formation du comité', 'مضخة شمسية + تدريب اللجنة'),
  -- Senegal school kits
  ('School kits for orphans in Senegal', 10::numeric, 0, 'Notebooks and pens', 'Cahiers et stylos', 'دفاتر وأقلام', 'One term of supplies', 'Un trimestre de fournitures', 'مستلزمات فصل دراسي واحد'),
  ('School kits for orphans in Senegal', 25::numeric, 1, 'Uniform and shoes', 'Uniforme et chaussures', 'زي مدرسي وأحذية', 'For one child', 'Pour un enfant', 'لطفل واحد'),
  ('School kits for orphans in Senegal', 100::numeric, 2, 'Full yearly kit', 'Kit annuel complet', 'حقيبة سنوية كاملة', 'Books, uniform + daily lunch', 'Livres, uniforme + déjeuner quotidien', 'كتب وزي + غداء يومي'),
  -- Bosnia mosque
  ('Rebuild the village mosque in Bosnia', 20::numeric, 0, 'One roof tile', 'Une tuile', 'قرميدة واحدة', 'Sadaqa jariya', 'Sadaqa jariya', 'صدقة جارية'),
  ('Rebuild the village mosque in Bosnia', 100::numeric, 1, 'One m² of roof', 'Un m² de toit', 'متر مربع من السقف', 'Insulated and snow-proof', 'Isolé et résistant à la neige', 'معزول ومقاوم للثلج'),
  ('Rebuild the village mosque in Bosnia', 250::numeric, 2, 'Heating for one winter', 'Chauffage pour un hiver', 'تدفئة لشتاء واحد', 'Five daily prayers, warm', 'Cinq prières quotidiennes, au chaud', 'الصلوات الخمس في دفء'),
  -- Morocco shelter
  ('Emergency shelter after the Morocco earthquake', 10::numeric, 0, 'Thermal blanket', 'Couverture thermique', 'بطانية حرارية', 'One person', 'Une personne', 'شخص واحد'),
  ('Emergency shelter after the Morocco earthquake', 50::numeric, 1, 'Heating kit', 'Kit de chauffage', 'طقم تدفئة', 'One family for the winter', 'Une famille pour l''hiver', 'عائلة واحدة للشتاء'),
  ('Emergency shelter after the Morocco earthquake', 150::numeric, 2, 'Winterised tent', 'Tente hivernale', 'خيمة شتوية', 'Shelter for a family of 6', 'Abri pour une famille de 6', 'مأوى لعائلة من 6 أفراد'),
  -- Pakistan filters
  ('Water filters for flooded Pakistan villages', 12::numeric, 0, 'One filter', 'Un filtre', 'مرشح واحد', 'Safe water for a family of 6', 'Eau saine pour une famille de 6', 'مياه آمنة لعائلة من 6 أفراد'),
  ('Water filters for flooded Pakistan villages', 60::numeric, 1, 'Five filters', 'Cinq filtres', 'خمسة مرشحات', 'A whole street', 'Toute une rue', 'شارع كامل'),
  ('Water filters for flooded Pakistan villages', 120::numeric, 2, 'Ten filters + training', 'Dix filtres + formation', 'عشرة مرشحات + تدريب', 'A village hamlet', 'Un hameau', 'قرية صغيرة')
) as t(project_title, amount, position, title_en, title_fr, title_ar, subtitle_en, subtitle_fr, subtitle_ar)
join public.impact_projects p on p.title_en = t.project_title
where not exists (
  select 1 from public.impact_project_tiers x
   where x.impact_project_id = p.id and x.title_en = t.title_en
);

-- ── Field stories ────────────────────────────────────────────────────────────
insert into public.project_stories (
  impact_project_id, title_en, title_fr, title_ar,
  description_en, description_fr, description_ar, images, created_at
)
select p.id, s.title_en, s.title_fr, s.title_ar,
       s.description_en, s.description_fr, s.description_ar, s.images, s.created_at
from (values
  ('Clean water wells in Somalia',
   'Well #7 completed in Baidoa district', 'Puits n°7 terminé dans le district de Baidoa', 'اكتمال البئر رقم 7 في مقاطعة بيدوا',
   'The seventh well is pumping. 380 people now have water at less than 300 m from home.',
   'Le septième puits fonctionne. 380 personnes ont désormais de l''eau à moins de 300 m de chez elles.',
   'البئر السابع يضخ الماء الآن. 380 شخصًا لديهم ماء على بعد أقل من 300 متر من منازلهم.',
   array['https://images.unsplash.com/photo-1594398901394-4e34939a4fd0?w=1200&q=80']::text[], now() - interval '5 days'),
  ('Clean water wells in Somalia',
   'Committee training in Afgooye', 'Formation du comité à Afgooye', 'تدريب اللجنة في أفغويي',
   'Twelve volunteers trained on pump maintenance and water testing.',
   'Douze bénévoles formés à l''entretien des pompes et aux tests de l''eau.',
   'تدريب اثني عشر متطوعًا على صيانة المضخات واختبار المياه.',
   '{}'::text[], now() - interval '19 days'),
  ('School kits for orphans in Senegal',
   '210 kits handed out before the school year', '210 kits distribués avant la rentrée', 'توزيع 210 حقيبة قبل بداية العام الدراسي',
   'Distribution day in Kaolack with the school directors and the parents'' committee.',
   'Journée de distribution à Kaolack avec les directeurs d''école et le comité des parents.',
   'يوم التوزيع في كاولاك مع مديري المدارس ولجنة أولياء الأمور.',
   array['https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&q=80','https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?w=1200&q=80']::text[], now() - interval '9 days'),
  ('Rebuild the village mosque in Bosnia',
   'Roof structure is up', 'La charpente est posée', 'تم تركيب هيكل السقف',
   'Local carpenters finished the timber frame; tiles arrive next week insha''Allah.',
   'Les charpentiers locaux ont terminé l''ossature bois ; les tuiles arrivent la semaine prochaine incha''Allah.',
   'أنهى النجارون المحليون الهيكل الخشبي؛ يصل القرميد الأسبوع المقبل إن شاء الله.',
   array['https://images.unsplash.com/photo-1564769625905-50e93615e769?w=1200&q=80']::text[], now() - interval '2 days'),
  ('Emergency shelter after the Morocco earthquake',
   '64 tents delivered to Tafeghaghte', '64 tentes livrées à Tafeghaghte', 'تسليم 64 خيمة إلى تافغاغت',
   'Reached by mule after a 4-hour climb. Every family in the hamlet is now under a winterised tent.',
   'Acheminées à dos de mulet après 4 heures de montée. Chaque famille du hameau est désormais sous une tente hivernale.',
   'وصلت على البغال بعد صعود دام 4 ساعات. كل عائلة في القرية الآن تحت خيمة شتوية.',
   array['https://images.unsplash.com/photo-1600096194534-95cf5ece04cf?w=1200&q=80']::text[], now() - interval '1 day'),
  ('Water filters for flooded Pakistan villages',
   'First 300 filters installed in Dadu', '300 premiers filtres installés à Dadu', 'تركيب أول 300 مرشح في دادو',
   'Health workers visited each home; cases of diarrhoea in children dropped within two weeks.',
   'Les agents de santé ont visité chaque foyer ; les cas de diarrhée chez les enfants ont chuté en deux semaines.',
   'زار العاملون الصحيون كل منزل؛ انخفضت حالات الإسهال لدى الأطفال خلال أسبوعين.',
   '{}'::text[], now() - interval '12 days')
) as s(project_title, title_en, title_fr, title_ar, description_en, description_fr, description_ar, images, created_at)
join public.impact_projects p on p.title_en = s.project_title
where not exists (
  select 1 from public.project_stories st
   where st.impact_project_id = p.id and st.title_en = s.title_en
);
