-- =============================================================================
-- Impact project: "Feed palestinian families" (Nour Charity, org id = 1)
--
-- Urgent category → red badge on the card / detail header.
-- Adds (all idempotent, safe on a DB where the old mock seed already ran):
--   * project_categories   → "Urgent" (created if missing) + 11-lang backfill
--   * impact_projects      → the project, 11 langs (title / subtitle / description)
--   * impact_project_tiers → 4 tiers (10 / 25 / 50 / 100 EUR), 11 langs
--
-- No project_stories / highlights for this project (on purpose).
--
-- Money: collected_amount / donors_count are only written when they are still 0,
-- so real donations are never clobbered. Set them to 0 below for a real launch.
-- =============================================================================

-- ── Category "Urgent" ────────────────────────────────────────────────────────
insert into public.project_categories (title_en, title_fr, title_ar, position)
select 'Urgent', 'Urgent', $q$عاجل$q$, 1
where not exists (
  select 1 from public.project_categories c where c.title_en = 'Urgent'
);

update public.project_categories
   set title_de = coalesce(title_de, 'Dringend'),
       title_nl = coalesce(title_nl, 'Dringend'),
       title_tr = coalesce(title_tr, 'Acil'),
       title_id = coalesce(title_id, 'Mendesak'),
       title_ur = coalesce(title_ur, $q$فوری$q$),
       title_bn = coalesce(title_bn, $q$জরুরি$q$),
       title_ms = coalesce(title_ms, 'Segera'),
       title_ru = coalesce(title_ru, $q$Срочно$q$)
 where title_en = 'Urgent';

-- ── Project (org id 1 = Nour Charity) ────────────────────────────────────────
insert into public.impact_projects (
  organization_id, project_category_id,
  title_en, title_fr, title_ar,
  subtitle_en, subtitle_fr, subtitle_ar,
  cover_image_url, required_amount, collected_amount, currency,
  donors_count, eligible_for_zakat, is_active, position
)
select
  o.id, c.id,
  'Feed palestinian families', 'Nourrir les familles palestiniennes', $q$إطعام العائلات الفلسطينية$q$,
  'Food, water and medical aid for displaced families',
  $q$Nourriture, eau et aide médicale pour les familles déplacées$q$,
  $q$طعام وماء ومساعدات طبية للعائلات النازحة$q$,
  'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=1200&q=80',
  50000, 0, 'EUR',
  0, false, true, 1
from public.partner_organizations o
cross join public.project_categories c
where o.id = 1
  and c.title_en = 'Urgent'
  and not exists (
    select 1 from public.impact_projects p where p.title_en = 'Feed palestinian families'
  );

-- ── Full content: 11 locales, gallery, presets, figures ──────────────────────
update public.impact_projects p
   set organization_id     = 1,
       project_category_id = (select c.id from public.project_categories c where c.title_en = 'Urgent'),

       title_fr = $q$Nourrir les familles palestiniennes$q$,
       title_ar = $q$إطعام العائلات الفلسطينية$q$,
       title_de = $q$Palästinensische Familien ernähren$q$,
       title_nl = $q$Palestijnse gezinnen voeden$q$,
       title_tr = $q$Filistinli ailelere yemek ulaştırın$q$,
       title_id = $q$Beri makan keluarga Palestina$q$,
       title_ur = $q$فلسطینی خاندانوں کو کھانا کھلائیں$q$,
       title_bn = $q$ফিলিস্তিনি পরিবারগুলোকে খাদ্য দিন$q$,
       title_ms = $q$Beri makanan kepada keluarga Palestin$q$,
       title_ru = $q$Накормите палестинские семьи$q$,

       subtitle_en = $q$Food, water and medical aid for displaced families$q$,
       subtitle_fr = $q$Nourriture, eau et aide médicale pour les familles déplacées$q$,
       subtitle_ar = $q$طعام وماء ومساعدات طبية للعائلات النازحة$q$,
       subtitle_de = $q$Nahrung, Wasser und medizinische Hilfe für vertriebene Familien$q$,
       subtitle_nl = $q$Voedsel, water en medische hulp voor ontheemde gezinnen$q$,
       subtitle_tr = $q$Yerinden edilmiş aileler için gıda, su ve tıbbi yardım$q$,
       subtitle_id = $q$Makanan, air, dan bantuan medis untuk keluarga terlantar$q$,
       subtitle_ur = $q$بے گھر خاندانوں کے لیے خوراک، پانی اور طبی امداد$q$,
       subtitle_bn = $q$বাস্তুচ্যুত পরিবারের জন্য খাদ্য, পানি ও চিকিৎসা সহায়তা$q$,
       subtitle_ms = $q$Makanan, air dan bantuan perubatan untuk keluarga yang terpaksa berpindah$q$,
       subtitle_ru = $q$Еда, вода и медицинская помощь для перемещённых семей$q$,

       description_en = $q$More than 1.9 million people have been displaced in Gaza, with severe shortages of food, clean water and medical supplies. Your donation funds emergency aid kits delivered directly to families through verified local partners on the ground.

