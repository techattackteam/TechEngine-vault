<#
.SYNOPSIS
    Gives every validated research card a section in Paper.md, and links the card to it.

.DESCRIPTION
    Reads the Kanban board at "05 Research/Research.md". Every card sitting in a column
    other than TO VALIDATE gets a stub section appended to "05 Research/Paper.md", and the
    card itself is rewritten into a link that jumps to that section.

    A section is just the heading and the source link. Everything under it is yours to
    write. Re-running is safe.

    The card keeps its title and loses its raw URL. That URL always lands in the section
    first: into a new section, or into an existing one whose source line is still the
    placeholder. A source link you have edited yourself is never overwritten.

    Obsidian holds the board file open while the board is on screen. Close the board tab
    before running this, or Obsidian may write its own copy back over the rewritten cards.

.PARAMETER VaultRoot
    Vault root. Defaults to the parent of the folder holding this script.

.PARAMETER InboxColumn
    The column treated as the inbox. Cards there are ignored. Matched against the start of
    the column name, so the emoji in the heading does not matter.

.PARAMETER DryRun
    Report what would change and write nothing.

.PARAMETER NoCommit
    Write the files but leave them uncommitted.

.PARAMETER Push
    Push to origin after committing.

.EXAMPLE
    ./Sync-Papers.ps1 -DryRun

.EXAMPLE
    ./Sync-Papers.ps1
#>
[CmdletBinding()]
param(
    [string] $VaultRoot = (Split-Path -Parent $PSScriptRoot),
    [string] $InboxColumn = 'TO VALIDATE',
    [switch] $DryRun,
    [switch] $NoCommit,
    [switch] $Push
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# PowerShell 7.4 turns a non-zero exit from git into a thrown error. The git calls below
# check $LASTEXITCODE themselves, so turn that off rather than wrap each one.
$PSNativeCommandUseErrorActionPreference = $false

$BoardPath = Join-Path $VaultRoot '05 Research/Research.md'
$PapersPath = Join-Path $VaultRoot '05 Research/Paper.md'

$Arrow = [char]0x2192
$PlaceholderSource = '- TODO: add the source link'

# Obsidian resolves a heading link by exact text, and these characters end the anchor early.
function Get-Anchor {
    param([string] $Title)

    $anchor = $Title -replace '[#\[\]\|\^]', ' '
    $anchor = $anchor -replace '\s+', ' '
    return $anchor.Trim()
}

function Split-CardBody {
    param([string] $Body)

    $title = $Body.Trim()
    $url = ''

    if ($title -match "^(.*?)\s*(?:->|=>|$Arrow)\s*(\S+)$") {
        $title = $Matches[1]
        $url = $Matches[2]
    }
    elseif ($title -match '^\[(.+?)\]\((https?://[^)]+)\)$') {
        $title = $Matches[1]
        $url = $Matches[2]
    }
    elseif ($title -match '^(.*\S)\s+(https?://\S+)$') {
        $title = $Matches[1]
        $url = $Matches[2]
    }

    return [pscustomobject]@{
        Title = $title.Trim()
        Url   = ($url -replace '[<>]', '').Trim()
    }
}

function New-PaperStub {
    param([string] $Anchor, [string] $Url)

    $source = if ($Url) { "- $Url" } else { $script:PlaceholderSource }

    return @(
        ''
        "## $Anchor"
        ''
        $source
    )
}

# The card loses its URL when it becomes a link, so the URL has to reach the section
# before that happens. Returns $true when a line was written.
function Set-SectionSource {
    param($Lines, [int] $HeadingIndex, [string] $Url)

    if (-not $Url) { return $false }

    $end = $Lines.Count
    for ($j = $HeadingIndex + 1; $j -lt $Lines.Count; $j++) {
        if ($Lines[$j] -match '^##\s') { $end = $j; break }
    }

    for ($j = $HeadingIndex + 1; $j -lt $end; $j++) {
        if ($Lines[$j] -notmatch '^-\s') { continue }
        if ($Lines[$j] -eq $script:PlaceholderSource) {
            $Lines[$j] = "- $Url"
            return $true
        }
        return $false
    }

    $Lines.Insert($HeadingIndex + 1, "- $Url")
    $Lines.Insert($HeadingIndex + 1, '')
    return $true
}

function Get-HeadingIndex {
    param($Lines)

    $map = @{}
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^##\s+(.+?)\s*$') {
            $map[(Get-Anchor $Matches[1]).ToLowerInvariant()] = $i
        }
    }
    return $map
}

function Read-Lines {
    param([string] $Path)

    $text = [System.IO.File]::ReadAllText($Path)
    $list = [System.Collections.Generic.List[string]]::new()
    foreach ($line in ($text -split "`r?`n")) { $list.Add($line) }

    $newline = "`n"
    if ($text.Contains("`r`n")) { $newline = "`r`n" }

    return [pscustomobject]@{
        Lines   = $list
        Newline = $newline
    }
}

function Write-Lines {
    param([string] $Path, $Lines, [string] $Newline)

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, ($Lines -join $Newline), $encoding)
}

