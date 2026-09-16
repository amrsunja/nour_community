-- =============================================================================
-- Subscription invoices → ledger integrity
-- -----------------------------------------------------------------------------
-- A recurring donation (impact or mosque) only reaches a collected total
-- through a `transactions` row, and that row is created from a paid Stripe
-- invoice. That write is now done by ONE shared routine used by both webhooks
-- AND by the donor-facing reconcile functions, so a missed/late webhook can be
-- repaired — which only works if the invoice itself is the idempotency key.
--
-- 1. UNIQUE `transactions.stripe_invoice_id` — makes the retry / resend /
--    reconcile paths safe against double counting.
-- 2. `fn_subscriptions_missing_invoices()` — admin diagnostic: active
--    subscriptions with no succeeded transaction since their last period.
-- =============================================================================

-- 1. ---------------------------------------------------------------------------
-- The idempotency key for webhook retries, dashboard resends and the reconcile
-- endpoints. Already created in 20260818000100 — re-asserted here because the
-- new write path depends on it (a 23505 is read as "already booked").
create unique index if not exists tx_stripe_invoice_uniq
  on public.transactions(stripe_invoice_id) where stripe_invoice_id is not null;

comment on index public.tx_stripe_invoice_uniq is
  'One ledger row per Stripe invoice: idempotency for webhook retries, dashboard resends and the reconcile endpoints.';

-- 2. ---------------------------------------------------------------------------
-- Subscriptions that are paying in Stripe but have nothing (or nothing recent)
-- in the ledger — i.e. money that is not counted in any collected total.
create or replace function public.fn_subscriptions_missing_invoices()
returns table (
  subscription_id   bigint,
  user_id           uuid,
  kind              text,
  target            text,
  amount            numeric,
  billing_interval  text,
  status            text,
  created_at        timestamptz,
  last_tx_at        timestamptz,
  booked_invoices   bigint,
  stripe_subscription_id text
)
language sql stable security definer set search_path = public as $$
  select s.id,
         s.user_id,
         s.type::text,
         coalesce(p.title_en, m.name, '—'),
         s.amount,
         s."interval"::text,
         s.status::text,
         s.created_at,
         (select max(t.created_at) from public.transactions t
           where t.subscription_id = s.id and t.status = 'succeeded'),
         (select count(*) from public.transactions t
           where t.subscription_id = s.id and t.status = 'succeeded'),
         s.stripe_subscription_id
    from public.donation_subscriptions s
    left join public.impact_projects p on p.id = s.impact_project_id
    left join public.mosques m on m.id = s.mosque_id
   -- Admins in the app; `auth.uid() is null` lets you run it straight from the
   -- Studio SQL editor / service role (anon never reaches it — execute is
   -- granted to `authenticated` only).
   where (public.is_admin() or auth.uid() is null)
     and s.status in ('active', 'past_due')
     and not exists (
       select 1 from public.transactions t
        where t.subscription_id = s.id
          and t.status = 'succeeded'
          and t.created_at > coalesce(s.current_period_end - case when s."interval" = 'year'
                                                                 then interval '1 year'
                                                                 else interval '1 month' end,
                                      s.created_at - interval '1 day')
     )
   order by s.created_at desc;
$$;

grant execute on function public.fn_subscriptions_missing_invoices() to authenticated;

comment on function public.fn_subscriptions_missing_invoices() is
  'Admin diagnostic: paying subscriptions whose current period has no succeeded transaction — their money is not in any collected total. Repair by resending the invoice.paid event in Stripe, or by opening the app (the reconcile endpoints book missing invoices).';
