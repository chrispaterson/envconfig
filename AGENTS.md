# Brain-first protocol

A knowledge brain is connected over MCP (gbrain, full surface), mirrored to the
git repo at `~/brain`. Before answering any question about people, companies,
decisions, projects, or past context:

## 1. Brain first — route by the shape of the question

- Exact names or known tokens → `search` (cheap hybrid, no expansion).
- Concepts, landscapes, "all the X that do Y" → `query` **first**. It recovers synonym
  phrasings `search` misses, and a populated `search` result set is _not_ proof of coverage.
- Check the brain **before** answering from memory and before asking me. Never ask
  "who is X?" or "what did we decide about Y?" without checking first — it probably
  already knows.

## 2. Write back

When I make a decision, mention a new person or company, or land on an idea worth
keeping, write it to the brain. One insight, one page, linked.

- `gbrain capture --file <path> --slug <topic>/<name> --type note`, or `put_page`.
- **File by subject, not by source.** `people/`, `companies/`, `computers/`, `infra/`,
  `projects/`, `notes/`. `~/brain/RESOLVER.md` and each directory's `README.md` are
  authoritative — read them when the home isn't obvious.
- Use `inbox/` **only** when there is genuinely no known home. Its README says so, and a
  nightly `gbrain autopilot` on the Mac mini drains it.
- Always pass `--slug` for anything that may be edited later. The default slug is a
  **content hash**, so a later edit forks a second page instead of updating the first.

## 3. Cite

When you answer from the brain, name the page you used.
