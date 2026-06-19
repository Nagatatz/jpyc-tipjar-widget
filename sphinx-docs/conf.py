# Configuration file for the Sphinx documentation builder.
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os

project = "JPYC Tip Jar Widget"
copyright = "2026, Nagatatz"
author = "Nagatatz"

# -- General configuration ---------------------------------------------------

extensions = [
    "myst_parser",
    "sphinx_copybutton",
    "sphinx_design",
    "sphinxext.opengraph",
    "sphinx_sitemap",
    "notfound.extension",
    "sphinx_tippy",
    "sphinx_last_updated_by_git",
    "sphinx_llms_txt",
    "sphinxcontrib.budoux",
    "atsphinx.htmx_boost",
    "sphinxcontrib.mermaid",
    "sphinx_togglebutton",
    "sphinx_multiversion",
]

# MyST Parser settings
myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "fieldlist",
    "attrs_inline",
]

# Auto-generate heading anchors up to level 3 (h1-h3)
myst_heading_anchors = 3

# Source file suffixes
source_suffix = {
    ".md": "markdown",
}

# The master toctree document
master_doc = "index"

# Exclude patterns
exclude_patterns = ["_build", ".venv", ".pytest_cache", "Thumbs.db", ".DS_Store"]

# -- Internationalization ----------------------------------------------------

language = "en"
locale_dirs = ["locale/"]
gettext_compact = False  # One .po file per source document

# -- HTML output -------------------------------------------------------------

html_theme = "furo"

html_theme_options = {
    "sidebar_hide_name": False,
    "navigation_with_keys": True,
    "top_of_page_button": "edit",
    "source_repository": "https://github.com/Nagatatz/jpyc-tipjar-widget",
    "source_branch": "main",
    "source_directory": "sphinx-docs/",
    "footer_icons": [
        {
            "name": "GitHub",
            "url": "https://github.com/Nagatatz/jpyc-tipjar-widget",
            "html": '<svg stroke="currentColor" fill="currentColor" stroke-width="0" '
            'viewBox="0 0 16 16"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 '
            "3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37"
            "-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 "
            "1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64"
            "-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 "
            "2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82"
            ".44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95"
            ".29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013"
            ' 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>',
            "class": "",
        },
    ],
}

html_static_path = ["_static"]
html_css_files = ["css/custom.css"]
templates_path = ["_templates"]

# Site prefix for GitHub Pages (e.g., "/my-project")
# Set SPHINX_SITE_PREFIX env var for deployment; empty for local dev.
html_context = {
    "site_prefix": os.environ.get("SPHINX_SITE_PREFIX", ""),
}

# Pagefind search page (replaces default Sphinx search)
html_additional_pages = {"search": "search.html"}

# -- Open Graph (social sharing previews) -----------------------------------

# TODO: Set html_baseurl to your deployed site URL (e.g., "https://user.github.io/repo/en/")
# When html_baseurl is non-empty, the setup(app) hook at the bottom of this
# file rewrites it to the `/ja/` variant during `make build-ja` and appends
# the matching og:locale meta tag.
html_baseurl = ""
ogp_site_url = html_baseurl
ogp_site_name = "JPYC Tip Jar Widget"
ogp_type = "website"

# Augment automatic Open Graph tags with Twitter Card and theme metadata.
# `og:locale` is appended per language by setup(app) when html_baseurl is set.
ogp_custom_meta_tags = [
    '<meta name="twitter:card" content="summary_large_image" />',
    '<meta name="theme-color" content="#3776AB" />',
]

# Map Sphinx language codes to Open Graph locale identifiers (BCP 47 → POSIX).
_OGP_LOCALES = {"en": "en_US", "ja": "ja_JP"}

# -- Sitemap (SEO) -----------------------------------------------------------

sitemap_url_scheme = "{link}"
sitemap_locales = ["en", "ja"]

# -- 404 page ----------------------------------------------------------------

