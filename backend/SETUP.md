# Supabase Setup — Nour Community

## 1. Prerequisites

```bash
brew install supabase/tap/supabase   # macOS
# or: npm i -g supabase
supabase --version                    # >= 1.180
```

## 2. Local dev

```bash
cd backend
supabase start                        # boots local Postgres + Studio
supabase db reset                     # applies migrations + seed.sql
```

Studio: http://127.0.0.1:54323 — Inbucket (emails): http://127.0.0.1:54324

## 3. Link to remote project

```bash
cp .env.example .env                  # fill SUPABASE_PROJECT_REF + DB password
supabase link --project-ref $SUPABASE_PROJECT_REF
supabase db push                      # pushes /supabase/migrations to remote
```

## 4. Deploy edge functions

```bash
supabase functions deploy getQuiz --no-verify-jwt=false
supabase functions deploy submitQuiz --no-verify-jwt=false
```

Set OAuth secrets used by `config.toml`:

```bash
supabase secrets set \
  GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=... \
  APPLE_CLIENT_ID=...  APPLE_CLIENT_SECRET=...
```

## 5. File layout

```
backend/
├── README.md              ← project spec (source of truth)
├── SETUP.md               ← this file
├── .env.example
├── .gitignore
└── supabase/
    ├── config.toml
    ├── seed.sql
    ├── migrations/
    │   ├── 20260515000000_enums_and_extensions.sql
    │   ├── 20260515000100_profiles.sql
    │   ├── 20260515000200_dhikr.sql
    │   ├── 20260515000300_adhkar.sql
    │   ├── 20260515000400_duas.sql
    │   ├── 20260515000500_hadith.sql
    │   ├── 20260515000600_quiz.sql
    │   ├── 20260515000700_impact_projects.sql
    │   ├── 20260515000800_transactions.sql
    │   ├── 20260515000900_progress.sql
    │   ├── 20260515001000_ajr_streak.sql
    │   ├── 20260515001100_favorites.sql
    │   ├── 20260515001200_storage_buckets.sql
    │   └── 20260515001300_rls_policies.sql
    └── functions/
        ├── _shared/{cors,errors,supabase}.ts
        ├── getQuiz/index.ts
        └── submitQuiz/index.ts
```

## 6. Architecture notes

- **`profiles.id = auth.users.id` (uuid).** Anonymous sign-ins create an auth row → `handle_new_auth_user` trigger seeds the profile + per-user progress rows.
- **Linking anon → email/google/apple**: use `supabase.auth.linkIdentity()` from Flutter — `profiles` row stays the same (same `auth.uid()`).
- **Ajr accounting**: never insert into `ajr_log` from the client. All sources go through DB triggers (`fn_dhikr_progress_after_change`) or edge functions (`submitQuiz`) running as service role. Profile `earned_ajr_count` is maintained by `fn_apply_ajr_to_profile`.
- **Daily streak**: call the SECURITY DEFINER function `fn_mark_daily_activity(user_id, 'dhikr' | 'quick_action')`. The dhikr-completion path already calls it automatically; ayah/dua opens call it explicitly from the Flutter client (`supabase.rpc('fn_mark_daily_activity', {...})`).
- **`likes_count`** on duas/adhkars/hadiths is maintained by triggers on the `favorite_*` tables. Don't update it manually.
- **Quiz answers** are scored server-side in `submitQuiz`. `correct_option_index` is fetched only with service role — the catalog RLS policy returns the column but the Flutter client should always go through the edge function for both fetching and submitting.
- **Catalog admin writes**: set `profiles.is_admin = true` for an admin account; the `public.is_admin()` helper drives all admin-write RLS.
- **Currency**: all monetary amounts are `numeric(12,2)` with a `currency_type` enum defaulting to `EUR`.

## 7. Useful RPC calls from Flutter

```dart
// Mark today's quick-action (ayah/dua opened, quiz played)
await supabase.rpc('fn_mark_daily_activity',
    params: {'p_user_id': supabase.auth.currentUser!.id, 'p_mark': 'quick_action'});

// Reset stale streaks (idempotent — also schedulable via pg_cron)
await supabase.rpc('fn_reset_stale_streaks');

// Fetch today's quiz
final res = await supabase.functions.invoke('getQuiz');

// Submit quiz
final res = await supabase.functions.invoke('submitQuiz',
    body: {'answers': [{'question_id': 1, 'selected_option_index': 3}]});
```