if (-not (Test-Path -LiteralPath $BoardPath)) { throw "Board not found: $BoardPath" }
if (-not (Test-Path -LiteralPath $PapersPath)) { throw "Papers note not found: $PapersPath" }

# --- Collect the cards that have left the inbox ------------------------------------------

$board = Read-Lines $BoardPath
$boardLines = $board.Lines

$inboxPattern = '^' + [regex]::Escape($InboxColumn)
$column = ''
$cards = [System.Collections.Generic.List[object]]::new()

for ($i = 0; $i -lt $boardLines.Count; $i++) {
    $line = $boardLines[$i]

    if ($line.StartsWith('%% kanban:settings')) { break }

    if ($line -match '^##\s+(.+?)\s*$') {
        $column = $Matches[1]
        continue
    }

    if (-not $column) { continue }
    if ($line -notmatch '^(\s*-\s+\[[ xX]\]\s+)(\S.*)$') { continue }

    $prefix = $Matches[1]
    $body = $Matches[2]

    $plainColumn = ($column -replace '[^\p{L}\p{N} ]', '').Trim()
    if ($plainColumn -imatch $inboxPattern) { continue }

    if ($body -match '^\[\[Paper#([^\]\|]+?)(?:\|[^\]]*)?\]\]') {
        $anchor = Get-Anchor $Matches[1]
        $title = $anchor
        $url = ''
    }
    else {
        $parsed = Split-CardBody $body
        $anchor = Get-Anchor $parsed.Title
        $title = $parsed.Title
        $url = $parsed.Url
    }

    if (-not $anchor) { continue }

    $cards.Add([pscustomobject]@{
            LineIndex = $i
            Prefix    = $prefix
            Column    = $column
            Title     = $title
            Anchor    = $anchor
            Url       = $url
        })
}

if ($cards.Count -eq 0) {
    Write-Host 'No cards have left the inbox. Nothing to do.'
    return
}

# --- Index what Paper.md already holds ---------------------------------------------------

$papers = Read-Lines $PapersPath
$papersLines = $papers.Lines

$headings = Get-HeadingIndex $papersLines

# --- Add the missing sections, fill the sources, relink the cards -------------------------

$added = [System.Collections.Generic.List[string]]::new()
$sourced = 0
$relinked = 0

foreach ($card in $cards) {
    $key = $card.Anchor.ToLowerInvariant()

    if (-not $headings.ContainsKey($key)) {
        $stub = New-PaperStub -Anchor $card.Anchor -Url $card.Url
        $headings[$key] = $papersLines.Count + 1
        foreach ($stubLine in $stub) { $papersLines.Add($stubLine) }
        $added.Add($card.Anchor)
    }
    elseif (Set-SectionSource -Lines $papersLines -HeadingIndex $headings[$key] -Url $card.Url) {
        $headings = Get-HeadingIndex $papersLines
        $sourced++
    }

    $newLine = "$($card.Prefix)[[Paper#$($card.Anchor)|$($card.Title)]]"
    if ($boardLines[$card.LineIndex] -ne $newLine) {
        $boardLines[$card.LineIndex] = $newLine
        $relinked++
    }
}

if ($papersLines.Count -eq 0 -or $papersLines[$papersLines.Count - 1] -ne '') { $papersLines.Add('') }

if ($added.Count -eq 0 -and $sourced -eq 0 -and $relinked -eq 0) {
    Write-Host 'The board and Paper.md already agree. Nothing to do.'
    return
}

foreach ($anchor in $added) { Write-Host "  + $anchor" }
$summary = "$($added.Count) section(s) added, $sourced source(s) filled, $relinked card(s) relinked."

if ($DryRun) {
    Write-Host "Dry run. $summary Nothing written."
    return
}

Write-Lines -Path $PapersPath -Lines $papersLines -Newline $papers.Newline
Write-Lines -Path $BoardPath -Lines $boardLines -Newline $board.Newline
Write-Host $summary

# --- Commit -------------------------------------------------------------------------------

if ($NoCommit) {
    Write-Host 'Left uncommitted (-NoCommit).'
    return
}

git -C $VaultRoot rev-parse --git-dir *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Warning 'The vault is not a git repository. Skipping the commit.'
    $global:LASTEXITCODE = 0
    return
}

$branch = (git -C $VaultRoot rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne 'master') {
    Write-Warning "The vault is on '$branch'. ADR-012 expects vault commits on master."
}

$message = if ($added.Count -eq 1) {
    "Add the Paper entry for $($added[0])"
}
elseif ($added.Count -gt 1) {
    "Add Paper entries for $($added.Count) research cards"
}
elseif ($sourced -gt 0) {
    'Fill in the missing Paper source links'
}
else {
    'Relink the research cards to their Paper entries'
}

git -C $VaultRoot commit -q -m $message -- '05 Research/Paper.md' '05 Research/Research.md'
if ($LASTEXITCODE -ne 0) { throw 'The commit failed. The files are written but uncommitted.' }
Write-Host "Committed: $message"

if ($Push) {
    git -C $VaultRoot push
    if ($LASTEXITCODE -ne 0) { throw 'The push failed. The commit is local.' }
    Write-Host 'Pushed.'
}
