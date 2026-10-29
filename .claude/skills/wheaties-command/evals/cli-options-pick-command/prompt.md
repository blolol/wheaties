---
tags: [wheaties-command]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Write a Wheaties command `.pick` that picks random items from the choices I give it, like `.pick pizza tacos sushi`. I want `-n`/`--count` to pick more than one, `-u`/`--unique` so the same item can't be picked twice, and `-s`/`--separator` to change what goes between the picked items, e.g. `.pick -n 3 -u pizza tacos sushi ramen`. Other commands should be able to call it too.
