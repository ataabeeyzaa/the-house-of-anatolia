-- The House of Anatolia - Supabase PostgreSQL Schema
-- Adım 2: Supabase veritabanı tabloları + güvenli RLS politikaları
-- Bu dosyayı Supabase > SQL Editor > New query alanında çalıştıracağız.

-- Gerekli extension
create extension if not exists pgcrypto;

-- updated_at otomatik güncelleme fonksiyonu
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- -------------------------------------------------------
-- 1) Admin kullanıcıları
-- -------------------------------------------------------
create table if not exists public.admins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null unique,
  role text not null default 'admin' check (role in ('super_admin', 'admin', 'editor')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

drop trigger if exists trg_admins_updated_at on public.admins;
create trigger trg_admins_updated_at
before update on public.admins
for each row execute function public.set_updated_at();

alter table public.admins enable row level security;


-- Admin kontrol fonksiyonu
-- Admin paneli için ileride Supabase Auth kullanacağız.
-- auth.uid() ile admins.user_id eşleşirse yönetim izni olacak.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admins
    where user_id = auth.uid()
      and is_active = true
  );
$$;

drop policy if exists "Admins can read admins" on public.admins;
create policy "Admins can read admins"
on public.admins for select
to authenticated
using (public.is_admin());

drop policy if exists "Admins can manage admins" on public.admins;
create policy "Admins can manage admins"
on public.admins for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 2) Şehirler
-- svg_id haritadaki path id: TR78, TR37 gibi.
-- is_active: hover kartı gösterilsin mi?
-- is_clickable: ürün sayfasına tıklanabilsin mi?
-- -------------------------------------------------------
create table if not exists public.cities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  plate_code text not null unique,
  svg_id text not null unique,
  is_active boolean not null default false,
  is_clickable boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

drop trigger if exists trg_cities_updated_at on public.cities;
create trigger trg_cities_updated_at
before update on public.cities
for each row execute function public.set_updated_at();

alter table public.cities enable row level security;

drop policy if exists "Public can read active cities" on public.cities;
create policy "Public can read active cities"
on public.cities for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage cities" on public.cities;
create policy "Admins can manage cities"
on public.cities for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 3) Ürünler
-- -------------------------------------------------------
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  city_id uuid not null references public.cities(id) on delete cascade,
  name text not null,
  slug text not null unique,
  short_name text not null,
  mini_image text,
  hero_image text,
  parts_main_image text,
  hero_badge text,
  hero_title text not null,
  hero_subtitle text,
  hero_left_text text,
  hero_right_text text,
  meta_description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_products_city_id on public.products(city_id);
create index if not exists idx_products_slug on public.products(slug);

drop trigger if exists trg_products_updated_at on public.products;
create trigger trg_products_updated_at
before update on public.products
for each row execute function public.set_updated_at();

alter table public.products enable row level security;

drop policy if exists "Public can read active products" on public.products;
create policy "Public can read active products"
on public.products for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage products" on public.products;
create policy "Admins can manage products"
on public.products for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 4) Ürün kısımları
-- -------------------------------------------------------
create table if not exists public.product_parts (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  title text not null,
  subtitle text,
  description text not null,
  image text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_product_parts_product_id on public.product_parts(product_id);

drop trigger if exists trg_product_parts_updated_at on public.product_parts;
create trigger trg_product_parts_updated_at
before update on public.product_parts
for each row execute function public.set_updated_at();

alter table public.product_parts enable row level security;

drop policy if exists "Public can read active product parts" on public.product_parts;
create policy "Public can read active product parts"
on public.product_parts for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage product parts" on public.product_parts;
create policy "Admins can manage product parts"
on public.product_parts for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 5) Kullanım rehberi adımları
-- -------------------------------------------------------
create table if not exists public.usage_steps (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  title text not null,
  description text not null,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_usage_steps_product_id on public.usage_steps(product_id);

drop trigger if exists trg_usage_steps_updated_at on public.usage_steps;
create trigger trg_usage_steps_updated_at
before update on public.usage_steps
for each row execute function public.set_updated_at();

alter table public.usage_steps enable row level security;

drop policy if exists "Public can read active usage steps" on public.usage_steps;
create policy "Public can read active usage steps"
on public.usage_steps for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage usage steps" on public.usage_steps;
create policy "Admins can manage usage steps"
on public.usage_steps for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 6) Galeri görselleri
-- -------------------------------------------------------
create table if not exists public.gallery_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  image text not null,
  caption text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_gallery_images_product_id on public.gallery_images(product_id);

drop trigger if exists trg_gallery_images_updated_at on public.gallery_images;
create trigger trg_gallery_images_updated_at
before update on public.gallery_images
for each row execute function public.set_updated_at();

alter table public.gallery_images enable row level security;

