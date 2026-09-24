#!/usr/bin/env python3
"""Generate docs/DOCUMENT_INDEX.md deterministically for long maintained docs.

Documents under docs/ with strictly more than THRESHOLD_WORDS words
(whitespace-separated tokens in the decoded UTF-8 source) are indexed by
heading, hierarchical context and 1-based inclusive line ranges. The generated
file is a locator, not a substitute for reading the applicable rules.

Run ``python build_document_index.py`` after an indexed source changes, is
renamed or crosses the threshold in either direction. Repeated runs against
identical sources produce byte-identical output; no volatile timestamp is
written. The normal validator checks freshness and coverage read-only.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

THRESHOLD_WORDS = 5000
INDEX_NAME = "DOCUMENT_INDEX.md"
TEXT_SUFFIXES = {".md", ".txt"}
CONTINUATION_LINES = 200

FENCE_RE = re.compile(r"^ {0,3}(```|~~~)")
ATX_RE = re.compile(r"^ {0,3}(#{1,6})[ \t]+(.*)$")
SLUG_RE = re.compile(r"[^\w\s-]", re.UNICODE)


def repo_root() -> Path:
    return Path(__file__).resolve().parent


def inventory_docs(root: Path) -> list[Path]:
    """Return maintained UTF-8 text docs under docs/, excluding the index."""
    docs = root / "docs"
    result = []
    for path in sorted(docs.rglob("*")):
        if not path.is_file():
            continue
        if path.relative_to(docs).as_posix() == INDEX_NAME:
            continue
        if path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        result.append(path)
    return result


def read_utf8(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def word_count(text: str) -> int:
    return len(text.split())


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def slug(title: str) -> str:
    value = title.strip().lower().replace(" ", "-")
    return SLUG_RE.sub("", value)


def parse_sections(text: str) -> list[dict]:
    """Split source into contiguous heading-anchored sections.

    ATX headings inside fenced code blocks are ignored. Repeated headings are
    disambiguated by ancestry and occurrence. Introductory text before the
    first heading is retained as a preamble section.
    """
    lines = text.splitlines()
    total = len(lines)
    sections = []
    stack = []
    current = None
    fence = None
    occurrences = {}

    for number, line in enumerate(lines, 1):
        if fence is not None:
            if FENCE_RE.match(line):
                fence = None
            continue
        fence_match = FENCE_RE.match(line)
        if fence_match:
            fence = fence_match.group(1)
            continue
        heading = ATX_RE.match(line)
        if not heading:
            continue

        title = heading.group(2).strip()
        title = re.sub(r"[ \t]+#+[ \t]*$", "", title).strip()
        level = len(heading.group(1))

        if current is not None:
            current["end"] = number - 1
        while stack and stack[-1]["level"] >= level:
            stack.pop()

        parents = [entry["title_display"] for entry in stack]
        key = (level, title, tuple(entry["title"] for entry in stack))
        occurrence = occurrences.get(key, 0) + 1
        occurrences[key] = occurrence
        display = title if occurrence == 1 else f"{title} ({occurrence})"

        current = {
            "level": level,
            "title": title,
            "title_display": display,
            "parents": list(parents),
            "start": number,
            "end": total,
        }
        sections.append(current)
        stack.append({"level": level, "title": title, "title_display": display})

    if current is not None:
        current["end"] = total

    first_start = sections[0]["start"] if sections else total + 1
    if first_start > 1:
        sections.insert(
            0,
            {
                "level": 0,
                "title": "(Preamble)",
                "title_display": "(Preamble)",
                "parents": [],
                "start": 1,
                "end": first_start - 1,
            },
        )
    return sections


def chunk_sections(sections):
    """Bound very long sections into deterministic continuation ranges."""
    entries = []
    for section in sections:
        start, end = section["start"], section["end"]
        if end < start:
            continue
        if end - start + 1 <= CONTINUATION_LINES:
            entries.append(
                {
                    "title_display": section["title_display"],
                    "parents": section["parents"],
                    "start": start,
                    "end": end,
                }
            )
            continue
        part = 1
        cursor = start
        while cursor <= end:
            stop = min(cursor + CONTINUATION_LINES - 1, end)
            label = (
                section["title_display"]
                if part == 1
                else f"{section['title_display']} [part {part}]"
            )
            entries.append(
                {
                    "title_display": label,
                    "parents": section["parents"],
                    "start": cursor,
                    "end": stop,
                }
            )
            part += 1
            cursor = stop + 1
    return entries


def collect_documents(root):
    docs = root / "docs"
    records = []
    for path in inventory_docs(root):
        text = read_utf8(path)
        words = word_count(text)
        if words <= THRESHOLD_WORDS:
            continue
        relative = path.relative_to(docs).as_posix()
        records.append(
            {
                "path": relative,
                "words": words,
                "sha256": sha256(path),
                "sections": chunk_sections(parse_sections(text)),
            }
        )
    records.sort(key=lambda record: record["path"])
    return records


def build_meta(records):
    documents = [
        {"path": record["path"], "words": record["words"], "sha256": record["sha256"]}
        for record in records
    ]
    return json.dumps(
        {
            "generated_by": "build_document_index.py",
            "threshold_words": THRESHOLD_WORDS,
            "documents": documents,
        },
        ensure_ascii=False,
        sort_keys=True,
    )


def build_index(root):
    records = collect_documents(root)
    lines = []
    lines.append("# Document index - Caelum Argenteum")
    lines.append("")
    lines.append("Generated by `build_document_index.py`. Do not edit this file manually.")
    lines.append(
        "It indexes maintained documents under `docs/` with strictly more than "
        f"{THRESHOLD_WORDS} words (whitespace-separated tokens). Exactly "
        f"{THRESHOLD_WORDS} words does not qualify. This file is a locator, not "
        "a substitute for reading the applicable rules."
    )
    lines.append("")
    lines.append(
        "Regenerate after an indexed source changes, is renamed or crosses the "
        "threshold in either direction:"
    )
    lines.append("")
    lines.append("```text")
    lines.append("python build_document_index.py")
    lines.append("```")
    lines.append("")
    lines.append("## Search and read commands")
    lines.append("")
    lines.append("List the indexed documents:")
    lines.append("")
    lines.append("```text")
    lines.append("python build_document_index.py list")
    lines.append("```")
    lines.append("")
    lines.append("List section entries matching a document or topic:")
    lines.append("")
    lines.append("```text")
    lines.append('python build_document_index.py list "prisoner"')
    lines.append("```")
    lines.append("")
    lines.append("Read a selected inclusive line range from the original:")
    lines.append("")
    lines.append("```text")
    lines.append("python build_document_index.py read SYSTEMS.md 3643 3676")
    lines.append("```")
    lines.append("")

    slug_counts = {}
    for record in records:
        for section in record["sections"]:
            base_title = section["title_display"].split(" [part ")[0]
            value = slug(base_title)
            slug_counts[value] = slug_counts.get(value, 0) + 1

    for record in records:
        path = record["path"]
        lines.append(f"## [{path}]({path}) - {record['words']} words")
        lines.append("")
        lines.append(f"SHA-256: `{record['sha256']}`")
        lines.append("")
        for section in record["sections"]:
            base_title = section["title_display"].split(" [part ")[0]
            value = slug(base_title)
            if slug_counts.get(value, 0) == 1:
                heading = f"[{section['title_display']}]({path}#{value})"
            else:
                heading = f"`{section['title_display']}`"
            context = " > ".join(section["parents"]) if section["parents"] else "-"
            lines.append(
                f"- Lines {section['start']}-{section['end']} - {heading} - "
                f"context: {context}"
            )
        lines.append("")

    lines.append("<!-- DOCUMENT_INDEX_META")
    lines.append(build_meta(records))
    lines.append("DOCUMENT_INDEX_META -->")
    lines.append("")
    return "\n".join(lines)


def write_index(root):
    target = root / "docs" / INDEX_NAME
    target.write_text(build_index(root) + "\n", encoding="utf-8", newline="\n")
    return target


def parse_index_meta(text):
    match = re.search(
        r"<!-- DOCUMENT_INDEX_META\s*\n(.*?)\nDOCUMENT_INDEX_META -->",
        text,
        re.S,
    )
    if not match:
        return None
    try:
        return json.loads(match.group(1))
    except ValueError:
        return None


def list_matches(root, query):
    records = collect_documents(root)
    lowered = query.lower() if query else ""
    for record in records:
        if not query:
            print(
                f"{record['path']}: {record['words']} words, "
                f"{len(record['sections'])} section entries"
            )
            continue
        for section in record["sections"]:
            haystack = " ".join(
                [
                    record["path"],
                    section["title_display"],
                    " ".join(section["parents"]),
                ]
            ).lower()
            if lowered in haystack:
                context = " > ".join(section["parents"]) or "-"
                print(
                    f"{record['path']} lines {section['start']}-{section['end']}: "
                    f"{section['title_display']} (context: {context})"
                )


def read_range(root, relative, start, end):
    docs = root / "docs"
    target = (docs / relative).resolve()
    docs_resolved = docs.resolve()
    if not target.is_relative_to(docs_resolved) or not target.is_file():
        print(f"error: {relative} is not a file under docs/", file=sys.stderr)
        return 2
    lines = read_utf8(target).splitlines()
    if start < 1 or end < start or end > len(lines):
        print(
            f"error: range {start}-{end} is outside 1-{len(lines)} for {relative}",
            file=sys.stderr,
        )
        return 2
    print(f"# {relative} lines {start}-{end} (inclusive)")
    for number in range(start, end + 1):
        print(f"{number}: {lines[number - 1]}")
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command")

    list_parser = subparsers.add_parser(
        "list", help="list indexed documents or matching section entries"
    )
    list_parser.add_argument("query", nargs="?", default=None)

    read_parser = subparsers.add_parser(
        "read", help="print an inclusive line range from a doc under docs/"
    )
    read_parser.add_argument("path")
    read_parser.add_argument("start", type=int)
    read_parser.add_argument("end", type=int)

    args = parser.parse_args(argv)
    root = repo_root()

    if args.command == "list":
        list_matches(root, args.query)
        return 0
    if args.command == "read":
        return read_range(root, args.path, args.start, args.end)

    target = write_index(root)
    records = collect_documents(root)
    print(f"Wrote {target.relative_to(root).as_posix()}")
    for record in records:
        print(
            f"{record['path']}: {record['words']} words, "
            f"{len(record['sections'])} section entries"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())