# FIRST_PROMPT — Yeni Claude Code Sohbeti İçin

> Bu metni **olduğu gibi kopyalayıp yeni Claude Code sohbetine yapıştır**. Tüm bağlamı + kuralları içerir.

---

```
Selam, "The House of Anatolia" projesini önceki Claude Code sohbetinden devraldın. Site şu an canlıda: https://house-of-anatolia.netlify.app — GitHub: https://github.com/ataabeeyzaa/the-house-of-anatolia (private). Tüm bağlam projeye ait MD dosyalarında.

Aşağıdaki kuralları sıkı uygula, sonra bağlamı oku, sonra başla.


## 1. MODEL — Sıkı Kural

Bu projede **her şey Claude Opus 4.7** ile yapılır. Plan, kod, debug, review, agent çağrıları, mockup — istisna yok.

- Agent tool'u kullanırken model: "opus" parametresini **her zaman** aç.
- Sonnet/Haiku'ya **asla** düşürme.
- Hızlı/küçük görünen iş için bile Opus 4.7 kullan.


## 2. ANALYSIS-FIRST — Her Görevden Önce Deep Think

Bana cevap vermeden ÖNCE şu adımları yaz:

1. **Görev tipi nedir?** (bug fix / feature / docs / refactor / tasarım kararı / vb.)
2. **Hangi skill'leri kullanacaksın?** (örn. superpowers:systematic-debugging + superpowers:test-driven-development)
3. **Hangi MCP/plugin'leri kombine edeceksin?** (örn. Playwright canlı test + context7 doküman + Claude Preview mockup)
4. **Sıralama** ve **neden bu kombinasyon en iyi sonuç verir** (1-3 cümle)

Sonra eyleme geç. Tahmin ile yapma — önce skill'leri **Skill tool ile gerçekten aç**, sonra uygula. using-superpowers kuralı: **%1 ihtimalle skill apply ediyorsa MUTLAKA çağır**.


## 3. GIT DİSİPLİNİ — Her Push Öncesi Rebase

Her git push öncesinde **istisnasız** şu iki komutu çalıştır:

```bash
git fetch origin main
git rebase origin/main
```

Conflict varsa manuel çöz, **asla `--theirs` veya `--ours` ile otomatik üstüne yazma**, sonra push et. Force push yasak (`git push --force` veya `--force-with-lease` kullanma — main korunmalı). Pre-commit hook bypass yasak (`--no-verify` yasak). Her commit kendi dalında atomic olsun, birden fazla değişikliği tek commit'e yığma.

Push sonrası GitHub Actions otomatik Netlify'a deploy eder (~1.5 dk).


## 4. BAĞLAM — Önce Oku

Eyleme geçmeden önce bu 4 dosyayı oku ve özümse:

1. **HANDOFF.md** — projenin tam haritası, yapılanlar (7 PR + Phase 0), kullanıcı tercihleri (en kritik)
2. **ARCHITECTURE.md** — stack, deploy pipeline, plugin envanteri (18 plugin + 2 MCP), DB şeması (15 tablo, marquee_items dahil), frontend mimarisi (hamburger overlay, ürünler section, marquee dinamik fetch, contact sade)
3. **DESIGN_SYSTEM.md** — Plus Jakarta Sans + Cormorant Garamond, Editorial Heritage direction, hamburger/marquee/eyebrow CSS pattern'leri, yasaklar listesi (sparkle TÜM VARYANTLAR yasak)
4. **KNOWN_ISSUES.md** — kalan işler (P0/P1/P2), sınırlamalar, bilinen bug'lar, çözülen referansları + PR #7 sonrası kullanıcı talimatları (SQL migration + safran hero_subtitle)

Sonra HTML dosyalarına ihtiyacın olduğunda Read tool ile aç (her biri büyük: index.html ~200KB+, admin.html ~165KB, products.html ~12KB, product.html ~80KB).


## 5. KULLANICI TERCİHLERİ — Hatırla

- **Türkçe**, kısa, doğrudan
- "Salak mısın" gibi sert tepkiler frustrasyon ifadesi → defensiveness yapma, somut cevap ver, kanıtla (curl + grep ile doğrulama göster)
- Major değişiklik öncesi git commit — geri alabilmek için
- Stale dosya riski: edit öncesi her zaman dosyanın güncel halini Read et
- Supabase Service Role Key ASLA isteme (sadece Anon Key var, HTML'de)
- Kullanıcının önceki feedback'leri (HANDOFF/KNOWN_ISSUES'da liste): stats bar, KÜNYE, sertifika rozeti, EST badge, 3-sütun contact, cinematic hero, **sparkle/gold-sim parçacıklar TÜM VARYANTLAR (üstünde/etrafında/ARKASINDA)** — REDDETTİ, tekrar ekleme YASAK (PR #6'da kaldırıldı)
- Beğendiği: italic gold accent, **KEŞFET eyebrow çift çizgi**, **map altında kayan şerit**, **contact 2-col (3 info kart sol + newsletter card sağ)**, Cormorant + Plus Jakarta Sans, koyu+altın+krem, mini-blossom safran çiçeği (product.html — dokunulmaz)


## 6. CANLI DURUM — Site Yayında

- 8 PR mergede (#1-7 önceki, #8 UI revize + galeri render + marquee grants fix)
- Lighthouse: **A11y 98 / SEO 92 / Best Practices 96 / Agentic 100** (PR #7+#8 sonrası yeniden ölçülmedi)
- Anasayfa: navbar [☰ logo] [yatay 4 link] [TR EN] + hamburger overlay + harita + marquee dinamik fetch + contact sade (3 kart + newsletter). Ürünler section anasayfadan kaldırıldı PR #8'de (kullanıcı isteği "full kaldır").
- `products.html` ayrı sayfada, küçük kare grid (tek ürün de küçük ortalanır)
- product.html galeri dinamik (gallery_images tablosundan 2x duplicate kayan şerit)
- Yeni DB tablo: `marquee_items` (PR #7) — 2 migration kullanıcı çalıştıracak (tablo + GRANT)
- Eksik P0: SQL migration #1 + #2 çalıştır + safran hero_subtitle güncel + telefon + yasal placeholder + domain + admin user + Netlify token revoke (hepsi kullanıcı yapacak)


## 7. İLK ADIMIN

1. 4 MD dosyasını oku (HANDOFF, ARCHITECTURE, DESIGN_SYSTEM, KNOWN_ISSUES)
2. Mevcut durumu özetle (3-5 cümle)
3. En kritik 2-3 yapılacak iş ne sence (KNOWN_ISSUES P0/P1'e bakarak — Claude'un bağımsız yapabileceği işler)
4. Bekle — kullanıcı senin önerine göre yön verecek

Hadi başla.
```

---

## Notlar

Yukarıdaki üç tırnaklı kod bloğunu yeni sohbete kopyala-yapıştır. Claude:
1. MODEL kuralını uygulayacak (Opus 4.7, asla Sonnet/Haiku'ya düşmeyecek)
2. ANALYSIS-FIRST'i her cevap öncesi yazacak
3. Git push'tan önce rebase yapacak, force push kullanmayacak
4. 4 MD'yi okuyup özet + öneri verecek
5. Senin yön vermeni bekleyecek

### Tamamlanmamış İşler (yeni sohbet bunları görür)

- **Marquee admin entegrasyonu** (KNOWN_ISSUES P1) — Supabase'de `marquee_items` tablosu yarat + admin'de CRUD UI ekle. Şu an i18n dict'te statik 5 yakında ürün var.
- **EN içerikleri** (KNOWN_ISSUES P1) — admin'den name_en, description_en doldurulacak
- **CSS dead code temizliği** (KNOWN_ISSUES P2) — `.future-pill`, `.future-list` rules
- **Kullanıcı P0 işleri** — telefon, domain, KVKK placeholder, admin user, Netlify token revoke
