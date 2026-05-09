-- ============================================================
-- Marquee items — sort_order'ları 1,2,3,... olarak renumber
-- 2026-05-09 — PR #9 (opsiyonel temizlik)
--
-- Sorun: İlk migration default 5 row'u 10/20/30/40/50 olarak
-- ekledi. Kullanıcı 1/2/3 gibi sıralı sayılar istiyor.
--
-- Çözüm: Mevcut satırları sıralı (mevcut sort_order, sonra
-- created_at) row_number ile yeniden numaralandır.
-- Sonuç: 1, 2, 3, 4, 5, ... şeklinde devam eder.
--
-- ÇALIŞTIRMA: Supabase Dashboard → SQL Editor → New query →
-- bu dosyanın içeriğini yapıştır → Run.
--
-- (Opsiyonel — frontend yeni eklemede zaten otomatik max+1
-- artırıyor; bu sadece mevcut data temizliği.)
-- ============================================================

with ranked as (
  select
    id,
    row_number() over (order by sort_order asc nulls last, created_at asc) as new_order
  from public.marquee_items
)
update public.marquee_items mi
   set sort_order = r.new_order
  from ranked r
 where mi.id = r.id
   and mi.sort_order is distinct from r.new_order;

-- Doğrulama (ayrı sorguda çalıştır):
--
--   select sort_order, label_tr from public.marquee_items order by sort_order;
--
-- Beklenen: 1, 2, 3, 4, 5, ... sıralı.