drop policy if exists "Public can read active gallery images" on public.gallery_images;
create policy "Public can read active gallery images"
on public.gallery_images for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage gallery images" on public.gallery_images;
create policy "Admins can manage gallery images"
on public.gallery_images for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 7) Formdaki ürün seçenekleri
-- -------------------------------------------------------
create table if not exists public.product_options (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  name text not null,
  image text,
  description text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_product_options_product_id on public.product_options(product_id);

drop trigger if exists trg_product_options_updated_at on public.product_options;
create trigger trg_product_options_updated_at
before update on public.product_options
for each row execute function public.set_updated_at();

alter table public.product_options enable row level security;

drop policy if exists "Public can read active product options" on public.product_options;
create policy "Public can read active product options"
on public.product_options for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage product options" on public.product_options;
create policy "Admins can manage product options"
on public.product_options for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 8) Paket seçenekleri
-- -------------------------------------------------------
create table if not exists public.package_options (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  name text not null,
  image text,
  description text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_package_options_product_id on public.package_options(product_id);

drop trigger if exists trg_package_options_updated_at on public.package_options;
create trigger trg_package_options_updated_at
before update on public.package_options
for each row execute function public.set_updated_at();

alter table public.package_options enable row level security;

drop policy if exists "Public can read active package options" on public.package_options;
create policy "Public can read active package options"
on public.package_options for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage package options" on public.package_options;
create policy "Admins can manage package options"
on public.package_options for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 9) Gramaj seçenekleri
-- -------------------------------------------------------
create table if not exists public.weight_options (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  label text not null,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_weight_options_product_id on public.weight_options(product_id);

drop trigger if exists trg_weight_options_updated_at on public.weight_options;
create trigger trg_weight_options_updated_at
before update on public.weight_options
for each row execute function public.set_updated_at();

alter table public.weight_options enable row level security;

drop policy if exists "Public can read active weight options" on public.weight_options;
create policy "Public can read active weight options"
on public.weight_options for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage weight options" on public.weight_options;
create policy "Admins can manage weight options"
on public.weight_options for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 10) Gelen teklif talepleri
-- Güvenlik notu:
-- Bu tablo public insert'e kapalı.
-- Form kayıtlarını ileride Next.js API route / server action üzerinden,
-- Supabase service role key ile güvenli şekilde yazacağız.
-- -------------------------------------------------------
create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  city_id uuid not null references public.cities(id) on delete restrict,
  product_option_id uuid references public.product_options(id) on delete set null,
  package_option_id uuid references public.package_options(id) on delete set null,
  weight_option_id uuid references public.weight_options(id) on delete set null,
  quantity int,
  request_type text,
  full_name text not null,
  company text,
  email text not null,
  phone text not null,
  delivery_location text,
  message text,
  status text not null default 'new' check (status in ('new','contacted','quoted','completed','cancelled')),
  ip_address text,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_requests_status on public.requests(status);
create index if not exists idx_requests_created_at on public.requests(created_at);
create index if not exists idx_requests_product_id on public.requests(product_id);

drop trigger if exists trg_requests_updated_at on public.requests;
create trigger trg_requests_updated_at
before update on public.requests
for each row execute function public.set_updated_at();

alter table public.requests enable row level security;

drop policy if exists "Admins can read requests" on public.requests;
create policy "Admins can read requests"
on public.requests for select
to authenticated
using (public.is_admin());

drop policy if exists "Admins can update requests" on public.requests;
create policy "Admins can update requests"
on public.requests for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 11) Başlangıç verileri
-- -------------------------------------------------------

insert into public.cities (name, plate_code, svg_id, is_active, is_clickable, sort_order)
values
('Karabük', '78', 'TR78', true, true, 1),
('Kastamonu', '37', 'TR37', true, false, 2)
on conflict (plate_code) do update set
  name = excluded.name,
  svg_id = excluded.svg_id,
  is_active = excluded.is_active,
  is_clickable = excluded.is_clickable,
  sort_order = excluded.sort_order;

insert into public.products (
  city_id, name, slug, short_name, mini_image, hero_image, parts_main_image,
  hero_badge, hero_title, hero_subtitle, hero_left_text, hero_right_text,
  meta_description, is_active
)
select
  c.id,
  'Karabük Safranı',
  'karabuk-safrani',
  'Safran',
  'assets/mini_safran.png',
  'assets/safran-cicegi.png',
  'assets/safran_soganli.png',
  'Karabük • Coğrafi İşaretli Ürün',
  'Karabük Safranı',
  'Karabük’ün coğrafi işaretli en zarif değeri',
  'SAF',
  'RAN',
  'Karabük Safranı için coğrafi işaretli ürün tanıtım ve teklif sayfası.',
  true
from public.cities c
where c.plate_code = '78'
on conflict (slug) do update set
  city_id = excluded.city_id,
  name = excluded.name,
  short_name = excluded.short_name,
  mini_image = excluded.mini_image,
  hero_image = excluded.hero_image,
  parts_main_image = excluded.parts_main_image,
  hero_badge = excluded.hero_badge,
  hero_title = excluded.hero_title,
  hero_subtitle = excluded.hero_subtitle,
  hero_left_text = excluded.hero_left_text,
  hero_right_text = excluded.hero_right_text,
  meta_description = excluded.meta_description,
  is_active = excluded.is_active;

