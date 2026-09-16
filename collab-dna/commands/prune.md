---
description: Prune pass — find standing rules in every CLAUDE.md, rules file, and memory entry that the current harness or model has superseded, and propose their removal or rewrite one decision at a time
allowed-tools: Bash(python3:*), Bash(claude:*), Bash(ls:*), Bash(git:*), Bash(gh:*), Read, Glob, Grep
---

Find the rules in this setup that were written for an older model or
harness and are now unnecessary or actively fighting the harness.
Propose changes; apply none.

1. The skill directory is `${CLAUDE_PLUGIN_ROOT}/skills/collab-dna/`
   (fall back to locating `collab-dna/skills/collab-dna/` under
   `~/.claude/plugins/` if that variable is unset).
2. Run `python3 <skill-dir>/scripts/inspect_setup.py --out <temp file>`
   and `python3 <skill-dir>/scripts/find_stale.py --out <temp file>`.
   The first is the inventory of every instruction surface in full. The
   second lists referenced paths that do not exist, rule lines older
   than the threshold, dates and state claims (PRs, branches, TODOs,
   retired things) to verify, memory index and link drift, and whether
   the harness or model changed since the last pass. Read both.
3. Read `<skill-dir>/references/supersession-rubric.md` and
   `<skill-dir>/references/superseded-patterns.md`. The patterns file
   is leads, not verdicts: verify each against the harness you are
   running in.
4. Bucket every rule per the rubric. For each rule not kept as a
   durable preference, answer the three questions and write the third
   answer ("what happens if removed") into the report.
5. Verify every stale-fact and native-now claim before reporting it:
   `ls` the path, `gh pr view` the PR, quote the harness guidance from
   your own context. Unverified claims go under "Plausible, not
   confirmed" with no patch.
6. Produce the report in the rubric's shape, ranked by cost. Each item
   stands alone with its exact replacement text, so the human can
   approve one at a time.
7. When the human approves an item, hand them the change as a patch
   file in the temp directory plus the one-line command to apply it.
   Do not edit `~/.claude/CLAUDE.md` yourself even if you can; hand it
   over. Repo files may be edited on approval.
8. After the pass is delivered, run
   `python3 <skill-dir>/scripts/find_stale.py --stamp` so the next run
   can say what changed since.

If `$ARGUMENTS` names a single surface (`global`, `project`, `memory`,
`rules`), limit the pass to it.

Remember the conflict of interest the rubric names: you are auditing
the rules that constrain you. Quote or it did not happen.
