-- =============================================================================
-- Transactions: zakat + donations
-- =============================================================================

create table if not exists public.zakat_transactions (
  id                bigserial primary key,
  user_id           uuid not null references public.profiles(id) on delete cascade,
  impact_project_id bigint not null references public.impact_projects(id) on delete restrict,
  amount            numeric(12,2) not null check (amount > 0),
  currency          public.currency_type not null default 'EUR',
  payment_ref       text,
  created_at        timestamptz not null default now()
);
create index if not exists zakat_tx_user_idx    on public.zakat_transactions(user_id);
create index if not exists zakat_tx_project_idx on public.zakat_transactions(impact_project_id);
create index if not exists zakat_tx_created_idx on public.zakat_transactions(created_at desc);

create table if not exists public.donation_transactions (
  id                bigserial primary key,
  user_id           uuid not null references public.profiles(id) on delete cascade,
  impact_project_id bigint not null references public.impact_projects(id) on delete restrict,
  amount            numeric(12,2) not null check (amount > 0),
  currency          public.currency_type not null default 'EUR',
  payment_ref       text,
  created_at        timestamptz not null default now()
);
create index if not exists donation_tx_user_idx    on public.donation_transactions(user_id);
create index if not exists donation_tx_project_idx on public.donation_transactions(impact_project_id);
create index if not exists donation_tx_created_idx on public.donation_transactions(created_at desc);

-- -----------------------------------------------------------------------------
-- Maintain impact_projects.collected_amount in real time
-- -----------------------------------------------------------------------------
create or replace function public.fn_bump_project_collected()
returns trigger
language plpgsql
as $$
begin
  if (tg_op = 'INSERT') then
    update public.impact_projects
       set collected_amount = collected_amount + new.amount
     where id = new.impact_project_id;
  elsif (tg_op = 'DELETE') then
    update public.impact_projects
       set collected_amount = greatest(0, collected_amount - old.amount)
     where id = old.impact_project_id;
  end if;
  return null;
end;
$$;

drop trigger if exists trg_zakat_tx_bump on public.zakat_transactions;
create trigger trg_zakat_tx_bump
  after insert or delete on public.zakat_transactions
  for each row execute function public.fn_bump_project_collected();

drop trigger if exists trg_donation_tx_bump on public.donation_transactions;
create trigger trg_donation_tx_bump
  after insert or delete on public.donation_transactions
  for each row execute function public.fn_bump_project_collected();