insert into public.products (
  city_id, name, slug, short_name, mini_image, hero_image, parts_main_image,
  hero_badge, hero_title, hero_subtitle, hero_left_text, hero_right_text,
  meta_description, is_active
)
select
  c.id,
  'Kastamonu Sarımsağı',
  'kastamonu-sarimsagi',
  'Sarımsak',
  'assets/mini_sarimsak.png',
  'assets/sarimsak.png',
  'assets/sarimsak.png',
  'Kastamonu • Coğrafi İşaretli Ürün',
  'Kastamonu Sarımsağı',
  'Kastamonu’nun güçlü aromalı coğrafi işaretli ürünü',
  'SARI',
  'MSAK',
  'Kastamonu Sarımsağı için coğrafi işaretli ürün tanıtım ve teklif sayfası.',
  true
from public.cities c
where c.plate_code = '37'
on conflict (slug) do update set
  city_id = excluded.city_id,
  name = excluded.name,
  short_name = excluded.short_name,
  mini_image = excluded.mini_image,
  hero_image = excluded.hero_image,
  parts_main_image = excluded.parts_main_image,
  hero_badge = excluded.hero_badge,
  hero_title = excluded.hero_title,
  hero_subtitle = excluded.hero_subtitle,
  hero_left_text = excluded.hero_left_text,
  hero_right_text = excluded.hero_right_text,
  meta_description = excluded.meta_description,
  is_active = excluded.is_active;

-- Karabük Safranı örnek ürün kısımları
insert into public.product_parts (product_id, title, subtitle, description, image, sort_order)
select p.id, x.title, x.subtitle, x.description, x.image, x.sort_order
from public.products p
cross join (
  values
  ('İplik', 'Yoğun Aroma', 'Safranın en değerli kısmı, elde özenle ayrılan kırmızı ipliklerdir. Renk gücü, karakteristik aroma ve premium algı bu ince liflerde toplanır.', 'assets/safran_iplik.png', 1),
  ('Çiçek', 'Zarif Görünüm', 'Mor çiçek, ürünün en dikkat çekici yüzüdür. Marka dili, görsel anlatım ve sunum estetiği açısından safranın en güçlü sahnesini oluşturur.', 'assets/safran_cicek.png', 2),
  ('Soğan', 'Üretim Döngüsü', 'Toprak altında yer alan soğan yapısı, yetiştiricilik ve çoğaltma sürecinin temelidir.', 'assets/safran_sogani.png', 3)
) as x(title, subtitle, description, image, sort_order)
where p.slug = 'karabuk-safrani';

-- Karabük Safranı kullanım rehberi
insert into public.usage_steps (product_id, title, description, sort_order)
select p.id, x.title, x.description, x.sort_order
from public.products p
cross join (
  values
  ('Hazırlama', '4-6 iplik safranı küçük bir kaba alın. Üzerine 3-4 yemek kaşığı ılık su veya süt dökün. 20-30 dakika bekletin.', 1),
  ('Demlenme', 'Safranın altın sarısı rengi ve eşsiz kokusu suyun içine geçer. Bu safran suyu tarifinize eklenmeye hazırdır.', 2),
  ('Kullanım', 'Pirinç, çorba, çay, tatlı veya et yemeklerine ekleyin. Az miktarda bile güçlü renk ve aroma verir.', 3),
  ('Saklama', 'Hava geçirmez kavanozda, ışıktan uzak ve serin ortamda saklayın. Bu şekilde 2-3 yıl kalitesini korur.', 4)
) as x(title, description, sort_order)
where p.slug = 'karabuk-safrani';

-- Galeri
insert into public.gallery_images (product_id, image, caption, sort_order)
select p.id, x.image, x.caption, x.sort_order
from public.products p
cross join (
  values
  ('assets/resim1.jpg', 'Safran Çiçeği', 1),
  ('assets/resim2.jpg', 'Kırmızı İplikler', 2),
  ('assets/resim3.jpg', 'Sunum', 3),
  ('assets/resim4.jpg', 'Hasat', 4),
  ('assets/resim5.jpg', 'Premium Ürün', 5),
  ('assets/resim6.jpg', 'Detay Kare', 6)
) as x(image, caption, sort_order)
where p.slug = 'karabuk-safrani';

-- Form ürün seçenekleri
insert into public.product_options (product_id, name, image, description, sort_order)
select p.id, x.name, x.image, x.description, x.sort_order
from public.products p
cross join (
  values
  ('Safran İplik', 'assets/safran_iplik.png', 'Yoğun aroma ve premium kalite', 1),
  ('Safran Çiçek', 'assets/safran_cicek.png', 'Doğal görünüm ve zarif sunum', 2),
  ('Safran Soğanı', 'assets/safran_sogani.png', 'Dikim için özel talep', 3)
) as x(name, image, description, sort_order)
where p.slug = 'karabuk-safrani';

