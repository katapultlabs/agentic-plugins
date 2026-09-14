#!/usr/bin/env python3
"""Extract the human side of a Claude Code session so it can be audited.

Claude Code stores every session as JSONL under ~/.claude/projects/<slug>/,
where <slug> is the working directory with "/" replaced by "-". This script
turns one of those files into a readable markdown transcript: the user's
turns in full, the assistant's turns truncated to a preview, tool noise
removed. The audit reads the output, not the raw JSONL.

Usage:
  extract_session.py list [--project DIR] [--all | --worktrees]
  extract_session.py extract (latest | SESSION_ID | PATH) [--project DIR]
                             [--out FILE] [--preview N] [--stats]
                             [--human-only] [--redact NAME,NAME]
  extract_session.py project [--project DIR] [--out DIR] [--last N]
                             [--since YYYY-MM-DD] [--no-worktrees]
                             [--min-turns N] [--preview N] [--redact NAME,NAME]

  list      Print sessions for the current project (or --all projects),
            newest first: id, start time, user turns, size, the model(s)
            that answered.
  extract   Write the markdown transcript. Prints the output path last.
            --stats prints a small JSON block of counts before the path.
  project   Extract every session of the project (git worktrees of the
            same checkout included unless --no-worktrees) into a
            directory, one markdown file each, plus index.md with a
            per-session stats table and totals. Prints the index path
            last. --last N keeps the N most recent; --since filters by
            start date; --min-turns drops sessions with fewer typed turns
            (default 2). Also writes <id>.human.md per session with only
            the human's turns. Session count and sizes go to stderr.

  Email addresses and credentials embedded in URLs are always redacted;
  --redact replaces the given names with <name>. --human-only drops the
  assistant's text and keeps only its turn markers.

No dependencies beyond the standard library.
"""
import argparse, json, os, re, sys, glob
from datetime import datetime

HOME = os.path.expanduser("~")
PROJECTS = os.path.join(HOME, ".claude", "projects")


def _dt(ts):
    return datetime.fromisoformat(ts.replace("Z", "+00:00"))


def slug_for(directory):
    return os.path.abspath(directory).replace("/", "-")


def text_of(msg):
    c = msg.get("content")
    if isinstance(c, str):
        return c
    out = []
    for b in c or []:
        if isinstance(b, dict) and b.get("type") == "text":
            out.append(b.get("text", ""))
    return "\n".join(out)


NOISE = [
    (re.compile(r"<task-notification>.*?</task-notification>", re.S), "[task notification]"),
    (re.compile(r"<system-reminder>.*?</system-reminder>", re.S), ""),
    (re.compile(r"<bash-stdout>.*?</bash-stdout>", re.S), "[stdout]"),
    (re.compile(r"<bash-stderr>\s*</bash-stderr>", re.S), ""),
    (re.compile(r"This session is being continued from a previous conversation.*", re.S), "[compaction summary]"),
]


def clean_user(txt, is_meta=False):
    if is_meta:
        m = re.search(r"<command-name>(.*?)</command-name>", txt)
        if m:
            return f"(slash) {m.group(1)}", "slash"
        if txt.startswith("Base directory for this skill:"):
            m = re.search(r"skills/([\w-]+)\s*$", txt.split("\n", 1)[0])
            return f"(skill loaded) {m.group(1) if m else ''}", "slash"
        return "", "skip"
    m = re.search(r"<command-name>(.*?)</command-name>", txt)
    if m:
        return f"(slash) {m.group(1)}", "slash"
    m = re.search(r"<bash-input>(.*?)</bash-input>", txt, re.S)
    if m:
        return f"(ran a command) `{m.group(1).strip()}`", "bash"
    if txt.startswith("<bash-stdout>") or txt.startswith("<bash-stderr>"):
        err = re.search(r"<bash-stderr>(.*?)</bash-stderr>", txt, re.S)
        body = (err.group(1) if err else "").strip()
        return "(command output) " + (body[:160].replace("\n", " ") if body else "[stdout]"), "output"
    if txt.startswith("<local-command") or txt.startswith("[Request interrupted"):
        return "", "skip"
    if txt.startswith("Base directory for this skill:"):
        m = re.search(r"skills/([\w-]+)\s*$", txt.split("\n", 1)[0])
        return f"(skill loaded) {m.group(1) if m else ''}", "slash"
    kind = "text"
    for rx, rep in NOISE:
        if rx.search(txt):
            if rep == "[task notification]":
                kind = "notification"
            elif rep == "[compaction summary]":
                kind = "compaction"
            txt = rx.sub(rep, txt)
    txt = txt.strip()
    return txt, kind


