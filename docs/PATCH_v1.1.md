# ARCHITECT-03 — PATCH v1.1.1 (amends v1.1)

**Status:** Contract amendment after Redteam hard-fail vs `/workspace/mechalearn-vsb`.  
**Toolkit:** Flutter only (Android + Arch Linux). Sync deferred.

## Struck from offline v1 (do not implement)

- **HMAC / pack integrity refuse-on-tamper** — struck for offline v1. Answers may remain in Dart sources. Optional later: content hash pack when server exists.
- Claims of “ignore multi-day forward clock jump without reset” — struck. Streak behaviour is defined below only.

## Must implement (Redteam clear bar)

### A. Engine unlock refuse

- `ProgressService.canPlayLesson(lessonId, progress, catalog)` — fail closed.
- `LessonPlayerScreen` and `/lesson/:lessonId` router: if locked, **refuse** (redirect / error), do not grade or award XP.
- UI hide alone is insufficient.

### B. XP best-of (no replay farm)

- Lesson completion XP = sum of `AnswerChecker.xpForExercise` for correct items in that run.
- Persist `lessonBestXp[lessonId]`.
- On finish: `delta = max(0, runXp - previousBest)`; add **only delta** to total XP; update best.
- Replay of a finished lesson must not stack full XP again.
- Do not trust a raw `earnedXp` from UI without recomputing from graded exercises.

### C. Numeric locale parse

- Normalize: remove all Unicode whitespace (incl. thin/nbsp), then replace `,` → `.`, then `double.tryParse`.
- Display: Czech decimal comma.

### D. Streak (accurate contract)

- Study day = local `yyyy-MM-dd`.
- Same day: no streak change.
- Exactly next calendar day: `streak += 1` (max +1 per day — intentional).
- Gap > 1 day: `streak = 1`.
- Clock backward (`today < lastStudyDate`): do not change streak.

### E. Unchanged

- `AnswerChecker` sole grader; types frozen (`multipleChoice|numericFill|orderSteps|trueFalse|multiStep`).
- Stable content IDs; professor packs additive only.
- `content_version` string may be stored with progress for future migrations; **no HMAC gate**.

## Acceptance

- [ ] Locked lesson deep-link refused in router/player  
- [ ] XP best-of / no replay stack  
- [ ] Whitespace+comma numeric parse + tests  
- [ ] Streak cases tested as above  
- [ ] No HMAC implementation  
- [ ] `flutter analyze` + tests green  

Source of truth: this file.
