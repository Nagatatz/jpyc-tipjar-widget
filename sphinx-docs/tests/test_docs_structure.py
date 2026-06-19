"""Smoke tests for the bilingual documentation structure.

These guard the invariant that every English source page has a place in the
tree and that the Japanese (ja) translation catalogs exist. They are
filesystem-only (no Sphinx build needed), so they run fast in CI.
"""

from pathlib import Path

DOCS_ROOT = Path(__file__).resolve().parent.parent

EXPECTED_PAGES = [
    "index.md",
    "user/index.md",
    "user/installation.md",
    "user/quickstart.md",
    "user/configuration.md",
    "user/changelog.md",
    "dev/index.md",
    "dev/setup.md",
    "dev/building.md",
    "dev/architecture.md",
    "dev/project-structure.md",
    "dev/contributing.md",
]


def test_expected_english_pages_exist():
    missing = [rel for rel in EXPECTED_PAGES if not (DOCS_ROOT / rel).is_file()]
    assert not missing, f"missing English doc pages: {missing}"


def test_japanese_locale_catalogs_exist():
    po_files = list((DOCS_ROOT / "locale" / "ja" / "LC_MESSAGES").rglob("*.po"))
    assert po_files, "no Japanese .po translation catalogs found under locale/ja"


def test_language_is_english_with_japanese_in_sitemap():
    conf = (DOCS_ROOT / "conf.py").read_text(encoding="utf-8")
    assert 'language = "en"' in conf, "conf.py should declare English as the source language"
    assert '"ja"' in conf, "conf.py should reference the ja locale (e.g. sitemap_locales)"
