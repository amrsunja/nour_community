-- =============================================================================
-- Impact project: "Help us build the Nour app" (Nour Charity)
--
-- Funds the continued development of the app (new features, servers, updates).
-- Adds:
--   * project_categories  → "App" (11 langs, position 5)
--   * partner_organizations → Nour Charity: 11-lang names (only where null)
--                             + brand avatar
--   * impact_projects     → the project (11 langs, position 0 = first in list)
--   * impact_project_tiers → 4 tiers (5 / 15 / 50 / 150 EUR, 11 langs)
--   * project_stories     → launch story (11 langs)
--
-- Images live in the public `app_images` bucket under impact/nour-app/
-- (see backend/supabase/seeds/impact/nour-app/README.md for the upload step).
-- Idempotent: guarded on title_en / name_en.
-- =============================================================================

-- ── Category "App" ───────────────────────────────────────────────────────────
insert into public.project_categories (
  title_en, title_fr, title_ar, title_de, title_nl, title_tr,
  title_id, title_ur, title_bn, title_ms, title_ru, position
)
select 'App', 'Application', 'التطبيق', 'App', 'App', 'Uygulama',
       'Aplikasi', 'ایپ', 'অ্যাপ', 'Aplikasi', 'Приложение', 5
where not exists (
  select 1 from public.project_categories c where c.title_en = 'App'
);

-- ── Partner org: Nour Charity (verified) ─────────────────────────────────────
insert into public.partner_organizations (name_en, name_fr, name_ar, is_verified)
select 'Nour Charity', 'Nour Charity', 'جمعية نور الخيرية', true
where not exists (
  select 1 from public.partner_organizations o where o.name_en = 'Nour Charity'
);

update public.partner_organizations
   set is_verified = true,
       name_de = coalesce(name_de, 'Nour Charity'),
       name_nl = coalesce(name_nl, 'Nour Charity'),
       name_tr = coalesce(name_tr, 'Nour Charity'),
       name_id = coalesce(name_id, 'Nour Charity'),
       name_ur = coalesce(name_ur, 'نور چیریٹی'),
       name_bn = coalesce(name_bn, 'নূর চ্যারিটি'),
       name_ms = coalesce(name_ms, 'Nour Charity'),
       name_ru = coalesce(name_ru, 'Нур Черити'),
       avatar_url = 'https://gawzqxnhliggvyebldmb.supabase.co/storage/v1/object/public/app_images/impact/nour-app/avatar.jpg'
 where name_en = 'Nour Charity';

