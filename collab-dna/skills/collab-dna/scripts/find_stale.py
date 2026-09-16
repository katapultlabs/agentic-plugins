#!/usr/bin/env python3
"""Find the deterministic half of instruction cruft: referenced paths that no
longer exist, rule lines older than a threshold, dates and state claims
(PRs, branches, TODOs, retired things) that need a look, memory files whose
links or index are broken, and whether the harness or model has changed
since the last prune pass. Read-only unless --stamp. Secrets are masked.

Usage:
  find_stale.py [--project DIR] [--out FILE] [--age-days N] [--stamp]

Surfaces: ~/.claude/CLAUDE.md, every CLAUDE.md / CLAUDE.local.md /
AGENTS.md from the project's ancestors down, .claude/rules/*.md, and the
project's memory directory. The prune pass reads this plus the setup
inventory; the judgment about what is superseded is the model's, not this
script's.

--stamp records the Claude Code version, configured model, and date under
~/.claude/collab-dna/last-prune.json for this project, so the next run can
say what changed. Write it after a pass is delivered, not before.
"""
import argparse, datetime as dt, glob, json, os, re, subprocess, sys

HOME = os.path.expanduser("~")
INLINE_SECRET = re.compile(r"(?i)\b(sk-[A-Za-z0-9_-]{8,}|ghp_[A-Za-z0-9]{8,}|xox[a-z]-[A-Za-z0-9-]{8,}|[A-Za-z0-9_-]{32,})\b")
PATH_RE = re.compile(r"(?<![\w:/])(~/[^\s`'\"()\[\]<>,;]+|/(?:Users|home|opt|usr|etc|var|Applications|Library|Volumes|private)/[^\s`'\"()\[\]<>,;]+|\.{1,2}/[^\s`'\"()\[\]<>,;]+|(?:[\w.-]+/)+[\w.-]+\.[A-Za-z][A-Za-z0-9]{0,5})")
DATE_RE = re.compile(r"\b(20\d{2}-\d{2}-\d{2})\b")
CLAIM_RE = re.compile(r"(?i)\b(PR\s*#?\d+|pull request|branch\b|draft\b|TODO|future step|possible future|not yet|pending|retired|deprecated|experiment|temporar|for now|until\b|workaround|no longer|currently|as of)\b")
RULE_LINE = re.compile(r"^\s*(?:[-*]\s+|\d+\.\s+|#{1,6}\s+)\S")
TODAY = dt.date.today()


def mask(s):
    return INLINE_SECRET.sub("<masked>", s)


def run(cmd, cwd=None, timeout=30):
    try:
        r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return r.returncode, r.stdout
    except Exception:
        return 1, ""


def git_root(path):
    rc, out = run(["git", "-C", os.path.dirname(path), "rev-parse", "--show-toplevel"])
    return out.strip() if rc == 0 else None


def tracked(path, root):
    rc, _ = run(["git", "-C", root, "ls-files", "--error-unmatch", path])
    return rc == 0


def blame_dates(path, root):
    """Return list of (lineno, date) for every line, via git blame."""
    rc, out = run(["git", "-C", root, "blame", "--line-porcelain", "--", path], timeout=120)
    if rc != 0:
        return None
    dates, n = [], 0
    for line in out.splitlines():
        if line.startswith("author-time "):
            n += 1
            dates.append((n, dt.date.fromtimestamp(int(line.split()[1]))))
    return dates


def file_date(path):
    root = git_root(path)
    if root and tracked(path, root):
        rc, out = run(["git", "-C", root, "log", "-1", "--format=%as", "--", path])
        if rc == 0 and out.strip():
            return dt.date.fromisoformat(out.strip()), "git", root
    return dt.date.fromtimestamp(os.path.getmtime(path)), "mtime", None


def resolve(ref, project, filedir):
    ref = ref.rstrip(".:,;)")
    if any(c in ref for c in "*<>{}$"):
        return None
    if ref.startswith("~/"):
        cands = [os.path.expanduser(ref)]
    elif ref.startswith("/"):
        cands = [ref]
    else:
        cands = [os.path.join(project, ref), os.path.join(filedir, ref)]
    return ref, any(os.path.exists(c) for c in cands)


def surfaces(project):
    files = []
    g = os.path.join(HOME, ".claude", "CLAUDE.md")
    if os.path.exists(g):
        files.append(("global", g))
    parts = project.split(os.sep)
    for i in range(2, len(parts) + 1):
        d = os.sep.join(parts[:i]) or os.sep
        if d == HOME:
            continue
        for name in ("CLAUDE.md", "CLAUDE.local.md", "AGENTS.md"):
            p = os.path.join(d, name)
            if os.path.exists(p):
                files.append(("project" if d == project else "ancestor", p))
    for r in sorted(glob.glob(os.path.join(project, ".claude", "rules", "*.md"))):
        files.append(("rules", r))
    return files


def memory_dir(project):
    return os.path.join(HOME, ".claude", "projects", project.replace("/", "-"), "memory")


