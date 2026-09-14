# MechaLearn

**MechaLearn** is an offline-first Flutter study app for mechatronics students — Duolingo-style skill path + Brilliant-style multi-step exercises.

Studijní aplikace pro mechatroniku (české UI): cesta dovedností, XP, série, životy, kurzy. Plný obsah má **Matematika pro mechatroniku**; ostatní kurzy jsou prázdné placeholdery pro materiály od vyučujících.

Associated with learning at **VŠB – Technická univerzita Ostrava** (not an official university product; no official logos).

Repository: https://github.com/sekkeikataki/mechalearn-vsb

## Features / Funkce

- Onboarding s denním cílem XP
- Domovská „skill path“ cesta lekcí
- Typy cvičení: výběr z možností, číselná odpověď (tolerance), seřazení kroků, pravda/nepravda + zdůvodnění, vícekrokové úlohy s nápovědami
- XP, streak, volitelná srdce (životy)
- Offline uložení postupu (`shared_preferences`)
- Kurzy: Matematika (komplet), Fyzika / Elektronika / Mechanika / Řízení / Programování (placeholdery)
- Material 3, `go_router`, `flutter_riverpod`

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

Math content lives in `lib/data/maths/` as typed Dart models (easy to extend with JSON packs later). Course catalog: `lib/data/courses.dart`.

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
