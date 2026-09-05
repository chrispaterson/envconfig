# To Install
`git clone https://github.com/chrispaterson/envconfig.git && ./envconfig/install && . ~/.profile`


# Agent memory

Skills save durable knowledge to the configured private GBrain. Do not commit runtime
memory under `agents/memory/`. The installer enables the repository's pre-commit check
unless an existing hook setup is present; CI also checks the committed tree.

For an existing clone without custom hooks, enable the check with
`git config --local core.hooksPath .githooks`. If you maintain your own hooks, invoke
`bin/check-agent-memory` from your pre-commit hook instead.

Run the guard tests with `python3 -m unittest discover -s tests -p 'test_*.py'`.


# Shared skills across Codex and Claude Code

Keep each skill in one canonical `<skills>/<name>/SKILL.md` directory, including
its scripts and reference files. The installer links each skill into both user
skill locations: `~/.agents/skills/` for Codex and `~/.claude/skills/` for Claude
Code. `~/agents/skills` alone is not a harness discovery location.

The normal installer includes this step and requires Python 3. To install only
skills without running terminal or package setup:

```sh
./install --agent-skills-only
./install --agent-skills-only --check
```

The check is read-only. Default installation is repeatable, leaves unrelated skills
in place, and refuses conflicting names, existing directories, or broken links.
It also refuses symlinked discovery directories so installation cannot write
through an entire harness directory into a tracked repository.

For an existing installation with conflicting skill copies or a linked skills
root, explicitly select the canonical source versions while retaining originals:

```sh
./install --agent-skills-only --migrate-existing
./install --agent-skills-only --check
```

Migration moves conflicting entries into unique `skills-backup-*` directories
beside each harness's `skills/` directory and prints their locations. It saves a
linked skills root itself, creates a real discovery directory, and links unrelated
entries back to the old target without modifying that target. Existing custom
content is preserved in backups, but the selected source version becomes active;
review and merge any desired customizations separately. A `restore.json` in each
backup records the original location and original symlink text. To restore an
entry, first move aside the replacement at that exact location, then move the
saved original back; do not copy a relative symlink into a different location and
assume it resolves identically. Keep backups until reviewed.

Migration still refuses linked harness parents (such as `~/.claude` itself),
broken skills-root links, duplicate source names, and source/destination nesting
that would move a canonical source. `--check` cannot be combined with migration.

To combine public and private configuration, clone both repositories and supply
each skill directory explicitly (`--source` replaces the default source):

```sh
./install --agent-skills-only \
  --source ./agents/skills \
  --source /path/to/private-config/agents/skills
```

Use the same source arguments with `--check`. Private sources remain outside this
repository. Names must be unique across sources. After moving or removing a
canonical skill, remove its old discovery links explicitly before reinstalling;
the installer preserves stale links for review. Keep secrets, sessions, caches,
and durable memory out of both configuration repositories. GBrain supplies
shared durable knowledge; connect it separately in each harness.

Start a fresh session after installation. Confirm the intended public and optional private skills appear in each harness's skill list, then ask each harness to retrieve
the same known GBrain page. Link checks verify installation, not authentication or
brain connectivity. Codex's AGENTS.md and Claude's CLAUDE.md, MCP configuration,
permissions, and hooks remain separate harness configuration. In particular, the
Claude auto-memory mirror and Codex transcript hook retain their existing roles.

Discovery references: [official OpenAI documentation](https://learn.chatgpt.com/docs/build-skills)
and [Claude Code documentation](https://code.claude.com/docs/en/skills).


After a verified migration to another source, use `--relink-source /absolute/former/source`
with the final `--source` list to replace only per-skill symlinks whose literal targets
match that former source. All sources and conflicts are checked before any link is
removed. Actual directories and differently targeted links are preserved. `--check`
reports links still needing replacement without modifying them.

Machine-specific shell settings can live in `~/.config/envconfig/local.sh`, which
`.shrc` sources if present. Keep local Git includes in a regular `~/.gitconfig`
that includes this checkout's `.gitconfig`; do not write private settings through
a symlink into this repository. Configure your own Git email locally, scoped to
appropriate repositories. Public-only skill installation requires no private checkout.


# Home links and uninstall

`./install --links-only` installs home and skill links without running package or
submodule setup. Full `./install` also initializes submodules and installs tools.
Both require Python 3. Install/uninstall share an explicit list of home entries;
repository metadata, tests, and implementation helpers are never linked into HOME.

`~/envconfig/agents/skills` contains the shared skill sources. `~/.agents/skills`
is Codex's discovery directory, and `~/.claude/skills` is Claude Code's. The old
`~/agents` alias is unnecessary: installation removes it only if it points to
this checkout's `agents` directory. An unrelated alias or real directory is retained.

Existing home files replaced by links are saved in `~/.envconfig-backups`.
A backup collision stops installation without overwriting either version.
Existing local `.gitconfig` files are preserved; include this checkout's `.gitconfig`
from your local file if it does not already include the public defaults.
Personal scripts from an old `~/bin` are backed up, never copied into the public
checkout. Review the backup and keep those scripts in a separate local/private bin
location if you still need them on PATH.

`./uninstall` removes only home and per-skill links pointing to this checkout,
then restores available known home entries from the new backup directory and
legacy `.bak`, including dotfiles. Occupied destinations are preserved. New installs record ownership in `~/.envconfig-install.json`, including partial
installations. Uninstall also reverses recorded skill migrations, unsets the hook
configuration it added, deinitializes newly initialized submodule checkouts, removes
new global npm packages and Homebrew formulae/dependencies/taps, and removes directories
it created when empty. If this install bootstrapped Homebrew, it removes Homebrew
only once no other packages remain. Modified submodules or dependencies now required
by other packages are preserved by the underlying tools; uninstall reports the failure
and retains its receipt for retry. Private settings and subsequent user additions remain.

The receipt stays local; do not delete it before uninstalling. Older installs have no
package ownership record: uninstall removes identifiable checkout links (including
humanize/ai-check across all three skill locations) and restores available home backups,
but cannot safely infer which old dependencies it added. It reports this limitation.
Previously installed global Yarn packages are not silently adopted or removed.
Global CLI packages now use npm and are installed only when missing, preserving
existing versions. The humanize submodule's overwrite-based installer is no longer run.
The obsolete build step for the missing vim-jsdoc directory has been removed.
Git's cached submodule objects and package-manager caches are not user installations;
they are left to Git/package-manager maintenance rather than recursively deleting
shared cache directories.

Validate with `shellcheck install uninstall lib/home-links.sh bin/yarn-global` and
`python3 -m unittest discover -s tests -p 'test_*.py'`.
