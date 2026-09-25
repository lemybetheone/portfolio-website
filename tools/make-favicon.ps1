# Rebuild the favicon and the iOS home-screen icon from assets/portrait.jpg.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/make-favicon.ps1
#
# An icon has to be square and the portrait is 560x697, so the whole photo only
# fits by padding the sides. -Mode Fit does that: the picture is scaled to the
# full height and the gaps are filled by stretching the outermost column of
# pixels, which follows the backdrop's vignette and leaves no visible seam.
#
# -Mode Crop takes a square of the face instead. It survives 16px far better,
# because at that size the whole figure is about 13 pixels wide.
#
# Sizes 16 and 32 are both written so the browser picks rather than downscaling
# 32 to 16 itself. 180 is what iOS uses for a home-screen icon.

param(
  [ValidateSet('Fit','Crop')][string]$Mode = 'Fit',
  [string]$Src    = (Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\portrait.jpg'),
  [string]$OutDir = (Join-Path (Split-Path $PSScriptRoot -Parent) 'assets'),
  [string]$Prefix = '',
  # Crop mode only: centre and side of the square, in source pixels
  [int]$CX = 282, [int]$CY = 235, [int]$SIZE = 240
)

Add-Type -AssemblyName System.Drawing

# not $src: a [string] parameter would coerce the Image back to a string
$img = [System.Drawing.Image]::FromFile($Src)
Write-Output ("source {0}x{1}, mode {2}" -f $img.Width, $img.Height, $Mode)

$targets = @{ 16 = 'favicon-16.png'; 32 = 'favicon-32.png'; 180 = 'apple-touch-icon.png' }

foreach ($px in ($targets.Keys | Sort-Object)) {
  $bmp = New-Object System.Drawing.Bitmap $px, $px
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

  if ($Mode -eq 'Crop') {
    $x = $CX - [int]($SIZE / 2)
    $y = $CY - [int]($SIZE / 2)
    $dst = New-Object System.Drawing.Rectangle 0, 0, $px, $px
    $g.DrawImage($img, $dst, $x, $y, $SIZE, $SIZE, [System.Drawing.GraphicsUnit]::Pixel)
  }
  else {
    # whole photo, scaled to the full height, centred
    $w = [int][Math]::Round($px * $img.Width / $img.Height)
    $left = [int][Math]::Floor(($px - $w) / 2)

    # pad by stretching the outermost source column across each gap, so the
    # fill follows the backdrop rather than sitting on it as a flat block
    if ($left -gt 0) {
      $lsrc = New-Object System.Drawing.Rectangle 0, 0, 1, $img.Height
      $rsrc = New-Object System.Drawing.Rectangle ($img.Width - 1), 0, 1, $img.Height
      $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $left, $px), $lsrc, [System.Drawing.GraphicsUnit]::Pixel)
      $g.DrawImage($img, (New-Object System.Drawing.Rectangle ($left + $w), 0, ($px - $left - $w), $px), $rsrc, [System.Drawing.GraphicsUnit]::Pixel)
    }
    $dst = New-Object System.Drawing.Rectangle $left, 0, $w, $px
    $g.DrawImage($img, $dst, 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel)
  }

  $g.Dispose()
  $out = Join-Path $OutDir ($Prefix + $targets[$px])
  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Output ("  {0}x{0} -> {1}" -f $px, $out)
}
$img.Dispose()