EMAIL = re.compile(r"[\w.+-]+@[\w-]+\.[\w.-]+")
CRED_URL = re.compile(r"(\w+://)[^\s/@]+:[^\s/@]+@")


def redact(txt, names):
    txt = EMAIL.sub("<email>", txt)
    txt = CRED_URL.sub(r"\1<credentials>@", txt)
    for n in names:
        if n:
            txt = re.sub(r"\b" + re.escape(n) + r"\b", "<name>", txt, flags=re.I)
    return txt


def iter_records(path):
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def session_models(path):
    c = {}
    for rec in iter_records(path):
        if rec.get("type") == "assistant":
            m = rec.get("message", {}).get("model") or "unknown"
            c[m] = c.get(m, 0) + 1
    return ", ".join(sorted(c, key=lambda k: -c[k])) or "unknown"


def session_summary(path):
    n = 0
    first = last = None
    for rec in iter_records(path):
        if rec.get("type") != "user":
            continue
        txt = text_of(rec.get("message", {})).strip()
        if not txt:
            continue
        cleaned, kind = clean_user(txt, rec.get("isMeta", False))
        if kind in ("skip", "notification", "compaction", "slash", "bash", "output") or not cleaned:
            continue
        n += 1
        ts = rec.get("timestamp", "")
        first = first or ts
        last = ts
    return n, first, last


def list_sessions(project_dir, all_projects, worktrees=False):
    if all_projects:
        dirs = [os.path.join(PROJECTS, d) for d in os.listdir(PROJECTS)]
    else:
        dirs = project_dirs(project_dir, worktrees)
    rows = []
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for p in glob.glob(os.path.join(d, "*.jsonl")):
            n, first, last = session_summary(p)
            if n == 0:
                continue
            rows.append((os.path.getmtime(p), os.path.basename(d), os.path.basename(p)[:-6], n, first, os.path.getsize(p), session_models(p)))
    rows.sort(reverse=True)
    if not rows:
        print("no sessions found", file=sys.stderr)
        return 1
    for _, proj, sid, n, first, size, models in rows:
        print(f"{sid}  {first[:16] if first else '?':16}  {n:4d} turns  {size/1e6:6.1f} MB  {models:28}  {proj}")
    return 0


def resolve(target, project_dir):
    if target.endswith(".jsonl") and os.path.exists(target):
        return target
    d = os.path.join(PROJECTS, slug_for(project_dir))
    if target == "latest":
        files = sorted(glob.glob(os.path.join(d, "*.jsonl")), key=os.path.getmtime, reverse=True)
        for p in files:
            if session_summary(p)[0] > 0:
                return p
        sys.exit(f"no sessions with user turns in {d}")
    hits = glob.glob(os.path.join(PROJECTS, "*", f"{target}*.jsonl"))
    if len(hits) == 1:
        return hits[0]
    sys.exit(f"could not resolve session {target!r} ({len(hits)} matches)")