Each kit is handed out by teams we work with every day, and every contribution is tracked and reported, so you can see exactly where your sadaqah goes. Give once or monthly — even a small amount keeps a family fed for another day, insha'Allah.$q$,
       description_fr = $q$Plus de 1,9 million de personnes ont été déplacées à Gaza, avec de graves pénuries de nourriture, d'eau potable et de fournitures médicales. Votre don finance des kits d'aide d'urgence livrés directement aux familles par des partenaires locaux vérifiés sur le terrain.

Chaque kit est distribué par des équipes avec lesquelles nous travaillons au quotidien, et chaque contribution est suivie et rapportée, afin que vous sachiez exactement où va votre sadaqa. Donnez une fois ou chaque mois — même un petit montant nourrit une famille un jour de plus, incha'Allah.$q$,
       description_ar = $q$تم تهجير أكثر من 1.9 مليون شخص في غزة، مع نقص حاد في الغذاء والماء النظيف والإمدادات الطبية. يموّل تبرعك أطقم إغاثة طارئة تُسلَّم مباشرة إلى العائلات عبر شركاء محليين موثوقين على الأرض.

يوزّع كل طقم فرقٌ نعمل معها يوميًا، ويُتابَع كل تبرع ويُوثَّق، لتعرف تمامًا أين تذهب صدقتك. تبرّع مرة واحدة أو شهريًا — حتى المبلغ الصغير يُطعم عائلة يومًا إضافيًا إن شاء الله.$q$,
       description_de = $q$Mehr als 1,9 Millionen Menschen wurden in Gaza vertrieben, bei akutem Mangel an Nahrung, sauberem Wasser und medizinischer Versorgung. Deine Spende finanziert Nothilfepakete, die über geprüfte lokale Partner direkt an Familien verteilt werden.

Jedes Paket wird von Teams übergeben, mit denen wir täglich zusammenarbeiten, und jeder Beitrag wird dokumentiert und berichtet, damit du genau siehst, wohin deine Sadaqa geht. Spende einmalig oder monatlich — schon ein kleiner Betrag ernährt eine Familie einen Tag länger, insha'Allah.$q$,
       description_nl = $q$Meer dan 1,9 miljoen mensen zijn in Gaza ontheemd geraakt, met ernstige tekorten aan voedsel, schoon water en medische voorraden. Jouw donatie financiert noodhulppakketten die via geverifieerde lokale partners rechtstreeks aan gezinnen worden geleverd.

Elk pakket wordt uitgedeeld door teams waarmee we dagelijks samenwerken, en elke bijdrage wordt bijgehouden en gerapporteerd, zodat je precies ziet waar je sadaqa naartoe gaat. Geef eenmalig of maandelijks — zelfs een klein bedrag houdt een gezin nog een dag gevoed, insha'Allah.$q$,
       description_tr = $q$Gazze'de 1,9 milyondan fazla insan yerinden edildi; gıda, temiz su ve tıbbi malzemede ciddi eksiklik var. Bağışınız, sahadaki doğrulanmış yerel ortaklar aracılığıyla doğrudan ailelere ulaştırılan acil yardım kolilerini finanse ediyor.

