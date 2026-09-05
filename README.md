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

The check is read-only. Installation is repeatable, leaves unrelated skills in
place, and refuses conflicting names, existing directories, or broken links.
It also refuses symlinked discovery directories so installation cannot write
through an entire harness directory into a tracked repository. Resolve conflicts
explicitly and rerun; the installer never replaces or deletes skills.

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

Start a fresh session after installation. Confirm `remember`, `getcontext`, and
`storypoint` appear in each harness's skill list, then ask each harness to retrieve
the same known GBrain page. Link checks verify installation, not authentication or
brain connectivity. Codex's AGENTS.md and Claude's CLAUDE.md, MCP configuration,
permissions, and hooks remain separate harness configuration. In particular, the
Claude auto-memory mirror and Codex transcript hook retain their existing roles.

Discovery references: [official OpenAI documentation](https://learn.chatgpt.com/docs/build-skills)
and [Claude Code documentation](https://code.claude.com/docs/en/skills).
