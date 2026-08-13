# diary

A tiny command-line diary, written in Nim.

```
diary                   open (or start) today's entry in $EDITOR
diary yyyy-MM-dd        open a specific past entry
diary list              list every day that has an entry
diary path              print where entries are stored
diary help              show usage
```

Entries are stored one plaintext file per day (`~/.diary/2026-08-13.txt` by default).
Every time you run `diary`, it appends a fresh block to today's file and opens your
editor with the cursor sitting right on the new blank line:

```
Thu, Aug 13 2026 - 10:15 AM
☉︎ in 20°40' Leo, ☽︎ in 29°21' Leo
I did such and such this morning.

Thu, Aug 13 2026 - 1:34 PM
☉︎ in 20°40' Leo, ☽︎ in 31°04' Leo
[cursor here]
```

## Build

Requires the Nim compiler (`apt install nim`, or via your package manager).
The `-d:ssl` flag is required since the Thelemic date fetch is over HTTPS.

```
nim c -d:release -d:ssl -o:diary diary.nim
```

A prebuilt `diary` binary (Linux x86_64) is included too, just make sure
it's executable and on your `$PATH`:

```
chmod +x diary
mv diary /usr/local/bin/diary
```

## Configuration

Both are optional, read from the environment:

- `DIARY_DIR` - where entries live (default `~/.diary`)
- `EDITOR` (or `VISUAL`) - which editor to launch
  (falls back to nvim → vim → nano → vi, whichever it finds first)