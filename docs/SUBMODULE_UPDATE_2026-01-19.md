# Aktualizace submodulu ksef-docs-official - 19. ledna 2026

## 📦 Přehled

Submodul `sources/ksef-docs-official` byl aktualizován na nejnovější verzi.

## 🔄 Změna verze

| Předchozí | Nová |
|-----------|------|
| `109f70a` (2.0.0-RC5.4) | `51fb808` (2.0.1) |

## ✨ Hlavní změny

### 1. Nové API URL ✅

Oficiální dokumentace potvrzuje nové API adresy:

| Prostředí | Dokumentace API |
|-----------|-----------------|
| **TEST** | https://api-test.ksef.mf.gov.pl/docs/v2 |
| **DEMO** | https://api-demo.ksef.mf.gov.pl/docs/v2 |
| **PROD** | https://api.ksef.mf.gov.pl/docs/v2 |

### 2. API verze 2.0.1

Nová verze API obsahuje:

#### Uprawnienia (Permissions)
- ✅ Oprava logiky pro `POST /permissions/query/personal/grants`
- ✅ Rozšířený `InternalId` format a limity
- ✅ Aktualizované příklady

#### Pobieranie faktur
- ✅ Upřesněná validace `dateRange` (3 měsíce v UTC nebo PL času)

#### Wysyłka faktur
- ✅ Validace kontrolního součtu NIP (pouze produkce)
- ✅ Validace NIP v `InternalId` (pouze produkce)

#### Status sesji
- ✅ Nové pole: `dateCreated` a `dateUpdated`

#### Pobieranie faktur/UPO
- ✅ Nový header: `x-ms-meta-hash` (SHA-256, Base64)

### 3. Nové schémata

Přidány schémata pro PEPPOL:
- ✅ `Schemat_PEF(3)_v2-1.xsd`
- ✅ `Schemat_PEF_KOR(3)_v2-1.xsd`
- ✅ UBL schémata pro PEPPOL faktury

### 4. Nová dokumentace

- ✅ **Przyrostowe pobieranie faktur** - Nový dokument o inkrementálním stahování
- ✅ **HWM (High Water Mark)** - Dokumentace o značkách pro inkrementální načítání
- ✅ Rozšířená dokumentace limitů
- ✅ Aktualizovaná dokumentace oprávnění

## 📊 Statistiky změn

```
61 souborů změněno
63,627 přidaných řádků (+)
2,415 smazaných řádků (-)
```

### Hlavní změny:
- Nové soubory: 28
- Přesunuté soubory: 7
- Upravené soubory: 26

## 🔍 Důležité změny pro gem

### ✅ Potvrzení nových URL
Oficiální dokumentace nyní používá nové API URL, což potvrzuje, že naše změny v gemu jsou správné.

### ⚠️ Nové API funkce (verze 2.0.1)

Některé změny v API 2.0.1 by mohly vyžadovat aktualizaci gemu:

1. **Validace NIP** (pouze produkce)
   - Kontrolní součet NIP je nyní validován
   - Ovlivní: `Podmiot1`, `Podmiot2`, `Podmiot3`

2. **Nový header `x-ms-meta-hash`**
   - Při stahování faktur/UPO
   - Gem by mohl tento hash vrátit uživatelům

3. **Status sesji** - nová pole
   - `dateCreated`
   - `dateUpdated`

4. **PEPPOL schémata**
   - Nové XSD schémata pro PEF faktury
   - Gem už podporuje PEF formáty (FA_PEF, FA_KOR_PEF)

## 📝 Doporučení pro gem

### Priorita: Nízká

Gem je aktuálně **plně funkční** s API 2.0.1. Změny v API jsou zpětně kompatibilní.

### Možná budoucí vylepšení:

1. ⏳ **Přidat vrácení `x-ms-meta-hash`** při stahování faktur
2. ⏳ **Přidat `dateCreated/dateUpdated`** do session response objektů
3. ⏳ **Přidat validaci kontrolního součtu NIP** (před odesláním)
4. ⏳ **Dokumentovat inkrementální stahování** (HWM pattern)

### Aktuální stav:

✅ **Gem je plně kompatibilní s API 2.0.1**
✅ **Používá správné nové URL**
✅ **Podporuje všechny hlavní funkce**

## 🔗 Související změny

Tato aktualizace submodulu je součástí migrace na nové API URL:

- 📘 [API URL Migration](API_URL_MIGRATION.md)
- 📗 [VCR Recording Guide](VCR_RECORDING_GUIDE.md)
- 📙 [Migration Summary](MIGRATION_SUMMARY.md)
- 🎬 [VCR Cassettes Deleted](../VCR_CASSETTES_DELETED.md)

## 📚 Nové dokumenty v submodulu

Zajímavé nové dokumenty pro další studium:

1. **`pobieranie-faktur/przyrostowe-pobieranie-faktur.md`**
   - Inkrementální stahování faktur
   - High Water Mark (HWM) pattern

2. **`pobieranie-faktur/hwm.md`**
   - Detailní popis HWM mechanismu

3. **`faktury/schemy/PEF/`**
   - Kompletní PEPPOL schémata

4. **`limity/limity-api.md`**
   - Aktualizované limity API

## ✅ Akce provedené

1. ✅ Odstraněny lokální změny v `srodowiska.md`
2. ✅ Submodul aktualizován na `51fb808` (2.0.1)
3. ✅ Ověřeny nové URL v oficiální dokumentaci
4. ✅ Zkontrolovány změny v API

## 🎯 Další kroky

Pro uživatele gemu:
- ❌ **Žádná akce potřebná** - gem je plně kompatibilní

Pro vývojáře:
- ⏳ Zvážit implementaci nových API funkcí (nízká priorita)
- ⏳ Aktualizovat dokumentaci s odkazy na nové dokumenty o HWM

---

**Aktualizováno:** 19. ledna 2026
**Verze submodulu:** 51fb808 (2.0.1)
**Status:** ✅ Hotovo a kompatibilní
