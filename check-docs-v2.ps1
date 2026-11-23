# check-docs-v2.ps1 — 《强化学习之旅》第二版体检
# 用法: powershell -NoProfile -ExecutionPolicy Bypass -File check-docs-v2.ps1
param([switch]$OutlineOnly)   # -OutlineOnly: 只校验目录/规范/实验设计，正文未写时不算错误
$ErrorActionPreference = 'Continue'
$root = 'H:\AI_Study\deepseek_harness\reinforcement-learning-journey'
$dir = Join-Path $root 'docs'

# 33 章 + 预备文件。编号 -> 期望文件名
$expected = @{
  '00-overview.md'                  = 0
  '01-bandit-exploration.md'        = 1
  '02-mdp-bellman.md'               = 2
  '03-value-policy-iteration.md'    = 3
  '04-model-free-control.md'        = 4
  '05-function-approximation-dqn.md'= 5
  '06-policy-gradient-actor-critic.md' = 6
  '07-ppo.md'                       = 7
  '08-offline-rl-sequence-modeling.md' = 8
  '09-llm-rl-formalization.md'      = 9
  '10-learned-reward.md'            = 10
  '11-verifiable-reward.md'         = 11
  '12-grpo.md'                      = 12
  '13-grpo-defects.md'              = 13
  '14-fixes-sequence-value-difficulty.md' = 14
  '15-what-rl-changes.md'           = 15
  '16-agentic-formalization.md'     = 16
  '17-credit-assignment.md'         = 17
  '18-environment-verifier.md'      = 18
  '19-internalize-externalize.md'   = 19
  '20-agentic-evaluation.md'        = 20
  '21-lever-exploration.md'         = 21
  '22-lever-long-training.md'       = 22
  '23-lever-environment-data.md'    = 23
  '24-lever-architecture.md'        = 24
  '25-stability-diagnostics.md'     = 25
  '26-constraints-safety.md'        = 26
  '27-reward-consolidation.md'      = 27
  '28-industry-sequential.md'       = 28
  '29-games-embodied.md'            = 29
  '30-science-optimization.md'      = 30
  '31-training-systems.md'          = 31
  '32-eval-debug-repro.md'          = 32
  '33-capstone.md'                  = 33
}
$exempt = @('00-overview.md')   # 全景章不套正文模板

$problems = New-Object System.Collections.Generic.List[string]

# ── 1. 文件齐全性与额外文件 ───────────────────────────────────────────────
$present = @(Get-ChildItem $dir -Filter *.md -File | ForEach-Object { $_.Name })
$pending = New-Object System.Collections.Generic.List[string]
foreach ($f in $expected.Keys) {
  if ($present -notcontains $f) {
    if ($OutlineOnly) { $pending.Add($f) } else { $problems.Add("MISSING CHAPTER FILE: $f") } } }
foreach ($f in $present) {
  if ($expected.Keys -notcontains $f -and $f -notin @('README.md','_STYLE-GUIDE.md','_EXPERIMENTS.md')) {
    $problems.Add("UNEXPECTED FILE: $f")
  }
}

# ── 2. 逐章结构 ──────────────────────────────────────────────────────────
$files = @(Get-ChildItem $dir -Filter *.md -File | Where-Object {
  ($expected.Keys -contains $_.Name) -and $_.Name -ne '00-overview.md'
} | Sort-Object Name)

