#!/usr/bin/env python3
"""Compare prononciation effective (wav2vec2-phoneme) vs cible (espeak-ng).

Usage : prononciation_check.py <wav_path> "<texte cible>" <lang>

lang : en | de | fr (mappé vers les voix espeak-ng en-us / de / fr-fr)

Sortie texte lisible : phonèmes cibles, phonèmes prononcés, diff avec
substitutions / omissions / insertions. Le LLM en mode prof interprète
le diff et donne le feedback pédagogique.
"""
from __future__ import annotations

import sys
import subprocess
from difflib import SequenceMatcher

LANG_TO_ESPEAK = {"en": "en-us", "de": "de", "fr": "fr-fr"}
MODEL_NAME = "facebook/wav2vec2-lv-60-espeak-cv-ft"


def target_phonemes(text: str, lang: str) -> list[str]:
    """Texte → phonèmes via phonemizer (wraps espeak-ng), espace-séparés."""
    from phonemizer import phonemize
    from phonemizer.separator import Separator
    voice = LANG_TO_ESPEAK.get(lang, lang)
    out = phonemize(
        text, language=voice, backend="espeak", with_stress=False,
        separator=Separator(phone=" ", word=" | "), strip=True,
    )
    return [p for p in out.replace("|", " ").split() if p]


def predicted_phonemes(wav_path: str) -> list[str]:
    """Audio → phonèmes via wav2vec2-phoneme (Meta, multilingue)."""
    from transformers import Wav2Vec2Processor, Wav2Vec2ForCTC
    import torch
    import soundfile as sf

    processor = Wav2Vec2Processor.from_pretrained(MODEL_NAME)
    model = Wav2Vec2ForCTC.from_pretrained(MODEL_NAME)
    model.eval()

    audio, sr = sf.read(wav_path)
    if sr != 16000:
        raise SystemExit(f"[erreur] WAV doit être en 16 kHz mono, reçu {sr} Hz.")
    inputs = processor(audio, sampling_rate=sr, return_tensors="pt", padding=True)
    with torch.no_grad():
        logits = model(inputs.input_values).logits
    pred_ids = torch.argmax(logits, dim=-1)
    transcription = processor.batch_decode(pred_ids)[0]
    return [p for p in transcription.strip().split() if p]


def diff_report(target: list[str], predicted: list[str]) -> str:
    if target == predicted:
        return "  ✓ aucune divergence détectée"
    sm = SequenceMatcher(None, target, predicted)
    lines: list[str] = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            continue
        t = " ".join(target[i1:i2]) or "∅"
        p = " ".join(predicted[j1:j2]) or "∅"
        if tag == "replace":
            lines.append(f"  /{t}/ → /{p}/   substitution")
        elif tag == "delete":
            lines.append(f"  /{t}/ → ∅          phonème non prononcé")
        elif tag == "insert":
            lines.append(f"  ∅ → /{p}/         phonème inattendu")
    return "\n".join(lines)


def main() -> int:
    if len(sys.argv) != 4:
        print(__doc__, file=sys.stderr)
        return 2
    wav, text, lang = sys.argv[1], sys.argv[2], sys.argv[3]
    try:
        tgt = target_phonemes(text, lang)
    except Exception as e:
        print(f"[erreur] phonemizer/espeak-ng : {e}", file=sys.stderr)
        return 1
    try:
        pred = predicted_phonemes(wav)
    except Exception as e:
        print(f"[erreur] wav2vec2 : {e}", file=sys.stderr)
        return 1

    print(f"Texte cible        : {text}")
    print(f"Phonèmes cibles    : /{' '.join(tgt)}/")
    print(f"Phonèmes prononcés : /{' '.join(pred)}/")
    print()
    print("Écarts :")
    print(diff_report(tgt, pred))
    return 0


if __name__ == "__main__":
    sys.exit(main())
