# ARCHITECT-03 — PATCH v1.2.1 (amends v1.2 after Redteam)

**Status:** Amended freeze. v1.1.1 A–D still in force.  
**Honest goal:** Ship a polished app + **one live public surface** so strangers can open/download it with the owner offline. One-time GitHub auth/Pages enable is a **publish gate**, not “already true.”

## Hard truth (do not market past this)

- Until CoS completes `gh` auth + public repo + (Pages **or** Release with artefact), **“everybody has access / zero owner action” = FAIL**. Architect does not claim it early.
- **Android for everybody** without Play ≠ true. v1.2 ships **unsigned APK sideload** when SDK exists; README must say so in Czech/EN. Missing SDK → Linux+Web first; Android follows — never imply Play reach.
- **HMAC:** do not advertise refuse-on-tamper in About/README unless `verifyOrThrow` is on the load path. Else copy = “offline v1, integrity deferred.”

## Distribution acceptance (Auditor gate)

Synthesis of “public access” only when **≥1** of:
1. GitHub Pages URL returns **200** and runs the web app, or  
2. Public Release tag has a downloadable Linux bundle (and APK if built).

Owner may be offline after that. Until then: polish OK; **public-access checklist = FAIL**.

## Polish (Executor) — additions vs v1.2

1–3,5–8 from v1.2 unchanged (empty states, Czech errors, offline clarity, a11y, web, stable IDs, version/README).

**New:**
- **Web progress honesty:** Czech copy that progress is local to this browser/device; private mode / cleared site data can wipe it; no multi-device sync.
- **CI:** GitHub Actions workflow — `flutter analyze` + `flutter test` on PR/push; release job builds linux (and web) artefacts when credentials exist.
- **Crash/quality budget:** no uncaught Flutter errors on first-run → complete lesson 1 path (manual or integration smoke where feasible).
- **README one-link:** only point “Open / Download” at a URL that already 200s; otherwise label “pending publish” — no fake ready link.

## CoS

Owns auth, public visibility, Pages, Releases. Report blocker plainly if desktop passkey/sudo required.

## Non-goals

Play/Flathub/Apple stores; cloud sync; professor PDF ingest.

## Acceptance checklist

- [ ] A–D PASS; analyze + tests green  
- [ ] Empty/error/offline/web-persistence Czech copy honest  
- [ ] No integrity advertising lie  
- [ ] CI workflow present  
- [ ] **Live public URL or Release artefact 200s** (required for public-access PASS)

Source of truth: this file.
