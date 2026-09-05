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
