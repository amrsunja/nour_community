# Mosques Module — Implementation Specification (V2)

**Status:** implemented on `feat/mosques-module` — see §15.
**Stack:** Supabase (Postgres 15 + PostGIS + Edge Functions/Deno + Storage + Realtime + pg_cron) · Flutter (`hooks_riverpod`, `auto_route`, `flutter_stripe` 13, `firebase_*`) · Stripe Connect (direct charges) · Firebase Cloud Messaging.
**Inputs:** `docs/devis_module_mosquees_v2_fr.md` (Poste 1 + Bloc A + Bloc B), `docs/Nour Specs V2 Final.docx` §7, Figma *Nour community* → page **Screens V2** → sections `Onboarding user` (995:2992), `Onboarding mosquée` (1212:9539), `Mosque search` (1333:17229), `Mosque profile - user POV` (1098:5923), `Mosque profile - admin POV` (1154:4245).
**Repo:** `backend/supabase` (migrations + functions) · `nour_app` (Flutter, `lib/src/features/*`).

> ⚠️ **The app is live in the stores (1.2.0).** Every change below is additive and backward compatible: new tables, new nullable columns, new enum values, new routes. Nothing existing is renamed, dropped or given a new NOT NULL constraint without a default. Existing users (all `profiles` rows) keep behaving exactly as today. See §12 for the safety checklist that MUST be re-read before each migration.

---

## 0. How to read this document

- §1 — scope & delivery phases (do them in order; each phase is shippable).
- §2 — Figma map (node ids → screens) so you can `get_design_context` per screen while implementing UI.
- §3 — Auth & onboarding rewrite (two profile types). **This is the entry point of everything else and touches production auth — read §12 first.**
- §4 — Database (enums, tables, triggers, RLS, RPCs, storage, realtime, cron).
- §5 — Edge Functions.
- §6 — Push notification infrastructure (Poste 1).
- §7 — Flutter architecture, routes, models, providers, screens (user POV).
- §8 — Flutter admin POV (mosque dashboard).
- §9 — Prayer-times integration (mosque times override computed times).
- §10 — Payments: Stripe Connect (Bloc B).
- §11 — Nour admin moderation.
- §12 — Production-safety checklist & backward compatibility.
- §13 — Test plan.
- §14 — Decisions taken / open questions.

**Pattern files to copy from (read them before coding):**
- Presenter/state: `features/tools/ui/state_management/prayer_times_provider.dart` + `_state.dart`; page with `useEffect` init: `features/tools/ui/pages/prayer_times_page.dart`.
- Datasource/repo/model: `features/impact/data/datasources/impact_remote_datasource.dart`, `impact_repo.dart`, `models/impact_project_model.dart`.
- Payment flow to mirror: `features/payments/ui/state_management/checkout_provider.dart`, `data/services/stripe_payment_service.dart`, `data/datasources/payment_remote_datasource.dart`.
- Edge functions to mirror: `functions/create-subscription/index.ts`, `functions/stripe-webhook/index.ts`, `functions/_shared/*`.
- Migrations to mirror: `20260818000100_payments_v2.sql` (idempotent style, RLS, realtime, pg_cron), `20260515001200_storage_buckets.sql`, `20260809000000_fix_is_admin_escalation_trusted_context.sql`.
- Auth: `features/auth/data/datasrouces/auth_remote_datasource.dart` (anonymous linking rules), `features/auth/ui/state_management/auth_provider.dart`, `core/routing/guards/auth_guard.dart`.
- Onboarding: `features/onboarding/ui/pages/onboarding_page.dart` + `widgets/onboarding_screen_N.dart`.
- Admin: `features/admin/*` (Nour admin dashboard).

Conventions used in this doc: `snake_case` = DB, `camelCase` = Dart, `kebab-case` = edge functions / routes. Code blocks are the target implementation, not pseudo-code, unless marked *(sketch)*.

---

## 1. Scope & phases