-- Paket seçenekleri
insert into public.package_options (product_id, name, image, description, sort_order)
select p.id, x.name, x.image, x.description, x.sort_order
from public.products p
cross join (
  values
  ('Karton Paket', 'assets/safran_karton_paket.png', 'Şık kutulu sunum', 1),
  ('Plastik Paket', 'assets/safran_plastik_paket.png', 'Pratik ve hafif', 2),
  ('Cam Kavanoz', 'assets/safran_kavanoz.png', 'Premium kavanoz sunum', 3)
) as x(name, image, description, sort_order)
where p.slug = 'karabuk-safrani';

-- Gramaj seçenekleri
insert into public.weight_options (product_id, label, sort_order)
select p.id, x.label, x.sort_order
from public.products p
cross join (
  values
  ('1 gr', 1),
  ('2 gr', 2),
  ('5 gr', 3),
  ('10 gr', 4),
  ('25 gr', 5),
  ('50 gr', 6),
  ('100 gr', 7)
) as x(label, sort_order)
where p.slug = 'karabuk-safrani';



-------------
-- The House of Anatolia - Supabase PostgreSQL Schema
-- Adım 2: Supabase veritabanı tabloları + güvenli RLS politikaları
-- Bu dosyayı Supabase > SQL Editor > New query alanında çalıştıracağız.

-- Gerekli extension
create extension if not exists pgcrypto;

-- updated_at otomatik güncelleme fonksiyonu
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- -------------------------------------------------------
-- 1) Admin kullanıcıları
-- -------------------------------------------------------
create table if not exists public.admins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null unique,
  role text not null default 'admin' check (role in ('super_admin', 'admin', 'editor')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

drop trigger if exists trg_admins_updated_at on public.admins;
create trigger trg_admins_updated_at
before update on public.admins
for each row execute function public.set_updated_at();

alter table public.admins enable row level security;


-- Admin kontrol fonksiyonu
-- Admin paneli için ileride Supabase Auth kullanacağız.
-- auth.uid() ile admins.user_id eşleşirse yönetim izni olacak.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admins
    where user_id = auth.uid()
      and is_active = true
  );
$$;

drop policy if exists "Admins can read admins" on public.admins;
create policy "Admins can read admins"
on public.admins for select
to authenticated
using (public.is_admin());

drop policy if exists "Admins can manage admins" on public.admins;
create policy "Admins can manage admins"
on public.admins for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 2) Şehirler
-- svg_id haritadaki path id: TR78, TR37 gibi.
-- is_active: hover kartı gösterilsin mi?
-- is_clickable: ürün sayfasına tıklanabilsin mi?
-- -------------------------------------------------------
create table if not exists public.cities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  plate_code text not null unique,
  svg_id text not null unique,
  is_active boolean not null default false,
  is_clickable boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

drop trigger if exists trg_cities_updated_at on public.cities;
create trigger trg_cities_updated_at
before update on public.cities
for each row execute function public.set_updated_at();

alter table public.cities enable row level security;

drop policy if exists "Public can read active cities" on public.cities;
create policy "Public can read active cities"
on public.cities for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage cities" on public.cities;
create policy "Admins can manage cities"
on public.cities for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 3) Ürünler
-- -------------------------------------------------------
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  city_id uuid not null references public.cities(id) on delete cascade,
  name text not null,
  slug text not null unique,
  short_name text not null,
  mini_image text,
  hero_image text,
  parts_main_image text,
  hero_badge text,
  hero_title text not null,
  hero_subtitle text,
  hero_left_text text,
  hero_right_text text,
  meta_description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_products_city_id on public.products(city_id);
create index if not exists idx_products_slug on public.products(slug);

drop trigger if exists trg_products_updated_at on public.products;
create trigger trg_products_updated_at
before update on public.products
for each row execute function public.set_updated_at();

alter table public.products enable row level security;

drop policy if exists "Public can read active products" on public.products;
create policy "Public can read active products"
on public.products for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage products" on public.products;
create policy "Admins can manage products"
on public.products for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 4) Ürün kısımları
-- -------------------------------------------------------
create table if not exists public.product_parts (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  title text not null,
  subtitle text,
  description text not null,
  image text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_product_parts_product_id on public.product_parts(product_id);

drop trigger if exists trg_product_parts_updated_at on public.product_parts;
create trigger trg_product_parts_updated_at
before update on public.product_parts
for each row execute function public.set_updated_at();

alter table public.product_parts enable row level security;

drop policy if exists "Public can read active product parts" on public.product_parts;
create policy "Public can read active product parts"
on public.product_parts for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage product parts" on public.product_parts;
create policy "Admins can manage product parts"
on public.product_parts for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 5) Kullanım rehberi adımları
-- -------------------------------------------------------
create table if not exists public.usage_steps (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  title text not null,
  description text not null,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_usage_steps_product_id on public.usage_steps(product_id);

drop trigger if exists trg_usage_steps_updated_at on public.usage_steps;
create trigger trg_usage_steps_updated_at
before update on public.usage_steps
for each row execute function public.set_updated_at();

alter table public.usage_steps enable row level security;

drop policy if exists "Public can read active usage steps" on public.usage_steps;
create policy "Public can read active usage steps"
on public.usage_steps for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage usage steps" on public.usage_steps;
create policy "Admins can manage usage steps"
on public.usage_steps for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 6) Galeri görselleri
-- -------------------------------------------------------
create table if not exists public.gallery_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  image text not null,
  caption text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_gallery_images_product_id on public.gallery_images(product_id);