Her koli, her gün birlikte çalıştığımız ekipler tarafından dağıtılır; her katkı kayıt altına alınır ve raporlanır, böylece sadakanızın nereye gittiğini tam olarak görürsünüz. Bir kez ya da her ay bağış yapın — küçük bir miktar bile bir aileyi bir gün daha doyurur, inşallah.$q$,
       description_id = $q$Lebih dari 1,9 juta orang telah mengungsi di Gaza, dengan kekurangan parah makanan, air bersih, dan pasokan medis. Donasi Anda mendanai paket bantuan darurat yang diantarkan langsung kepada keluarga melalui mitra lokal terverifikasi di lapangan.

Setiap paket dibagikan oleh tim yang bekerja bersama kami setiap hari, dan setiap kontribusi dicatat serta dilaporkan, sehingga Anda tahu persis ke mana sedekah Anda pergi. Berdonasi sekali atau setiap bulan — jumlah kecil pun membuat satu keluarga tetap makan satu hari lagi, insya Allah.$q$,
       description_ur = $q$غزہ میں 19 لاکھ سے زائد افراد بے گھر ہو چکے ہیں، جہاں خوراک، صاف پانی اور طبی سامان کی شدید قلت ہے۔ آپ کا عطیہ ہنگامی امدادی کٹس کے لیے استعمال ہوتا ہے جو زمین پر موجود تصدیق شدہ مقامی شراکت داروں کے ذریعے براہِ راست خاندانوں تک پہنچائی جاتی ہیں۔

ہر کٹ ان ٹیموں کے ذریعے تقسیم کی جاتی ہے جن کے ساتھ ہم روزانہ کام کرتے ہیں، اور ہر عطیے کا حساب رکھا اور رپورٹ کیا جاتا ہے، تاکہ آپ کو معلوم ہو کہ آپ کا صدقہ کہاں جا رہا ہے۔ ایک بار یا ہر ماہ عطیہ دیں — تھوڑی سی رقم بھی ایک خاندان کو ایک اور دن کھانا فراہم کرتی ہے، ان شاء اللہ۔$q$,
       description_bn = $q$গাজায় ১৯ লাখেরও বেশি মানুষ বাস্তুচ্যুত হয়েছেন, সেখানে খাদ্য, বিশুদ্ধ পানি ও চিকিৎসা সামগ্রীর তীব্র ঘাটতি। আপনার দান জরুরি ত্রাণ কিটের খরচ বহন করে, যা মাঠপর্যায়ের যাচাইকৃত স্থানীয় অংশীদারদের মাধ্যমে সরাসরি পরিবারগুলোর কাছে পৌঁছে দেওয়া হয়।

প্রতিটি কিট বিতরণ করে সেই দলগুলো, যাদের সঙ্গে আমরা প্রতিদিন কাজ করি; প্রতিটি অবদানের হিসাব রাখা ও প্রতিবেদন করা হয়, যাতে আপনার সদকা কোথায় যাচ্ছে তা আপনি জানতে পারেন। একবার বা প্রতি মাসে দান করুন — ছোট অঙ্কও একটি পরিবারকে আরও একটি দিন খাবার জোগায়, ইনশাআল্লাহ।$q$,
       description_ms = $q$Lebih 1.9 juta orang telah kehilangan tempat tinggal di Gaza, dengan kekurangan makanan, air bersih dan bekalan perubatan yang teruk. Derma anda membiayai kit bantuan kecemasan yang dihantar terus kepada keluarga melalui rakan tempatan yang disahkan di lapangan.

Setiap kit diagihkan oleh pasukan yang bekerja bersama kami setiap hari, dan setiap sumbangan direkod serta dilaporkan, supaya anda tahu ke mana sedekah anda pergi. Derma sekali atau setiap bulan — jumlah kecil pun memberi makan sebuah keluarga untuk satu hari lagi, insya-Allah.$q$,
       description_ru = $q$В Газе более 1,9 миллиона человек стали вынужденными переселенцами на фоне острой нехватки еды, чистой воды и медикаментов. Ваше пожертвование оплачивает наборы экстренной помощи, которые доставляются семьям напрямую через проверенных местных партнёров.

