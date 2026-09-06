# Impact project "Help us build the Nour app" — image assets

Referenced by `migrations/20260906000000_impact_nour_app_development_project.sql`
in the public `app_images` bucket under `impact/nour-app/`:

| file              | used as                                   | size      |
|-------------------|-------------------------------------------|-----------|
| `cover.jpg`       | `cover_image_url` + `images[1]`           | 1200×675  |
| `gallery-logo.jpg`| `images[2]` + launch story image          | 1200×675  |
| `avatar.jpg`      | `partner_organizations.avatar_url` (Nour Charity) | 400×400 |

Upload **before** `supabase db push` (public URLs are hardcoded in the migration):

```sh
cd backend/supabase/seeds/impact/nour-app
supabase storage cp cover.jpg        ss:///app_images/impact/nour-app/cover.jpg        --experimental
supabase storage cp gallery-logo.jpg ss:///app_images/impact/nour-app/gallery-logo.jpg --experimental
supabase storage cp avatar.jpg       ss:///app_images/impact/nour-app/avatar.jpg       --experimental
```

Or drag-and-drop the three files into Studio → Storage → `app_images` → `impact/nour-app/`.

Sources: `docs/Nour Community Brand Guidelines` (business card recto, vertical logo + pattern, icon).