def extract(path, out, preview, want_stats, human_only=False, names=()):
    stats = {"user_turns": 0, "user_words": 0, "assistant_turns": 0, "assistant_words": 0,
             "commands_run_by_user": 0, "slash_commands": 0, "subagent_notifications": 0,
             "compactions": 0, "questions_asked_by_user": 0, "first": None, "last": None,
             "models": {}}
    # user_turns / user_words count only what the human typed; slash commands,
    # skill bodies and other injected records (isMeta) are listed but not counted.
    lines = [f"# Session {os.path.basename(path)[:-6]}", "", f"Source: `{path}`", "",
             "Typed human turns are numbered and in full; `+Nm` is the time since the previous typed turn. "
             + ("Assistant turns are listed by length only. " if human_only else "Assistant turns show their head and tail. ")
             + "Injected content (skill bodies, slash-command expansions), commands the human ran and their "
             "output, re-sent messages, and subagent notifications are one line each and not counted. "
             "Email addresses and credentials in URLs are redacted.", ""]
    session_first = session_last = None
    prev_user_ts = None
    prev_user_txt = None
    stats["resent_turns"] = 0
    for rec in iter_records(path):
        t = rec.get("type")
        ts = rec.get("timestamp", "")
        if ts and t in ("user", "assistant"):
            session_first = session_first or ts
            session_last = ts
        msg = rec.get("message", {})
        if t == "user":
            raw = text_of(msg).strip()
            if not raw:
                continue
            txt, kind = clean_user(raw, rec.get("isMeta", False))
            if kind == "skip" or not txt:
                continue
            txt = redact(txt, names)
            if kind == "notification":
                stats["subagent_notifications"] += 1
                lines.append(f"\n> [{ts[11:16]}] {txt[:200]}")
                continue
            if kind == "compaction":
                stats["compactions"] += 1
                lines.append(f"\n> [{ts[11:16]}] [context compacted]")
                continue
            if kind == "bash":
                stats["commands_run_by_user"] += 1
                lines.append(f"\n> [{ts[11:16]}] human {txt}")
                continue
            if kind == "slash":
                stats["slash_commands"] += 1
                lines.append(f"\n> [{ts[11:16]}] human {txt}")
                continue
            if kind == "output":
                lines.append(f"\n> [{ts[11:16]}] {txt}")
                continue
            if prev_user_txt is not None and txt == prev_user_txt and prev_user_ts and \
                    (_dt(ts) - _dt(prev_user_ts)).total_seconds() < 600:
                stats["resent_turns"] += 1
                lines.append(f"\n> [{ts[11:16]}] human re-sent the previous message unchanged")
                continue
            prev_user_txt = txt
            stats["user_turns"] += 1
            stats["user_words"] += len(txt.split())
            stats["questions_asked_by_user"] += txt.count("?")
            stats["first"] = stats["first"] or ts
            stats["last"] = ts
            gap = ""
            if prev_user_ts:
                mins = int((_dt(ts) - _dt(prev_user_ts)).total_seconds() // 60)
                gap = f" +{mins}m"
            prev_user_ts = ts
            lines.append(f"\n### USER #{stats['user_turns']} [{ts[:16].replace('T', ' ')}{gap}]\n{txt}")
        elif t == "assistant":
            txt = text_of(msg).strip()
            if not txt:
                continue
            stats["assistant_turns"] += 1
            model = msg.get("model") or "unknown"
            stats["models"][model] = stats["models"].get(model, 0) + 1
            words = len(txt.split())
            stats["assistant_words"] += words
            if human_only:
                lines.append(f"\n> ASSISTANT [{ts[11:16]}] ({words} words)")
                continue
            txt = redact(txt, names)
            if len(txt) <= preview * 2:
                short = txt
            else:
                head, tail = txt[:preview], txt[-(preview // 2):]
                hidden = words - len(head.split()) - len(tail.split())
                short = f"{head} … [+{max(hidden, 0)} words] … {tail}"
            lines.append(f"\n> ASSISTANT [{ts[11:16]}] ({words} words)\n> " + short.replace("\n", "\n> "))
    if session_first and session_last:
        stats["span_hours"] = round((_dt(session_last) - _dt(session_first)).total_seconds() / 3600, 1)
    models = ", ".join(f"{m} ({n} turns)" for m, n in sorted(stats["models"].items(), key=lambda x: -x[1]))
    lines.insert(3, f"Assistant model: {models or 'unknown'}. Subagents' models are not visible here.")
    with open(out, "w") as f:
        f.write("\n".join(lines) + "\n")
    if want_stats:
        print(json.dumps(stats, indent=2))
    if want_stats is not None:
        print(out)
    return stats


def project_dirs(project_dir, worktrees=True):
    slug = slug_for(project_dir)
    dirs = [os.path.join(PROJECTS, slug)]
    if worktrees:
        for d in os.listdir(PROJECTS):
            if d.startswith(slug + "--claude-worktrees-"):
                dirs.append(os.path.join(PROJECTS, d))
    return [d for d in dirs if os.path.isdir(d)]


def project(project_dir, out_dir, last, since, worktrees, min_turns, preview, names=()):
    files = []
    for d in project_dirs(project_dir, worktrees):
        for p in glob.glob(os.path.join(d, "*.jsonl")):
            n, first, _ = session_summary(p)
            if n < min_turns or not first:
                continue
            if since and first[:10] < since:
                continue
            files.append((first, p, os.path.basename(d)))
    files.sort()
    if last:
        files = files[-last:]
    if not files:
        sys.exit("no sessions matched")
    os.makedirs(out_dir, exist_ok=True)
    rows = []
    totals = {k: 0 for k in ("user_turns", "user_words", "assistant_turns", "assistant_words",
                             "questions_asked_by_user", "commands_run_by_user",
                             "subagent_notifications", "compactions", "span_hours")}
    for first, p, d in files:
        sid = os.path.basename(p)[:-6]
        full = os.path.join(out_dir, f"{sid}.md")
        st = extract(p, full, preview, None, names=names)
        extract(p, os.path.join(out_dir, f"{sid}.human.md"), preview, None, human_only=True, names=names)
        wt = d.split("--claude-worktrees-", 1)[1] if "--claude-worktrees-" in d else "main"
        rows.append((sid, first[:16].replace("T", " "), wt, st, os.path.getsize(full)))
        for k in totals:
            totals[k] += st.get(k, 0)
    lines = [f"# Project sessions: {os.path.abspath(project_dir)}", "",
             f"{len(rows)} sessions, oldest first. `full` has the assistant's turns as head and tail; "
             "`human` has only the human's turns (read that first, it is much smaller). "
             "Typed turns and words exclude injected content, command output, and re-sent messages. "
             "Sessions with fewer than five typed turns are too short to score; say so rather than scoring them.", "",
             "| Session | Start | Worktree | Model | Typed turns | Typed words | Questions | Commands run | Subagent notifications | Compactions | Span h | Size |",
             "| --- | --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |"]
    for sid, start, wt, st, size in rows:
        models = ", ".join(sorted(st["models"], key=lambda k: -st["models"][k])) or "unknown"
        lines.append(f"| {sid[:8]} [full]({sid}.md) [human]({sid}.human.md) | {start} | {wt} | {models} | {st['user_turns']} | {st['user_words']} | "
                     f"{st['questions_asked_by_user']} | {st['commands_run_by_user']} | {st['subagent_notifications']} | "
                     f"{st['compactions']} | {st.get('span_hours', 0)} | {size // 1024} KB |")
        print(f"{sid[:8]}  {start}  {st['user_turns']:4d} typed turns  {size // 1024:5d} KB full", file=sys.stderr)
    lines.append(f"| **total** | | | | {totals['user_turns']} | {totals['user_words']} | {totals['questions_asked_by_user']} | "
                 f"{totals['commands_run_by_user']} | {totals['subagent_notifications']} | {totals['compactions']} | "
                 f"{round(totals['span_hours'], 1)} | |")
    print(f"{len(rows)} sessions extracted to {out_dir}", file=sys.stderr)
    index = os.path.join(out_dir, "index.md")
    with open(index, "w") as f:
        f.write("\n".join(lines) + "\n")
    print(index)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    l = sub.add_parser("list")
    l.add_argument("--project", default=os.getcwd())
    l.add_argument("--all", action="store_true")
    l.add_argument("--worktrees", action="store_true", help="include sessions run from git worktrees of this checkout")
    e = sub.add_parser("extract")
    e.add_argument("target")
    e.add_argument("--project", default=os.getcwd())
    e.add_argument("--out")
    e.add_argument("--preview", type=int, default=400)
    e.add_argument("--stats", action="store_true")
    e.add_argument("--human-only", action="store_true")
    e.add_argument("--redact", default="", help="comma-separated names to replace with <name>")
    pj = sub.add_parser("project")
    pj.add_argument("--redact", default="", help="comma-separated names to replace with <name>")
    pj.add_argument("--project", default=os.getcwd())
    pj.add_argument("--out")
    pj.add_argument("--last", type=int)
    pj.add_argument("--since")
    pj.add_argument("--no-worktrees", action="store_true")
    pj.add_argument("--min-turns", type=int, default=2)
    pj.add_argument("--preview", type=int, default=400)
    a = ap.parse_args()
    if a.cmd == "list":
        sys.exit(list_sessions(a.project, a.all, a.worktrees))
    if a.cmd == "project":
        out = a.out or os.path.join(os.environ.get("TMPDIR", "/tmp"),
                                    "collab-dna-" + os.path.basename(os.path.abspath(a.project)))
        project(a.project, out, a.last, a.since, not a.no_worktrees, a.min_turns, a.preview,
                names=[n.strip() for n in a.redact.split(",") if n.strip()])
        return
    path = resolve(a.target, a.project)
    out = a.out or os.path.join(os.environ.get("TMPDIR", "/tmp"), f"collab-dna-{os.path.basename(path)[:8]}.md")
    extract(path, out, a.preview, a.stats, human_only=a.human_only,
            names=[n.strip() for n in a.redact.split(",") if n.strip()])


if __name__ == "__main__":
    main()
