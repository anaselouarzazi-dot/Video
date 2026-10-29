# Video

Studio vidéo programmable : **HyperFrames** (HTML + GSAP → MP4), **Remotion** (React → MP4)
et **FFmpeg** (montage, audio, sous-titres, export).

## Installation

```bash
npm run setup     # FFmpeg (si absent), dépendances npm, GSAP local, Chrome headless, skills HyperFrames
npm run verify    # test de bout en bout : rend les deux démos et les post-traite avec FFmpeg
```

Prérequis : Node.js ≥ 22. FFmpeg est installé via `apt`/`brew` s'il manque.

## Structure

| Dossier | Rôle |
| --- | --- |
| `hyperframes/` | Projet HyperFrames (`index.html` = composition principale, `vendor/gsap.min.js` en local) |
| `remotion/src/` | Projet Remotion (`Root.tsx` déclare les compositions, `Intro.tsx` = démo) |
| `remotion.config.ts` | Config Remotion (point d'entrée, choix du navigateur headless) |
| `scripts/ff.sh` | Recettes FFmpeg prêtes à l'emploi |
| `out/` | Rendus (ignoré par git) |

## HyperFrames

```bash
npm run hf:preview    # studio de prévisualisation (en arrière-plan)
npm run hf:check      # lint + runtime + layout + contraste
npm run hf:render     # → out/hyperframes.mp4
cd hyperframes && npx hyperframes snapshot --at 1,3   # images PNG à des instants donnés
```

Voir `hyperframes/CLAUDE.md` pour le contrat de composition (`data-*`, `window.__timelines`).
GSAP est chargé depuis `vendor/` plutôt que depuis un CDN pour des rendus reproductibles hors-ligne.

## Remotion

```bash
npm run remotion:studio   # éditeur interactif
npm run remotion:render   # → out/remotion.mp4
npm run remotion:still    # → out/remotion.png
npm run typecheck
```

Paquets inclus : `@remotion/transitions`, `media-utils`, `shapes`, `paths`, `noise`, `layout-utils`.
Si Remotion ne peut pas télécharger son Chrome, il réutilise celui de HyperFrames
(`REMOTION_BROWSER_EXECUTABLE` permet d'en forcer un autre).

## FFmpeg (`scripts/ff.sh`)

```bash
bash scripts/ff.sh xfade  a.mp4 b.mp4 out.mp4 1      # fondu enchaîné
bash scripts/ff.sh concat out.mp4 a.mp4 b.mp4        # concaténation sans ré-encodage
bash scripts/ff.sh audio  video.mp4 musique.mp3 out.mp4   # bande-son normalisée (-14 LUFS)
bash scripts/ff.sh subs   video.mp4 sous-titres.srt out.mp4
bash scripts/ff.sh web    in.mp4 out.webm            # VP9 + Opus
bash scripts/ff.sh gif    in.mp4 out.gif 640
bash scripts/ff.sh thumb  in.mp4 vignette.png 2
bash scripts/ff.sh social in.mp4 out.mp4             # H.264 high, faststart
```

## Optionnel

`npx hyperframes doctor` liste les outils facultatifs : whisper.cpp (transcription),
Kokoro (`pip install kokoro-onnx soundfile`, voix off locale), MusicGen (musique générée).
