# Build assets/f1-banner.jpg from assets/source-f1.jpg.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/make-banner.ps1
#
# The warehouse banner comes from the same script:
#
#   ... -File tools/make-banner.ps1 -Src assets/source-warehouse.jpg `
#       -Out assets/warehouse-banner.jpg -CropTop 692 -Blur 855,112,124,230
#
# The source is 3930x2620 (3:2) and the header it sits behind is about 2.13:1,
# so the crop is a horizontal band. It is positioned to keep the car, which sits
# below the centre line of the frame.
#
# Re-encoding also drops the EXIF, XMP and IPTC blocks the download carried.
param(
  [string]$Src    = (Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\source-f1.jpg'),
  [string]$Out    = (Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\f1-banner.jpg'),
  [int]$CropTop   = 775,      # band start in source pixels
  [int]$OutWidth  = 1856,     # 928 CSS px at 2x
  [int]$Quality   = 72,
  # optional "x,y,w,h" in output pixels to blur, e.g. a sign carrying a logo
  [string]$Blur   = ''
)
Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Image]::FromFile($Src)
$cropH = [int][Math]::Round($img.Width / 2.131)
if ($CropTop + $cropH -gt $img.Height) { $CropTop = $img.Height - $cropH }
$outH = [int][Math]::Round($OutWidth * $cropH / $img.Width)

Write-Output ("source {0}x{1}" -f $img.Width, $img.Height)
Write-Output ("crop   {0}x{1} at y={2}" -f $img.Width, $cropH, $CropTop)
Write-Output ("out    {0}x{1}" -f $OutWidth, $outH)

$bmp = New-Object System.Drawing.Bitmap $OutWidth, $outH
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$dst = New-Object System.Drawing.Rectangle 0, 0, $OutWidth, $outH
$g.DrawImage($img, $dst, 0, $CropTop, $img.Width, $cropH, [System.Drawing.GraphicsUnit]::Pixel)

# Blur by shrinking the region to about one pixel per 20 and stretching it
# back: detail such as text and logos is gone, the light and colour stay.
if ($Blur) {
  $b = $Blur.Split(',') | ForEach-Object { [int]$_ }
  $r = New-Object System.Drawing.Rectangle $b[0], $b[1], $b[2], $b[3]
  $region = $bmp.Clone($r, $bmp.PixelFormat)
  $tiny = New-Object System.Drawing.Bitmap ([Math]::Max(1, [int]($r.Width / 20))), ([Math]::Max(1, [int]($r.Height / 20)))
  # Without TileFlipXY, GDI+ blends edge pixels with transparency when it
  # resamples, in both directions. The blurred patch then came out partly
  # see-through at its edges, and the sign's text ghosted along the left.
  $ia = New-Object System.Drawing.Imaging.ImageAttributes
  $ia.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
  $gt = [System.Drawing.Graphics]::FromImage($tiny)
  $gt.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBilinear
  $gt.DrawImage($region, (New-Object System.Drawing.Rectangle 0, 0, $tiny.Width, $tiny.Height), 0, 0, $region.Width, $region.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
  $gt.Dispose(); $region.Dispose()
  $g.DrawImage($tiny, $r, 0, 0, $tiny.Width, $tiny.Height, [System.Drawing.GraphicsUnit]::Pixel, $ia)
  $ia.Dispose(); $tiny.Dispose()
  Write-Output ("blur   {0}" -f $Blur)
}
$g.Dispose()

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([int]$Quality)
$bmp.Save($Out, $codec, $ep)
$bmp.Dispose(); $img.Dispose()

Write-Output ("wrote {0} ({1:N0} bytes, quality {2})" -f $Out, (Get-Item $Out).Length, $Quality)