$rows = @()
$allSlugs = @{}
foreach ($f in $files) {
  $name = $f.Name
  $lines = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
  $text  = $lines -join "`n"

  $body = New-Object System.Collections.ArrayList
  $inFence0 = $false
  foreach ($ln in $lines) {
    if ($ln -match '^\s*```') { $inFence0 = -not $inFence0; continue }
    if (-not $inFence0) { [void]$body.Add($ln) }
  }
  $code = $body -join "`n"
  $h2 = @($body | Where-Object { $_ -match '^## ' })
  $sec = @($body | Where-Object { $_ -match '^### ' }).Count
  $eq  = [int]((@($body | Where-Object { $_ -match '^\$\$' }).Count) / 2)
  $tbl = @($body | Where-Object { $_ -match '^\|' }).Count
  $tip = @($body | Where-Object { $_ -match '>\s*\*\*(工程提示|常见错误)' }).Count
  $sum = @($body | Where-Object { $_ -match '^\*\*小结\*\*' }).Count
  $ask = @($body | Where-Object { $_ -match '>\s*\*\*本节回答的问题\*\*' }).Count
  $end = @($body | Where-Object { $_ -match '^\*\*本章收束\*\*' }).Count
  $ev  = @($body | Where-Object { $_ -match '>\s*\*\*证据强度\*\*' }).Count
  $bd  = @($body | Where-Object { $_ -match '>\s*\*\*本章边界\*\*' }).Count
  $q0  = @($body | Where-Object { $_ -match '>\s*\*\*本章回答的问题\*\*' }).Count

  # 章标题必须唯一且编号正确
  $num = $expected[$name]
  if ($h2.Count -ne 1) { $problems.Add("${name}: expected 1 '## ' title, found $($h2.Count)") }
  elseif ($h2[0] -notmatch "^## $num\. ") { $problems.Add("${name}: title should start with '## $num. ', found '$($h2[0])'") }

  # 页首三行
  if ($q0 -ne 1) { $problems.Add("${name}: '本章回答的问题' count $q0 (need exactly 1)") }
  if ($ev -lt 1) { $problems.Add("${name}: MISSING '证据强度' line (required)") }
  elseif ($text -notmatch '>\s*\*\*证据强度\*\*：(📕|📗|📙|📓)') {
    $problems.Add("${name}: '证据强度' must start with one of 📕/📗/📙/📓") }
  if ($bd -ne 1) { $problems.Add("${name}: '本章边界' count $bd (need exactly 1)") }

  # 节级结构
  if ($ask -lt $sec) { $problems.Add("${name}: $sec sections but only $ask '本节回答的问题'") }
  if ($sum -lt ($sec - 1)) { $problems.Add("${name}: $sec sections but only $sum 小结 (need >= $($sec-1))") }
  if ($end -ne 1) { $problems.Add("${name}: 章末收束 count $end (need exactly 1)") }

  # 密度
  if ($eq -lt 5)  { $problems.Add("${name}: only $eq display formulas (soft min 5)") }
  if ($tbl -lt 8) { $problems.Add("${name}: only $tbl table rows") }
  if ($tip -lt 2) { $problems.Add("${name}: only $tip 工程提示/常见错误 (need >=3)") }
  if ($lines.Count -lt 130) { $problems.Add("${name}: only $($lines.Count) lines (target 140-240)") }
  if ($lines.Count -gt 420) { $problems.Add("${name}: $($lines.Count) lines (over 420 hard cap)") }

  # 繁体字混入（写作过程中最易发生的一类错字）
  if ($code -match '[\u3040-\u30FF]') { $problems.Add("${name}: kana character found (Japanese kana mixed into Chinese text)") }
  $tradSet = '問題這們為時說對開學實數優獎訓練評環驗證與從會過還讓麼樣點線據體變現發個'
  foreach ($ch in $tradSet.ToCharArray()) {
    if ($text.Contains([string]$ch)) { $problems.Add("${name}: traditional character [$ch] found (should be simplified)") }
  }

  # 层级与锚点
  if ($code -match '(?m)^#{5,}') { $problems.Add("${name}: heading deeper than ####") }
  if ($text -match '\\\(|\\\[') { $problems.Add("${name}: uses \( \) or \[ \] math delimiters (use dollar signs)") }
  $inFence = $false
  foreach ($ln in $lines) {
    if ($ln -match '^\s*```') { $inFence = -not $inFence; continue }
    if ($inFence) { continue }
    if ($ln -match '^#{2,4} ') {
      $s = ($ln -replace '^#+\s*','').Trim().ToLower()
      $s = $s -replace '\$[^$]*\$','' -replace '[`*_]',''
      $s = $s -replace '[^\p{L}\p{Nd}\s-]','' -replace '\s+','-'
      $allSlugs[($s -replace '-{2,}','-').Trim('-')] = $name
    }
  }

  $rows += [pscustomobject]@{ File=$name; Num=$num; Lines=$lines.Count; Sec=$sec; Eq=$eq; Tbl=$tbl; Note=$tip; Sum=$sum; Ask=$ask; Ev=$ev; Bd=$bd; Close=$end }
}

$rows | Format-Table -AutoSize

