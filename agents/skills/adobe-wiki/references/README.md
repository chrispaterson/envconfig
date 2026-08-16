# adobe-wiki plugin

Confluence/Adobe Wiki plugin for Claude marketplace.

## Install

Add the marketplace, then install the skill:

```bash
/plugin marketplace add https://github.com/Adobe-AIFoundations/adobe-skills
/plugin install adobe-internal-tools@adobe-skills-marketplace
```

## Required environment variables

Set these before using the Wiki skill:

### macOS/Linux (bash/zsh)

```bash
export ADOBE_WIKI_URL="https://wiki.corp.adobe.com"
export ADOBE_WIKI_PAT="your-confluence-personal-access-token"
```

### macOS (persist in `.zprofile`)

Add these lines to `~/.zprofile`:

```bash
export ADOBE_WIKI_URL="https://wiki.corp.adobe.com"
export ADOBE_WIKI_PAT="your-confluence-personal-access-token"
```

Then open a new terminal session.

### Windows (PowerShell)

```powershell
$env:ADOBE_WIKI_URL="https://wiki.corp.adobe.com"
$env:ADOBE_WIKI_PAT="your-confluence-personal-access-token"
```

## Verify

```bash
echo "$ADOBE_WIKI_URL"
```

If `ADOBE_WIKI_URL` is set and `ADOBE_WIKI_PAT` is valid, the Wiki skill can authenticate with Confluence.