drop trigger if exists trg_gallery_images_updated_at on public.gallery_images;
create trigger trg_gallery_images_updated_at
before update on public.gallery_images
for each row execute function public.set_updated_at();

alter table public.gallery_images enable row level security;

drop policy if exists "Public can read active gallery images" on public.gallery_images;
create policy "Public can read active gallery images"
on public.gallery_images for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage gallery images" on public.gallery_images;
create policy "Admins can manage gallery images"
on public.gallery_images for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 7) Formdaki ürün seçenekleri
-- -------------------------------------------------------
create table if not exists public.product_options (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  name text not null,
  image text,
  description text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_product_options_product_id on public.product_options(product_id);

drop trigger if exists trg_product_options_updated_at on public.product_options;
create trigger trg_product_options_updated_at
before update on public.product_options
for each row execute function public.set_updated_at();

alter table public.product_options enable row level security;

drop policy if exists "Public can read active product options" on public.product_options;
create policy "Public can read active product options"
on public.product_options for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage product options" on public.product_options;
create policy "Admins can manage product options"
on public.product_options for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 8) Paket seçenekleri
-- -------------------------------------------------------
create table if not exists public.package_options (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  name text not null,
  image text,
  description text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_package_options_product_id on public.package_options(product_id);

drop trigger if exists trg_package_options_updated_at on public.package_options;
create trigger trg_package_options_updated_at
before update on public.package_options
for each row execute function public.set_updated_at();

alter table public.package_options enable row level security;

drop policy if exists "Public can read active package options" on public.package_options;
create policy "Public can read active package options"
on public.package_options for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage package options" on public.package_options;
create policy "Admins can manage package options"
on public.package_options for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 9) Gramaj seçenekleri
-- -------------------------------------------------------
create table if not exists public.weight_options (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  label text not null,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_weight_options_product_id on public.weight_options(product_id);

drop trigger if exists trg_weight_options_updated_at on public.weight_options;
create trigger trg_weight_options_updated_at
before update on public.weight_options
for each row execute function public.set_updated_at();

alter table public.weight_options enable row level security;

drop policy if exists "Public can read active weight options" on public.weight_options;
create policy "Public can read active weight options"
on public.weight_options for select
to anon, authenticated
using (is_active = true);

drop policy if exists "Admins can manage weight options" on public.weight_options;
create policy "Admins can manage weight options"
on public.weight_options for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 10) Gelen teklif talepleri
-- Güvenlik notu:
-- Bu tablo public insert'e kapalı.
-- Form kayıtlarını ileride Next.js API route / server action üzerinden,
-- Supabase service role key ile güvenli şekilde yazacağız.
-- -------------------------------------------------------
create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  city_id uuid not null references public.cities(id) on delete restrict,
  product_option_id uuid references public.product_options(id) on delete set null,
  package_option_id uuid references public.package_options(id) on delete set null,
  weight_option_id uuid references public.weight_options(id) on delete set null,
  quantity int,
  request_type text,
  full_name text not null,
  company text,
  email text not null,
  phone text not null,
  delivery_location text,
  message text,
  status text not null default 'new' check (status in ('new','contacted','quoted','completed','cancelled')),
  ip_address text,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create index if not exists idx_requests_status on public.requests(status);
create index if not exists idx_requests_created_at on public.requests(created_at);
create index if not exists idx_requests_product_id on public.requests(product_id);

drop trigger if exists trg_requests_updated_at on public.requests;
create trigger trg_requests_updated_at
before update on public.requests
for each row execute function public.set_updated_at();

alter table public.requests enable row level security;

drop policy if exists "Admins can read requests" on public.requests;
create policy "Admins can read requests"
on public.requests for select
to authenticated
using (public.is_admin());

drop policy if exists "Admins can update requests" on public.requests;
create policy "Admins can update requests"
on public.requests for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- -------------------------------------------------------
-- 11) Başlangıç verileri
-- -------------------------------------------------------

insert into public.cities (name, plate_code, svg_id, is_active, is_clickable, sort_order)
values
('Karabük', '78', 'TR78', true, true, 1),
('Kastamonu', '37', 'TR37', true, false, 2)
on conflict (plate_code) do update set
  name = excluded.name,
  svg_id = excluded.svg_id,
  is_active = excluded.is_active,
  is_clickable = excluded.is_clickable,
  sort_order = excluded.sort_order;

