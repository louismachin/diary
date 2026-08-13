# diary

A tiny command-line diary, written in Nim.

```
diary                  open (or start) today's entry in $EDITOR
diary yyyy-MM-dd        open a specific past entry
diary list               list every day that has an entry
diary path                print where entries are stored
diary help                 show usage
```

Entries are stored one plaintext file per day (`~/.diary/2026-08-13.txt` by
default). Every time you run `diary`, it appends a fresh block to today's
file and opens your editor with the cursor sitting right on the new blank
line:

```
Thu, Aug 13 2026 - 10:15 AM
☉︎ in 20°40' Leo, ☽︎ in 29°21' Leo
I did such and such this morning.

Thu, Aug 13 2026 - 1:34 PM
☉︎ in 20°40' Leo, ☽︎ in 31°04' Leo
[cursor here]
```

The Sol/Luna line comes from `getThelemicDate()`, which calls
`https://louismachin.com/api/thelemic_date.json` fresh on every launch (not
just once a day, since the positions shift throughout the day). If that
request fails for any reason (offline, timeout, endpoint down) it's silently
skipped — you still get your timestamp and the editor still opens right on
the blank line, just without that line.

Jumping to the right line on open uses the `+N` line-number convention
shared by vim, nvim, nano, emacs (terminal), and classic vi, so it should
work with whatever `$EDITOR` you have set.

## Build

Requires the Nim compiler (`apt install nim`, or via your package manager).
The `-d:ssl` flag is required since the Thelemic date fetch is over HTTPS.

```
nim c -d:release -d:ssl -o:diary diary.nim
```

Note: Nim's `httpclient` loads OpenSSL at runtime rather than linking it at
compile time, so the machine you run `diary` on needs `libssl` installed
(virtually always already the case on Linux/macOS).

A prebuilt `diary` binary (Linux x86_64) is included too — just make sure
it's executable and on your `$PATH`:

```
chmod +x diary
mv diary /usr/local/bin/diary
```

## Configuration

Both are optional, read from the environment:

- `DIARY_DIR` — where entries live (default `~/.diary`)
- `EDITOR` (or `VISUAL`) — which editor to launch (falls back to
  nvim → vim → nano → vi, whichever it finds first)

## Archiving to a server later

You mentioned wanting to POST entries to an archive server via cron —
intentionally left out for now since you're building that part yourself.
When you're ready, the natural hook is a small script that runs on a
schedule (e.g. nightly via cron) and POSTs any `.md` files under
`DIARY_DIR` that changed that day. Since entries are just one plain
Markdown file per date, it's easy to read and ship them from any language
or script without touching `diary.nim` itself.