-- ── Project ──────────────────────────────────────────────────────────────────
insert into public.impact_projects (
  organization_id, project_category_id,
  title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru,
  subtitle_en, subtitle_fr, subtitle_ar, subtitle_de, subtitle_nl, subtitle_tr, subtitle_id, subtitle_ur, subtitle_bn, subtitle_ms, subtitle_ru,
  description_en, description_fr, description_ar, description_de, description_nl, description_tr, description_id, description_ur, description_bn, description_ms, description_ru,
  cover_image_url, images, preset_amounts,
  required_amount, collected_amount, currency,
  donors_count, eligible_for_zakat, is_active, position
)
select
  o.id, c.id,
  -- title
  $q$Help us build the Nour app$q$,
  $q$Aidez-nous à développer l'application Nour$q$,
  $q$ساعدونا في تطوير تطبيق نور$q$,
  $q$Hilf uns, die Nour-App weiterzuentwickeln$q$,
  $q$Help ons de Nour-app verder te ontwikkelen$q$,
  $q$Nour uygulamasını geliştirmemize yardım edin$q$,
  $q$Bantu kami mengembangkan aplikasi Nour$q$,
  $q$نور ایپ کی ترقی میں ہماری مدد کریں$q$,
  $q$নূর অ্যাপ তৈরিতে আমাদের সাহায্য করুন$q$,
  $q$Bantu kami membangunkan aplikasi Nour$q$,
  $q$Помогите нам развивать приложение Nour$q$,
  -- subtitle
  $q$Fund new features, servers and updates$q$,
  $q$Financez les nouvelles fonctionnalités, les serveurs et les mises à jour$q$,
  $q$موّلوا الميزات الجديدة والخوادم والتحديثات$q$,
  $q$Finanziere neue Funktionen, Server und Updates$q$,
  $q$Financier nieuwe functies, servers en updates$q$,
  $q$Yeni özellikleri, sunucuları ve güncellemeleri destekleyin$q$,
  $q$Danai fitur baru, server, dan pembaruan$q$,
  $q$نئے فیچرز، سرورز اور اپ ڈیٹس کے لیے تعاون کریں$q$,
  $q$নতুন ফিচার, সার্ভার ও আপডেটে সহায়তা করুন$q$,
  $q$Biayai ciri baharu, pelayan dan kemas kini$q$,
  $q$Поддержите новые функции, серверы и обновления$q$,
  -- description
  $q$Nour Community is built and maintained by a small team of volunteers, and it will always stay free and ad-free for everyone. Your donation goes directly into the development of the app: new features such as the mosque finder, community events and more Islamic content, bug fixes, server and infrastructure costs, translations in 11 languages and regular updates on iOS and Android. Every euro is reinvested in the project so that Muslims around the world can keep learning, remembering Allah and doing good together. Supporting a tool that helps thousands of people in their worship is a sadaqah jariyah, insha'Allah.$q$,
  $q$Nour Community est développée et maintenue par une petite équipe de bénévoles, et restera toujours gratuite et sans publicité pour tous. Votre don finance directement le développement de l'application : de nouvelles fonctionnalités comme la recherche de mosquées, les événements communautaires et davantage de contenu islamique, la correction de bugs, les coûts de serveurs et d'infrastructure, les traductions en 11 langues et des mises à jour régulières sur iOS et Android. Chaque euro est réinvesti dans le projet pour que les musulmans du monde entier puissent continuer à apprendre, à se rappeler d'Allah et à faire le bien ensemble. Soutenir un outil qui aide des milliers de personnes dans leur adoration est une sadaqa jariya, incha'Allah.$q$,
  $q$يُطوَّر تطبيق نور كوميونيتي ويُصان بجهود فريق صغير من المتطوعين، وسيبقى دائمًا مجانيًا وخاليًا من الإعلانات للجميع. يذهب تبرعكم مباشرة إلى تطوير التطبيق: ميزات جديدة مثل البحث عن المساجد وفعاليات المجتمع والمزيد من المحتوى الإسلامي، وإصلاح الأخطاء، وتكاليف الخوادم والبنية التحتية، والترجمة إلى 11 لغة، وتحديثات منتظمة على iOS وAndroid. يُعاد استثمار كل يورو في المشروع ليواصل المسلمون حول العالم التعلّم وذكر الله وفعل الخير معًا. دعم أداة تعين آلاف الناس على عبادتهم صدقة جارية إن شاء الله.$q$,
  $q$Nour Community wird von einem kleinen Team von Freiwilligen entwickelt und gepflegt und bleibt für alle immer kostenlos und werbefrei. Deine Spende fließt direkt in die Entwicklung der App: neue Funktionen wie die Moscheesuche, Community-Veranstaltungen und mehr islamische Inhalte, Fehlerbehebungen, Server- und Infrastrukturkosten, Übersetzungen in 11 Sprachen und regelmäßige Updates für iOS und Android. Jeder Euro wird in das Projekt reinvestiert, damit Muslime auf der ganzen Welt weiter lernen, Allah gedenken und gemeinsam Gutes tun können. Ein Werkzeug zu unterstützen, das Tausenden Menschen bei ihrer Anbetung hilft, ist eine Sadaqa Dschariya, insha'Allah.$q$,
  $q$Nour Community wordt ontwikkeld en onderhouden door een klein team vrijwilligers en blijft voor iedereen altijd gratis en zonder advertenties. Jouw donatie gaat rechtstreeks naar de ontwikkeling van de app: nieuwe functies zoals de moskeezoeker, community-evenementen en meer islamitische inhoud, bugfixes, server- en infrastructuurkosten, vertalingen in 11 talen en regelmatige updates voor iOS en Android. Elke euro wordt opnieuw in het project geïnvesteerd, zodat moslims over de hele wereld kunnen blijven leren, Allah gedenken en samen het goede doen. Het ondersteunen van een hulpmiddel dat duizenden mensen helpt bij hun aanbidding is een sadaqa jariya, insha'Allah.$q$,
  $q$Nour Community, küçük bir gönüllü ekibi tarafından geliştirilip sürdürülmektedir ve herkes için her zaman ücretsiz ve reklamsız kalacaktır. Bağışınız doğrudan uygulamanın geliştirilmesine gider: cami bulucu, topluluk etkinlikleri ve daha fazla İslami içerik gibi yeni özellikler, hata düzeltmeleri, sunucu ve altyapı maliyetleri, 11 dilde çeviriler ve iOS ile Android'de düzenli güncellemeler. Her euro, dünyanın dört bir yanındaki Müslümanların öğrenmeye, Allah'ı zikretmeye ve birlikte iyilik yapmaya devam edebilmesi için projeye yeniden yatırılır. Binlerce insana ibadetlerinde yardımcı olan bir aracı desteklemek, inşallah bir sadaka-i cariyedir.$q$,
  $q$Nour Community dibangun dan dikelola oleh tim kecil relawan, dan akan selalu gratis serta bebas iklan untuk semua orang. Donasi Anda langsung digunakan untuk pengembangan aplikasi: fitur baru seperti pencari masjid, acara komunitas dan lebih banyak konten Islami, perbaikan bug, biaya server dan infrastruktur, terjemahan dalam 11 bahasa, serta pembaruan rutin di iOS dan Android. Setiap euro diinvestasikan kembali ke proyek agar umat Muslim di seluruh dunia dapat terus belajar, mengingat Allah, dan berbuat kebaikan bersama. Mendukung sarana yang membantu ribuan orang dalam ibadah mereka adalah sedekah jariyah, insya Allah.$q$,
  $q$نور کمیونٹی رضاکاروں کی ایک چھوٹی ٹیم تیار اور برقرار رکھتی ہے، اور یہ سب کے لیے ہمیشہ مفت اور اشتہارات سے پاک رہے گی۔ آپ کا عطیہ براہِ راست ایپ کی ترقی پر خرچ ہوتا ہے: نئے فیچرز جیسے مسجد تلاش کرنے کی سہولت، کمیونٹی ایونٹس اور مزید اسلامی مواد، بگ فکسز، سرور اور انفراسٹرکچر کے اخراجات، 11 زبانوں میں تراجم اور iOS اور Android پر باقاعدہ اپ ڈیٹس۔ ہر یورو دوبارہ اس منصوبے میں لگایا جاتا ہے تاکہ دنیا بھر کے مسلمان سیکھتے رہیں، اللہ کو یاد کرتے رہیں اور مل کر نیکی کرتے رہیں۔ ایسے ذریعے کی مدد کرنا جو ہزاروں لوگوں کی عبادت میں معاون ہو، ان شاء اللہ صدقۂ جاریہ ہے۔$q$,
  $q$নূর কমিউনিটি একটি ছোট স্বেচ্ছাসেবক দল তৈরি ও রক্ষণাবেক্ষণ করে, এবং এটি সবার জন্য সবসময় বিনামূল্যে ও বিজ্ঞাপনমুক্ত থাকবে। আপনার দান সরাসরি অ্যাপের উন্নয়নে ব্যয় হয়: মসজিদ খোঁজার সুবিধা, কমিউনিটি ইভেন্ট ও আরও ইসলামিক কনটেন্টের মতো নতুন ফিচার, বাগ সংশোধন, সার্ভার ও অবকাঠামোর খরচ, ১১টি ভাষায় অনুবাদ এবং iOS ও Android-এ নিয়মিত আপডেট। প্রতিটি ইউরো প্রকল্পে পুনরায় বিনিয়োগ করা হয়, যাতে বিশ্বজুড়ে মুসলিমরা শিখতে, আল্লাহকে স্মরণ করতে ও একসাথে ভালো কাজ করতে পারেন। হাজারো মানুষের ইবাদতে সহায়ক একটি মাধ্যমকে সহায়তা করা ইনশাআল্লাহ একটি সদকায়ে জারিয়া।$q$,
  $q$Nour Community dibangunkan dan diselenggara oleh sekumpulan kecil sukarelawan, dan akan sentiasa percuma serta bebas iklan untuk semua. Derma anda disalurkan terus kepada pembangunan aplikasi: ciri baharu seperti pencari masjid, acara komuniti dan lebih banyak kandungan Islamik, pembetulan pepijat, kos pelayan dan infrastruktur, terjemahan dalam 11 bahasa serta kemas kini berkala di iOS dan Android. Setiap euro dilaburkan semula ke dalam projek supaya umat Islam di seluruh dunia dapat terus belajar, mengingati Allah dan melakukan kebaikan bersama. Menyokong satu wadah yang membantu ribuan orang dalam ibadah mereka adalah sedekah jariah, insya-Allah.$q$,
  $q$Nour Community создаётся и поддерживается небольшой командой волонтёров и всегда останется бесплатным и без рекламы для всех. Ваше пожертвование напрямую идёт на развитие приложения: новые функции, такие как поиск мечетей, мероприятия сообщества и больше исламского контента, исправление ошибок, расходы на серверы и инфраструктуру, переводы на 11 языков и регулярные обновления для iOS и Android. Каждый евро реинвестируется в проект, чтобы мусульмане по всему миру могли продолжать учиться, поминать Аллаха и вместе творить добро. Поддержка инструмента, который помогает тысячам людей в их поклонении, — это садака джария, иншаАллах.$q$,
  -- media
  'https://gawzqxnhliggvyebldmb.supabase.co/storage/v1/object/public/app_images/impact/nour-app/cover.jpg',
  array[
    'https://gawzqxnhliggvyebldmb.supabase.co/storage/v1/object/public/app_images/impact/nour-app/cover.jpg',
    'https://gawzqxnhliggvyebldmb.supabase.co/storage/v1/object/public/app_images/impact/nour-app/gallery-logo.jpg'
  ]::text[],
  array[5, 15, 50, 150]::int[],
  25000, 0, 'EUR',
  0, false, true, 0