insert into public.products (
  city_id, name, slug, short_name, mini_image, hero_image, parts_main_image,
  hero_badge, hero_title, hero_subtitle, hero_left_text, hero_right_text,
  meta_description, is_active
)
select
  c.id,
  'Karabük Safranı',
  'karabuk-safrani',
  'Safran',
  'assets/mini_safran.png',
  'assets/safran-cicegi.png',
  'assets/safran_soganli.png',
  'Karabük • Coğrafi İşaretli Ürün',
  'Karabük Safranı',
  'Karabük’ün coğrafi işaretli en zarif değeri',
  'SAF',
  'RAN',
  'Karabük Safranı için coğrafi işaretli ürün tanıtım ve teklif sayfası.',
  true
from public.cities c
where c.plate_code = '78'
on conflict (slug) do update set
  city_id = excluded.city_id,
  name = excluded.name,
  short_name = excluded.short_name,
  mini_image = excluded.mini_image,
  hero_image = excluded.hero_image,
  parts_main_image = excluded.parts_main_image,
  hero_badge = excluded.hero_badge,
  hero_title = excluded.hero_title,
  hero_subtitle = excluded.hero_subtitle,
  hero_left_text = excluded.hero_left_text,
  hero_right_text = excluded.hero_right_text,
  meta_description = excluded.meta_description,
  is_active = excluded.is_active;

insert into public.products (
  city_id, name, slug, short_name, mini_image, hero_image, parts_main_image,
  hero_badge, hero_title, hero_subtitle, hero_left_text, hero_right_text,
  meta_description, is_active
)
select
  c.id,
  'Kastamonu Sarımsağı',
  'kastamonu-sarimsagi',
  'Sarımsak',
  'assets/mini_sarimsak.png',
  'assets/sarimsak.png',
  'assets/sarimsak.png',
  'Kastamonu • Coğrafi İşaretli Ürün',
  'Kastamonu Sarımsağı',
  'Kastamonu’nun güçlü aromalı coğrafi işaretli ürünü',
  'SARI',
  'MSAK',
  'Kastamonu Sarımsağı için coğrafi işaretli ürün tanıtım ve teklif sayfası.',
  true
from public.cities c
where c.plate_code = '37'
on conflict (slug) do update set
  city_id = excluded.city_id,
  name = excluded.name,
  short_name = excluded.short_name,
  mini_image = excluded.mini_image,
  hero_image = excluded.hero_image,
  parts_main_image = excluded.parts_main_image,
  hero_badge = excluded.hero_badge,
  hero_title = excluded.hero_title,
  hero_subtitle = excluded.hero_subtitle,
  hero_left_text = excluded.hero_left_text,
  hero_right_text = excluded.hero_right_text,
  meta_description = excluded.meta_description,
  is_active = excluded.is_active;

-- Karabük Safranı örnek ürün kısımları
insert into public.product_parts (product_id, title, subtitle, description, image, sort_order)
select p.id, x.title, x.subtitle, x.description, x.image, x.sort_order
from public.products p
cross join (
  values
  ('İplik', 'Yoğun Aroma', 'Safranın en değerli kısmı, elde özenle ayrılan kırmızı ipliklerdir. Renk gücü, karakteristik aroma ve premium algı bu ince liflerde toplanır.', 'assets/safran_iplik.png', 1),
  ('Çiçek', 'Zarif Görünüm', 'Mor çiçek, ürünün en dikkat çekici yüzüdür. Marka dili, görsel anlatım ve sunum estetiği açısından safranın en güçlü sahnesini oluşturur.', 'assets/safran_cicek.png', 2),
  ('Soğan', 'Üretim Döngüsü', 'Toprak altında yer alan soğan yapısı, yetiştiricilik ve çoğaltma sürecinin temelidir.', 'assets/safran_sogani.png', 3)
) as x(title, subtitle, description, image, sort_order)
where p.slug = 'karabuk-safrani';

-- Karabük Safranı kullanım rehberi
insert into public.usage_steps (product_id, title, description, sort_order)
select p.id, x.title, x.description, x.sort_order
from public.products p
cross join (
  values
  ('Hazırlama', '4-6 iplik safranı küçük bir kaba alın. Üzerine 3-4 yemek kaşığı ılık su veya süt dökün. 20-30 dakika bekletin.', 1),
  ('Demlenme', 'Safranın altın sarısı rengi ve eşsiz kokusu suyun içine geçer. Bu safran suyu tarifinize eklenmeye hazırdır.', 2),
  ('Kullanım', 'Pirinç, çorba, çay, tatlı veya et yemeklerine ekleyin. Az miktarda bile güçlü renk ve aroma verir.', 3),
  ('Saklama', 'Hava geçirmez kavanozda, ışıktan uzak ve serin ortamda saklayın. Bu şekilde 2-3 yıl kalitesini korur.', 4)
) as x(title, description, sort_order)
where p.slug = 'karabuk-safrani';

-- Galeri
insert into public.gallery_images (product_id, image, caption, sort_order)
select p.id, x.image, x.caption, x.sort_order
from public.products p
cross join (
  values
  ('assets/resim1.jpg', 'Safran Çiçeği', 1),
  ('assets/resim2.jpg', 'Kırmızı İplikler', 2),
  ('assets/resim3.jpg', 'Sunum', 3),
  ('assets/resim4.jpg', 'Hasat', 4),
  ('assets/resim5.jpg', 'Premium Ürün', 5),
  ('assets/resim6.jpg', 'Detay Kare', 6)
) as x(image, caption, sort_order)
where p.slug = 'karabuk-safrani';

