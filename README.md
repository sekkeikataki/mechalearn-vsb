# MechaLearn

**MechaLearn** is an offline-first Flutter study app for mechatronics students — Duolingo-style skill path + Brilliant-style multi-step exercises.

Studijní aplikace pro mechatroniku (české UI): cesta dovedností, XP, série, životy, kurzy. Plný obsah má **Matematika pro mechatroniku**; ostatní kurzy jsou prázdné placeholdery pro materiály od vyučujících.

Associated with learning at **VŠB – Technická univerzita Ostrava** (not an official university product; no official logos or verified official course IDs).

Repository: https://github.com/sekkeikataki/mechalearn-vsb

## Features / Funkce

- Onboarding s denním cílem XP
- Domovská „skill path“ cesta lekcí (odemčení i v engine / routeru, ne jen UI)
- Typy cvičení: výběr z možností, číselná odpověď (tolerance, česká čárka), seřazení kroků, pravda/nepravda + zdůvodnění, vícekrokové úlohy s nápovědami
- XP jen přes `AnswerChecker` po grade; streak +1/den (anti clock-skip)
- Content packs: `content_version` + HMAC integrity (tamper → refuse load)
- Offline uložení postupu (`shared_preferences`)
- Kurzy: Matematika (komplet), Fyzika / Elektronika / Mechanika / Řízení / Programování (placeholdery)
- Material 3, `go_router`, `flutter_riverpod`

## Deferred / Odloženo (v1)

- **Multi-device sync** — synchronizace postupu mezi zařízeními je záměrně odložena. v1 je offline-first na jednom zařízení (`shared_preferences`). Cloud sync / účet přijde později.
- Symbolický CAS solver — v1 pouze stávající typy cvičení (žádný CAS).

## Requirements / Požadavky

- Flutter stable (3.24+ recommended; developed on 3.47)
- For **Linux desktop**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`
- For **Android**: Android SDK / Android Studio

## Run on Arch Linux

```bash
# Dependencies (Arch)
sudo pacman -S --needed flutter clang cmake ninja pkgconf gtk3

# Or use a local Flutter SDK and put it on PATH
export PATH="$PATH:/path/to/flutter/bin"

flutter config --enable-linux-desktop
cd mechalearn-vsb
flutter pub get
flutter run -d linux
```

Build release:

```bash
flutter build linux --release
# Binary under build/linux/x64/release/bundle/
```

## Run on Android

```bash
flutter pub get
flutter devices
flutter run -d <android-device-id>
# or
flutter build apk --release
```

Install APK from `build/app/outputs/flutter-apk/app-release.apk`.

## Develop / Vývoj

```bash
flutter analyze
flutter test
```

Math content lives in `lib/data/maths/` as typed Dart models. Integrity: `lib/services/content_integrity.dart` (HMAC over exercise ids/answers). Course catalog: `lib/data/courses.dart`.

Při změně matematického obsahu spusť `dart run tool/compute_content_hmac.dart` a aktualizuj `ContentManifest.contentHmacHex` (případně `contentVersion`).

## Maths units / Matematické jednotky

1. Čísla, absolutní hodnota, nerovnosti  
2. Funkce a grafy  
3. Derivace  
4. Integrály  
5. Lineární algebra  
6. Diferenciální rovnice intro (RC, pružina–tlumič)  
7. Komplexní čísla (fázory light)  
8. Fourier / signály (intuice)

## License

Student / education project — see repository for license details.
