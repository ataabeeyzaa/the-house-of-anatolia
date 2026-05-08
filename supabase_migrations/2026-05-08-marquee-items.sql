-- ============================================================
-- Marquee items — anasayfa kayan şerit (TV altyazısı tarzı)
-- 2026-05-08 — PR #7
--
-- Çalıştırma: Supabase Dashboard → SQL Editor → New query →
-- bu dosyanın içeriğini yapıştır → Run.
-- ============================================================

create table if not exists public.marquee_items (
  id uuid primary key default gen_random_uuid(),
  label_tr text not null,
  label_en text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists marquee_items_active_sort_idx
  on public.marquee_items (is_active, sort_order);

alter table public.marquee_items enable row level security;

-- Anon (ve authenticated) kullanıcılar sadece aktif satırları okur
drop policy if exists "marquee anon read" on public.marquee_items;
create policy "marquee anon read"
  on public.marquee_items
  for select
  to anon, authenticated
  using (is_active = true);

-- Admin (is_admin() true olan authenticated user) tüm yetkilere sahip
drop policy if exists "marquee admin all" on public.marquee_items;
create policy "marquee admin all"
  on public.marquee_items
  for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- updated_at otomatik tetikleyicisi
create or replace function public.touch_marquee_items_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_marquee_items_updated_at on public.marquee_items;
create trigger trg_marquee_items_updated_at
  before update on public.marquee_items
  for each row execute function public.touch_marquee_items_updated_at();

-- Default 5 row (mevcut "yakında" şerit içerikleri).
-- label_tr unique olduğunda yeniden eklemez (idempotent migration).
insert into public.marquee_items (label_tr, label_en, sort_order, is_active)
select v.label_tr, v.label_en, v.sort_order, v.is_active
from (values
  ('Yakında — Kastamonu Sarımsağı', 'Coming Soon — Kastamonu Garlic',  10, true),
  ('Yakında — Antep Fıstığı',       'Coming Soon — Antep Pistachio',   20, true),
  ('Yakında — Trabzon Hamsisi',     'Coming Soon — Trabzon Anchovy',   30, true),
  ('Yakında — Maraş Dondurması',    'Coming Soon — Maraş Ice Cream',   40, true),
  ('Yakında — Edirne Ciğeri',       'Coming Soon — Edirne Liver',      50, true)
) as v(label_tr, label_en, sort_order, is_active)
where not exists (
  select 1 from public.marquee_items mi where mi.label_tr = v.label_tr
);