-- Form ürün seçenekleri
insert into public.product_options (product_id, name, image, description, sort_order)
select p.id, x.name, x.image, x.description, x.sort_order
from public.products p
cross join (
  values
  ('Safran İplik', 'assets/safran_iplik.png', 'Yoğun aroma ve premium kalite', 1),
  ('Safran Çiçek', 'assets/safran_cicek.png', 'Doğal görünüm ve zarif sunum', 2),
  ('Safran Soğanı', 'assets/safran_sogani.png', 'Dikim için özel talep', 3)
) as x(name, image, description, sort_order)
where p.slug = 'karabuk-safrani';

-- Paket seçenekleri
insert into public.package_options (product_id, name, image, description, sort_order)
select p.id, x.name, x.image, x.description, x.sort_order
from public.products p
cross join (
  values
  ('Karton Paket', 'assets/safran_karton_paket.png', 'Şık kutulu sunum', 1),
  ('Plastik Paket', 'assets/safran_plastik_paket.png', 'Pratik ve hafif', 2),
  ('Cam Kavanoz', 'assets/safran_kavanoz.png', 'Premium kavanoz sunum', 3)
) as x(name, image, description, sort_order)
where p.slug = 'karabuk-safrani';

-- Gramaj seçenekleri
insert into public.weight_options (product_id, label, sort_order)
select p.id, x.label, x.sort_order
from public.products p
cross join (
  values
  ('1 gr', 1),
  ('2 gr', 2),
  ('5 gr', 3),
  ('10 gr', 4),
  ('25 gr', 5),
  ('50 gr', 6),
  ('100 gr', 7)
) as x(label, sort_order)
where p.slug = 'karabuk-safrani';

----------
update public.admins
set 
  user_id = (
    select id 
    from auth.users 
    where email = 'beyzata37@gmail.com'
    limit 1
  ),
  is_active = true,
  role = 'super_admin'
where email = 'beyzata37@gmail.com';
----
drop policy if exists "Admins can read admins" on public.admins;

create policy "Admins can read own admin row"
on public.admins
for select
to authenticated
using (user_id = auth.uid());
---------
-- Admin panelin admins tablosunu okuyabilmesi için izin
grant usage on schema public to authenticated;
grant select on table public.admins to authenticated;

-- Admin panel şehirleri okuyup güncelleyebilsin
grant select, update on table public.cities to authenticated;

-- Admin panel ürünleri okuyabilsin
grant select on table public.products to authenticated;
grant select on table public.product_parts to authenticated;
grant select on table public.usage_steps to authenticated;
grant select on table public.gallery_images to authenticated;
grant select on table public.product_options to authenticated;
grant select on table public.package_options to authenticated;
grant select on table public.weight_options to authenticated;

-- Admin kendi admin kaydını okuyabilsin
drop policy if exists "Admins can read admins" on public.admins;
drop policy if exists "Admins can read own admin row" on public.admins;

create policy "Authenticated user can read own admin row"
on public.admins
for select
to authenticated
using (user_id = auth.uid());

-- Admin olan kişi şehirleri güncelleyebilsin
drop policy if exists "Admins can manage cities" on public.cities;

create policy "Admins can manage cities"
on public.cities
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());
------
delete from public.weight_options a
using public.weight_options b
where a.product_id = b.product_id
  and a.label = b.label
  and a.sort_order = b.sort_order
  and a.created_at > b.created_at;

create unique index if not exists unique_weight_option_per_product
on public.weight_options(product_id, label, sort_order);

---
-- Ziyaretçilerin teklif formu gönderebilmesi için sınırlı insert izni

grant usage on schema public to anon, authenticated;

grant insert on table public.requests to anon, authenticated;

drop policy if exists "Public can create request" on public.requests;

create policy "Public can create request"
on public.requests
for insert
to anon, authenticated
with check (
  full_name is not null
  and length(trim(full_name)) >= 2
  and email is not null
  and email like '%@%'
  and phone is not null
  and length(trim(phone)) >= 7
  and product_id is not null
  and city_id is not null
);
-------
-- Admin panelin ürünleri güncelleyebilmesi için izinler
grant select, insert, update, delete on table public.products to authenticated;
grant select, insert, update, delete on table public.product_parts to authenticated;
grant select, insert, update, delete on table public.usage_steps to authenticated;
grant select, insert, update, delete on table public.gallery_images to authenticated;
grant select, insert, update, delete on table public.product_options to authenticated;
grant select, insert, update, delete on table public.package_options to authenticated;
grant select, insert, update, delete on table public.weight_options to authenticated;

-- PRODUCTS policy
drop policy if exists "Admins can manage products" on public.products;

create policy "Admins can manage products"
on public.products
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- PRODUCT PARTS policy
drop policy if exists "Admins can manage product parts" on public.product_parts;

