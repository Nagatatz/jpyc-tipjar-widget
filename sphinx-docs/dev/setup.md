# Development Setup

## Prerequisites

| Requirement | Version | Note |
|-------------|---------|------|
| [uv](https://docs.astral.sh/uv/) | 0.5+ | Python package management and virtual environments |
| Python | 3.12+ | Installed automatically by uv |
| Node.js | 24+ | Used to generate the Pagefind search index |

### Install uv

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Homebrew
brew install uv
```

## Clone the Repository

```bash
git clone https://github.com/Nagatatz/jpyc-tipjar-widget.git
cd jpyc-tipjar-widget
```

## Install Dependencies

```bash
cd sphinx-docs
make install    # install dependencies with uv sync
```

## Verify the Setup

```bash
make html       # build the English HTML
make serve      # preview at localhost:8000
```