| Phase | Content | Depends on | Shippable? |
|---|---|---|---|
| **P0 — Accounts & onboarding** | `profiles.account_type`, pre-auth Welcome + profile-type screens, mosque onboarding (local draft → sign-up → `fn_register_mosque`), "in review" gate, user onboarding "Select a mosque" step | — | yes (mosque accounts exist but can't do anything until P2) |
| **P1 — Push infra** (devis Poste 1) | FCM iOS/Android, `device_tokens`, `notification_preferences`, `send-push` function, `notifications_log`, deep links, settings screen | — | yes |
| **P2 — Bloc A: mosques core** | `mosques` + prayer times + posts + followers + user mosques, PostGIS search, profile 4 tabs (user POV), admin shell (Dashboard / Community / Mosque / Post), prayer editor + overrides + copy, Nour-admin moderation, prayer-times override in Tools/Dashboard | P0, P1 (for "notify followers") | yes |
| **P3 — Bloc B: donations** | Stripe Connect onboarding, Sadaqa settings, campaigns, membership (+ optional annual fee), donation tab (user), donation analytics (admin), donors list, receipts, `stripe-connect-webhook` | P2 | yes |

Everything in P3 is behind `mosques.donations_enabled` (server-side) **and** a remote feature flag `app_config.mosque_donations_enabled` (see §4.14) so the client can ship the tab hidden.

Out of scope (per specs): rating system (option), external donation link fallback (option), check-in/badges, live khutba, DM/comments, content translation.

---

## 2. Figma map

File key `yxEYXRUDmmkCZO0nNFZUT6`. Use `mcp__Figma__get_design_context(fileKey, nodeId)` per frame when building the widget. Frames are 393 px wide (iPhone 15). Design tokens already exist in `lib/src/core/design_system` (`UITheme`, `UIColorsToken`, `UITypographyToken`, `UICard`, `UIButton`, `UITabs`, `UIInputField`, `UIToggle`, `UIAvatar`, `UIAppBar`, `UIGradientLinedScaffold`, `UINavbar`…). **Reuse them; do not introduce a second design system.**

### 2.1 Onboarding user (section 995:2992) — order left → right
1. Splash (logo) — existing.
2. **Welcome to Nour** — "Your premium companion for a beautiful spiritual journey" · CTA *Let's get started* (existing screen 1, but now shown **before** any session exists).
3. **How will you use Nour?** (frame "Onboarding 29") — two selectable cards: *I am a mosque manager — Publish to your community, run fundraising campaigns* / *I am a worshipper — Follow mosques, track prayer times, and stay connected* · CTA *Let's get started*. **NEW.**
4. Build a beautiful daily routine — existing (screen 3).
5. Where are you on your journey? — existing (screen 4).
6. How much time daily? — existing (screen 5).
7. **Select a mosque** (frame "Onboarding 32") — search field with locate icon, "Near you" list (name, distance · city, avatar/logo, ⊕ / ✓) · *Maybe later* / *Continue*. **NEW** — inserts between "time daily" and "Choose a voice".
8. Choose a voice — existing (7).
9. Choose your language — existing (8).
10. Gentle reminders — existing (6).
11. Tell us about yourself / create account — existing (9).

### 2.2 Onboarding mosquée (section 1212:9539) — order left → right
1. Splash · 2. Welcome to Nour · 3. How will you use Nour? (shared with 2.1) → mosque manager selected.
4. **Made for mosque announcements** (Onboarding 24) — 4 tiles Event / Volunteering / Highlight / Janaza · "Events, fundraisers, volunteer calls, janazas, reminders, highlights" · *Continue*.
5. **Raise funds the trusted way** (Onboarding 16) — donation analytics illustration · "Ongoing Sadaqah and time-bound campaigns".
6. **A calendar that reflects your imam** (Onboarding 28) — prayer card illustration (Isha 22:34 +10).
7. **Choose your country** (Onboarding 30) — searchable list with flags (France, Belgium, Sweden, Netherlands, Spain…). Stored in draft `countryCode`.
8. **Choose your language** (Onboarding 21) — English / العربية / Français (reuse existing language screen widget).
9. **Gentle reminders** (Onboarding 19) — same toggles as user flow (prayer times, morning/evening adhkar, daily ayah) · *Maybe later* / *Allow notifications*.
10. **Let's register your mosque** (Onboarding 31) — *Legal name* (text), *Legal status* (select: `association_1901`, `association_1905`, `other`), *RNA* (text, e.g. `W751123456`), *SIREN number* (9 digits) · CTA *Register*.
11. **Let's create your account** (Onboarding 23) — email (+ password in the mock) · *or sign up with* Google / Apple / Facebook · "You already have an account? **Sign in**" · CTA *Sign up*. **Decision:** keep Nour's existing methods — email + OTP, Google, Apple (no password, no Facebook). See §3.

### 2.3 Mosque search (section 1333:17229)
- `1212:9436` **Prayer time** — existing Tools › Prayer times page with a new mosque chip "Grande mosquée de Paris - Paris" under the title (tap → *Mosques* sheet).
- `1245:10598` / `1293:15918` **Mosques** bottom sheet — "Your mosque(s) — Drag and drop the mosques to reorder them and set the main mosque." · *Principal mosque* row · *Secondary mosque* row ("No secondary mosque yet" empty state) · *Save*.
- `1245:10989` / `1245:11400` / `1272:11655` **Search mosques** — full-screen map with pins + search bar (back, "Search mosque", locate button) + draggable bottom sheet "Mosques near you": card = logo, name, address · distance, today's 5 times row, "Chourouk 06:28 | Jumu'a 14:00", CTA *Add to my mosques* (map icon at left = itinerary). `1272:11655` = empty/loading state.

### 2.4 Mosque profile — user POV (section 1098:5923)
- `1050:1551` **Prayers tab** — cover carousel (dots), back + share icons, logo, name, address (copy icon), status pill *Open*, "1,247 followers · 183 members", buttons *Follow* (outlined, heart) / *Become a member* (filled gold), 3 action tiles *Itinerary* / *Call* / *Email*, segmented tabs *Prayers · Information · News (dot badge) · Donation*, "Today's prayer times · 18 Safar 1448 · Dim. 2 août", 5 prayer rows (name, time, "+10" iqama offset; next prayer highlighted with illustration + countdown 00:22:12), "Chourouk 06:28 | Jumu'a 14:00", sticky CTA *Add to my mosques*.
- `1053:4054` **Information tab** — Capacity (3,200 · Men + Women), Founded (1973 · 53 years old), Services list with icons (Parking, Accès handicapés, Salle d'ablution, Espace pour femmes, Cours pour adultes, Cours pour enfants, Salat Al Aïd, Salat Al Janaza, Iftar Ramadan), Khutbah language(s) flags (French, Arabic, English), Imams (avatar/initials, name, "Since 2018").
- `1076:4743` **News tab** — feed of posts: *Announcement* (14 min ago, title, body), *Volunteering* card (body, "3 volunteer(s)", date "September, 12th 13:15", *Share* / *Apply*), *Urgent* (red badge), *Event* card (date chip "AUG 25", title, body, position/language chips, "124 attending", *I'll attend*), *Highlight* (cover photo, "1 week ago"), *Janaza* (arabic dua text, "After Duhr prayer - 13:45", "892 duas", *Say a dua*).
- `1180:6503` **Say a dua** bottom sheet — dua text + audio + *I'm done*.
- `1093:5464` **Donation tab** — "Support the mosque" card: description, frequency segmented *Monthly (Popular) / Yearly / One time*, amounts `10€ 50€ 100€ 150€`, "Or — Enter amount manually", CTA *Give to the mosque*, badge *Tax deductible 66%*; "Fundraising campaigns" list: card with cover, "12 days left", title, subtitle, progress "12,400€ / 50,000€", avatars "1,247+ people have donated", *Share* / *Contribute*.
- `1105:5936` **Become a member** — form: First name*, Last name*, Date of birth*, Profession*, Email*, Phone number*, "Available for volunteer projects?*" Yes/No, GDPR consent checkbox, (optional annual fee 60/120/240 € or custom — devis B4), CTA *Register*.
- `1105:7925` **Home – mosque news** — dashboard (existing Home) with a new **"My mosque" card** between *Next prayer* and *Quick tools*: empty state "No mosque selected yet — get prayer times, news and more" + *Find a mosque*; filled state shows mosque name, next prayer at the mosque, latest post.

### 2.5 Mosque profile — admin POV (section 1154:4245)
Admin app shell = bottom navbar **Dashboard · Community · Mosque · Post(+)** (the mosque account never sees the worshipper navbar).
- `1109:8176` **Dashboard** — header "Salam Alaykoum, Annour Center Mulhouse" + bell; attention banner "2 things need your attention — 1 pending event · 1 fundraising ending soon"; *Community* stats (Followers 1,247 +42 last 7 days · Members 183 −3) + Growth chart (+18% last 30 days); *Fundraising* (3): €103,570 total raised (this year ▾), 1,583 donors, campaign progress rows (58% 7d left…); *Recent posts* (badge, age, title, views 847, reactions 43, "Notified all").
- `1117:10010` **Community** — search "name, email, phone", filter chips *All / Followers / Members / Volunteers*, list rows (avatar, name, badge Member/Follower, "Since 2018", ⋮ menu).
- `1123:10726` / `1333:17366` / `1333:17593` / `1333:17807` **Mosque › Prayers (editor)** — public header in edit mode (0 followers, *Edit* button), tabs, "Prayer times" month header (Dhul Qa'ada 1447 · April–May 2026, ‹ ›), week strip S M T W T F S with hijri day + gregorian sub-label, per-slot rows (Fajr 05:03 +10 ✎ …, Chourouk, Jumu'a), empty state "The day's prayers have not yet been set. Enter them manually or copy from another day" + *Copy from another day*, toast "Prayer time successfully copied from Jun 14th", **Prayer's overrides** card: "Shift a prayer today — change one prayer's time for today only, without touching the permanent schedule" · *Create an override* · "Applied overrides: Maghrib 23:30 (was 21:11) ✕".
- `1333:17251` **Copy to day only** / `1333:17299` **Copy to range** sheets — "Copy from [date]", times preview, "Apply to: This day only / A date range", From / To, warning "Days that already have times will be overwritten." · *Copy*.
- `1125:11933` **Mosque › Information (editor)** — Capacity (total / Men's space / Women's space), Founded, Services multi-select ("Select the services your mosque offers. They'll appear on your public profile"), Khutbah languages (search + chips), Imams list + *Add an Imam*.
- `1137:1802` **Add imam** sheet — photo (optional), Full name, Role (Principal Imam…), At the mosque since (year), Short bio.
- `1140:2046` **Create a post** — header "Annour Center Mulhouse", *Title*, *Start writing* body, "Or choose a category": Event (Date, time, place) / Volunteering (Recruit helpers) / Highlight (Share moments) / Janaza (Date, prayer time) · "Add to your post" (photo) · *Post*.
- `1142:5343` **Post an event** — Cover photo (optional), Event name, Description, Date, Time, Location ("At the mosque"), toggle *Notify followers — Send push to 1,247 followers*, toggle *Mark as urgent — Post appears at top with urgent badge* · *Post*.
- `1150:6236` **Mosque › Donation (admin analytics)** — €103,570 total raised this year (+24% vs 2025), split Support 43,500€ 42% / Campaigns 60,070€ 58%, Donors 1,583 · Recurring 87 · Avg gift 65€; "Support the mosque — Sadaqah · Active · This month 64 gifts · Monthly donors" + *Manage settings*; "Active campaigns (3)" + *New*, rows with progress, "7d left", donors, raised/of goal; "Also here": *All campaigns* / *Donors list* / *Tax receipts*.
- `1190:8268` **Sadaqa settings** — Section title, Short description, Suggested amounts (chips 10/50/100/150 + *Add amount*), Frequency options (One-time gift / Monthly recurring / Yearly recurring toggles), Tax deductibility ("Show 66% tax deduction badge"), live *Preview* of the public card.
- `1202:8978` **Campaigns settings** — Active campaigns list (progress, days left, donors, raised/goal, actions *Extend · Edit · Post update · Close early*), closed campaigns, + same amount/frequency/tax settings for campaigns.
- `1171:6379` **Profile** (mosque account) — Settings: Journey, Statistics, Favourites, Preferences, Reminders, Reading preferences, Account, Help & support, About Nour (+ `lucide/layout-dashboard` icon = "Mosque dashboard" entry when the account is a mosque). Existing `ProfilePage` reused.

---

## 3. Auth & onboarding — two account types

### 3.1 Target behaviour (as decided with Amir)

```
App start
 └─ session exists? ──yes──► authorization() as today ► profile.account_type
 │                                  ├─ 'user'   ► existing flow (onboarding_completed? Home : Onboarding)
 │                                  └─ 'mosque' ► mosque status? approved ► MosqueAdminShell
 │                                                              pending/rejected/suspended ► MosqueReviewPage
 └─ no session ──► WelcomePage ► ProfileTypePage
                     ├─ "I am a worshipper" + Let's get started
                     │     ► signInAnonymously() (today's behaviour, just moved later) ► OnboardingPage (user)
                     │       ... last step = create account (email OTP / Google / Apple)
                     │         ► if the credentials belong to an EXISTING **mosque** profile
                     │           ► anonymous session is dropped, sign into that account ► mosque branch above
                     └─ "I am a mosque manager"
                           ► NO session. MosqueOnboardingPage (local draft in SharedPreferences)
                             steps: features ×3 → country → language → reminders → register mosque → account
                           ► sign up / sign in (email OTP / Google / Apple)
                               ├─ credentials belong to an EXISTING **user** profile ► clear draft, treat as user login (Home)
                               ├─ credentials belong to an EXISTING **mosque** profile ► clear draft, mosque branch
                               └─ NEW account ► rpc fn_register_mosque(draft) ► profiles.account_type='mosque'
                                                ► mosques.status='pending_review' ► MosqueReviewPage
```

Rules:
1. A **mosque account is never anonymous**. No `signInAnonymously()` on that branch.
2. `profiles.account_type` is the single source of truth for routing. Default `'user'` → every existing row stays a worshipper.
3. A mosque account with status ≠ `approved` **cannot do anything**: client shows `MosqueReviewPage` (logout only) and RLS refuses all writes to mosque content (§4.10).
4. "Existing profile" = a `profiles` row for that auth user with `onboarding_completed = true` **or** `account_type = 'mosque'`. A brand-new auth user created by OTP/Google/Apple in the mosque flow has no such row yet → it is claimed by `fn_register_mosque`.
5. The local mosque onboarding draft is cleared on: successful `fn_register_mosque`, login into an existing profile of either type, explicit "Start over".

### 3.2 Flutter changes

**Routing (`app_router.dart` / `route_paths.dart`)** — add, under `RootRoute`:

```dart
// route_paths.dart
static const welcome = 'welcome';
static const profileType = 'profile-type';
static const mosqueOnboarding = 'mosque-onboarding';
static const mosqueReview = 'mosque-review';
static const mosqueAdmin = 'mosque-admin';           // shell with its own nested tabs (see §8)
```

```dart
// app_router.dart — siblings of SignIn/Onboarding (NOT under HomeRouter, no authGuard)
AutoRoute(path: RoutePaths.welcome, page: WelcomeRoute.page),
AutoRoute(path: RoutePaths.profileType, page: ProfileTypeRoute.page),
AutoRoute(path: RoutePaths.mosqueOnboarding, page: MosqueOnboardingRoute.page),
AutoRoute(path: RoutePaths.mosqueReview, page: MosqueReviewRoute.page),
AutoRoute(path: RoutePaths.mosqueAdmin, page: MosqueAdminShellRoute.page, guards: [mosqueAdminGuard], children: [...]),
```

**`AuthGuard`** (`core/routing/guards/auth_guard.dart`) becomes account-type aware:

```dart
@override
void onNavigation(NavigationResolver resolver, StackRouter router) {
  final auth = ref.read(authProvider);
  if (!auth.isAuthenticated) { router.replaceAll([WelcomeRoute()]); return; }
  final profile = ref.read(profileProvider).profile;
  if (profile == null) { router.replaceAll([WelcomeRoute()]); return; }
  switch (profile.accountType) {
    case AccountType.mosque:
      final m = ref.read(myMosqueProvider).mosque;
      router.replaceAll([m?.status == MosqueStatus.approved ? MosqueAdminShellRoute() : MosqueReviewRoute()]);
      return;
    case AccountType.user:
      if (!profile.onboardingCompleted) { router.replaceAll([OnboardingRoute()]); return; }
      resolver.next();
  }
}
```

Add a symmetric `MosqueAdminGuard` (only `account_type == mosque && status == approved`, otherwise redirect to `MosqueReviewRoute` / `HomeRouterRoute`).

**`AuthPresenter.authorization()`** (`features/auth/ui/state_management/auth_provider.dart`):
- Today: no session → `signInAnonymously()` immediately. **Change:** no session → `state = state.copyWith(isAuthenticated: false, needsProfileType: true)` and navigate to `WelcomeRoute`. Anonymous sign-in is triggered only by `ProfileTypePage` → *worshipper* → *Let's get started* (`startAsWorshipper()` = `signInAnonymously()` + `initProfile()` + `toOnboarding()`).
- After any successful login (`linkEmailWithOTP`, `linkWithGoogle`, `linkWithApple`, and the new sessionless variants) call `_routeAfterLogin()`:

```dart
Future<void> _routeAfterLogin({MosqueOnboardingDraft? draft}) async {
  await ref.read(profileProvider.notifier).initProfile();           // creates/loads profiles row
  final profile = ref.read(profileProvider).profile!;
  final draftStore = ref.read(mosqueOnboardingLocalDataProvider);

  if (profile.accountType == AccountType.mosque) {                    // existing mosque account
    await draftStore.clear();
    await ref.read(myMosqueProvider.notifier).load();
    nav.toMosqueAdminOrReview();
    return;
  }
  final isExistingUser = profile.onboardingCompleted;                 // existing worshipper account
  if (draft != null && !isExistingUser) {                             // brand-new account in the mosque flow
    final ok = await ref.read(mosqueRepoProvider).registerMosque(draft);
    if (ok) { await draftStore.clear(); await ref.read(profileProvider.notifier).initProfile(); nav.toMosqueReview(); return; }
    appEvents.send(ShowErrorEvent(...)); return;                      // keep draft, stay on account step
  }
  await draftStore.clear();
  nav.toHome();                                                       // or onboarding if !onboarding_completed
}
```

**Sessionless sign-in** (mosque flow has no anonymous session): `AuthRemoteDatasource.startEmailAuth` already handles `!hasSession` → `signInWithOtp(shouldCreateUser: !exists)`. Google/Apple: `_connectIdentity` already falls back to `signInWithIdToken` when there is no anonymous session. **No datasource change needed**; only the presenter must not assume an anonymous session and must not call `initProfile()` before the session exists.

Edge: the worshipper flow ends with the same `SignUpPage`/`SignInPage`. If the OTP/Google/Apple resolves to an existing **mosque** account, `startEmailAuth` (email exists → OTP → `verifyOTP`) / `signInWithIdToken` already replaces the anonymous session. `_routeAfterLogin()` then routes to the mosque branch. Anonymous data of that throwaway session is lost — acceptable and identical to today's behaviour for an existing user account.

**Local draft** — `features/mosque_onboarding/data/datasources/mosque_onboarding_local_datasource.dart`, key `mosque_onboarding_draft_v1` in `SharedPreferences` (JSON). Model:

```dart
class MosqueOnboardingDraft extends Equatable {
  final int step;                     // resume where the user left
  final String? countryCode;          // 'FR'
  final String? language;             // 'en' | 'fr' | 'ar' (also applied to app locale as today)
  final Map<String, bool> reminders;  // same keys as NotificationsSettingsModel
  final String? legalName;
  final MosqueLegalStatus? legalStatus; // association1901 | association1905 | other
  final String? rna;                  // /^W\d{9}$/ (French RNA), optional if legalStatus == other
  final String? siren;                // /^\d{9}$/
  // persisted as JSON; toRegisterPayload() maps to fn_register_mosque args
}
```

On cold start with a draft present and no session → open `MosqueOnboardingRoute` at `draft.step` (offer *Start over* in the app bar).

**Onboarding (user) new step "Select a mosque"** — `OnboardingScreenMosque` between screen 5 and 7 (`lastOnboardingScreen` indices shift: add the new screen at index 5, existing 6→7 … 9→10 — `profiles.last_onboarding_screen` is `smallint`, no migration; **existing users mid-onboarding** (rare, `onboarding_completed=false`) simply see one extra screen). Uses `mosqueSearchProvider` (§7) with "Near you" from `GeolocatorTools.currentOrCachedPosition()`; if location denied → show search only. Selecting a mosque → `user_mosques` upsert rank 1 (§4.5). *Maybe later* skips.

**Profile type screen** stores nothing server-side. Choosing *mosque manager* only writes the draft (`step = 0`).

### 3.3 Server-side registration — `fn_register_mosque`

Called once by the freshly signed-up mosque manager (RLS: `authenticated`, `SECURITY DEFINER`, validates caller):

```sql
create or replace function public.fn_register_mosque(
  p_legal_name   text,
  p_legal_status public.mosque_legal_status,
  p_rna          text,
  p_siren        text,
  p_country_code text,
  p_language     text default 'en'
) returns bigint
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); v_mosque_id bigint; v_profile public.profiles%rowtype;
begin
  if v_uid is null then raise exception 'unauthorized'; end if;
  select * into v_profile from public.profiles where id = v_uid;
  if v_profile.account_type = 'mosque' then
    select mosque_id into v_mosque_id from public.mosque_admins where user_id = v_uid and role = 'owner' limit 1;
    return v_mosque_id;                                   -- idempotent replay
  end if;
  if v_profile.onboarding_completed then
    raise exception 'profile_is_worshipper';              -- never convert an existing worshipper silently
  end if;
  if exists (select 1 from auth.users where id = v_uid and is_anonymous) then
    raise exception 'anonymous_not_allowed';
  end if;
  if p_siren !~ '^\d{9}$' then raise exception 'invalid_siren'; end if;
  if p_legal_status <> 'other' and p_rna !~ '^W\d{9}$' then raise exception 'invalid_rna'; end if;

  insert into public.mosques (name, legal_name, legal_status, rna, siren, country_code, default_language, status, created_by)
  values (p_legal_name, p_legal_name, p_legal_status, p_rna, p_siren, upper(p_country_code), p_language, 'pending_review', v_uid)
  returning id into v_mosque_id;

  insert into public.mosque_admins (mosque_id, user_id, role) values (v_mosque_id, v_uid, 'owner');
  perform set_config('nour.trusted', 'on', true);        -- allows the account_type change (trigger §4.2)
  update public.profiles set account_type = 'mosque', onboarding_completed = true where id = v_uid;
  return v_mosque_id;
end $$;
revoke execute on function public.fn_register_mosque(text, public.mosque_legal_status, text, text, text, text) from public;
grant execute on function public.fn_register_mosque(text, public.mosque_legal_status, text, text, text, text) to authenticated;
```

`profiles.account_type` is protected by a trigger (§4.2): only this function (trusted context) or a Nour admin may change it; a client `update profiles set account_type` is rejected.

### 3.4 MosqueReviewPage
Full-screen state page (reuse `reward_scaffold.dart` visual language): status `pending_review` → "Your mosque is being reviewed — we'll notify you (push + email) once approved"; `rejected` → reason text (`mosques.review_note`) + *Contact support* (mailto); `suspended` → same. Actions: *Refresh* (re-reads `fn_my_mosque`), *Log out*. Realtime subscription on `mosques` row (`id = my mosque`) flips to the admin shell automatically on approval.

---

## 4. Database

All in **one migration per phase**, named `backend/supabase/migrations/2026090X0000NN_mosques_<phase>.sql`, idempotent (`if not exists`, `do $$ … exception when duplicate_object`). Reuse `public.set_updated_at()` and `public.is_admin()`.

### 4.1 Extensions & enums (P0)

```sql
create extension if not exists postgis with schema extensions;   -- geography search (Supabase: Dashboard › Extensions if this fails)

do $$ begin create type public.account_type as enum ('user','mosque'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_status as enum ('pending_review','approved','rejected','suspended'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_legal_status as enum ('association_1901','association_1905','other'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_admin_role as enum ('owner','manager'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_service as enum (
  'parking','disabled_access','ablution_room','women_space','adult_classes','children_classes',
  'quran_classes','arabic_classes','eid_prayer','janaza','iftar_ramadan','library','new_muslims_support'); exception when duplicate_object then null; end $$;
do $$ begin create type public.prayer_slot as enum ('fajr','dhuhr','asr','maghrib','isha'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_post_type as enum ('announcement','event','volunteering','highlight','janaza'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_post_status as enum ('draft','published','archived'); exception when duplicate_object then null; end $$;
do $$ begin create type public.mosque_campaign_status as enum ('draft','active','closed','cancelled'); exception when duplicate_object then null; end $$;
do $$ begin create type public.stripe_account_status as enum ('not_started','onboarding','active','restricted','disabled'); exception when duplicate_object then null; end $$;
do $$ begin create type public.push_kind as enum (
  'mosque_post','mosque_event','mosque_campaign','mosque_broadcast','mosque_status',
  'dua_ameen','family_milestone','system'); exception when duplicate_object then null; end $$;

-- Existing enums: ADD VALUES ONLY (never reorder/rename). Each in its own statement, outside a transaction block if run via psql.
alter type public.tx_type add value if not exists 'mosque_sadaqa';
alter type public.tx_type add value if not exists 'mosque_campaign';
alter type public.tx_type add value if not exists 'mosque_membership';
alter type public.ajr_source add value if not exists 'donation';       -- already added by 20260818000000; keep for safety
alter type public.ajr_source add value if not exists 'mosque_dua';     -- "Say a dua" on janaza posts
```

> `alter type … add value` cannot run inside the same transaction that uses the new value. Supabase CLI runs each migration file in one transaction: put the enum additions in their **own migration file** (`…_00_mosques_enums.sql`) before the tables file.

### 4.2 `profiles` additions (P0)

```sql
alter table public.profiles
  add column if not exists account_type public.account_type not null default 'user',
  add column if not exists country_code  text,                       -- ISO-3166 alpha-2, filled by onboarding (both types)
  add column if not exists push_prefs    jsonb not null default '{}'; -- see §6.3
create index if not exists profiles_account_type_idx on public.profiles(account_type) where account_type = 'mosque';

-- account_type can only be changed by a trusted context (no JWT / service role) or a Nour admin.
create or replace function public.fn_protect_account_type() returns trigger language plpgsql security definer set search_path = public as $$
declare
  jwt_claims text := current_setting('request.jwt.claims', true);
  effective_role text := coalesce(current_setting('request.jwt.claim.role', true), current_setting('role', true), current_user);
  v_trusted boolean := jwt_claims is null
                       or effective_role in ('service_role', 'postgres', 'supabase_admin')
                       or current_setting('nour.trusted', true) = 'on';     -- set by fn_register_mosque / review-mosque RPCs
begin
  if new.account_type is distinct from old.account_type and not (v_trusted or public.is_admin()) then
    raise exception 'account_type can only be changed by the server';
  end if;
  return new;
end $$;
drop trigger if exists trg_profiles_protect_account_type on public.profiles;
create trigger trg_profiles_protect_account_type before update on public.profiles
  for each row execute function public.fn_protect_account_type();
```

`fn_register_mosque` is `security definer` but runs with the caller's JWT claims still set → it must bypass the trigger with a transaction-local flag: `perform set_config('nour.trusted', 'on', true);` right before the `update public.profiles …` (the `true` = local to the transaction, so it can never leak). The role detection mirrors `fn_prevent_is_admin_escalation` in `20260809000000_fix_is_admin_escalation_trusted_context.sql`.

`ProfileModel` (Dart) gains `accountType` (default `AccountType.user` when the key is absent → old cached payloads keep working), `countryCode`.

### 4.3 `mosques` (P0 skeleton, P2 content)

```sql
create table if not exists public.mosques (
  id                 bigserial primary key,
  -- identity / legal (from onboarding)
  name               text not null,
  legal_name         text,
  legal_status       public.mosque_legal_status,
  rna                text,
  siren              text,
  country_code       text not null default 'FR',
  default_language   text not null default 'fr',
  status             public.mosque_status not null default 'pending_review',
  review_note        text,                                   -- shown to the mosque when rejected/suspended
  reviewed_by        uuid references public.profiles(id) on delete set null,
  reviewed_at        timestamptz,
  created_by         uuid references public.profiles(id) on delete set null,
  -- public profile (editable by admins once approved)
  slug               text unique,                            -- for deep links / share, generated from name
  logo_url           text,
  cover_images       text[] not null default '{}',           -- carousel, storage paths in bucket mosque-media
  description        text,
  address_line       text,
  city               text,
  postal_code        text,
  location           extensions.geography(point, 4326),      -- lat/lng
  phone              text,
  email              text,
  website            text,
  socials            jsonb not null default '{}',             -- {instagram, facebook, youtube, tiktok, x}
  capacity_total     int,
  capacity_men       int,
  capacity_women     int,
  founded_year       int,
  services           public.mosque_service[] not null default '{}',
  khutbah_languages  text[] not null default '{}',           -- ISO-639-1 codes
  timezone           text not null default 'Europe/Paris',   -- IANA; used for "today", iqama countdown, cron
  opening_status     text,                                   -- null = derive from prayer times; 'open'|'closed' manual override
  -- donations (P3)
  donations_enabled  boolean not null default false,          -- true only when stripe account is active
  can_issue_tax_receipts boolean not null default false,      -- self-declared at Stripe onboarding (devis §7)
  -- denormalised counters (triggers)
  followers_count    int not null default 0,
  members_count      int not null default 0,
  views_count        bigint not null default 0,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index if not exists mosques_status_idx   on public.mosques(status);
create index if not exists mosques_location_gix on public.mosques using gist(location);
create index if not exists mosques_name_trgm    on public.mosques using gin (name extensions.gin_trgm_ops);
create index if not exists mosques_city_trgm    on public.mosques using gin (city extensions.gin_trgm_ops);
create unique index if not exists mosques_siren_uniq on public.mosques(siren) where siren is not null and status <> 'rejected';
drop trigger if exists trg_mosques_updated_at on public.mosques;
create trigger trg_mosques_updated_at before update on public.mosques for each row execute function public.set_updated_at();

create table if not exists public.mosque_admins (
  mosque_id  bigint not null references public.mosques(id) on delete cascade,
  user_id    uuid   not null references public.profiles(id) on delete cascade,
  role       public.mosque_admin_role not null default 'manager',
  created_at timestamptz not null default now(),
  primary key (mosque_id, user_id)
);
create index if not exists mosque_admins_user_idx on public.mosque_admins(user_id);

-- Helper used by every RLS policy below.
create or replace function public.is_mosque_admin(p_mosque_id bigint) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.mosque_admins a join public.mosques m on m.id = a.mosque_id
                  where a.mosque_id = p_mosque_id and a.user_id = auth.uid() and m.status = 'approved');
$$;
-- Variant that ignores status (used only to let the owner READ his own pending mosque).
create or replace function public.is_mosque_member_admin(p_mosque_id bigint) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.mosque_admins where mosque_id = p_mosque_id and user_id = auth.uid());
$$;
```

Concurrent claims (devis §7): a second registration with the same SIREN fails on the unique index → the client shows "This mosque is already registered — contact support". Nour admin can reject the first one to free the SIREN.

### 4.4 Prayer times (P2)

Design: one row per mosque per calendar day (the admin's calendar in Figma is day-based; copy-from-day/range creates rows). Iqama offsets are per row (+10 etc.). Overrides are a separate table so the "permanent schedule" is never touched.

```sql
create table if not exists public.mosque_prayer_times (
  id           bigserial primary key,
  mosque_id    bigint not null references public.mosques(id) on delete cascade,
  day          date   not null,
  fajr         time not null, dhuhr time not null, asr time not null, maghrib time not null, isha time not null,
  sunrise      time,                       -- chourouk (optional, else computed client-side)
  jumua        time,                       -- only meaningful on Fridays; kept on every row for "copy" simplicity
  jumua_2      time, jumua_3 time,         -- extra jumu'as (News mock: "3 Jumu'ahs")
  iqama_offsets jsonb not null default '{"fajr":10,"dhuhr":10,"asr":10,"maghrib":0,"isha":10}',
  source       text not null default 'manual',   -- 'manual' | 'copied' | 'imported'
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (mosque_id, day)
);
create index if not exists mosque_prayer_times_lookup on public.mosque_prayer_times(mosque_id, day);
drop trigger if exists trg_mpt_updated_at on public.mosque_prayer_times;
create trigger trg_mpt_updated_at before update on public.mosque_prayer_times for each row execute function public.set_updated_at();

create table if not exists public.mosque_prayer_overrides (
  id          bigserial primary key,
  mosque_id   bigint not null references public.mosques(id) on delete cascade,
  day         date not null,
  slot        public.prayer_slot not null,
  time        time not null,
  reason      text,
  created_by  uuid references public.profiles(id) on delete set null,
  created_at  timestamptz not null default now(),
  unique (mosque_id, day, slot)
);

-- Copy helper (admin only, validated inside).
create or replace function public.fn_copy_mosque_prayer_times(
  p_mosque_id bigint, p_from date, p_to_start date, p_to_end date
) returns int language plpgsql security definer set search_path = public as $$
declare v_src public.mosque_prayer_times%rowtype; v_d date; v_n int := 0;
begin
  if not public.is_mosque_admin(p_mosque_id) then raise exception 'forbidden'; end if;
  if p_to_end < p_to_start or p_to_end - p_to_start > 366 then raise exception 'invalid_range'; end if;
  select * into v_src from public.mosque_prayer_times where mosque_id = p_mosque_id and day = p_from;
  if not found then raise exception 'source_day_empty'; end if;
  v_d := p_to_start;
  while v_d <= p_to_end loop
    insert into public.mosque_prayer_times (mosque_id, day, fajr, dhuhr, asr, maghrib, isha, sunrise, jumua, jumua_2, jumua_3, iqama_offsets, source)
    values (p_mosque_id, v_d, v_src.fajr, v_src.dhuhr, v_src.asr, v_src.maghrib, v_src.isha, v_src.sunrise, v_src.jumua, v_src.jumua_2, v_src.jumua_3, v_src.iqama_offsets, 'copied')
    on conflict (mosque_id, day) do update set
      fajr = excluded.fajr, dhuhr = excluded.dhuhr, asr = excluded.asr, maghrib = excluded.maghrib, isha = excluded.isha,
      sunrise = excluded.sunrise, jumua = excluded.jumua, jumua_2 = excluded.jumua_2, jumua_3 = excluded.jumua_3,
      iqama_offsets = excluded.iqama_offsets, source = 'copied';
    v_n := v_n + 1; v_d := v_d + 1;
  end loop;
  return v_n;
end $$;
grant execute on function public.fn_copy_mosque_prayer_times(bigint, date, date, date) to authenticated;

-- Effective times for a day = row + overrides merged (what every reader should call).
create or replace function public.fn_mosque_prayer_times_effective(p_mosque_id bigint, p_day date)
returns table (slot public.prayer_slot, scheduled time, effective time, iqama_offset int, is_override boolean)
language sql stable security invoker as $$
  with base as (
    select t.* from public.mosque_prayer_times t where t.mosque_id = p_mosque_id and t.day = p_day
  ), slots as (
    select 'fajr'::public.prayer_slot s, b.fajr t, (b.iqama_offsets->>'fajr')::int o from base b union all
    select 'dhuhr', b.dhuhr, (b.iqama_offsets->>'dhuhr')::int from base b union all
    select 'asr', b.asr, (b.iqama_offsets->>'asr')::int from base b union all
    select 'maghrib', b.maghrib, (b.iqama_offsets->>'maghrib')::int from base b union all
    select 'isha', b.isha, (b.iqama_offsets->>'isha')::int from base b
  )
  select s.s, s.t, coalesce(o.time, s.t), coalesce(s.o, 0), o.id is not null
    from slots s left join public.mosque_prayer_overrides o
      on o.mosque_id = p_mosque_id and o.day = p_day and o.slot = s.s;
$$;
```

Overrides older than today are deleted nightly (pg_cron `mosques-purge-overrides`, `delete … where day < current_date - 1`).

### 4.5 Followers, user mosques, views (P2)

```sql
create table if not exists public.mosque_followers (
  mosque_id  bigint not null references public.mosques(id) on delete cascade,
  user_id    uuid   not null references public.profiles(id) on delete cascade,
  notify     boolean not null default true,      -- per-mosque mute (devis A3)
  created_at timestamptz not null default now(),
  primary key (mosque_id, user_id)
);
create index if not exists mosque_followers_user_idx on public.mosque_followers(user_id);

-- "Add to my mosques": rank 1 = principal, rank 2 = secondary (specs A1: max 1 + 1).
create table if not exists public.user_mosques (
  user_id    uuid   not null references public.profiles(id) on delete cascade,
  mosque_id  bigint not null references public.mosques(id) on delete cascade,
  rank       smallint not null check (rank in (1, 2)),
  created_at timestamptz not null default now(),
  primary key (user_id, mosque_id),
  unique (user_id, rank)
);

-- Atomic reorder/save from the "Mosques" sheet (avoids the unique(rank) clash on swap).
create or replace function public.fn_set_user_mosques(p_principal bigint, p_secondary bigint default null)
returns void language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'unauthorized'; end if;
  if p_secondary is not null and p_secondary = p_principal then raise exception 'same_mosque'; end if;
  delete from public.user_mosques where user_id = v_uid;
  if p_principal is not null then insert into public.user_mosques(user_id, mosque_id, rank) values (v_uid, p_principal, 1); end if;
  if p_secondary is not null then insert into public.user_mosques(user_id, mosque_id, rank) values (v_uid, p_secondary, 2); end if;
end $$;
grant execute on function public.fn_set_user_mosques(bigint, bigint) to authenticated;

-- Profile views (stats). One row per (user, mosque, day) to avoid spam; anonymous users count too.
create table if not exists public.mosque_profile_views (
  mosque_id bigint not null references public.mosques(id) on delete cascade,
  user_id   uuid   not null references public.profiles(id) on delete cascade,
  day       date   not null default current_date,
  primary key (mosque_id, user_id, day)
);
create or replace function public.fn_track_mosque_view(p_mosque_id bigint) returns void
language plpgsql security definer set search_path = public as $$
begin
  insert into public.mosque_profile_views(mosque_id, user_id) values (p_mosque_id, auth.uid())
  on conflict do nothing;
  if found then update public.mosques set views_count = views_count + 1 where id = p_mosque_id; end if;
end $$;
grant execute on function public.fn_track_mosque_view(bigint) to authenticated;

-- Counter triggers (followers_count / members_count).
create or replace function public.fn_mosque_followers_count() returns trigger language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then update public.mosques set followers_count = followers_count + 1 where id = new.mosque_id;
  elsif tg_op = 'DELETE' then update public.mosques set followers_count = greatest(0, followers_count - 1) where id = old.mosque_id; end if;
  return null;
end $$;
drop trigger if exists trg_mosque_followers_count on public.mosque_followers;
create trigger trg_mosque_followers_count after insert or delete on public.mosque_followers for each row execute function public.fn_mosque_followers_count();
```

### 4.6 Imams (P2)

```sql
create table if not exists public.mosque_imams (
  id          bigserial primary key,
  mosque_id   bigint not null references public.mosques(id) on delete cascade,
  full_name   text not null,
  role        text,                 -- 'Principal Imam', 'Imam', 'Muezzin'…
  since_year  int,
  bio         text,
  photo_url   text,
  position    int not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists mosque_imams_mosque_idx on public.mosque_imams(mosque_id, position);
```

### 4.7 Posts (announcements, events, volunteering, highlights, janaza) (P2)

One polymorphic table; `type` drives which columns are used. Limits from the specs (2 active announcements, 3 active events) enforced by trigger.

```sql
create table if not exists public.mosque_posts (
  id               bigserial primary key,
  mosque_id        bigint not null references public.mosques(id) on delete cascade,
  type             public.mosque_post_type not null,
  status           public.mosque_post_status not null default 'published',
  title            text not null,
  body             text,
  cover_url        text,
  is_urgent        boolean not null default false,
  -- event / janaza / volunteering
  event_date       date,
  event_time       time,
  event_end_time   time,
  location         text,                       -- 'At the mosque' or free text
  after_prayer     public.prayer_slot,          -- janaza: "After Duhr prayer"
  language         text,                        -- event language chip
  volunteers_needed int,
  -- lifecycle
  published_at     timestamptz not null default now(),
  expires_at       timestamptz,                 -- announcements auto-archive; events: event_date + 1 day
  archived_at      timestamptz,
  -- counters
  views_count      int not null default 0,
  attendees_count  int not null default 0,
  applicants_count int not null default 0,
  duas_count       int not null default 0,
  notified_at      timestamptz,                 -- set by notify-mosque-followers
  created_by       uuid references public.profiles(id) on delete set null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index if not exists mosque_posts_feed_idx on public.mosque_posts(mosque_id, status, is_urgent desc, published_at desc);
create index if not exists mosque_posts_event_idx on public.mosque_posts(event_date) where type in ('event','janaza','volunteering');
drop trigger if exists trg_mosque_posts_updated_at on public.mosque_posts;
create trigger trg_mosque_posts_updated_at before update on public.mosque_posts for each row execute function public.set_updated_at();

-- Active limits (specs A4): announcements ≤ 2, events ≤ 3 (volunteering/highlight/janaza unlimited).
create or replace function public.fn_mosque_posts_limits() returns trigger language plpgsql as $$
declare v_limit int; v_count int;
begin
  if new.status <> 'published' then return new; end if;
  v_limit := case new.type when 'announcement' then 2 when 'event' then 3 else null end;
  if v_limit is null then return new; end if;
  select count(*) into v_count from public.mosque_posts
   where mosque_id = new.mosque_id and type = new.type and status = 'published' and id <> coalesce(new.id, 0);
  if v_count >= v_limit then raise exception 'post_limit_reached:%', new.type; end if;
  if new.type = 'event' and new.event_date is null then raise exception 'event_date_required'; end if;
  return new;
end $$;
drop trigger if exists trg_mosque_posts_limits on public.mosque_posts;
create trigger trg_mosque_posts_limits before insert or update of status on public.mosque_posts for each row execute function public.fn_mosque_posts_limits();

-- Interactions
create table if not exists public.mosque_post_attendees (   -- "I'll attend"
  post_id bigint not null references public.mosque_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(), primary key (post_id, user_id));
create table if not exists public.mosque_post_applicants (  -- "Apply" (volunteering)
  post_id bigint not null references public.mosque_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  message text, created_at timestamptz not null default now(), primary key (post_id, user_id));
create table if not exists public.mosque_post_duas (        -- "Say a dua" (janaza) — one per user per post
  post_id bigint not null references public.mosque_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(), primary key (post_id, user_id));
create table if not exists public.mosque_post_views (
  post_id bigint not null references public.mosque_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  primary key (post_id, user_id));

-- Generic counter trigger for the 4 interaction tables (attendees_count / applicants_count / duas_count / views_count).
create or replace function public.fn_mosque_post_counters() returns trigger language plpgsql security definer set search_path = public as $$
declare v_col text := tg_argv[0]; v_delta int := case tg_op when 'INSERT' then 1 else -1 end; v_post bigint := coalesce(new.post_id, old.post_id);
begin
  execute format('update public.mosque_posts set %I = greatest(0, %I + $1) where id = $2', v_col, v_col) using v_delta, v_post;
  -- "Say a dua" earns ajr once (source mosque_dua, source_id = post id)
  if tg_table_name = 'mosque_post_duas' and tg_op = 'INSERT' then
    insert into public.ajr_log (user_id, earned_ajr, source, source_id)
    select new.user_id, 5, 'mosque_dua', new.post_id
     where not exists (select 1 from public.ajr_log where user_id = new.user_id and source = 'mosque_dua' and source_id = new.post_id);
  end if;
  return null;
end $$;
create trigger trg_attendees_count after insert or delete on public.mosque_post_attendees for each row execute function public.fn_mosque_post_counters('attendees_count');
create trigger trg_applicants_count after insert or delete on public.mosque_post_applicants for each row execute function public.fn_mosque_post_counters('applicants_count');
create trigger trg_duas_count after insert or delete on public.mosque_post_duas for each row execute function public.fn_mosque_post_counters('duas_count');
create trigger trg_post_views_count after insert on public.mosque_post_views for each row execute function public.fn_mosque_post_counters('views_count');
```

> `ajr_log` has **no** unique constraint on `(user_id, source, source_id)` (see `20260515001000_ajr_streak.sql`) — hence the `where not exists` guard, same as `fn_apply_tx_to_projects`.

Auto-archive (pg_cron hourly `mosques-archive-posts`): `update mosque_posts set status='archived', archived_at=now() where status='published' and ((expires_at is not null and expires_at < now()) or (type in ('event','janaza') and event_date < current_date - 1))`.

### 4.8 Members (P2 table, P3 fee) 

```sql
create table if not exists public.mosque_members (
  id               bigserial primary key,
  mosque_id        bigint not null references public.mosques(id) on delete cascade,
  user_id          uuid   not null references public.profiles(id) on delete cascade,
  first_name       text not null,
  last_name        text not null,
  birth_date       date not null,
  profession       text,
  email            text not null,
  phone            text not null,
  volunteer        boolean not null default false,
  consent_at       timestamptz not null,                  -- RGPD checkbox timestamp
  status           text not null default 'active',        -- 'active' | 'left'
  fee_subscription_id bigint,                             -- P3: references donation_subscriptions(id) (added in P3 migration)
  since_year       int generated always as (extract(year from created_at)::int) stored,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (mosque_id, user_id)
);
create index if not exists mosque_members_mosque_idx on public.mosque_members(mosque_id, status);
-- members_count trigger: same shape as fn_mosque_followers_count on status='active'.
```

Personal data: readable only by the member and the mosque admins (RLS §4.10). CSV export = client-side from the admin list (devis B4), no server endpoint needed.

### 4.9 Search (P2)

```sql
create or replace function public.fn_search_mosques(
  p_query text default null, p_lat double precision default null, p_lng double precision default null,
  p_radius_km int default 50, p_limit int default 30
) returns table (
  id bigint, name text, slug text, logo_url text, cover_url text, address_line text, city text, postal_code text,
  lat double precision, lng double precision, distance_km double precision,
  followers_count int, members_count int,
  fajr time, dhuhr time, asr time, maghrib time, isha time, sunrise time, jumua time, has_times boolean
) language sql stable security invoker as $$
  with me as (select case when p_lat is null then null else extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography end g)
  select m.id, m.name, m.slug, m.logo_url, m.cover_images[1], m.address_line, m.city, m.postal_code,
         extensions.st_y(m.location::extensions.geometry), extensions.st_x(m.location::extensions.geometry),
         case when me.g is null or m.location is null then null else extensions.st_distance(m.location, me.g) / 1000.0 end,
         m.followers_count, m.members_count,
         t.fajr, t.dhuhr, t.asr, t.maghrib, t.isha, t.sunrise, t.jumua, t.id is not null
    from public.mosques m cross join me
    left join public.mosque_prayer_times t on t.mosque_id = m.id and t.day = (now() at time zone m.timezone)::date
   where m.status = 'approved'
     and (p_query is null or p_query = '' or m.name ilike '%' || p_query || '%' or m.city ilike '%' || p_query || '%'
          or m.address_line ilike '%' || p_query || '%' or m.postal_code ilike p_query || '%')
     and (me.g is null or m.location is null or extensions.st_dwithin(m.location, me.g, p_radius_km * 1000))
   order by (case when me.g is null or m.location is null then 1 else 0 end),
            extensions.st_distance(m.location, me.g) nulls last, m.followers_count desc
   limit greatest(1, least(p_limit, 100));
$$;
grant execute on function public.fn_search_mosques(text, double precision, double precision, int, int) to authenticated;
```

The client falls back to `adhan_dart` computed times when `has_times = false` (§9).

### 4.10 Row Level Security (P0–P2)

Principles: public read of **approved** mosques and their public content; a mosque admin reads/writes **only his approved mosque**; the owner can read (not write) his own `pending_review` mosque; Nour admins (`is_admin()`) can do everything; personal tables (`mosque_members`, followers) are owner-scoped.

```sql
alter table public.mosques enable row level security;
create policy mosques_public_read on public.mosques for select to authenticated
  using (status = 'approved' or public.is_mosque_member_admin(id) or public.is_admin());
create policy mosques_admin_update on public.mosques for update to authenticated
  using (public.is_mosque_admin(id) or public.is_admin())
  with check (public.is_mosque_admin(id) or public.is_admin());
-- No client INSERT (fn_register_mosque only). No client DELETE.

-- Protect moderation/legal columns from mosque admins (column-level): a trigger, because RLS is row-level.
create or replace function public.fn_mosques_guard_columns() returns trigger language plpgsql as $$
begin
  if not public.is_admin() and current_setting('nour.trusted', true) is distinct from 'on' then
    if new.status is distinct from old.status or new.review_note is distinct from old.review_note
       or new.siren is distinct from old.siren or new.rna is distinct from old.rna or new.legal_status is distinct from old.legal_status
       or new.donations_enabled is distinct from old.donations_enabled
       or new.followers_count is distinct from old.followers_count or new.members_count is distinct from old.members_count
       or new.views_count is distinct from old.views_count then
      raise exception 'column protected';
    end if;
  end if;
  return new;
end $$;
create trigger trg_mosques_guard_columns before update on public.mosques for each row execute function public.fn_mosques_guard_columns();

alter table public.mosque_admins enable row level security;
create policy mosque_admins_read on public.mosque_admins for select to authenticated using (user_id = auth.uid() or public.is_mosque_admin(mosque_id) or public.is_admin());
create policy mosque_admins_owner_write on public.mosque_admins for all to authenticated
  using (public.is_admin() or exists (select 1 from public.mosque_admins o where o.mosque_id = mosque_admins.mosque_id and o.user_id = auth.uid() and o.role = 'owner'))
  with check (public.is_admin() or exists (select 1 from public.mosque_admins o where o.mosque_id = mosque_admins.mosque_id and o.user_id = auth.uid() and o.role = 'owner'));

-- Content tables: public read when mosque approved; admin write.
do $$ declare t text; begin
  foreach t in array array['mosque_prayer_times','mosque_prayer_overrides','mosque_imams','mosque_posts'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists %I_read on public.%I', t, t);
    execute format('create policy %I_read on public.%I for select to authenticated using (exists (select 1 from public.mosques m where m.id = %I.mosque_id and (m.status = ''approved'' or public.is_mosque_member_admin(m.id) or public.is_admin())))', t, t, t);
    execute format('drop policy if exists %I_admin_write on public.%I', t, t);
    execute format('create policy %I_admin_write on public.%I for all to authenticated using (public.is_mosque_admin(mosque_id) or public.is_admin()) with check (public.is_mosque_admin(mosque_id) or public.is_admin())', t, t);
  end loop; end $$;
-- mosque_posts: only published rows are visible to non-admins
drop policy if exists mosque_posts_read on public.mosque_posts;
create policy mosque_posts_read on public.mosque_posts for select to authenticated
  using ((status = 'published' and exists (select 1 from public.mosques m where m.id = mosque_id and m.status = 'approved'))
         or public.is_mosque_admin(mosque_id) or public.is_admin());

-- Per-user tables
alter table public.mosque_followers enable row level security;
create policy mosque_followers_self on public.mosque_followers for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy mosque_followers_admin_read on public.mosque_followers for select to authenticated using (public.is_mosque_admin(mosque_id) or public.is_admin());
alter table public.user_mosques enable row level security;
create policy user_mosques_self on public.user_mosques for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
alter table public.mosque_profile_views enable row level security;   -- no policies: only fn_track_mosque_view (definer) + admins via stats RPC
alter table public.mosque_post_views enable row level security;
create policy mosque_post_views_self on public.mosque_post_views for insert to authenticated with check (user_id = auth.uid());
do $$ declare t text; begin
  foreach t in array array['mosque_post_attendees','mosque_post_applicants','mosque_post_duas'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I_self on public.%I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())', t, t);
    execute format('create policy %I_admin_read on public.%I for select to authenticated using (exists (select 1 from public.mosque_posts p where p.id = %I.post_id and public.is_mosque_admin(p.mosque_id)))', t, t, t);
  end loop; end $$;
alter table public.mosque_members enable row level security;
create policy mosque_members_self on public.mosque_members for select to authenticated using (user_id = auth.uid());
create policy mosque_members_self_insert on public.mosque_members for insert to authenticated with check (user_id = auth.uid() and exists (select 1 from public.mosques m where m.id = mosque_id and m.status = 'approved'));
create policy mosque_members_self_update on public.mosque_members for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy mosque_members_admin on public.mosque_members for select to authenticated using (public.is_mosque_admin(mosque_id) or public.is_admin());
create policy mosque_members_admin_update on public.mosque_members for update to authenticated using (public.is_mosque_admin(mosque_id)) with check (public.is_mosque_admin(mosque_id));
```

Community list (admin) needs profile names/avatars of followers/members → the existing `profiles_read` policy (`id = auth.uid() or is_admin()`) blocks it. **Do not loosen `profiles` RLS.** Expose a definer RPC `fn_mosque_community(p_mosque_id, p_filter, p_query, p_limit, p_offset)` returning `(user_id, name, avatar_url, kind text /*follower|member|volunteer*/, since date, email, phone)` guarded by `is_mosque_admin`; email/phone come from `mosque_members` only (followers expose name + avatar only).

### 4.11 Stats RPC (P2)

```sql
create or replace function public.fn_mosque_dashboard_stats(p_mosque_id bigint)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare r jsonb;
begin
  if not public.is_mosque_admin(p_mosque_id) then raise exception 'forbidden'; end if;
  select jsonb_build_object(
    'followers_total', m.followers_count,
    'followers_7d', (select count(*) from public.mosque_followers f where f.mosque_id = m.id and f.created_at > now() - interval '7 days'),
    'members_total', m.members_count,
    'members_7d', (select count(*) from public.mosque_members x where x.mosque_id = m.id and x.created_at > now() - interval '7 days'),
    'views_30d', (select count(*) from public.mosque_profile_views v where v.mosque_id = m.id and v.day > current_date - 30),
    'growth_series', (select coalesce(jsonb_agg(jsonb_build_object('day', d, 'followers', c) order by d), '[]')
                        from (select f.created_at::date d, count(*) c from public.mosque_followers f where f.mosque_id = m.id and f.created_at > now() - interval '30 days' group by 1) s),
    'notif_open_rate', (select case when count(*) = 0 then null else round(100.0 * count(*) filter (where opened_at is not null) / count(*), 1) end
                          from public.notifications_log l where l.mosque_id = m.id and l.sent_at > now() - interval '30 days'),
    'pending_events', (select count(*) from public.mosque_posts p where p.mosque_id = m.id and p.type = 'event' and p.status = 'published' and p.event_date >= current_date),
    'campaigns_ending_soon', (select count(*) from public.mosque_campaigns c where c.mosque_id = m.id and c.status = 'active' and c.ends_at < now() + interval '7 days')
  ) into r from public.mosques m where m.id = p_mosque_id;
  return r;
end $$;
grant execute on function public.fn_mosque_dashboard_stats(bigint) to authenticated;
```

(`mosque_campaigns` exists from P3; in P2 return `0` or create the table early — simplest: create all P3 tables in P2's migration but leave them unused.)

### 4.12 Storage (P2 / P3)

```sql
insert into storage.buckets (id, name, public) values ('mosque-media', 'mosque-media', true) on conflict (id) do nothing;      -- logos, covers, post covers, imam photos
insert into storage.buckets (id, name, public) values ('mosque-receipts', 'mosque-receipts', false) on conflict (id) do nothing; -- PDF receipts (P3)
-- Path convention: mosque-media/<mosque_id>/<logo|cover|posts|imams>/<uuid>.<ext>
create policy "mosque-media: public read" on storage.objects for select using (bucket_id = 'mosque-media');
create policy "mosque-media: admin write" on storage.objects for insert with check (
  bucket_id = 'mosque-media' and public.is_mosque_admin(((storage.foldername(name))[1])::bigint));
create policy "mosque-media: admin update" on storage.objects for update using (
  bucket_id = 'mosque-media' and public.is_mosque_admin(((storage.foldername(name))[1])::bigint));
create policy "mosque-media: admin delete" on storage.objects for delete using (
  bucket_id = 'mosque-media' and public.is_mosque_admin(((storage.foldername(name))[1])::bigint));
-- mosque-receipts: no client policies; served via signed URLs created by the edge function (donor) or admins.
```

Client uploads through `supabaseClient.storage.from('mosque-media').upload(...)` after `image_picker` + downscale (max 1600 px, JPEG 80) — same helper as `avatar_action_sheet.dart`.

### 4.13 Realtime

```sql
do $$ begin alter publication supabase_realtime add table public.mosques; exception when duplicate_object then null; end $$;             -- review status flip
do $$ begin alter publication supabase_realtime add table public.mosque_prayer_overrides; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.mosque_campaigns; exception when duplicate_object then null; end $$;    -- P3 progress bar
```

### 4.14 Remote config (P0)

Tiny key/value table for feature flags read at startup (also useful later for Premium):

```sql
create table if not exists public.app_config (key text primary key, value jsonb not null, updated_at timestamptz not null default now());
alter table public.app_config enable row level security;
create policy app_config_read on public.app_config for select to authenticated using (true);
create policy app_config_admin on public.app_config for all to authenticated using (public.is_admin()) with check (public.is_admin());
insert into public.app_config(key, value) values
  ('mosques_enabled', 'true'), ('mosque_donations_enabled', 'false'), ('mosque_membership_fee_enabled', 'false')
on conflict (key) do nothing;
```

Client: `appConfigProvider` (loaded in `authorization()` after profile init, cached in memory, defaults `false` on error). When `mosques_enabled=false` all mosque entry points are hidden (kill-switch for the store rollout).

---

## 5. Edge Functions

Folder `backend/supabase/functions/<name>/index.ts`. Reuse `_shared/supabase.ts` (`serviceClient`, `userClient`), `_shared/cors.ts`, `_shared/errors.ts` (`errorResponse`, `jsonResponse`), `_shared/stripe.ts`. Register every function in `config.toml` (`[functions.<name>] verify_jwt = …`). Extend `ErrorKey` in `_shared/errors.ts` with the keys used below and mirror them in `nour_app/.../api_error_key.dart` + arb files.

| Function | JWT | Phase | Purpose |
|---|---|---|---|
| `send-push` | internal (service key header `x-internal-key`) | P1 | Generic FCM sender: `{ userIds?|tokens?|segment?, kind, title, body, data, collapseKey? }` → resolves tokens, respects `profiles.push_prefs`, sends via FCM HTTP v1, writes `notifications_log`, deletes invalid tokens. Called by other functions/DB (pg_net) — never by the app. |
| `notify-mosque-followers` | true | P2 | Admin-triggered broadcast for a post/campaign/free message. Checks `is_mosque_admin`, enforces **quota 2 / rolling 7 days** per mosque (server-side, `mosque_notification_quota`), builds the deep link, calls `send-push` with `segment = {mosqueId}`. Marks `mosque_posts.notified_at`. |
| `review-mosque` | true (Nour admin) | P2 | `{ mosqueId, action: 'approve'|'reject'|'suspend', note? }` → updates `status`, `reviewed_*`, sends push `mosque_status` + email to the owner (Supabase `auth.admin` email or Resend if configured). Kept as a function (not RPC) so the email side-effect lives in one place. |
| `mosque-stripe-onboarding` | true | P3 | Creates (or reuses) a Stripe **Connect Express** account for the mosque (`country = mosques.country_code`, `business_type = 'non_profit'`), stores `mosque_stripe_accounts`, returns an `accountLinks.create` URL (`type: 'account_onboarding'`, `refresh_url`/`return_url` = `nour://mosque-admin/stripe/{refresh|return}`). Also `{ action: 'status' }` → refreshes `charges_enabled/payouts_enabled/requirements` from Stripe. |
| `create-mosque-payment-intent` | true | P3 | One-time Sadaqa / campaign contribution / one-time membership fee. **Direct charge on the connected account** (`stripe.paymentIntents.create({...}, { stripeAccount })`). Validates target (mosque approved + donations_enabled + account active; campaign active & not ended), amount bounds, inserts `transactions` row (`type`, `mosque_id`, `mosque_campaign_id`, `stripe_account_id`), returns `{ clientSecret, transactionId, stripeAccountId, fee, amountCharged }`. `application_fee_amount` param reserved for V3 (0 today). |
| `create-mosque-subscription` | true | P3 | Monthly/yearly Sadaqa or yearly membership fee. Customer is created **on the connected account** (Connect requires per-account customers for direct charges), Product/Price inline, `default_incomplete`; inserts `donation_subscriptions` (`mosque_id`, `mosque_campaign_id` null, `membership_id`). Returns same shape as existing `create-subscription` + `stripeAccountId`. |
| `cancel-mosque-subscription` | true | P3 | Mirrors `cancel-subscription` with `{ stripeAccount }`. |
| `stripe-connect-webhook` | false | P3 | Separate endpoint registered as a **Connect webhook** in Stripe (events carry `event.account`). Signature secret `STRIPE_CONNECT_WEBHOOK_SECRET`. Handles `account.updated` (→ `mosque_stripe_accounts` status, `mosques.donations_enabled`), and the same payment/invoice/subscription events as `stripe-webhook` but routed to mosque rows. Hard idempotency via the existing `stripe_events` table. |
| `generate-mosque-receipt` | true | P3 | `{ transactionId }` (donor) or `{ mosqueId, year, userId }` (annual recap) → PDF (pdf-lib) to `mosque-receipts/<mosque_id>/<user_id>/<file>.pdf`, row in `mosque_receipts`, returns a signed URL (1 h). Email delivery optional (Resend). Refuses when `mosques.can_issue_tax_receipts = false`. |

### 5.1 `send-push` (P1) — contract

```ts
interface SendPushPayload {
  kind: PushKind;                          // enum public.push_kind
  title: string; body: string;
  data?: Record<string, string>;           // must include `link` (deep link, §6.4)
  userIds?: string[];                      // OR
  segment?: { mosqueId: number };          // all followers with notify = true
  collapseKey?: string;
  mosqueId?: number; postId?: number; campaignId?: number;   // for notifications_log attribution
}
```

Algorithm: resolve recipients → filter by `profiles.push_prefs[kind] !== false` → load `device_tokens` (not revoked) → chunk by 500 → FCM v1 `messages:send` per token (batch endpoint is deprecated; use `Promise.allSettled` with concurrency 20) using a **service-account JWT** (`FCM_SERVICE_ACCOUNT_JSON` secret, sign with WebCrypto RS256, cache the OAuth token 50 min) → on `UNREGISTERED` / `INVALID_ARGUMENT` delete the token → insert one `notifications_log` row per recipient (`status sent|failed`). Returns `{ sent, failed, invalidated }`.

Android payload: `android.notification.channel_id = 'nour_mosques'` (create the channel in the app, §6.1); iOS: `apns.payload.aps = { sound: 'default', 'mutable-content': 1 }`, `apns.headers['apns-priority'] = '10'`.

### 5.2 `notify-mosque-followers` quota

```sql
create table if not exists public.mosque_notification_quota (   -- one row per broadcast
  id bigserial primary key, mosque_id bigint not null references public.mosques(id) on delete cascade,
  post_id bigint references public.mosque_posts(id) on delete set null,
  campaign_id bigint,                                           -- P3 fk added later
  sent_at timestamptz not null default now(), recipients int not null default 0);
create index if not exists mnq_idx on public.mosque_notification_quota(mosque_id, sent_at desc);
```
`limit = 2` broadcasts per rolling 7 days (`app_config.mosque_broadcasts_per_week`, default 2). Function returns `quota_exceeded` (HTTP 429) with `nextAllowedAt`; the client shows it on the *Notify followers* toggle before posting (pre-check via RPC `fn_mosque_broadcast_quota(p_mosque_id) → {used, limit, next_allowed_at}`).

Urgent posts (`is_urgent = true`) **do not bypass** the quota (product decision — otherwise the limit is meaningless). Approval notification (`mosque_status`) and campaign-ending reminders are system pushes, outside the quota.

### 5.3 Stripe Connect specifics (P3)

- Secrets: existing `STRIPE_SECRET_KEY` (platform), new `STRIPE_CONNECT_WEBHOOK_SECRET`, `STRIPE_CONNECT_CLIENT_ID` (not needed for Express created via API, keep for OAuth fallback).
- All Stripe calls for a mosque pass `{ stripeAccount: acct.stripe_account_id }` as the request option.
- Client side: `flutter_stripe` must be initialised with `Stripe.stripeAccountId = <acct>` **before** `initPaymentSheet` for direct charges (the PaymentIntent lives on the connected account). Wrap this in `StripePaymentService.presentForAccount(...)` and **reset `stripeAccountId = null` in `finally`** so the existing Nour Impact flow is untouched.
- Fees: Stripe fees are deducted on the connected account (mosque pays them, devis §7). The "cover fees" toggle is **not** shown for mosques (they are the merchant); keep `fee_covered = 0`.
- Receipts: pass `receipt_email` and `description = 'Don ' + mosque.name`; `statement_descriptor_suffix` is set from `mosques.name` (max 22 chars, sanitised).
- Refunds/disputes: handled by the mosque in its Stripe Express dashboard; the Connect webhook keeps our ledger in sync (`charge.refunded`).

---

## 6. Push infrastructure (P1 — devis Poste 1)

Today: `flutter_local_notifications` only (`core/notifications/notifications_services.dart`, ids partitioned per feature). **Keep it untouched** — local prayer/adhkar/ayah reminders stay local. FCM is added beside it.

### 6.1 Flutter setup
- `pubspec.yaml`: `firebase_messaging: ^16.x` (compatible with `firebase_core ^4.10`). Firebase project already exists (analytics/crashlytics) → add APNs key in Firebase console, enable Push Notifications + Background Modes (remote notifications) capabilities in Xcode, `FirebaseAppDelegateProxyEnabled` stays default. Android: `POST_NOTIFICATIONS` permission is already requested through `permission_handler`; create channel `nour_mosques` ("Mosque updates") next to the existing channels in `NotificationsServices.initialize()`.
- New `core/notifications/push_notifications_services.dart` (`pushNotificationsServicesProvider`):
  - `initialize()` — `FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true)`, `onMessage` → show via `flutter_local_notifications` (id range **5000..5999**, add `NotificationIds.pushBase/pushEnd`), `onMessageOpenedApp` + `getInitialMessage()` → `DeepLinksServices.open(data['link'])`, `onTokenRefresh` → `registerToken`.
  - `registerToken()` — called after `authorization()` succeeds and on every token refresh: upsert `device_tokens` (`token`, `platform`, `app_version`, `locale`). Anonymous users are registered too (they can follow mosques).
  - `revokeToken()` — on logout/delete account: delete row, `FirebaseMessaging.instance.deleteToken()`.
  - The **background handler** (`@pragma('vm:entry-point') Future<void> _onBackground(RemoteMessage m)`) only logs; the OS displays the notification (payload has `notification` block).

### 6.2 Tables

```sql
create table if not exists public.device_tokens (
  id          bigserial primary key,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  token       text not null unique,
  platform    text not null check (platform in ('ios','android')),
  app_version text, locale text, timezone text,
  last_seen_at timestamptz not null default now(),
  created_at  timestamptz not null default now()
);
create index if not exists device_tokens_user_idx on public.device_tokens(user_id);
alter table public.device_tokens enable row level security;
create policy device_tokens_self on public.device_tokens for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create table if not exists public.notifications_log (
  id          bigserial primary key,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  kind        public.push_kind not null,
  title       text not null, body text,
  data        jsonb not null default '{}',
  mosque_id   bigint references public.mosques(id) on delete set null,
  post_id     bigint, campaign_id bigint,
  status      text not null default 'sent',          -- sent | failed
  error       text,
  sent_at     timestamptz not null default now(),
  opened_at   timestamptz                            -- set by fn_mark_notification_opened (client, on tap)
);
create index if not exists notifications_log_user_idx on public.notifications_log(user_id, sent_at desc);
create index if not exists notifications_log_mosque_idx on public.notifications_log(mosque_id, sent_at desc);
alter table public.notifications_log enable row level security;
create policy notifications_log_self_read on public.notifications_log for select to authenticated using (user_id = auth.uid());
create or replace function public.fn_mark_notification_opened(p_id bigint) returns void language sql security definer set search_path = public as $$
  update public.notifications_log set opened_at = coalesce(opened_at, now()) where id = p_id and user_id = auth.uid();
$$;
grant execute on function public.fn_mark_notification_opened(bigint) to authenticated;
```

Every push `data` payload carries `logId` so the app can call `fn_mark_notification_opened` on tap → this feeds the mosque "notification open rate" (devis §7: an estimate, iOS doesn't report delivery).

### 6.3 Preferences
`profiles.push_prefs jsonb` — `{"mosque_post": true, "mosque_event": true, "mosque_campaign": true, "mosque_broadcast": true, "dua_ameen": true, "family_milestone": true}`; missing key = enabled. Settings UI: new section in `SettingsPage` ("Push notifications") listing the kinds relevant to the account type, using `UIToggle`; writes via `profileRepo.updatePushPrefs(Map)` (plain `update profiles set push_prefs = …` — allowed by existing self-update policy).

### 6.4 Deep links
`DeepLinksServices` (`core/routing/deep_links_services.dart`) is a stub today. Implement `open(String link)`:

| link | route |
|---|---|
| `nour://mosque/{id}` | `MosqueProfileRoute(id, tab: prayers)` |
| `nour://mosque/{id}/news` / `…/post/{postId}` | `MosqueProfileRoute(id, tab: news, postId)` (scroll to post) |
| `nour://mosque/{id}/campaign/{campaignId}` | `MosqueCampaignRoute(id, campaignId)` |
| `nour://mosque-admin` | `MosqueAdminShellRoute()` (used by `mosque_status` push) |
| `nour://mosque-admin/stripe/return` | `MosqueStripeStatusRoute()` |

Also register the `nour` URL scheme (iOS `CFBundleURLTypes`, Android `<intent-filter>`) and Universal/App Links for `https://nour.app/m/{slug}` later (share links use the https form with a fallback web page — out of scope now, use `nour://` for share until the domain exists).

---

## 7. Flutter — user POV (P2 / P3)

### 7.1 Feature layout

```
lib/src/features/mosques/
  data/
    models/           mosque_model.dart, mosque_search_item_model.dart, mosque_prayer_day_model.dart,
                      mosque_post_model.dart, mosque_imam_model.dart, mosque_member_model.dart,
                      mosque_campaign_model.dart (P3), mosque_donation_settings_model.dart (P3), mosque_enums.dart
    datasources/      mosque_remote_datasource.dart (reads), mosque_user_remote_datasource.dart (follow/user_mosques/interactions)
    mosque_repo.dart  (Failure.exceptionsCatcher wrappers, as impact_repo.dart)
  ui/
    pages/            mosque_search_page.dart, mosque_profile_page.dart, mosque_become_member_page.dart,
                      mosque_campaign_page.dart (P3), mosque_donation_checkout_page.dart (P3)
    state_management/ mosque_search_provider.dart/state, mosque_profile_provider.dart/state (family by id),
                      my_mosques_provider.dart/state (principal/secondary + effective prayer times), mosque_donation_provider (P3)
    widgets/          mosque_header.dart, mosque_action_tiles.dart, mosque_prayer_rows.dart, mosque_post_card.dart (+ per type),
                      mosque_campaign_card.dart, my_mosques_sheet.dart, say_dua_sheet.dart, mosque_card_home.dart
lib/src/features/mosque_admin/      (§8)
lib/src/features/mosque_onboarding/ (§3)
```

State pattern = existing `Presenter<State>` (`StateNotifier`) with hand-written `Equatable` states, `useEffect(... presenter.init())` in `HookConsumerWidget`, errors via `appEvents.send(ShowErrorEvent(error))`. **No new state library.**

### 7.2 Routes

```dart
// route_paths.dart
static const mosqueSearch = 'mosques/search';
static String mosqueProfile({int? id}) => 'mosque/${id ?? ':id'}';           // ?tab=prayers|information|news|donation&postId=
static String mosqueMember({int? id}) => 'mosque/${id ?? ':id'}/member';
static String mosqueCampaign({int? id, int? campaignId}) => 'mosque/${id ?? ':id'}/campaign/${campaignId ?? ':campaignId'}';
static String mosqueCheckout({int? id}) => 'mosque/${id ?? ':id'}/checkout';  // ?amount=&frequency=&campaignId=&membershipId=
static const myMosques = 'my-mosques';                                        // bottom sheet, no route (kept for deep link)
```
Registered under `HomeRouterRoute` children (full-screen over the navbar, like `ImpactProjectDetailRoute`).

### 7.3 Models (Dart, `fromJson` tolerant to missing keys)

```dart
enum MosqueStatus { pendingReview, approved, rejected, suspended }
enum MosqueService { parking, disabledAccess, ablutionRoom, womenSpace, adultClasses, childrenClasses, quranClasses, arabicClasses, eidPrayer, janaza, iftarRamadan, library, newMuslimsSupport }   // + icon asset + l10n label
enum MosquePostType { announcement, event, volunteering, highlight, janaza }

class MosqueModel extends Equatable {
  final int id; final String name; final String? slug, logoUrl, description, addressLine, city, postalCode, phone, email, website;
  final List<String> coverImages; final Map<String, String> socials; final double? lat, lng; final String timezone;
  final int? capacityTotal, capacityMen, capacityWomen, foundedYear;
  final List<MosqueService> services; final List<String> khutbahLanguages;
  final MosqueStatus status; final bool donationsEnabled, canIssueTaxReceipts;
  final int followersCount, membersCount; final String? openingStatus;
  final List<MosqueImamModel> imams;                      // embedded select mosque_imams(*)
  // client-side helpers
  String get fullAddress; bool get isOpenNow(MosquePrayerDayModel? today);
}

class MosquePrayerDayModel {                              // from fn_mosque_prayer_times_effective + row
  final DateTime day; final Map<PrayerSlot, TimeOfDay> scheduled, effective; final Map<PrayerSlot, int> iqamaOffsets;
  final Set<PrayerSlot> overridden; final TimeOfDay? sunrise, jumua, jumua2, jumua3; final bool fromMosque; // false = computed fallback
  DailyPrayerTimes toDailyPrayerTimes(DateTime day, String tz);   // adapter to the existing IslamicTools type (§9)
}
```

`PrayerSlot` already exists in `core/utils/islamic_tools/islamic_tools.dart` — reuse it, map to/from the DB enum strings.

### 7.4 Screens & logic

**Mosque search** (`MosqueSearchPage`, Figma 2.3) — map (see note) + draggable sheet.
- `MosqueSearchPresenter.init()` → `GeolocatorTools.currentOrCachedPosition()` (non-blocking: if it throws → `hasLocation=false`, list ordered by name) → `repo.search(query: null, lat, lng)`.
- Search field debounced 350 ms → `repo.search(query, lat, lng, radiusKm: hasLocation ? 50 : null)`.
- Card: logo (`UIAvatar` initials fallback), name, address · `${distance.toStringAsFixed(2)}km`, times row (from `has_times ? row : IslamicTools.getPrayerTimesForDate(position: mosque latlng, method: settings.method)`), Chourouk/Jumu'a pill, *Add to my mosques* (→ `MyMosquesSheet` prefilled with this mosque as principal if none, else as secondary; if both slots full → sheet lets the user replace), map-pin button → `url_launcher` `geo:`/Apple Maps.
- Tap card → `MosqueProfileRoute(id)`.
- **Map:** `google_maps_flutter` requires API keys and adds ~1 day (iOS/Android setup). Decision: ship P2 with `flutter_map` (OpenStreetMap tiles, no key, ^7.x) + `flutter_map_marker_cluster` optional; markers = search results; tapping a marker scrolls the sheet to the card. Keep the widget isolated (`MosqueMapWidget`) so the tile provider can be swapped.

**My mosques sheet** (`MyMosquesSheet`, Figma 1245:10598) — `ReorderableListView` with two slots; *Save* → `fn_set_user_mosques(principal, secondary)` → `myMosquesProvider.reload()` → `prayerTimesProvider.refresh()` (§9). Entry points: chip on `PrayerTimesPage`, *Add to my mosques* CTAs, Home card.

**Mosque profile** (`MosqueProfilePage`, Figma 2.4) — `MosqueProfilePresenter(id)`:
- `init()`: `repo.getMosque(id)` (embedded imams), `repo.getPrayerDay(id, todayInMosqueTz)`, `repo.getPosts(id)` (published, urgent first, page 20), `repo.getFollowState(id)`, `repo.getMembership(id)`, `repo.getCampaigns(id)` (P3), then `fn_track_mosque_view(id)` fire-and-forget.
- Header: cover `PageView` + dots (reuse `project_cover_carousel.dart`), back, share (`share_plus` with `nour://mosque/{id}` + name), logo, name, address row with copy icon (`Clipboard.setData` + snackbar), status pill (`isOpenNow`: open from Fajr-30 min until Isha+45 min unless `opening_status` manual), counters, *Follow/Following* (optimistic toggle → `mosque_followers` insert/delete; anonymous users allowed), *Become a member* (→ `MosqueMemberRoute`; label *Member* disabled state when already member), tiles Itinerary (`maps`), Call (`tel:`), Email (`mailto:`).
- Tabs `UITabs<MosqueTab>` with a dot on *News* when there is a post newer than `last_seen_news_at` (stored in `SharedPreferences` per mosque). *Donation* tab hidden when `!mosque.donationsEnabled || !appConfig.mosqueDonationsEnabled`.
- **Prayers tab**: "Today's prayer times" + hijri (`HijriTool`) + gregorian date; 5 rows with `+offset`; next slot highlighted with the slot illustration and countdown (reuse `PrayerTimeWidget` with `notify` hidden); Chourouk / Jumu'a; if `!fromMosque` show a small caption "Times computed — the mosque hasn't published today's schedule yet"; sticky CTA *Add to my mosques* (hidden when already principal/secondary → replaced by "Your principal/secondary mosque").
- **Information tab**: capacity block, founded block (age = now.year − founded), services (only the ones in `services`, icons from `Assets.images.services*` — add 13 icon assets), khutbah languages (flag emoji from ISO code), imams list.
- **News tab**: `ListView` of `MosquePostCard` variants (Figma 1076:4743). Interactions: *I'll attend* (toggle `mosque_post_attendees`), *Apply* (insert `mosque_post_applicants`, then disabled "Applied"), *Say a dua* (open `SayDuaSheet` with the janaza dua `اللَّهُمَّ اغْفِرْ لَهُ…` + audio if available, *I'm done* → insert `mosque_post_duas` → ajr toast via existing reward flow), *Share* (`share_plus`), event *Add to calendar* → generate `.ics` (`text/calendar`, `BEGIN:VCALENDAR … DTSTART;TZID=…`) to temp file and `Share.shareXFiles` (specs A2 — no calendar permissions). Post view tracking: insert `mosque_post_views` when a card is ≥50 % visible for 1 s (`VisibilityDetector` or manual scroll listener), throttled per session.
- **Donation tab** (P3): `MosqueSadaqaCard` driven by `mosque_donation_settings` (frequencies, suggested amounts, tax badge) → *Give to the mosque* → `MosqueCheckoutRoute`; campaigns list → `MosqueCampaignCard` (progress, days left, donors) → *Contribute* / *Share*.

**Become a member** (`MosqueBecomeMemberPage`, Figma 1105:5936) — form with `UIInputField`s, DOB picker, Yes/No segmented, consent checkbox (required), (P3) optional "Annual membership fee" selector 60/120/240/custom with "Free membership" default. Submit: insert `mosque_members` (prefill from profile: name/email); if a fee was chosen → `MosqueCheckoutRoute(membershipId)` (yearly subscription) after the row exists. Success sheet "Welcome to the community".

**Home card** (`MosqueCardHome`, Figma 1105:7925) — on `DashboardPage` after `NextPrayerWidget`: reads `myMosquesProvider`; empty → *Find a mosque* → `MosqueSearchRoute`; filled → principal mosque name + next prayer at the mosque + latest post title → tap → profile. Hidden when `appConfig.mosquesEnabled == false`.

**Profile page** — add row *My mosques* (→ sheet) and, for followers, nothing else. *My donations* page (existing `MyDonationsPage`) must list mosque transactions/subscriptions too (P3): extend the query to `or(impact_project_id.not.is.null, mosque_id.not.is.null)` and render the mosque name.

---

## 8. Flutter — mosque admin POV (P2 / P3)

`lib/src/features/mosque_admin/` — its own **shell route** with a nested `AutoTabsRouter` (4 tabs) and a custom bottom bar `MosqueAdminNavbar` (Figma: Dashboard · Community · Mosque · Post(+) — the "+" is a raised gold button). `UINavbar` is worshipper-specific; build a sibling widget with the same tokens.

```dart
// app_router.dart
AutoRoute(path: RoutePaths.mosqueAdmin, page: MosqueAdminShellRoute.page, guards: [mosqueAdminGuard], children: [
  AutoRoute(path: 'dashboard', page: MosqueAdminDashboardRoute.page, initial: true),
  AutoRoute(path: 'community', page: MosqueAdminCommunityRoute.page),
  AutoRoute(path: 'mosque', page: MosqueAdminMosqueRoute.page),            // editor with the 4 public tabs
  AutoRoute(path: 'post', page: MosqueAdminCreatePostRoute.page),
  AutoRoute(path: 'post/event', page: MosqueAdminPostEventRoute.page),     // also volunteering/highlight/janaza variants via param
  AutoRoute(path: 'sadaqa-settings', page: MosqueAdminSadaqaSettingsRoute.page),        // P3
  AutoRoute(path: 'campaigns', page: MosqueAdminCampaignsRoute.page),                   // P3
  AutoRoute(path: 'campaigns/:campaignId', page: MosqueAdminCampaignEditRoute.page),    // P3
  AutoRoute(path: 'donors', page: MosqueAdminDonorsRoute.page),                          // P3
  AutoRoute(path: 'receipts', page: MosqueAdminReceiptsRoute.page),                      // P3
  AutoRoute(path: 'stripe', page: MosqueStripeStatusRoute.page),                         // P3
  AutoRoute(path: 'profile', page: ProfileRoute.page),                                   // existing page, reused
  AutoRoute(path: 'settings', page: SettingsRoute.page),
]),
```

`myMosqueProvider` (app-lifetime, `MyMosqueState { mosque, role, stats, isLoading }`) loaded once after login for mosque accounts via `fn_my_mosque()` (definer RPC returning the admin's mosque regardless of status).

### 8.1 Dashboard (Figma 1109:8176)
`fn_mosque_dashboard_stats` + `mosque_posts` (last 5) + (P3) `fn_mosque_donation_stats`. Attention banner = `pending_events + campaigns_ending_soon` (tap → relevant tab). Growth chart = simple `CustomPainter` line (no chart lib). Bell → `NotificationsLogPage` (own notifications, e.g. approval).

### 8.2 Community (Figma 1117:10010)
`fn_mosque_community` paginated (30), chips All / Followers / Members / Volunteers, search (name/email/phone → server `ilike`), row ⋮ menu: *View details* (member form data), *Remove member* (`status='left'`), *Export CSV* (AppBar action: builds CSV of members with `csv`-free manual join, `Share.shareXFiles`).

### 8.3 Mosque editor (Figma 1123:10726, 1125:11933)
Same `MosqueProfilePage` widgets in **edit mode** (`isAdmin: true`): header shows *Edit* → `MosqueEditProfileSheet` (name, description, address + geocode via `geocoding` package → `location`, phone, email, website, socials, logo & covers upload to `mosque-media/<id>/…`, timezone auto from device, opening status).
- **Prayers tab (editor)**: month header (hijri via `HijriTool`), week strip (`PageView` of weeks, selected day), per-slot rows with ✎ → `TimePicker` + offset stepper; empty-day state with *Copy from another day* → `CopyPrayerTimesSheet` (Figma 1333:17251/17299: from-date, preview, "This day only / A date range", From/To, overwrite warning) → `fn_copy_mosque_prayer_times`; toast "Prayer time successfully copied from {date}". Save = upsert `mosque_prayer_times` row (`onConflict: 'mosque_id,day'`). **Overrides card**: *Create an override* → sheet (slot, new time, reason) → insert `mosque_prayer_overrides` for today; list "Applied overrides: Maghrib 23:30 (was 21:11) ✕" → delete. Overrides for a future day are allowed (date picker defaults to today).
- **Information tab (editor)**: capacity ×3 numeric, founded year, services multi-select chips, khutbah languages (search list of ISO languages, chips), imams list (+ *Add an Imam* sheet, Figma 1137:1802; reorder = position). Autosave on field blur with debounce, or explicit *Save* button — use explicit *Save* (matches app patterns, avoids partial writes).
- **News tab (editor)**: same feed + per-post ⋮ (*Edit*, *Archive*, *Notify followers* if not yet notified and quota available, *Delete*).
- **Donation tab (editor)** (P3): analytics view (Figma 1150:6236) → §10.

### 8.4 Create post (Figma 1140:2046, 1142:5343)
`MosqueAdminCreatePostPage`: title + body (announcement by default) or pick a category → typed form:
- Event: cover (optional), name, description, date, time, location (default "At the mosque"), *Notify followers* toggle (shows `Send push to {followers} followers`, disabled with reason when quota exhausted), *Mark as urgent*.
- Volunteering: + volunteers needed, date/time.
- Highlight: cover required, body.
- Janaza: name of the deceased (title), *after prayer* slot picker + time, dua text prefilled.
Submit → insert `mosque_posts` → if notify → `notify-mosque-followers { postId }` → snackbar with sent count. Trigger error `post_limit_reached` → localized message "You already have {n} active {type}s — archive one first".

---

## 9. Prayer-times integration (mosque times override computed times)

Decision (Amir): when the user has a **principal mosque**, `PrayerTimesPage`, the dashboard *Next prayer* card and the local prayer notifications use the mosque's effective times for that day; **fallback to `adhan_dart`** (today's behaviour) when the mosque has no row for the day. Users without a mosque see zero change.

Implementation in `PrayerTimesPresenter._recompute()` (`features/tools/ui/state_management/prayer_times_provider.dart`):

```dart
final myMosques = ref.read(myMosquesProvider);            // principal + cached prayer days (today + 7)
final mosqueDay = myMosques.effectiveDayFor(DateTime.now());   // null if no principal mosque or no row
if (mosqueDay != null) {
  times = mosqueDay.toDailyPrayerTimes(today, mosqueDay.timezone);
  offsets = mosqueDay.iqamaOffsets;                       // replaces PrayerSettingsModel.displayOffsets
  jumua = mosqueDay.jumua ?? computedJumua;
  source = PrayerSource.mosque(myMosques.principal!);
} else { /* existing GPS + method computation, source = PrayerSource.computed */ }
```

- `PrayerTimesState` gains `source` (`computed | mosque`) and `offsets` (`Map<PrayerSlot,int>`), defaults keep old behaviour. `PrayerTimeWidget.offsetMinutes` now reads `state.offsets` (was `settings.offsetFor`).
- `PrayerTimesPage` header: mosque chip (Figma 1212:9436) `"{name} - {city}"` when source = mosque, or "Add your mosque" when none → `MyMosquesSheet`. The calculation-method card stays but is greyed with hint "Times come from your mosque" when source = mosque.
- Next-prayer rollover timer: unchanged (works on any `DailyPrayerTimes`).
- **Local notifications** (`NotificationsPresenter.rescheduleAll()` schedules 7 days × 5 prayers): inject the same resolver — `for day in 0..6: mosqueDay(day) ?? computed(day)`. `myMosquesProvider` caches `mosque_prayer_times` rows for `[today, today+7]` (single query) and refreshes on app resume + after the sheet saves. Overrides are merged for today only (they're realtime-subscribed while the app is open → reschedule on change).
- Timezone: mosque `time` columns are wall-clock in `mosques.timezone`; convert with `timezone` package (`tz.TZDateTime(location, y, m, d, h, min)`) — never with `DateTime.now()` local unless equal.
- Secondary mosque: displayed only in the profile/sheet; not used for computation (specs: 1 principal).

---

## 10. Payments — Stripe Connect (P3, devis Bloc B)

### 10.1 Tables

```sql
create table if not exists public.mosque_stripe_accounts (
  mosque_id          bigint primary key references public.mosques(id) on delete cascade,
  stripe_account_id  text not null unique,
  status             public.stripe_account_status not null default 'not_started',
  charges_enabled    boolean not null default false,
  payouts_enabled    boolean not null default false,
  requirements       jsonb not null default '{}',     -- currently_due / disabled_reason from account.updated
  onboarded_at       timestamptz,
  created_at         timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.mosque_donation_settings (   -- Sadaqa card (Figma 1190:8268)
  mosque_id          bigint primary key references public.mosques(id) on delete cascade,
  title              text not null default 'Support the mosque',
  description        text,
  suggested_amounts  int[] not null default '{10,50,100,150}',
  allow_one_time     boolean not null default true,
  allow_monthly      boolean not null default true,
  allow_yearly       boolean not null default true,
  show_tax_badge     boolean not null default false,          -- requires mosques.can_issue_tax_receipts
  membership_fee_amounts int[] not null default '{60,120,240}',
  updated_at         timestamptz not null default now()
);
create table if not exists public.mosque_campaigns (
  id                 bigserial primary key,
  mosque_id          bigint not null references public.mosques(id) on delete cascade,
  title              text not null, description text, cover_url text,
  goal_amount        numeric(12,2) not null check (goal_amount > 0),
  collected_amount   numeric(12,2) not null default 0,
  donors_count       int not null default 0,
  suggested_amounts  int[] not null default '{10,50,100,150}',
  currency           public.currency_type not null default 'EUR',
  status             public.mosque_campaign_status not null default 'active',
  starts_at          timestamptz not null default now(),
  ends_at            timestamptz not null,
  closed_at          timestamptz, closed_reason text,
  created_by         uuid references public.profiles(id) on delete set null,
  created_at         timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists mosque_campaigns_idx on public.mosque_campaigns(mosque_id, status, ends_at);
-- max 3 active campaigns (devis B3): same trigger shape as fn_mosque_posts_limits, limit 3 on status='active'.
create table if not exists public.mosque_campaign_updates (   -- "Post update" action
  id bigserial primary key, campaign_id bigint not null references public.mosque_campaigns(id) on delete cascade,
  body text not null, image_url text, created_at timestamptz not null default now());
create table if not exists public.mosque_receipts (
  id bigserial primary key, mosque_id bigint not null references public.mosques(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  transaction_id bigint references public.transactions(id) on delete set null,   -- null = annual recap
  year int not null, number text not null,                                        -- "<mosque_id>-<year>-<seq>"
  amount numeric(12,2) not null, storage_path text not null,
  emailed_at timestamptz, created_at timestamptz not null default now(),
  unique (mosque_id, number));
```

### 10.2 Reusing the existing ledger (additive)

```sql
alter table public.transactions
  add column if not exists mosque_id          bigint references public.mosques(id) on delete restrict,
  add column if not exists mosque_campaign_id bigint references public.mosque_campaigns(id) on delete restrict,
  add column if not exists membership_id      bigint references public.mosque_members(id) on delete set null,
  add column if not exists stripe_account_id  text;                       -- connected account for direct charges
create index if not exists tx_mosque_idx on public.transactions(mosque_id, status, created_at desc) where mosque_id is not null;
create index if not exists tx_campaign_idx on public.transactions(mosque_campaign_id) where mosque_campaign_id is not null;

-- donation_subscriptions: today impact_project_id is NOT NULL and type is checked = 'donation'.
alter table public.donation_subscriptions alter column impact_project_id drop not null;
alter table public.donation_subscriptions drop constraint if exists donation_subscriptions_type_check;
alter table public.donation_subscriptions
  add column if not exists mosque_id         bigint references public.mosques(id) on delete restrict,
  add column if not exists membership_id     bigint references public.mosque_members(id) on delete set null,
  add column if not exists stripe_account_id text,
  add constraint donation_subscriptions_target_chk check (
    (impact_project_id is not null and mosque_id is null) or (impact_project_id is null and mosque_id is not null)),
  add constraint donation_subscriptions_type_chk check (type in ('donation','mosque_sadaqa','mosque_membership'));
alter table public.mosque_members add constraint mosque_members_fee_fk foreign key (fee_subscription_id) references public.donation_subscriptions(id) on delete set null;
```

Why safe: existing rows all have `impact_project_id` set and `type='donation'` → both new checks pass. `fn_apply_tx_to_projects` joins `transaction_items` → mosque transactions have **no items** → the impact trigger is a no-op for them (verify: it must not raise when zero items; it doesn't). Ajr for mosque donations: the existing trigger awards ajr only inside the `update … from transaction_items` branch? **No** — it awards ajr for any succeeded tx regardless of items → mosque donations automatically earn +50 ajr. Keep (product-consistent).

New trigger for campaign progress:

```sql
create or replace function public.fn_apply_tx_to_mosque() returns trigger language plpgsql security definer set search_path = public as $$
declare v_succ boolean; v_ref boolean;
begin
  if new.mosque_campaign_id is null then return new; end if;
  if tg_op = 'INSERT' then v_succ := new.status = 'succeeded'; v_ref := false;
  else v_succ := new.status = 'succeeded' and old.status is distinct from 'succeeded';
       v_ref := new.status = 'refunded' and old.status = 'succeeded'; end if;
  if v_succ then
    update public.mosque_campaigns c set collected_amount = c.collected_amount + new.amount_total,
      donors_count = c.donors_count + case when exists (select 1 from public.transactions t where t.user_id = new.user_id and t.status = 'succeeded' and t.id <> new.id and t.mosque_campaign_id = new.mosque_campaign_id) then 0 else 1 end
     where c.id = new.mosque_campaign_id;
  elsif v_ref then
    update public.mosque_campaigns c set collected_amount = greatest(0, c.collected_amount - new.amount_total) where c.id = new.mosque_campaign_id;
  end if;
  return new;
end $$;
drop trigger if exists trg_tx_apply_mosque on public.transactions;
create trigger trg_tx_apply_mosque after insert or update of status on public.transactions for each row execute function public.fn_apply_tx_to_mosque();
```

Campaign auto-close: pg_cron `mosques-close-campaigns` every 10 min: `update mosque_campaigns set status='closed', closed_at=now(), closed_reason='deadline' where status='active' and ends_at < now()`. Reminder push (`mosque_campaign`, "2 days left") to the mosque's followers is a system push → via `pg_net` → `send-push`, once per campaign (`reminded_at` column).

### 10.3 RLS (P3)
- `mosque_stripe_accounts`, `mosque_donation_settings`: read = admin of the mosque or Nour admin; `mosque_donation_settings` public read of approved mosques (the Sadaqa card needs it); write = mosque admin (`show_tax_badge` guarded by `can_issue_tax_receipts` in a trigger).
- `mosque_campaigns`: public read where `status in ('active','closed')` and mosque approved; admin write except `collected_amount`/`donors_count` (guard trigger like §4.10).
- `transactions` / `donation_subscriptions`: existing self-read policies unchanged. Add **admin read for their mosque**: `create policy tx_mosque_admin_read on public.transactions for select to authenticated using (mosque_id is not null and public.is_mosque_admin(mosque_id));` (same for subscriptions). Donor identity: expose through `fn_mosque_donors(p_mosque_id, filters)` (definer) that returns `'Anonymous'` + no avatar when `is_anonymous`.
- `mosque_receipts`: donor reads own; admin reads mosque's.

### 10.4 Client flows
- **Stripe status page** (`MosqueStripeStatusRoute`, devis B1): states *Not started* (CTA *Activate donations* → `mosque-stripe-onboarding` → `url_launcher` external browser — **not webview**, Stripe requires it) / *Onboarding in progress* / *Active* / *Documents required* (deep link back into Stripe). On `nour://mosque-admin/stripe/return` → call `{action:'status'}` and refresh. Checkbox "My association is entitled to issue tax receipts (art. 200 CGI)" → `mosques.can_issue_tax_receipts` (self-declared, devis §7).
- **Checkout** (`MosqueDonationCheckoutPage`): reuse `CheckoutPage` visual (summary card, stepper, anonymous toggle, method picker Card / Apple Pay / Google Pay; **no PayPal** for Connect direct charges in V1, **no cover-fees**). Presenter mirrors `CheckoutPresenter`: `create-mosque-payment-intent` or `create-mosque-subscription` → `StripePaymentService.presentForAccount(stripeAccountId, …)` → processing → Realtime on `transactions.id` / `donation_subscriptions.id` + polling fallback → `DonationRewardPage` (existing) with a mosque card variant. Amount bounds: server `MIN_AMOUNT=1`, `MAX_AMOUNT=10000`.
- **Campaign page** (`MosqueCampaignPage`): cover, progress (Realtime on `mosque_campaigns` row), donors avatars (`fn_mosque_campaign_recent_donors`), updates timeline, *Contribute*, *Share*.
- **Admin Donation tab** (Figma 1150:6236): `fn_mosque_donation_stats(p_mosque_id, p_year)` → `{ total_year, total_prev_year, support_amount, campaigns_amount, donors, recurring_active, avg_gift, month_gifts, monthly_donors }`; *Manage settings* → `MosqueAdminSadaqaSettingsRoute` (Figma 1190:8268, live preview widget = the public `MosqueSadaqaCard`); campaigns → `MosqueAdminCampaignsRoute` (Figma 1202:8978: *Extend* = ends_at picker, *Edit*, *Post update*, *Close early* = status closed); *Donors list* (filters period/type/recurring, CSV export); *Tax receipts* (list `mosque_receipts`, "Generate annual receipts for {year}" → loops `generate-mosque-receipt` per donor, shows progress).
- **My donations** (user): show mosque gifts; *Cancel* on mosque subscriptions → `cancel-mosque-subscription`.

---

## 11. Nour admin moderation (P2, devis A5)

Existing `AdminDashboardPage` (`features/admin`, guarded by `profile.isAdmin`) gets a third tab **Mosques**:
- List `mosques` with status filter (default `pending_review`), row: name, legal name, legal status, RNA, SIREN, country, owner email (via definer RPC `fn_admin_mosque_requests()` that joins `auth.users.email` — admins only), created date.
- Detail sheet: all fields + *Approve* / *Reject* (note required) / *Suspend* → `review-mosque` function. Duplicate SIREN warning when another mosque exists with the same SIREN.
- On approve: the mosque owner receives push `mosque_status` (`link: nour://mosque-admin`) + email; `MosqueReviewPage` flips via Realtime.

Operational checks (documents, phone call) remain manual (devis §7). Store nothing about them except `review_note`.

---

## 12. Production safety & backward compatibility checklist

Read before writing each migration and before each release.

1. **Never** rename/drop existing tables, columns, enum values, functions, policies, storage buckets or routes. Only add.
2. New columns on existing tables (`profiles`, `transactions`, `donation_subscriptions`, `mosque_members`) are **nullable or have a default**. `donation_subscriptions.impact_project_id` NOT NULL is *relaxed*, never tightened. Replace the `type` check with a superset check.
3. Enum additions in a **separate migration file** run before their first use (`alter type … add value` restriction).
4. `profiles.account_type default 'user'` → all existing auth users are worshippers; `AuthGuard` treats a missing `account_type` key in a cached JSON as `user`.
5. **Auth bootstrap change** (§3): existing installs with a valid session never see Welcome/Profile-type (session exists → `authorization()` path unchanged). Only sessionless installs (fresh install, logged out, deleted account) see the new screens. Test the upgrade path 1.2.0 → 1.3.0 with an existing anonymous session and with an email session.
6. `last_onboarding_screen` index shift (§3.2) only affects users with `onboarding_completed=false`; they get one extra screen, never a crash (clamp index to the page count).
7. Existing local prayer notifications and the calculation method keep working exactly as before when `user_mosques` is empty — guard every mosque branch with `if (principal == null)`.
8. Existing Stripe flow (`create-payment-intent`, `create-subscription`, `stripe-webhook`) is not modified. Connect gets its own functions and webhook endpoint. `Stripe.stripeAccountId` is reset to `null` after every mosque payment (`finally`).
9. `fn_apply_tx_to_projects` unchanged; verify with a mosque tx (no items) that it neither errors nor touches `impact_projects`.
10. RLS: every new table has RLS enabled **and** explicit policies; no policy on existing tables is loosened. `profiles` stays self/admin-read; community data goes through definer RPCs that check `is_mosque_admin`.
11. Feature flags in `app_config` allow shipping the client with the module hidden; server side can be deployed before the app release.
12. Migrations must be re-runnable (`if not exists`, `drop policy if exists`, `create or replace`). Test with `supabase db reset` locally **and** `supabase db push --dry-run` against a branch/staging.
13. Storage policies cast `(storage.foldername(name))[1]` to bigint — guard with a `case when … ~ '^\d+$'` to avoid cast errors on unrelated uploads.
14. iOS release: adding `firebase_messaging` requires the Push capability and an APNs key; a missing key only disables pushes, never crashes. Wrap `FirebaseMessaging` calls in try/catch + Crashlytics non-fatal.
15. Keep `talker` logging for all new datasources; localize all new strings in **all 11 arb files** (en, fr, ar, de, nl, tr, id, ur, bn, ms, ru) — `l10n.yaml` build fails otherwise? (No — untranslated keys fall back to `app_en.arb`, but the store listing promises 11 languages; at minimum en/fr/ar are mandatory).

---

## 13. Test plan (minimum)

**DB (pgTAP or SQL scripts in `backend/supabase/tests/`)**
- `fn_register_mosque`: new user ok; anonymous → error; existing worshipper → error; replay → same id; duplicate SIREN → unique violation.
- RLS matrix: worshipper cannot update mosques/prayer times/posts; admin of mosque A cannot touch mosque B; pending mosque invisible to others, readable by owner; members' PII invisible to other users.
- Triggers: post limits (3rd announcement fails), followers/members counters, campaign progress on `pending→succeeded`, refund reversal, `fn_apply_tx_to_projects` no-op for mosque tx.
- `fn_search_mosques`: distance ordering, text search, radius, `has_times`.
- `fn_copy_mosque_prayer_times`: range overwrite, 366-day cap, forbidden for non-admin.
- Quota: 3rd broadcast in 7 days → `quota_exceeded`.

**Edge functions (Deno test + Stripe CLI `stripe trigger --stripe-account`)**
- Connect webhook idempotency (same event twice), `account.updated` → `donations_enabled` flips, `invoice.paid` on connected account → succeeded tx with `mosque_id`.

**Flutter (widget/integration)**
- Auth routing table (§3.1) — 8 cases (existing user session, existing mosque session, fresh → worshipper, fresh → mosque → new account, fresh → mosque → existing user creds, fresh → mosque → existing mosque creds, worshipper flow → existing mosque creds, pending mosque relaunch).
- Prayer times: with/without principal mosque, missing day fallback, override today, notification rescheduling.
- Manual: Apple Pay on connected account (needs merchant id on the connected account too — Stripe handles for Express), Google Pay, `.ics` export opens in iOS/Android calendar, deep links from push (cold/warm/foreground).

---

## 14. Decisions taken & open questions

**Decisions (already validated with Amir)**
- Full scope A + B + Push, phased P0→P3; mosque times override computed ones with fallback.
- Two onboardings; mosque accounts are never anonymous; login cross-cases resolved by `profiles.account_type` (§3.1).
- Mosque auth methods = existing (email OTP, Google, Apple). No password, no Facebook despite the mock.
- Prayer schedule stored per day (matches the Figma calendar), overrides in a separate table.
- Map via `flutter_map`/OSM (no API key) — swap later if Google Maps is wanted.
- Urgent posts do not bypass the 2/week broadcast quota.

**Open questions (answer before P3; defaults applied if unanswered)**
1. Membership annual fee: yearly Stripe subscription on the connected account (default) vs one-time yearly payment? → default subscription (`type='mosque_membership'`).
2. Tax receipts: per-donation PDF at payment time (email) **and** annual recap (default), or annual only?
3. Should worshippers be able to follow a mosque anonymously (anonymous session)? Default **yes** (follow row is user-scoped; converting the session later keeps it).
4. Share links: `nour://` only until a web domain exists? Default yes.
5. Community "Volunteers" chip = members with `volunteer = true` **plus** applicants of volunteering posts? Default: members with `volunteer=true` only.
6. Do we show the mosque's *secondary* mosque anywhere else than the sheet/profile? Default no.
7. Language of mosque-entered content: stored as-is (specs: no translation).

---

*End of specification.*


---

## 15. Implementation status (branch `feat/mosques-module`)

All four phases are implemented on `feat/mosques-module` (5 commits after the spec: P0, P1, P2, P3-backend, P3-flutter). Nothing has been run through `flutter analyze` / `build_runner` in the cloud — see §15.4 for the local checklist.

### 15.1 What landed

| Phase | Backend | Flutter |
|---|---|---|
| P0 accounts | `20260906000000_mosques_enums.sql`, `20260906000100_mosques_accounts.sql` (`profiles.account_type`, `app_config`, `mosques`, `mosque_admins`, `fn_register_mosque`, `fn_my_mosque`, admin review RPCs), `review-mosque` fn | Welcome / profile-type pages, sessionless mosque onboarding (draft in SharedPreferences), `_afterLogin` routing by account type, `MosqueReviewPage` realtime gate, `AuthGuard` + `MosqueAdminGuard` |
| P1 push | `20260906000200_push_infra.sql` (`device_tokens`, `notifications_log`, quota), `_shared/push.ts` (FCM v1), `send-push`, `notify-mosque-followers` | `firebase_messaging`, `PushNotificationsServices`, `push_provider`, `PushSettingsPage`, deep links (`nour://`, `https://nour-community.com`) |
| P2 core | `20260906000300_mosques_core.sql` (prayer times/overrides, followers, user_mosques, posts + interactions, members, campaigns skeleton, search RPC, dashboard stats, storage buckets, housekeeping cron) | Search (map+list), profile (Prayers / Info / News tabs), follow, My mosques (principal/secondary), membership form, admin shell (Dashboard / Community / Mosque), prayer editor, posts CRUD + broadcast, Nour-admin moderation tab, prayer-times override in the app's prayer engine |
| P3 donations | `20260906000400_mosques_donations.sql` (`mosque_stripe_accounts`, `mosque_donation_settings`, `mosque_campaign_updates`, `mosque_receipts`, additive columns on `transactions` / `donation_subscriptions`, `fn_apply_tx_to_mosque`, stats/donors RPCs), fns `mosque-stripe-onboarding`, `create-mosque-payment-intent`, `create-mosque-subscription`, `cancel-mosque-subscription`, `stripe-connect-webhook`, `generate-mosque-receipt` | Donation tab (Sadaqa card + campaigns), campaign page (realtime progress), `MosqueCheckoutPage` (direct charge — `Stripe.stripeAccountId` switched for the confirmation only), admin Donation tab (Stripe status card, analytics, Sadaqa settings, campaigns create/edit/extend/close/update+push, donors list + CSV + receipts, receipts list), "My donations → Mosques" tab |

### 15.2 Deviations from the spec

- **Checkout widgets extracted**: `_OptionTile/_MethodTile/_StatusOverlay/…` moved verbatim from `checkout_page.dart` to `payments/ui/widgets/checkout_widgets.dart` (public names) so the mosque checkout reuses them. `checkout_page.dart` behaviour is unchanged.
- **`StripePaymentService.confirm` gained `stripeAccountId`**: sets `Stripe.stripeAccountId` + `applySettings()` before confirming and resets it to the platform account in `finally`. Impact checkout passes nothing → identical to before.
- **Legacy lists filtered**: `getHistory()` adds `.isFilter('mosque_id', null)` and `getMySubscriptions()` adds `.not('impact_project_id','is',null)`; `DonationSubscriptionModel.impactProjectId` parses `?? 0`. Mosque rows are listed through `fn_my_mosque_donations` / a dedicated query instead, so the existing Impact screens never see them.
- **Membership fee**: yearly only (`create-mosque-subscription` rejects `interval != 'year'` when `membershipId` is set). Amounts come from `mosque_donation_settings.membership_fee_amounts` (default 60/120/240, second one recommended); the member form still uses the fixed preset — wire `membershipFeeAmounts` in `mosque_become_member_page.dart` if you want it configurable per mosque.
- **Tax receipts**: `mosques.can_issue_tax_receipts` is set once at Stripe onboarding start (`canIssueTaxReceipts` toggle) — it is a protected column, so changing it later is a Nour-admin action (service role / SQL).
- **Campaign "ending soon" reminder push**: candidates exposed by `fn_mosque_campaigns_to_remind()`; the push itself is not scheduled (needs pg_net or an external cron calling `send-push`). See §10.2.
- **Receipts PDF**: generated by `generate-mosque-receipt` with `pdf-lib` into the private `mosque-receipts` bucket; the app opens a 1 h signed URL. Email sending (Resend) is only wired for the review decision, not for receipts.
- **Donor receipts route**: `MosqueAdminReceiptsPage(mine: true)` is reused on the worshipper stack at `mosque-receipts` (no guard) — same page, own rows via RLS.

### 15.3 Backend deployment

```bash
cd backend
supabase db push                       # 5 new migrations, all idempotent / additive
supabase functions deploy send-push notify-mosque-followers review-mosque \
  mosque-stripe-onboarding create-mosque-payment-intent create-mosque-subscription \
  cancel-mosque-subscription stripe-connect-webhook generate-mosque-receipt
supabase secrets set \
  INTERNAL_FUNCTIONS_KEY=<random 32+ chars> \
  FCM_SERVICE_ACCOUNT_JSON='<firebase service-account json, single line>' \
  STRIPE_CONNECT_WEBHOOK_SECRET=whsec_... \
  STRIPE_CONNECT_RETURN_URL=https://nour-community.com/stripe/return \
  STRIPE_CONNECT_REFRESH_URL=https://nour-community.com/stripe/refresh \
  RESEND_API_KEY=re_... NOTIFICATIONS_FROM_EMAIL="Nour <no-reply@nour-community.com>"   # optional
```

- Stripe Dashboard → Developers → Webhooks → **"Listen to events on Connected accounts"** → endpoint `https://<project>.supabase.co/functions/v1/stripe-connect-webhook`, events: `account.updated`, `payment_intent.succeeded`, `payment_intent.payment_failed`, `payment_intent.canceled`, `invoice.paid`, `invoice.payment_failed`, `customer.subscription.updated`, `customer.subscription.deleted`. Copy the signing secret into `STRIPE_CONNECT_WEBHOOK_SECRET`. The existing platform webhook stays untouched.
- Stripe Connect settings: enable **Express** accounts, branding (name/logo/colour) — the hosted onboarding shows it.
- `app_config`: `mosque_donations_enabled` ships **false** — flip it to `true` (SQL) once Stripe Connect is live. `mosques_enabled` is `true`.
- Firebase: add the APNs key (.p8) in Firebase Cloud Messaging settings; create a service account with "Firebase Cloud Messaging API" role → JSON → `FCM_SERVICE_ACCOUNT_JSON`. Xcode: Push Notifications + Background Modes (remote notifications) capabilities are in the entitlements/plist already.
- pg_cron: `fn_mosques_housekeeping()` is scheduled every 10 min by the P2 migration (requires the `pg_cron` extension, already used by the project).

### 15.4 Flutter — local checklist

```bash
cd nour_app
flutter pub get                       # firebase_messaging, flutter_map, latlong2 added
dart run build_runner build --delete-conflicting-outputs   # app_router.gr.dart (11 new routes), assets
flutter gen-l10n                      # ~450 new keys (en/fr)
flutter analyze
```

- `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` must include the FCM sender (already the case if Firebase is set up for analytics).
- Deep links: Android intent filters for `nour://` + `https://nour-community.com/mosque/*` are in the manifest; iOS needs the `applinks:nour-community.com` associated domain + an `apple-app-site-association` on the website for universal links (custom scheme works without it).
- Things worth a look during analyze: nullable `MosqueModel?` narrowing inside closures in the new pages (`campaign.value!`), `firstOrNull` (Dart 3 `collection`), and `Stripe.stripeAccountId` (flutter_stripe ≥ 9 — present in 13.x).

### 15.5 Suggested manual test path

1. Fresh install → Welcome → "I am a mosque manager" → 8 onboarding steps → sign-up (email OTP) → "Your mosque is being reviewed".
2. Nour admin → Admin dashboard → Mosques tab → Approve → the mosque device flips to the admin shell in realtime.
3. Admin → Mosque tab → Donation → "Set up payments" → Stripe test onboarding → back → status "Active", `donations_enabled = true`.
4. Admin → Sadaqa settings (amounts/frequencies), New campaign (+ notify followers).
5. Worshipper (second device) → search → follow → Donation tab → 10 € one-time (card `4242…`) → thank-you; then 5 €/month → "My donations → Mosques" → cancel.
6. Admin → Donors → issue receipt (only if tax receipts enabled) → PDF opens; Donors CSV export.
7. Prayer times page shows the mosque chip once the mosque is set as principal and has published times.