create policy "Admins can manage product parts"
on public.product_parts
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- USAGE STEPS policy
drop policy if exists "Admins can manage usage steps" on public.usage_steps;

create policy "Admins can manage usage steps"
on public.usage_steps
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- GALLERY policy
drop policy if exists "Admins can manage gallery images" on public.gallery_images;

create policy "Admins can manage gallery images"
on public.gallery_images
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- PRODUCT OPTIONS policy
drop policy if exists "Admins can manage product options" on public.product_options;

create policy "Admins can manage product options"
on public.product_options
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- PACKAGE OPTIONS policy
drop policy if exists "Admins can manage package options" on public.package_options;

create policy "Admins can manage package options"
on public.package_options
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- WEIGHT OPTIONS policy
drop policy if exists "Admins can manage weight options" on public.weight_options;

create policy "Admins can manage weight options"
on public.weight_options
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());
-------
-- Ana sayfa / site ayarları için tablolar

create table if not exists public.site_settings (
  id uuid primary key default gen_random_uuid(),
  setting_key text not null unique,
  setting_value text,
  setting_type text not null default 'text',
  label text,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create table if not exists public.homepage_sections (
  id uuid primary key default gen_random_uuid(),
  section_key text not null unique,
  title text,
  subtitle text,
  content text,
  image text,
  button_text text,
  button_link text,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- updated_at triggerları
drop trigger if exists trg_site_settings_updated_at on public.site_settings;
create trigger trg_site_settings_updated_at
before update on public.site_settings
for each row execute function public.set_updated_at();

drop trigger if exists trg_homepage_sections_updated_at on public.homepage_sections;
create trigger trg_homepage_sections_updated_at
before update on public.homepage_sections
for each row execute function public.set_updated_at();

-- RLS aç
alter table public.site_settings enable row level security;
alter table public.homepage_sections enable row level security;

-- Okuma izinleri
grant select on table public.site_settings to anon, authenticated;
grant select on table public.homepage_sections to anon, authenticated;

-- Admin yönetim izinleri
grant select, insert, update, delete on table public.site_settings to authenticated;
grant select, insert, update, delete on table public.homepage_sections to authenticated;

-- Public aktif site ayarlarını okuyabilir
drop policy if exists "Public can read site settings" on public.site_settings;
create policy "Public can read site settings"
on public.site_settings
for select
to anon, authenticated
using (true);

-- Public aktif ana sayfa bölümlerini okuyabilir
drop policy if exists "Public can read active homepage sections" on public.homepage_sections;
create policy "Public can read active homepage sections"
on public.homepage_sections
for select
to anon, authenticated
using (is_active = true);

-- Admin site ayarlarını yönetebilir
drop policy if exists "Admins can manage site settings" on public.site_settings;
create policy "Admins can manage site settings"
on public.site_settings
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- Admin ana sayfa bölümlerini yönetebilir
drop policy if exists "Admins can manage homepage sections" on public.homepage_sections;
create policy "Admins can manage homepage sections"
on public.homepage_sections
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- Başlangıç site ayarları
-- NOT: on conflict do nothing — mevcut değerleri override etme (kullanıcı admin'den
-- güncellemiş olabilir). Sadece ilk kurulumda default değerler eklenir.
insert into public.site_settings (setting_key, setting_value, setting_type, label, sort_order)
values
('site_name', 'The House of Anatolia', 'text', 'Site Adı', 1),
('map_slogan', 'A Journey to the Roots of Taste', 'text', 'Harita Üstü Slogan', 2),
('contact_email', 'thehouseofanatoliaco@gmail.com', 'text', 'E-posta', 3),
('contact_phone', '+90 538 331 03 76', 'text', 'Telefon', 4),
('contact_whatsapp', '', 'text', 'WhatsApp', 5),
('contact_address', 'Türkiye', 'textarea', 'Adres', 6),
('instagram_url', '', 'text', 'Instagram URL', 7),
('footer_text', '© 2026 The House of Anatolia. Tüm hakları saklıdır.', 'text', 'Footer Yazısı', 8)
on conflict (setting_key) do nothing;

-- Başlangıç ana sayfa bölümleri
-- Sadece "about" (Hikayemiz) row'u eklenir. vision/contact frontend'de gösterilmiyor.
-- on conflict do nothing — mevcut admin tarafından düzenlenen değerleri override etme.
insert into public.homepage_sections (
  section_key, title, subtitle, content, image, button_text, button_link, is_active, sort_order
)
values
(
  'about',
  'Hikayemiz',
  'Anadolu’nun köklü lezzetlerini dijital dünyaya taşıyoruz.',
  'The House of Anatolia, Türkiye’nin coğrafi işaretli ürünlerini estetik, güvenilir ve erişilebilir bir dijital deneyimle tanıtmayı hedefler.',
  '',
  '',
  '',
  true,
  1
)
on conflict (section_key) do nothing;

  ------
  grant select, insert, update, delete on table public.cities to authenticated;

drop policy if exists "Admins can manage cities" on public.cities;

create policy "Admins can manage cities"
on public.cities
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());
-----