Каждый набор раздают команды, с которыми мы работаем ежедневно, а каждый взнос учитывается и подтверждается отчётом, поэтому вы точно видите, куда идёт ваша садака. Пожертвуйте разово или ежемесячно — даже небольшая сумма кормит семью ещё один день, иншаАллах.$q$,

       cover_image_url = 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=1200&q=80',
       images = array[
         'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=1200&q=80',
         'https://images.unsplash.com/photo-1593113646773-028c64a8f1b8?w=1200&q=80',
         'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=1200&q=80'
       ]::text[],
       preset_amounts     = array[10, 25, 50, 100]::int[],
       required_amount    = 50000,
       currency           = 'EUR',
       eligible_for_zakat = false,
       is_active          = true,
       position           = 1,
       -- demo figures from the design; never overwrite real money
       collected_amount   = case when p.collected_amount = 0 then 12400 else p.collected_amount end,
       donors_count       = case when p.donors_count     = 0 then 12000 else p.donors_count     end
 where p.title_en = 'Feed palestinian families';

-- ── Tiers: "Your donation provides" ──────────────────────────────────────────
insert into public.impact_project_tiers (
  impact_project_id, amount, position, title_en, title_fr, title_ar
)
select p.id, t.amount, t.position, t.title_en, t.title_fr, t.title_ar
from public.impact_projects p
cross join (values
  (10::numeric,  0, 'Daily food parcel',  $q$Colis alimentaire quotidien$q$, $q$طرد غذائي يومي$q$),
  (25::numeric,  1, 'Clean water supply', $q$Accès à l'eau potable$q$,       $q$إمداد بالمياه النظيفة$q$),
  (50::numeric,  2, 'Medical aid kit',    $q$Kit d'aide médicale$q$,         $q$حقيبة إسعافات طبية$q$),
  (100::numeric, 3, 'Emergency shelter',  $q$Abri d'urgence$q$,              $q$مأوى طارئ$q$)
) as t(amount, position, title_en, title_fr, title_ar)
where p.title_en = 'Feed palestinian families'
  and not exists (
    select 1 from public.impact_project_tiers x
     where x.impact_project_id = p.id and x.amount = t.amount
  );

update public.impact_project_tiers x
   set position   = t.position,
       title_en   = t.title_en,   title_fr = t.title_fr, title_ar = t.title_ar,
       title_de   = t.title_de,   title_nl = t.title_nl, title_tr = t.title_tr, title_id = t.title_id,
       title_ur   = t.title_ur,   title_bn = t.title_bn, title_ms = t.title_ms, title_ru = t.title_ru,
       subtitle_en = t.subtitle_en, subtitle_fr = t.subtitle_fr, subtitle_ar = t.subtitle_ar,
       subtitle_de = t.subtitle_de, subtitle_nl = t.subtitle_nl, subtitle_tr = t.subtitle_tr,
       subtitle_id = t.subtitle_id, subtitle_ur = t.subtitle_ur, subtitle_bn = t.subtitle_bn,
       subtitle_ms = t.subtitle_ms, subtitle_ru = t.subtitle_ru
from public.impact_projects p,
(values
  (10::numeric, 0,
   'Daily food parcel', $q$Colis alimentaire quotidien$q$, $q$طرد غذائي يومي$q$,
   $q$Tägliches Lebensmittelpaket$q$, $q$Dagelijks voedselpakket$q$, $q$Günlük gıda kolisi$q$, $q$Paket makanan harian$q$,
   $q$روزانہ کا غذائی پیکٹ$q$, $q$দৈনিক খাদ্য প্যাকেজ$q$, $q$Bungkusan makanan harian$q$, $q$Ежедневная продуктовая посылка$q$,
   'Feeds a family of 5 for 1 day', $q$Nourrit une famille de 5 pendant 1 jour$q$, $q$يطعم عائلة من 5 أفراد ليوم واحد$q$,
   $q$Ernährt eine 5-köpfige Familie einen Tag$q$, $q$Voedt een gezin van 5 voor 1 dag$q$, $q$5 kişilik bir aileyi 1 gün doyurur$q$,
   $q$Memberi makan keluarga 5 orang selama 1 hari$q$, $q$پانچ افراد کے خاندان کو ایک دن کا کھانا$q$,
   $q$৫ জনের পরিবারকে ১ দিনের খাবার$q$, $q$Memberi makan keluarga 5 orang selama 1 hari$q$, $q$Кормит семью из 5 человек один день$q$),
  (25::numeric, 1,
   'Clean water supply', $q$Accès à l'eau potable$q$, $q$إمداد بالمياه النظيفة$q$,
   $q$Sauberes Trinkwasser$q$, $q$Schoon drinkwater$q$, $q$Temiz su tedariki$q$, $q$Pasokan air bersih$q$,
   $q$صاف پانی کی فراہمی$q$, $q$বিশুদ্ধ পানির সরবরাহ$q$, $q$Bekalan air bersih$q$, $q$Снабжение чистой водой$q$,
   '7-day water access for a family', $q$7 jours d'eau pour une famille$q$, $q$مياه لمدة 7 أيام لعائلة$q$,
   $q$7 Tage Wasser für eine Familie$q$, $q$7 dagen water voor een gezin$q$, $q$Bir aile için 7 günlük su$q$,
   $q$Akses air 7 hari untuk satu keluarga$q$, $q$ایک خاندان کے لیے 7 دن کا پانی$q$,
   $q$একটি পরিবারের জন্য ৭ দিনের পানি$q$, $q$Akses air selama 7 hari untuk sekeluarga$q$, $q$Вода для семьи на 7 дней$q$),
  (50::numeric, 2,
   'Medical aid kit', $q$Kit d'aide médicale$q$, $q$حقيبة إسعافات طبية$q$,
   $q$Medizinisches Hilfspaket$q$, $q$Medische hulpset$q$, $q$Tıbbi yardım seti$q$, $q$Paket bantuan medis$q$,
   $q$طبی امدادی کٹ$q$, $q$চিকিৎসা সহায়তা কিট$q$, $q$Kit bantuan perubatan$q$, $q$Аптечка первой помощи$q$,
   'Essential supplies for one person', $q$Fournitures essentielles pour une personne$q$, $q$مستلزمات أساسية لشخص واحد$q$,
   $q$Grundausstattung für eine Person$q$, $q$Basisbenodigdheden voor één persoon$q$, $q$Bir kişi için temel malzemeler$q$,
   $q$Perlengkapan penting untuk satu orang$q$, $q$ایک فرد کے لیے ضروری سامان$q$,
   $q$একজনের জন্য প্রয়োজনীয় সরঞ্জাম$q$, $q$Keperluan asas untuk seorang$q$, $q$Необходимые средства для одного человека$q$),
  (100::numeric, 3,
   'Emergency shelter', $q$Abri d'urgence$q$, $q$مأوى طارئ$q$,
   $q$Notunterkunft$q$, $q$Noodonderdak$q$, $q$Acil barınak$q$, $q$Tempat tinggal darurat$q$,
   $q$ہنگامی پناہ گاہ$q$, $q$জরুরি আশ্রয়$q$, $q$Tempat perlindungan kecemasan$q$, $q$Экстренное укрытие$q$,
   'Tent + bedding for a family', $q$Tente + literie pour une famille$q$, $q$خيمة + فراش لعائلة$q$,
   $q$Zelt + Bettzeug für eine Familie$q$, $q$Tent + beddengoed voor een gezin$q$, $q$Bir aile için çadır + yatak takımı$q$,
   $q$Tenda + perlengkapan tidur untuk satu keluarga$q$, $q$ایک خاندان کے لیے خیمہ اور بستر$q$,
   $q$একটি পরিবারের জন্য তাঁবু ও বিছানা$q$, $q$Khemah + tilam untuk sekeluarga$q$, $q$Палатка и спальные принадлежности для семьи$q$)
) as t(amount, position,
       title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru,
       subtitle_en, subtitle_fr, subtitle_ar, subtitle_de, subtitle_nl, subtitle_tr, subtitle_id, subtitle_ur,
       subtitle_bn, subtitle_ms, subtitle_ru)
where p.title_en = 'Feed palestinian families'
  and x.impact_project_id = p.id
  and x.amount = t.amount;