# ── 3. 跨文件链接 / 章内锚点 ──────────────────────────────────────────────
$cross = 0; $bad = 0
foreach ($f in $files) {
  $text = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
  $m = [regex]::Matches($text, '\]\((?:[0-9]{2}-|_)[A-Za-z0-9._-]*\.md')
  if ($m.Count -gt 0) { $cross += $m.Count; $problems.Add("$($f.Name): $($m.Count) cross-file links (use plain text refs)") }
  foreach ($mm in [regex]::Matches($text, '\]\(#([^)\s]+)\)')) {
    if (-not $allSlugs.ContainsKey($mm.Groups[1].Value)) {
      $bad++; $problems.Add("$($f.Name): unresolved anchor #$($mm.Groups[1].Value)") }
  }
}

# ── 4. README 链接可达 + 目录章数 ─────────────────────────────────────────
$readmePath = Join-Path $root 'README.md'
$readmeChapters = 0
if (Test-Path $readmePath) {
  $rt = [System.IO.File]::ReadAllText($readmePath, [System.Text.Encoding]::UTF8)
  foreach ($m in [regex]::Matches($rt, '\]\(([0-9]{2}-[A-Za-z0-9._-]*\.md|_[A-Za-z0-9._-]*\.md)\b')) {
    $t = $m.Groups[1].Value
    if (-not (Test-Path (Join-Path $dir $t)) -and -not (Test-Path (Join-Path $root $t))) { $problems.Add("README -> missing file: $t") }
  }
  # 统计目录表里的章行（以 "| N |" 开头的表行）
  $tocPart = ($rt -split '## 变更说明')[0]
  $readmeChapters = @($tocPart -split "`n" | Where-Object { $_ -match '^\|\s*(0|[1-9]|[12][0-9]|3[0-3])\s*\|' }).Count

} else { $problems.Add('MISSING README.md') }

# ── 5. 边界表行数（规范第四节应覆盖全部 33 章）────────────────────────────
$stylePath = Join-Path $root '_STYLE-GUIDE.md'
$boundaryRows = 0
if (Test-Path $stylePath) {
  $st = [System.IO.File]::ReadAllText($stylePath, [System.Text.Encoding]::UTF8)
  $boundaryRows = @($st -split "`n" | Where-Object { $_ -match '^\|\s*(0|[1-9]|[12][0-9]|3[0-3])\s*\|' }).Count
  if ($boundaryRows -ne 34) { $problems.Add("_STYLE-GUIDE.md: boundary table has $boundaryRows chapter rows (expected 34 = ch0 + 33)") }
  # 证据强度四级定义必须齐全
  foreach ($sym in @('📕','📗','📙','📓')) {
    if ($st -notmatch [regex]::Escape($sym)) { $problems.Add("_STYLE-GUIDE.md: evidence symbol $sym not defined") }
  }
  if ($st -notmatch 'on-policy vs off-policy') { $problems.Add('_STYLE-GUIDE.md: missing the on/off-policy vs offline confusion warning') }
} else { $problems.Add('MISSING _STYLE-GUIDE.md') }

# ── 6. 实验设计文档 ──────────────────────────────────────────────────────
$expPath = Join-Path $root '_EXPERIMENTS.md'
if (Test-Path $expPath) {
  $et = [System.IO.File]::ReadAllText($expPath, [System.Text.Encoding]::UTF8)
  foreach ($e in @('E1','E2','E3','E4')) {
    if ([regex]::Matches($et, "# $e ").Count -lt 1) { $problems.Add("_EXPERIMENTS.md: section for $e not found") }
  }
  if ($et -notmatch '3 个种子') { $problems.Add('_EXPERIMENTS.md: missing the 3-seed rule') }
} else { $problems.Add('MISSING _EXPERIMENTS.md') }

# ── 汇总 ────────────────────────────────────────────────────────────────
Write-Host ''
Write-Host ('chapters checked: {0} | cross-file links: {1} | unresolved anchors: {2} | boundary rows: {3} | README chapter rows: {4} | pending chapters: {5}' -f `
  $files.Count, $cross, $bad, $boundaryRows, $readmeChapters, $pending.Count)
Write-Host ''
if ($problems.Count -eq 0) { Write-Host 'ALL CHECKS PASSED' -ForegroundColor Green }
else {
  Write-Host ('PROBLEMS: {0}' -f $problems.Count) -ForegroundColor Yellow
  $problems | ForEach-Object { Write-Host "  $_" }
}
