# YENİ CLAUDE CODE SOHBETİ — İLK PROMPT

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

1. **HANDOFF.md** — projenin tam haritası, yapılanlar, kullanıcı tercihleri (en kritik)
2. **ARCHITECTURE.md** — stack, deploy pipeline, plugin envanteri (18 plugin), DB şeması
3. **DESIGN_SYSTEM.md** — Plus Jakarta Sans + Cormorant + Editorial Heritage direction, yasaklar listesi
4. **KNOWN_ISSUES.md** — kalan işler, dead code, sınırlamalar

Sonra HTML dosyalarına ihtiyacın olduğunda Read tool ile aç (her biri büyük: index.html ~200KB, admin.html ~168KB).


## 5. KULLANICI TERCIHLERI — Hatırla

- **Türkçe**, kısa, doğrudan
- "Salak mısın" gibi sert tepkiler frustrasyon ifadesi → defensiveness yapma, somut cevap ver, kanıtla (curl + grep ile doğrulama göster)
- Major değişiklik öncesi git commit — geri alabilmek için
- Stale dosya riski: edit öncesi her zaman dosyanın güncel halini Read et
- Supabase Service Role Key ASLA isteme (sadece Anon Key var, HTML'de)
- Kullanıcının önceki feedback'leri (KNOWN_ISSUES'da liste): stats bar, KÜNYE, sertifika rozeti, EST badge, 3-sütun contact, cinematic hero — **REDDETTİ**, tekrar ekleme
- Beğendiği: italic gold accent, sparkle (✦) effect, Cormorant + Plus Jakarta Sans, koyu+altın+krem


## 6. İLK ADIMIN

1. 4 MD dosyasını oku
2. Mevcut durumu özetle (3-5 cümle)
3. En kritik 2-3 yapılacak iş ne sence (KNOWN_ISSUES P0'a bakarak)
4. Bekle — kullanıcı senin önerine göre yön verecek

Hadi başla.
```

---

## 📋 Bu Prompt Neyi İçeriyor

| Bölüm | Amacı |
|---|---|
| **1. MODEL** | Opus 4.7 zorunluluğu, downgrade yasak |
| **2. ANALYSIS-FIRST** | Deep think + skill kullanımı, tahminden kaçınma |
| **3. GIT DİSİPLİNİ** | Rebase before push, force push yasak |
| **4. BAĞLAM** | 4 MD dosya okuma sırası |
| **5. KULLANICI TERCİHLERİ** | Geçmiş feedback ve kişilik |
| **6. İLK ADIM** | Yeni session ne yapacak |

## 🔗 Faydalı Linkler

- **Site:** https://house-of-anatolia.netlify.app
- **GitHub:** https://github.com/ataabeeyzaa/the-house-of-anatolia
- **Netlify:** https://app.netlify.com/projects/house-of-anatolia
- **Supabase:** https://supabase.com/dashboard/project/owcgcyvgibyawxfxwlbn

## ⚠️ Önemli — Bu Prompt'tan Önce

Yeni Claude Code'u açtıktan sonra:

1. `cd C:\Users\User\Downloads\Beyza_project` ile klasöre git
2. `claude` komutuyla session başlat
3. Bu dosyadaki **kod bloğunun içindeki** metni (1.MODEL'den 6.İLK ADIM'ın sonuna kadar) kopyala
4. Yeni sohbete yapıştır + gönder
5. Claude 18 plugin yüklü olarak başlayacak (önceki session'da kuruldular)
6. 4 MD dosyasını okuyacak, durumu özetleyecek, P0 önerileri sunacak
7. Sen yön ver

İyi şanslar! 🌿