def scan_file(kind, path, project, out, age_days):
    label = path.replace(HOME, "~")
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            lines = f.read().splitlines()
    except OSError:
        return
    date, how, root = file_date(path)
    age = (TODAY - date).days
    out.append(f"\n### {label} ({kind}, {len(lines)} lines, last changed {date} via {how}, {age}d ago)\n")
    per_line = blame_dates(path, root) if root else None
    if per_line:
        old = [(n, d) for n, d in per_line if (TODAY - d).days > age_days and n <= len(lines) and RULE_LINE.match(lines[n - 1])]
        newest = max(d for _, d in per_line)
        oldest = min(d for _, d in per_line)
        out.append(f"- line ages: oldest {oldest}, newest {newest}; {len(old)} rule lines older than {age_days}d")
        for n, d in old[:40]:
            out.append(f"  - L{n} ({d}): {mask(lines[n - 1].strip())[:140]}")
    elif age > age_days:
        out.append(f"- whole file older than {age_days}d (no per-line history available)")
    missing, seen = [], set()
    for n, line in enumerate(lines, 1):
        for m in PATH_RE.finditer(line):
            r = resolve(m.group(1), project, os.path.dirname(path))
            if r and not r[1] and r[0] not in seen:
                seen.add(r[0]); missing.append((n, r[0]))
    if missing:
        out.append(f"- referenced paths not found ({len(missing)}):")
        for n, ref in missing[:40]:
            out.append(f"  - L{n}: `{ref}`")
    claims = []
    for n, line in enumerate(lines, 1):
        ds = DATE_RE.findall(line)
        cm = CLAIM_RE.search(line)
        if ds or cm:
            tag = []
            for d in ds:
                try:
                    tag.append(f"{d} ({(TODAY - dt.date.fromisoformat(d)).days}d ago)")
                except ValueError:
                    pass
            if cm:
                tag.append(f"claim: {cm.group(1)}")
            claims.append((n, ", ".join(tag), mask(line.strip())[:140]))
    if claims:
        out.append(f"- dates and state claims to verify ({len(claims)}):")
        for n, tag, text in claims[:40]:
            out.append(f"  - L{n} [{tag}]: {text}")
    if not (missing or claims or (per_line and old)):
        out.append("- nothing mechanical to flag")


def scan_memory(project, out, age_days):
    mem = memory_dir(project)
    files = sorted(glob.glob(os.path.join(mem, "*.md")))
    out.append(f"\n## Memory ({mem.replace(HOME, '~')})\n")
    if not files:
        out.append("- no memory directory for this project")
        return
    names = {}
    for f in files:
        base = os.path.basename(f)
        if base == "MEMORY.md":
            continue
        names[base[:-3]] = f
        try:
            head = open(f, encoding="utf-8", errors="replace").read(2000)
        except OSError:
            continue
        m = re.search(r"^name:\s*(.+)$", head, re.M)
        if m:
            names[m.group(1).strip().strip('"')] = f
    idx = os.path.join(mem, "MEMORY.md")
    indexed = set()
    if os.path.exists(idx):
        for n, line in enumerate(open(idx, encoding="utf-8", errors="replace"), 1):
            for m in re.finditer(r"\(([^)]+\.md)\)", line):
                indexed.add(m.group(1))
                if not os.path.exists(os.path.join(mem, m.group(1))):
                    out.append(f"- MEMORY.md L{n} points at missing file `{m.group(1)}`")
    else:
        out.append("- no MEMORY.md index")
    for f in files:
        base = os.path.basename(f)
        if base == "MEMORY.md":
            continue
        if base not in indexed and os.path.exists(idx):
            out.append(f"- `{base}` is not in MEMORY.md")
        text = open(f, encoding="utf-8", errors="replace").read()
        for link in set(re.findall(r"\[\[([^\]]+)\]\]", text)):
            if link not in names:
                out.append(f"- `{base}` links [[{link}]] which does not resolve")
    for f in files:
        if os.path.basename(f) != "MEMORY.md":
            scan_file("memory", f, project, out, age_days)


def stamp_path():
    return os.path.join(HOME, ".claude", "collab-dna", "last-prune.json")


def current_env():
    rc, v = run(["claude", "--version"], timeout=10)
    gs = {}
    try:
        gs = json.load(open(os.path.join(HOME, ".claude", "settings.json")))
    except Exception:
        pass
    return {"claude_version": v.strip() if rc == 0 else "unknown", "model": gs.get("model", "(unset)"), "date": TODAY.isoformat()}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--project", default=os.getcwd())
    ap.add_argument("--out")
    ap.add_argument("--age-days", type=int, default=90)
    ap.add_argument("--stamp", action="store_true", help="record this pass so the next run can say what changed")
    a = ap.parse_args()
    project = os.path.abspath(a.project)
    env = current_env()
    out = [f"# Stale-rule scan: {project}", ""]
    out.append(f"- Today: {TODAY}; Claude Code {env['claude_version']}; configured model `{env['model']}`; rule-age threshold {a.age_days}d")
    stamps = {}
    try:
        stamps = json.load(open(stamp_path()))
    except Exception:
        pass
    last = stamps.get(project)
    if last:
        changed = [f"{k}: {last.get(k)} → {env[k]}" for k in ("claude_version", "model") if last.get(k) != env[k]]
        out.append(f"- Last prune pass: {last.get('date')}" + ("; CHANGED since then: " + "; ".join(changed) if changed else "; harness and model unchanged since"))
    else:
        out.append("- No prune pass recorded for this project (run with --stamp after delivering one)")
    out.append("\n## Instruction files\n")
    for kind, path in surfaces(project):
        scan_file(kind, path, project, out, a.age_days)
    scan_memory(project, out, a.age_days)
    out.append("\n## How to read this\n")
    out.append("Missing paths and broken links are facts. Old lines, dates, and claims are leads: a rule can be old and right. "
               "Which rules are superseded is the auditing model's call against its own harness, per references/supersession-rubric.md.")
    text = "\n".join(out) + "\n"
    if a.out:
        with open(a.out, "w") as f:
            f.write(text)
        print(a.out)
    else:
        sys.stdout.write(text)
    if a.stamp:
        os.makedirs(os.path.dirname(stamp_path()), exist_ok=True)
        stamps[project] = env
        with open(stamp_path(), "w") as f:
            json.dump(stamps, f, indent=1)
        print(f"stamped {stamp_path()}", file=sys.stderr)


if __name__ == "__main__":
    main()
