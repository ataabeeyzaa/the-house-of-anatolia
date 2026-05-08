# Spec — PR #7 Mega: Hamburger + Ürünler section + Marquee admin + product.html refresh

> **Tarih:** 2026-05-08
> **Branch:** claude/elegant-saha-adf877 (worktree reused)
> **Origin:** Kullanıcı talebi (8 madde toplu)

## Kapsam

8 değişiklik atomic commit'lerle:

1. **Anasayfa contact sadeleştir** — SOL kolon eyebrow+başlık+intro kalkar; sadece 3 kart kalır; SAĞ newsletter aynen, hizalama dengeli
2. **Anasayfa "Ürünler" section ekle** — Supabase fetch is_active=true; küçük kart grid; "Tümünü Gör →" /products.html
3. **Hamburger menü (Aesop pattern)** — Navbar minimal: [Logo] [☰] [TR/EN]; yatay nav linkleri overlay'e taşınır; overlay içinde Sayfalar + dinamik Ürünler kategorisi (Supabase fetch) + lang switcher + yasal linkler
4. **product.html "Karabük'ün" → "Safranbolu'nun"** — TR+EN tüm GI cümleleri (il adı/adres'te Karabük kalır)
5. **product.html alt contact** — tipografik 3 sütun → anasayfa `.contact-info-card` stilinde 3 yatay kart (mobile dikey)
6. **Marquee admin entegrasyonu**
   - Supabase tablo `marquee_items` (label_tr, label_en, sort_order, is_active, created_at) + RLS (anon read is_active=true, admin all)
   - Default 5 row insert (mevcut yakındalar)
   - Frontend: i18n statik render → `loadMarqueeItems()` async fetch + render
   - Admin'de yeni "Şerit" sekmesi (CRUD UI)
7. **Ürünler admin teyit** — mevcut admin.html'de ürün CRUD'da is_active toggle var mı? Yoksa eklenir.
8. **Docs sync** (HANDOFF / ARCHITECTURE / DESIGN_SYSTEM / KNOWN_ISSUES / FIRST_PROMPT) + spec güncel + PR + merge + canlı verify

## Yapı kararları

- **Hamburger overlay:** fullscreen + backdrop blur + dark gradient bg; nav-links yatay layout YOK
- **Ürünler section konumu:** map section + marquee strip arasından sonra, about öncesi (marquee → ürünler → about → contact akışı)
- **Ürünler kartı boyutu:** auto-fit minmax(220px, 1fr), aspect-ratio görsel 16/10
- **Marquee dinamik:** `marquee_items` boşsa fallback to i18n statik (defensive)

## Kapsam dışı

- Yeni ürün ekleme (kullanıcı kendi yapacak admin'den)
- Domain bağlama (kullanıcı işi)
- KVKK metinleri doldurma (kullanıcı işi)

## Risk değerlendirmesi

- **Orta:** hamburger menü navbar'ı tamamen değiştirir — yatay nav kaybolur, kullanıcı isterse revert edilebilir
- **Düşük-orta:** Supabase migration `marquee_items` tablo — RLS doğru kurulmazsa data exposure riski (anon SELECT is_active=true filter şart)
- **Düşük:** product.html metin değişikliği — TR+EN i18n keys
- **Düşük:** Anasayfa Ürünler section — products.html ile paralel kod, paylaşılabilir helper fn yapılabilir

## Atomic commit planı

1. `index: contact section sadeleştirildi (sol yazılar kalktı)`
2. `index: Ürünler section eklendi (Supabase fetch + küçük kart grid)`
3. `index: hamburger menü (Aesop pattern fullscreen overlay)`
4. `product: Karabük → Safranbolu (TR/EN GI cümleleri)`
5. `product: alt contact kart stilinde 3 yatay`
6. `db: marquee_items tablosu + RLS + default 5 row`
7. `index: marquee dinamik fetch (Supabase)`
8. `admin: Şerit sekmesi (CRUD)`
9. `admin: ürün is_active toggle teyit/ekle (gerekirse)`
10. `docs: 5 MD + spec güncel`

## Verification

- Lokal: Claude Preview viewport 1440 + 375
- DOM doğrulama: hamburger overlay, ürünler section, marquee fetch, admin tabs
- Supabase MCP doğrulama: marquee_items tablo + RLS policies
- Newsletter form smoke test
- Push öncesi rebase
- Canlı: curl + grep, deploy verify
