# Spec — Contact Re-design + Sparkle Removal

> **Tarih:** 2026-05-08
> **Branch:** claude/elegant-saha-adf877
> **Origin:** Kullanıcı talebi (ekran görüntüsü referans + sparkle kaldır)

## Hedef

3 değişiklik, atomic commit'ler:

1. **Sparkle removal** — index.html harita section'ındaki uçuşan altın parçacıklar tamamen kaldırılır.
2. **Contact section yeniden** — mevcut horizontal 2-col card → 2-col layout (SOL: intro + 3 dikey bilgi kartı / SAĞ: newsletter formu).
3. **Footer newsletter footer'dan kaldırılır** — newsletter contact section'a taşınır, footer-grid 4-col aynen kalır.

## Kapsam Dışı

- Marquee admin entegrasyonu (P1, ayrı PR)
- product.html mini-blossom safran çiçeği (kullanıcı beğeniyor, korunur)
- Yasal placeholder doldurma (kullanıcı yapacak)
- Performance/font subsetting (ayrı PR)
- contact-centered / contact-footer-col CSS (HTML'de kullanım var, dead değil)

## Değişiklikler

### 1. Sparkle Removal

**index.html silinecek:**
- CSS satır 497-533 (.hero-blossom-layer, .gold-sparkle, ::before, ::after, @keyframes sparkle-twinkle, prefers-reduced-motion)
- CSS satır 498 (.map-wrap > svg z-index:1) — sparkle gittikten sonra gerek yok
- HTML satır 1581 (`<div class="hero-blossom-layer" id="blossom-layer">`)
- JS satır 2356-2373 (sparkleEffect IIFE bloğu)

**product.html dokunulmadı (revize karar):**
- Line 136 `.hero-blossom-layer` rule'u mini-blossom safran çiçeği için kapsayıcı OLABİLİR (dosyada usage doğrulanamadı, mini-blossom JS dynamic render edebilir). Risk al ma maktan kaçınıldı, korundu. Mini-blossom kullanıcının beğendiği bir özellik.

### 2. Contact Section Yeniden

**Yeni CSS (1446-1468 yerini alır):**
- `.contact-card` — `grid-template-columns: 1.05fr 1fr; gap: 56px; align-items: start`
- `.contact-info-card` (3 kart) — panel-soft bg, 1px line border, 18px radius, 22px padding, flex (ikon + label/value), hover gold border
- `.contact-info-card .icon` — 40×40 yuvarlak gold-soft glow, içinde 22×22 SVG
- `.contact-newsletter-card` (sağ) — radial gold glow gradient, 22px radius, 36px padding
- Mobile (<980px) → 1-col

**Yeni HTML (1984-2009 yerini alır):**
- SOL kolon: intro-block + 3 div.contact-info-card (e-posta, adres, telefon)
- SAĞ kolon: newsletter-card (form id="newsletter-form" ve status id="newsletter-status" KORUNUR — JS handler aynı çalışır)

**SVG ikonlar:** Heroicons outline, stroke gold-soft, 22×22 — mail/map-pin/phone

### 3. Footer Newsletter Removal

**Sil:**
- CSS 755-816 (.footer-top, .footer-newsletter ve alt rule'lar)
- CSS responsive 904-915 (.footer-newsletter strong/p references)
- CSS 1265-1290 (.footer-newsletter form/button/disabled, .newsletter-status)
- HTML 2015-2025 (`<div class="footer-top">` + içeriği)

**Korunur:**
- footer-grid 4-col layout aynen (brand + sayfalar + yasal + iletişim)
- i18n keys `footer_newsletter_*` (contact'a taşınır, key adları aynı)
- JS handler 2734-2820 (id selectors aynı, kod değişmez)

### 4. Docs Sync (4 MD)

- **HANDOFF.md** — Beğendiği listesinden sparkle çıkar; PR #6 ekle
- **DESIGN_SYSTEM.md** — Sparkle CSS bloğu sil; Contact section güncel layout
- **KNOWN_ISSUES.md** — PR #5 docs ekle (eksik); PR #6 yeni
- **FIRST_PROMPT.md** — sparkle beğendiği listesinden çıkar

## Commit Plan (3 atomic + docs)

1. `sparkle: harita section uçuşan parçacıklar kaldırıldı (index + product)`
2. `contact: 2-col layout — 3 kart sol + newsletter kart sağ; footer newsletter taşındı`
3. `docs: 4 MD güncel — sparkle removal + new contact layout`

## Verification

- Local: Claude Preview viewport 1440 + 375
- Newsletter form smoke test: input doldur → submit → success/error UI
- Lighthouse skoru korunur (A11y ≥98)
- Push öncesi: `git fetch origin main && git rebase origin/main` (zorunlu)
- Force push + `--no-verify` YASAK

## Risk

- **Düşük:** newsletter form id selector'leri aynı, JS handler dokunulmuyor
- **Düşük:** sparkle silme — element/CSS atomik, başka yerde referans yok (grep doğrulandı)
- **Düşük-orta:** contact section CSS yeniden yazılması — sınıf adı çakışması yok (`.contact-info-card`, `.contact-newsletter-card` yeni)

## Implementation Notları (post-completion)

**Beklenmedik bulgular:**

1. **Duplicate `contact_title` (TR i18n):** Contact section üstünde çalışırken tespit edildi — TR I18N içinde aynı key 2 defa tanımlı (line 2077: "Bizimle iletişime geçin." + line 2114: "Bizimle bağlantıya geçin."). JS'te ikinci tanım override eder; canlıda "bağlantıya" görüntülenirken HTML default "iletişime"ydi. Duplicate (line 2114) silindi, "iletişime" geçerli (kullanıcının ekran görüntüsündeki referans metniyle uyumlu).

2. **product.html scope dışı:** Spec başlangıcında "product.html line 136 sparkle CSS rule sil" maddesi vardı. Doğrulama sırasında `.hero-blossom-layer` class adının mini-blossom çiçeği için JS dynamic kapsayıcı olarak kullanılabileceği belirlendi (HTML'de element yok ama JS render risk var). Mini-blossom kullanıcının beğendiği bir özellik olduğu için riske girilmedi.

**Final commit dizisi (atomic):**
- `b7e3d4b` docs: spec yaz + commit
- `d2a8206` sparkle: harita section uçuşan parçacıklar tamamen kaldırıldı (58 satır silindi)
- `152f9a4` contact: 2-col layout — 3 info cards (sol) + newsletter (sağ) (+171/-144)
- (sıradaki commit: docs sync — 5 MD + spec güncel + .gitignore canli-snapshot)
