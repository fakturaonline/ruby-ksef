# Integration Tests

Tato složka obsahuje integrační testy, které testují komunikaci s reálným KSeF API.

## Invoice Sending Test

Test v `invoice_sending_spec.rb` ověřuje celý proces odesílání faktury:

1. **Vytvoření faktury** - Vytvoří validní FA(3) fakturu
2. **Odesílání** - Použije high-level API `client.send_invoice_online(xml)` které automaticky:
   - Získá šifrovací certifikát z KSeF
   - Vygeneruje AES-256 šifrovací klíč
   - Zašifruje klíč pomocí RSA public key
   - Otevře online session se šifrováním
   - Zašifruje fakturu
   - Odešle zašifrovanou fakturu
   - Vrátí reference number

## Použití VCR pro nahrávání HTTP interakcí

Tento projekt používá [VCR gem](https://github.com/vcr/vcr) pro zaznamenávání HTTP interakcí.

### První spuštění (s platným tokenem)

Pro první spuštění potřebujete **platný KSeF token**:

```ruby
# Aktualizujte údaje v testu:
let(:test_nip) { "váš_testovací_nip" }
let(:test_ksef_token) { "váš_platný_token" }
```

Jak získat token:
1. Přihlaste se na https://ksef-test.mf.gov.pl/ (webové rozhraní)
2. Jděte do **Ustawienia** → **Tokeny**
3. Vytvořte nový token s potřebnými oprávněními
4. Token má formát: `datum-typ-číslo|identifikátor|hash`

Pak spusťte test:

```bash
bundle exec rspec spec/integration/invoice_sending_spec.rb
```

VCR automaticky zaznamená všechny HTTP requesty a response do složky:
```
spec/fixtures/vcr_cassettes/invoice_sending/
```

### Další spuštění (bez tokenu)

Po prvním spuštění VCR přehrává zaznamenané HTTP interakce ze souborů.
Test funguje **offline** a není potřeba platný token!

### Citlivá data

VCR automaticky filtruje:
- KSeF tokeny v hlavičkách i v body
- NIP čísla v URL

Tyto hodnoty jsou v cassettes nahrazeny za `<KSEF_TOKEN>` a `<NIP>`.

## Struktura testu

```ruby
describe "sending a valid FA(3) invoice" do
  it "successfully sends an invoice using high-level API" do
    # 1. Vytvoří testovací fakturu
    invoice = create_test_invoice

    # 2. Vygeneruje XML
    xml = invoice.to_xml

    # 3. Odešle fakturu (vše ostatní je automatické!)
    response = client.send_invoice_online(xml)

    # 4. Ověří response
    expect(response).to have_key("referenceNumber")
    expect(response).to have_key("sessionReferenceNumber")
  end
end
```

## Aktualizace VCR cassettes

Pokud potřebujete znovu nahrát HTTP interakce (např. změnilo se API):

1. Smažte staré cassettes:
   ```bash
   rm -rf spec/fixtures/vcr_cassettes/invoice_sending/
   ```

2. Získejte nový platný token

3. Spusťte testy znovu - VCR nahraje nové interakce

## Troubleshooting

### "Nieprawidłowe wyzwanie autoryzacyjne"

Token je neplatný nebo expirovaný. Získejte nový token z KSeF test prostředí.

### "VCR cassette not found"

Test běží poprvé a VCR ještě nemá nahrané interakce. Spusťte test s platným tokenem.

### Chyba při šifrování

Ujistěte se, že máte nainstalovaný OpenSSL:
```bash
ruby -ropenssl -e 'puts OpenSSL::VERSION'
```

## Testovací údaje

Pro testy používáme:
- **NIP prodejce**: Váš testovací NIP z KSeF test prostředí
- **NIP kupujícího**: 1234567890 (testovací)
- **Částka**: 123,00 PLN (100,00 PLN + 23,00 PLN DPH)
- **Forma faktury**: FA(3) - aktuální verze pro KSeF API 2.0

## Poznámky

- Testy používají **testovací prostředí** KSeF API (`https://api-test.ksef.mf.gov.pl/v2`)
- Faktury odeslané v testu jsou skutečné testovací faktury v KSeF test DB
- High-level API automaticky řeší všechnu složitost (šifrování, session management)
- Pro production použití stačí změnit `mode :test` na `mode :production`
