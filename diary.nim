import std/[os, times, strformat, strutils, algorithm, httpclient, json]

# ---------------------------------------------------------------------------
# diary - a tiny command-line diary
#
#   diary                   open (or start) today's entry in $EDITOR
#   diary yyyy-MM-dd        open a specific past entry
#   diary list              list every day that has an entry
#   diary path              print where entries are stored
#   diary help              show usage
#
# Entries are stored as one plaintext file per day. Every launch appends a
# fresh timestamped block (date/time + Sol/Luna position) to that day's file
# and drops the cursor on the new blank line underneath it, so the day's
# file ends up as a running log of dated entries rather than one big blob.
# ---------------------------------------------------------------------------

proc getDiaryDir(): string =
  ## Storage directory. Override with $DIARY_DIR, defaults to ~/.diary
  let envDir = getEnv("DIARY_DIR")
  if envDir.len > 0:
    return expandTilde(envDir)
  return getHomeDir() / ".diary"

proc getEditor(): string =
  ## Respect $EDITOR / $VISUAL first, then fall back to whatever is installed.
  let visual = getEnv("VISUAL")
  if visual.len > 0:
    return visual
  let editor = getEnv("EDITOR")
  if editor.len > 0:
    return editor
  for candidate in ["nvim", "vim", "nano", "vi"]:
    if findExe(candidate).len > 0:
      return candidate
  return "vi"

proc getThelemicDate(): string =
  ## Fetches today's Thelemic date (sun/moon positions) from
  ## louismachin.com and returns it as one line, e.g.
  ##   ☉︎ in 20°40' Leo, ☽︎ in 29°21' Leo
  const url = "https://louismachin.com/api/thelemic_date.json"
  var client = newHttpClient(timeout = 3000)
  defer: client.close()
  try:
    let body = client.getContent(url)
    let data = parseJson(body)
    let sol = data{"sol"}.getStr("")
    let luna = data{"luna"}.getStr("")
    if sol.len > 0 and luna.len > 0:
      result = sol & ", " & luna
  except CatchableError:
    result = ""

proc formatTimestamp(d: DateTime): string =
  ## e.g. "Thu, Aug 13 2026 - 9:27 AM"
  d.format("ddd, MMM d yyyy") & " - " & d.format("h:mm tt")

proc entryPath(dir: string, d: DateTime): string =
  dir / (d.format("yyyy-MM-dd") & ".txt")

proc appendEntryBlock(path: string, timestamp, solLuna: string): int =
  ## Appends a new entry block to `path` (creating it if needed):
  ##   Thu, Aug 13 2026 - 9:27 AM
  ##   ☉︎ in 20°40' Leo, ☽︎ in 29°21' Leo
  ##   <blank line - cursor lands here>
  ## Blocks after the first are separated from the previous one by a blank
  ## line. Returns the line number of the new blank line, so the editor can
  ## be told to open right there.
  var existing = ""
  if fileExists(path):
    existing = readFile(path)

  var blockLines: seq[string] = @[]
  if existing.len > 0:
    blockLines.add("") # separator between this entry and the previous one
  blockLines.add(timestamp)
  if solLuna.len > 0:
    blockLines.add(solLuna)
  blockLines.add("") # blank line where the cursor lands

  let newContent = existing & blockLines.join("\n") & "\n"
  writeFile(path, newContent)
  result = newContent.count('\n')

proc openInEditor(path: string, line: int = 0) =
  let editor = getEditor()
  # "+N" to jump to a line on open is a shared convention across 
  # vim, nvim, nano, emacs (terminal), and classic vi.
  let lineArg = if line > 0: "+" & $line & " " else: ""
  let cmd = editor & " " & lineArg & quoteShell(path)
  let code = execShellCmd(cmd)
  if code != 0:
    echo &"[diary] editor exited with code {code}"
    quit(code)

proc openToday(dir: string) =
  let now = now()
  let path = entryPath(dir, now)
  let solLuna = getThelemicDate()
  let line = appendEntryBlock(path, formatTimestamp(now), solLuna)
  openInEditor(path, line)

proc openDate(dir, dateStr: string) =
  var parsed: DateTime
  try:
    parsed = parse(dateStr, "yyyy-MM-dd")
  except TimeParseError:
    echo &"[diary] '{dateStr}' isn't a date (expected yyyy-MM-dd)"
    quit(1)

  let path = entryPath(dir, parsed)
  if not fileExists(path):
    echo &"[diary] no entry for {dateStr} yet"
    quit(1)
  openInEditor(path)

proc listEntries(dir: string) =
  if not dirExists(dir):
    echo "[diary] no entries yet"
    return

  var dates: seq[string]
  for _, path in walkDir(dir):
    let name = extractFilename(path)
    if name.endsWith(".txt"):
      dates.add(name[0 ..< name.len - 4])

  if dates.len == 0:
    echo "[diary] no entries yet"
    return

  dates.sort()
  for d in dates:
    echo d

proc printHelp() =
  echo """diary - a tiny command-line diary

Usage:
  diary                 open (or start) today's entry
  diary yyyy-MM-dd        open a specific past entry
  diary list               list every day that has an entry
  diary path                print where entries are stored
  diary help                 show this help

Environment:
  DIARY_DIR    where entries are stored (default: ~/.diary)
  EDITOR       editor to launch (default: nvim/vim/nano/vi, whichever exists)"""

when isMainModule:
  let dir = getDiaryDir()
  if not dirExists(dir):
    createDir(dir)

  let args = commandLineParams()
  if args.len == 0:
    openToday(dir)
  else:
    case args[0]
    of "list", "-l", "--list":
      listEntries(dir)
    of "path":
      echo dir
    of "help", "-h", "--help":
      printHelp()
    else:
      openDate(dir, args[0])