from public.partner_organizations o
cross join public.project_categories c
where o.name_en = 'Nour Charity'
  and c.title_en = 'App'
  and not exists (
    select 1 from public.impact_projects p where p.title_en = 'Help us build the Nour app'
  );

-- ── Tiers ("Your donation provides") ─────────────────────────────────────────
insert into public.impact_project_tiers (
  impact_project_id, amount, position,
  title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru,
  subtitle_en, subtitle_fr, subtitle_ar, subtitle_de, subtitle_nl, subtitle_tr, subtitle_id, subtitle_ur, subtitle_bn, subtitle_ms, subtitle_ru
)
select p.id, t.amount, t.position,
       t.title_en, t.title_fr, t.title_ar, t.title_de, t.title_nl, t.title_tr, t.title_id, t.title_ur, t.title_bn, t.title_ms, t.title_ru,
       t.subtitle_en, t.subtitle_fr, t.subtitle_ar, t.subtitle_de, t.subtitle_nl, t.subtitle_tr, t.subtitle_id, t.subtitle_ur, t.subtitle_bn, t.subtitle_ms, t.subtitle_ru
from public.impact_projects p
cross join (values
  (5::numeric, 0,
   $q$One day of servers$q$, $q$Une journée de serveurs$q$, $q$يوم واحد من الخوادم$q$, $q$Ein Tag Serverkosten$q$, $q$Eén dag servers$q$, $q$Bir günlük sunucu$q$, $q$Satu hari server$q$, $q$ایک دن کے سرورز$q$, $q$এক দিনের সার্ভার$q$, $q$Satu hari pelayan$q$, $q$Один день серверов$q$,
   $q$Keeps the app online for everyone$q$, $q$Garde l'application en ligne pour tous$q$, $q$يُبقي التطبيق متاحًا للجميع$q$, $q$Hält die App für alle online$q$, $q$Houdt de app online voor iedereen$q$, $q$Uygulamayı herkes için çevrimiçi tutar$q$, $q$Menjaga aplikasi tetap online untuk semua$q$, $q$ایپ کو سب کے لیے آن لائن رکھتا ہے$q$, $q$সবার জন্য অ্যাপ অনলাইন রাখে$q$, $q$Memastikan aplikasi kekal dalam talian untuk semua$q$, $q$Поддерживает приложение онлайн для всех$q$),
  (15::numeric, 1,
   $q$One hour of development$q$, $q$Une heure de développement$q$, $q$ساعة من التطوير$q$, $q$Eine Stunde Entwicklung$q$, $q$Eén uur ontwikkeling$q$, $q$Bir saatlik geliştirme$q$, $q$Satu jam pengembangan$q$, $q$ایک گھنٹے کی ڈیویلپمنٹ$q$, $q$এক ঘণ্টার ডেভেলপমেন্ট$q$, $q$Satu jam pembangunan$q$, $q$Один час разработки$q$,
   $q$Bug fixes and small improvements$q$, $q$Corrections de bugs et petites améliorations$q$, $q$إصلاح الأخطاء وتحسينات صغيرة$q$, $q$Fehlerbehebungen und kleine Verbesserungen$q$, $q$Bugfixes en kleine verbeteringen$q$, $q$Hata düzeltmeleri ve küçük iyileştirmeler$q$, $q$Perbaikan bug dan peningkatan kecil$q$, $q$بگ فکسز اور چھوٹی بہتریاں$q$, $q$বাগ সংশোধন ও ছোট উন্নতি$q$, $q$Pembetulan pepijat dan penambahbaikan kecil$q$, $q$Исправление ошибок и небольшие улучшения$q$),
  (50::numeric, 2,
   $q$A new small feature$q$, $q$Une nouvelle petite fonctionnalité$q$, $q$ميزة صغيرة جديدة$q$, $q$Eine neue kleine Funktion$q$, $q$Een nieuwe kleine functie$q$, $q$Yeni küçük bir özellik$q$, $q$Satu fitur kecil baru$q$, $q$ایک نیا چھوٹا فیچر$q$, $q$একটি নতুন ছোট ফিচার$q$, $q$Satu ciri kecil baharu$q$, $q$Новая небольшая функция$q$,
   $q$Designed, built and tested$q$, $q$Conçue, développée et testée$q$, $q$مصمَّمة ومطوَّرة ومختبَرة$q$, $q$Entworfen, entwickelt und getestet$q$, $q$Ontworpen, gebouwd en getest$q$, $q$Tasarlandı, geliştirildi ve test edildi$q$, $q$Dirancang, dibangun, dan diuji$q$, $q$ڈیزائن، تیار اور ٹیسٹ شدہ$q$, $q$ডিজাইন, তৈরি ও পরীক্ষিত$q$, $q$Direka, dibina dan diuji$q$, $q$Спроектирована, реализована и протестирована$q$),
  (150::numeric, 3,
   $q$A full feature screen$q$, $q$Un écran de fonctionnalité complet$q$, $q$شاشة ميزة كاملة$q$, $q$Ein kompletter Feature-Screen$q$, $q$Een volledig functiescherm$q$, $q$Tam bir özellik ekranı$q$, $q$Satu layar fitur lengkap$q$, $q$ایک مکمل فیچر اسکرین$q$, $q$একটি সম্পূর্ণ ফিচার স্ক্রিন$q$, $q$Satu skrin ciri lengkap$q$, $q$Полноценный экран функции$q$,
   $q$From design to release on iOS and Android$q$, $q$Du design à la publication sur iOS et Android$q$, $q$من التصميم إلى الإطلاق على iOS وAndroid$q$, $q$Vom Design bis zur Veröffentlichung auf iOS und Android$q$, $q$Van ontwerp tot release op iOS en Android$q$, $q$Tasarımdan iOS ve Android'de yayına$q$, $q$Dari desain hingga rilis di iOS dan Android$q$, $q$ڈیزائن سے لے کر iOS اور Android پر ریلیز تک$q$, $q$ডিজাইন থেকে iOS ও Android-এ রিলিজ পর্যন্ত$q$, $q$Dari reka bentuk hingga keluaran di iOS dan Android$q$, $q$От дизайна до релиза на iOS и Android$q$)
) as t(amount, position,
       title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru,
       subtitle_en, subtitle_fr, subtitle_ar, subtitle_de, subtitle_nl, subtitle_tr, subtitle_id, subtitle_ur, subtitle_bn, subtitle_ms, subtitle_ru)
where p.title_en = 'Help us build the Nour app'
  and not exists (
    select 1 from public.impact_project_tiers x
     where x.impact_project_id = p.id and x.title_en = t.title_en
  );

-- ── Launch story ─────────────────────────────────────────────────────────────
insert into public.project_stories (
  impact_project_id,
  title_en, title_fr, title_ar, title_de, title_nl, title_tr, title_id, title_ur, title_bn, title_ms, title_ru,
  description_en, description_fr, description_ar, description_de, description_nl, description_tr, description_id, description_ur, description_bn, description_ms, description_ru,
  images, created_at
)
select p.id,
  $q$Development fund launched$q$,
  $q$Lancement du fonds de développement$q$,
  $q$إطلاق صندوق التطوير$q$,
  $q$Entwicklungsfonds gestartet$q$,
  $q$Ontwikkelingsfonds gelanceerd$q$,
  $q$Geliştirme fonu başlatıldı$q$,
  $q$Dana pengembangan diluncurkan$q$,
  $q$ڈیویلپمنٹ فنڈ کا آغاز$q$,
  $q$ডেভেলপমেন্ট ফান্ড চালু হলো$q$,
  $q$Dana pembangunan dilancarkan$q$,
  $q$Фонд развития запущен$q$,
  $q$Thank you for supporting the app. Progress on new features will be shared here, insha'Allah.$q$,
  $q$Merci de soutenir l'application. L'avancement des nouvelles fonctionnalités sera partagé ici, incha'Allah.$q$,
  $q$شكرًا لدعمكم التطبيق. سنشارك هنا تقدّم الميزات الجديدة إن شاء الله.$q$,
  $q$Danke für deine Unterstützung der App. Fortschritte zu neuen Funktionen werden hier geteilt, insha'Allah.$q$,
  $q$Bedankt voor je steun aan de app. De voortgang van nieuwe functies wordt hier gedeeld, insha'Allah.$q$,
  $q$Uygulamayı desteklediğiniz için teşekkürler. Yeni özelliklerdeki ilerleme burada paylaşılacak, inşallah.$q$,
  $q$Terima kasih telah mendukung aplikasi ini. Perkembangan fitur baru akan dibagikan di sini, insya Allah.$q$,
  $q$ایپ کی حمایت کا شکریہ۔ نئے فیچرز کی پیش رفت ان شاء اللہ یہاں شیئر کی جائے گی۔$q$,
  $q$অ্যাপকে সহায়তা করার জন্য ধন্যবাদ। নতুন ফিচারের অগ্রগতি ইনশাআল্লাহ এখানে জানানো হবে।$q$,
  $q$Terima kasih kerana menyokong aplikasi ini. Kemajuan ciri baharu akan dikongsi di sini, insya-Allah.$q$,
  $q$Спасибо за поддержку приложения. Прогресс по новым функциям будет публиковаться здесь, иншаАллах.$q$,
  array['https://gawzqxnhliggvyebldmb.supabase.co/storage/v1/object/public/app_images/impact/nour-app/gallery-logo.jpg']::text[],
  now()
from public.impact_projects p
where p.title_en = 'Help us build the Nour app'
  and not exists (
    select 1 from public.project_stories st
     where st.impact_project_id = p.id and st.title_en = 'Development fund launched'
  );