notfound_urls_prefix = os.environ.get("SPHINX_SITE_PREFIX", "") + "/en/"

# -- Tooltip previews (sphinx-tippy) -----------------------------------------

tippy_anchor_parent_selector = "div.content"
tippy_enable_mathjax = False

# -- Last updated by git -----------------------------------------------------

git_last_updated_timezone = "Asia/Tokyo"

# -- LLM documentation (llms.txt) --------------------------------------------

# URI template uses html_baseurl automatically; no override needed

# -- BudouX (Japanese line breaking) -----------------------------------------

budoux_targets = ["h1", "h2", "h3"]

# -- HTMX Boost (SPA-like page transitions) ----------------------------------

htmx_boost_preload = "mouseover"

# -- Mermaid diagrams --------------------------------------------------------

mermaid_version = "11"  # CDN version; no server-side renderer needed
mermaid_d3_zoom = True

# -- Togglebutton (collapsible sections) -------------------------------------

# togglebutton_hint and togglebutton_hint_hide can be overridden here if needed

# -- sphinx-multiversion -----------------------------------------------------
# Builds docs for all matching tags and the main branch.
# Adjust smv_tag_whitelist to match your versioning scheme (e.g. "v1.0", "v1.2.3").

smv_tag_whitelist = r"^v\d+\.\d+.*$"
smv_branch_whitelist = r"^main$"
smv_remote_whitelist = r"^origin$"
smv_released_pattern = r"^refs/tags/.*$"
smv_outputdir_format = "{ref.name}"

# -- Suppress toctree warnings for locale files ------------------------------

suppress_warnings = ["toc.excluded"]

# -- Link check --------------------------------------------------------------
# Tune Sphinx linkcheck for less flakiness in CI without masking genuinely
# broken links. The `linkcheck_ignore` list intentionally covers only
# patterns that are unreachable from CI by construction; add project-specific
# entries below as needed.

linkcheck_timeout = 60
linkcheck_retries = 3
linkcheck_ignore = [
    # Local dev server URLs documented in setup guides — unreachable from CI.
    r"^http://localhost(:\d+)?(/.*)?$",
    # npmjs.com returns 403 to linkcheck bot's HEAD/GET requests.
    r"^https://www\.npmjs\.com/package/.*",
]


# -- Locale-aware OGP wiring -------------------------------------------------


def setup(app):  # noqa: D401
    """Rewrite ``html_baseurl`` / ``ogp_site_url`` and append ``og:locale``.

    No-op when ``html_baseurl`` is empty (the template default). Once a
    deploying project sets ``html_baseurl`` to e.g.
    ``https://user.github.io/repo/en/``, this hook swaps ``/en/`` for
    ``/ja/`` during ``make build-ja`` and appends the matching
    ``og:locale`` meta tag, so Open Graph scrapers receive the correct
    locale and the sitemap routes to the right language prefix.
    """

    def _apply_locale_aware_ogp(_app, config):
        baseurl = config.html_baseurl or ""
        if not baseurl:
            return
        lang = (config.language or "en").split("_")[0]
        # Replace the trailing language segment (`/en/` or `/<other>/`)
        # with the resolved language. We rely on the convention that
        # html_baseurl ends with `/<lang>/`.
        for known in _OGP_LOCALES:
            suffix = f"/{known}/"
            if baseurl.endswith(suffix):
                baseurl = baseurl[: -len(suffix)] + f"/{lang}/"
                break
        config.html_baseurl = baseurl
        config.ogp_site_url = baseurl
        og_locale = _OGP_LOCALES.get(lang, "en_US")
        og_locale_tag = f'<meta property="og:locale" content="{og_locale}" />'
        if og_locale_tag not in config.ogp_custom_meta_tags:
            config.ogp_custom_meta_tags = [
                *config.ogp_custom_meta_tags,
                og_locale_tag,
            ]

    app.connect("config-inited", _apply_locale_aware_ogp)
    return {"parallel_read_safe": True, "parallel_write_safe": True}
