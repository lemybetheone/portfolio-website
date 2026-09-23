# Rebuild assets/og.png, the Open Graph card.
#
# That card is the image a link preview shows on LinkedIn, Slack or iMessage.
# Its text is part of the image rather than markup, so changing the site title,
# the location or the words along the bottom means regenerating it.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/make-og.ps1
#
# The first version of this card had no source, and its design had to be read
# back out of the pixels. The constants below are that measurement, so this
# script reproduces the card rather than reinventing it.
#
# Font sizes are fitted to target widths instead of being set directly. If a
# font is missing, Windows substitutes another and the fitting scales it to
# occupy the same space, so the layout degrades instead of breaking.

param(
  [string]$OutPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\og.png'),
  # vertical offsets, tuned against the rendered output until each text band
  # landed within 2px of the original
  [double]$NameY = 131,
  [double]$L1Y   = 230,
  [double]$L2Y   = 308,
  [double]$SubY  = 424,
  [double]$FootY = 538
)

Add-Type -AssemblyName System.Drawing

# ---- measured from the original card -------------------------------------
$W = 1200; $H = 630          # the size every platform expects, and the size
$LEFT = 90; $RIGHT = 1110    # declared in og:image:width / og:image:height
$BG    = [System.Drawing.ColorTranslator]::FromHtml('#FBFAF8')
$BAR   = [System.Drawing.ColorTranslator]::FromHtml('#8A1C1C')
$RULE  = [System.Drawing.ColorTranslator]::FromHtml('#EFEDE9')
$INK   = [System.Drawing.ColorTranslator]::FromHtml('#1A1D23')
$MUTED = [System.Drawing.ColorTranslator]::FromHtml('#5D6570')
$RULE_Y1 = 182; $RULE_Y2 = 512

# target text widths, also measured from the original
$W_NAME = 202; $W_LINE1 = 514; $W_SUB = 596; $W_FOOT = 530

# ---- the copy -------------------------------------------------------------
$DOT      = [string][char]0x00B7
$NAME     = 'LEMUEL CALINOG'
$LINE1    = 'Building the layer'
$LINE2    = 'the business reports from.'
$SUBTITLE = "Data engineering $DOT Manila, Philippines"
$FOOTER   = "Pipelines $DOT Modelling $DOT Testing $DOT Scheduling"

# The subtitle is sized from the string the original carried, not from the one
# above. Fitting the current text to the original width would change the type
# size every time the wording changed.
$SUB_REF  = "Data professional in Manila $DOT Analytics engineering"

# ---- helpers --------------------------------------------------------------
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

$fmt = [System.Drawing.StringFormat]::GenericTypographic.Clone()
$fmt.FormatFlags = $fmt.FormatFlags -bor [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces

function MW($t, $f) { $g.MeasureString($t, $f, [int]::MaxValue, $fmt).Width }

function Fit($t, $family, $target) {
  $lo = 4.0; $hi = 160.0
  for ($i = 0; $i -lt 40; $i++) {
    $mid = ($lo + $hi) / 2
    $f = New-Object System.Drawing.Font($family, $mid, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    if ((MW $t $f) -lt $target) { $lo = $mid } else { $hi = $mid }
    $f.Dispose()
  }
  [Math]::Round(($lo + $hi) / 2, 2)
}

# System.Drawing has no letter-spacing, so tracked text is drawn glyph by glyph
function DrawTracked($t, $f, $brush, $x, $y, $track) {
  $cx = $x
  foreach ($c in $t.ToCharArray()) {
    $g.DrawString([string]$c, $f, $brush, $cx, $y, $fmt)
    $cx += (MW ([string]$c) $f) + $track
  }
}

function FitTrack($t, $f, $target) {
  $nat = 0.0
  foreach ($c in $t.ToCharArray()) { $nat += (MW ([string]$c) $f) }
  ($target - $nat) / ($t.Length - 1)
}

# ---- fonts ----------------------------------------------------------------
$serifSize = Fit $LINE1   'Georgia'  $W_LINE1
$subSize   = Fit $SUB_REF 'Segoe UI' $W_SUB
$footSize  = Fit $FOOTER  'Consolas' $W_FOOT

$fSerif = New-Object System.Drawing.Font('Georgia',  $serifSize, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fSub   = New-Object System.Drawing.Font('Segoe UI', $subSize,   [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fName  = New-Object System.Drawing.Font('Consolas', 22.0,       [System.Drawing.FontStyle]::Bold,    [System.Drawing.GraphicsUnit]::Pixel)
$fFoot  = New-Object System.Drawing.Font('Consolas', $footSize,  [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$bInk = New-Object System.Drawing.SolidBrush($INK)
$bMut = New-Object System.Drawing.SolidBrush($MUTED)

# ---- draw -----------------------------------------------------------------
$g.Clear($BG)
$g.FillRectangle((New-Object System.Drawing.SolidBrush($BAR)), 0, 0, $W, 8)
$pRule = New-Object System.Drawing.Pen($RULE, 2)
$g.DrawLine($pRule, $LEFT, $RULE_Y1, $RIGHT, $RULE_Y1)
$g.DrawLine($pRule, $LEFT, $RULE_Y2, $RIGHT, $RULE_Y2)

# the name is letterspaced; the footer is a mono face already the right width,
# so tracking it would only make it wrong
DrawTracked $NAME $fName $bMut $LEFT $NameY (FitTrack $NAME $fName $W_NAME)
$g.DrawString($LINE1,    $fSerif, $bInk, $LEFT, $L1Y,  $fmt)
$g.DrawString($LINE2,    $fSerif, $bInk, $LEFT, $L2Y,  $fmt)
$g.DrawString($SUBTITLE, $fSub,   $bMut, $LEFT, $SubY, $fmt)
DrawTracked $FOOTER $fFoot $bMut $LEFT $FootY 0.0

$bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

Write-Output ("wrote {0}" -f $OutPath)
Write-Output ("  Georgia {0}px  Segoe UI {1}px  Consolas {2}px" -f $serifSize, $subSize, $footSize)
