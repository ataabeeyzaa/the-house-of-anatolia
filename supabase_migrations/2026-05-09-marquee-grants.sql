-- ============================================================
-- Marquee items — table-level GRANT düzeltmesi
-- 2026-05-09 — PR #8 (önceki migration'a EKLEMEDİR, üzerine yaz)
--
-- Sorun: 2026-05-08 migration RLS + policy yarattı ama Postgres
-- table-level GRANT'leri set etmedi. Anon role tabloya erişemiyor
-- ("permission denied for table marquee_items").
--
-- Çözüm: Anon role'e SELECT, authenticated role'e tam yetki ver.
-- (RLS hâlâ aktif, policy'ler kayıt-level filtreyi koruyor.)
--
-- ÇALIŞTIRMA: Supabase Dashboard → SQL Editor → New query →
-- bu dosyanın içeriğini yapıştır → Run.
-- ============================================================

grant select on table public.marquee_items to anon;
grant select, insert, update, delete on table public.marquee_items to authenticated;

-- Sequence/identity grant gerekmiyor (uuid pk).

-- Doğrulama: aşağıdaki sorguyu çalıştırarak kontrol edebilirsin
-- (SQL Editor'da ayrı bir query):
--
--   select grantee, privilege_type from information_schema.role_table_grants
--   where table_schema='public' and table_name='marquee_items';
--
-- Beklenen satırlar: anon→SELECT, authenticated→SELECT/INSERT/UPDATE/DELETE
