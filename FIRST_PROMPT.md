# FIRST_PROMPT — Yeni Claude Code Sohbeti İçin

> Bu metni **olduğu gibi kopyalayıp yeni Claude Code sohbetine yapıştır**. Tüm bağlamı + kuralları içerir.

---

```
Selam, "The House of Anatolia" projesini önceki Claude Code sohbetinden devraldın. Site şu an canlıda: https://thehouseofanatolia.com — GitHub: https://github.com/ataabeeyzaa/the-house-of-anatolia (PUBLIC repo, GitHub Pages hosting). Tüm bağlam projeye ait MD dosyalarında.

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

Push sonrası **GitHub Pages otomatik deploy** eder (~1-2 dk). Custom domain `thehouseofanatolia.com` Cloudflare DNS üzerinden GitHub Pages IP'lerine bağlı (185.199.108-111.153). HTTPS otomatik (Let's Encrypt). **Netlify ARTIK YOK** — credit limit + contributor sorunu nedeniyle taşındık.


## 4. BAĞLAM — Önce Oku

Eyleme geçmeden önce bu 4 dosyayı oku ve özümse:

1. **HANDOFF.md** — projenin tam haritası, yapılanlar (17 PR + Phase 0), kullanıcı tercihleri (en kritik)
2. **ARCHITECTURE.md** — stack, deploy pipeline (GitHub Pages + Cloudflare), plugin envanteri, DB şeması (16 tablo, marquee_items dahil), frontend mimarisi (hamburger overlay, marquee dinamik, contact sade)
3. **DESIGN_SYSTEM.md** — Plus Jakarta Sans + Cormorant Garamond, Editorial Heritage direction, hamburger/marquee/eyebrow CSS pattern'leri, yasaklar listesi (sparkle TÜM VARYANTLAR yasak)
4. **KNOWN_ISSUES.md** — kalan işler (P0/P1/P2), sınırlamalar, bilinen bug'lar, çözülen referansları + PR #10-17 sonrası kullanıcı talimatları

Sonra HTML dosyalarına ihtiyacın olduğunda Read tool ile aç (her biri büyük: index.html ~210 KB, admin.html ~175 KB, products.html ~12KB, product.html ~80KB).


## 5. KULLANICI TERCİHLERİ — Hatırla

- **Türkçe**, kısa, doğrudan
- "Salak mısın" gibi sert tepkiler frustrasyon ifadesi → defensiveness yapma, somut cevap ver, kanıtla (curl + grep ile doğrulama göster)
- Major değişiklik öncesi git commit — geri alabilmek için
- Stale dosya riski: edit öncesi her zaman dosyanın güncel halini Read et
- **Supabase Service Role Key ASLA isteme** (sadece Anon Key var, HTML'de — RLS korumalı)
- **REPO PUBLIC** — credential, secret, .env asla commit etme. Defensive .gitignore mevcut (.env, *.pem, *.key, secrets.json vb.).
- **Netlify token gibi credential KULLANICIDAN İSTEME**, bana yapıştırırsa derhal revoke etmesini söyle (sızıntı)
- Kullanıcının önceki feedback'leri (HANDOFF/KNOWN_ISSUES'da liste): stats bar, KÜNYE, sertifika rozeti, EST badge, 3-sütun yan yana contact, cinematic hero, **sparkle/gold-sim parçacıklar (TÜM VARYANTLAR)** — REDDETTİ, tekrar ekleme YASAK
- Beğendiği: italic gold accent, **KEŞFET silindi (PR #10) ama eyebrow çift altın çizgi pattern'i kaldı**, **map altında kayan şerit (marquee dinamik)**, **contact 3 info kart sol + newsletter card sağ (sade, başlık yok)**, Cormorant + Plus Jakarta Sans, koyu+altın+krem, mini-blossom safran çiçeği (product.html — dokunulmaz), **hamburger menü ☰ EN SOLDA** + yatay 4 nav link (PR #8)


## 6. CANLI DURUM — Site Yayında

- 17 PR mergede (#1-9 önceki, #10 KEŞFET kaldır + Coğrafi işaret + e-posta gmail + adres Türkiye + tracking validation + admin sil + product hamburger + about DB-bağ, #11 GitHub Actions workflow kaldır, #12-13 deploy trigger commits, #14 GitHub Pages migration + CNAME + URL replace, #15 .gitignore defensive secrets, #16+#17 admin Cloudflare Access entegrasyonu + client gate revert)
- **Hosting:** GitHub Pages (ücretsiz, sınırsız bandwidth) + Cloudflare DNS proxy
- **Custom domain:** thehouseofanatolia.com (HTTPS Let's Encrypt otomatik)
- **Admin koruması:** Cloudflare Zero Trust Access — sadece `thehouseofanatoliaco@gmail.com` ve `beyzata37@gmail.com` email PIN ile admin.html'e erişebilir; rastgele kişi sayfanın HTML'ini bile göremez
- Anasayfa: navbar [☰ logo] [yatay 4 link] [TR EN] + hamburger overlay + harita (sparkle YOK) + marquee dinamik fetch (Supabase marquee_items) + contact sade (3 kart + newsletter, başlık yok)
- E-posta tüm yerlerde: `thehouseofanatoliaco@gmail.com`
- Adres tüm yerlerde: `Türkiye` (sadeleştirilmiş)
- products.html ayrı sayfada, küçük kare grid (auto-fill 240px sabit, tek ürün de küçük ortalanır)
- product.html galeri dinamik (gallery_images tablosundan kayan şerit), navbar hamburger + Haritaya Dön/Teklif Al butonları
- Yeni DB tablo: `marquee_items` (PR #7-9) — 2 SQL migration kullanıcı çalıştırdı (tablo + GRANT)
- **Netlify SİLİNDİ** — artık kullanılmıyor, hesap silinebilir
- Eksik P0: telefon numarası placeholder, yasal sayfa placeholder'ları (KVKK), gerçek şirket bilgisi (kullanıcı yapacak)


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

- **EN içerikleri** (KNOWN_ISSUES P1) — admin'den `name_en`, `description_en` doldurulacak
- **Newsletter SMTP** (KNOWN_ISSUES P1) — abone ekledikçe gönderim için Brevo/Resend entegrasyonu
- **CSS dead code temizliği** (KNOWN_ISSUES P2) — `.future-pill`, `.future-list`, `.contact-footer-col`, `.contact-centered` kalan rule'ları
- **Performans** (KNOWN_ISSUES P1) — image lazy loading audit, font subsetting (Cormorant büyük)
- **Lighthouse re-audit** — PR #10-17 sonrası yeniden ölçüm yapılmadı (önceki: A11y 98 / SEO 92 / BP 96 / Agentic 100)
- **Kullanıcı P0 işleri** — telefon, yasal placeholder doldurma, KVKK avukat danışmanı, şirket kuruluş bekliyor
