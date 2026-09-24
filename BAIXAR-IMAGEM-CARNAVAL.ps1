param([switch]$Force)
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PhotoDir = Join-Path $Root "assets\photos"
$Dest = Join-Path $PhotoDir "carnaval-cinema-hero.jpg"
$Url = "https://www.u2.com/cdn/shop/t/56/assets/cinema-hero-d.jpg?v=140511160924944904371789395551"
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/140 Safari/537.36"
New-Item -ItemType Directory -Force -Path $PhotoDir | Out-Null
Write-Host ""
Write-Host "U250 - IMAGEM CARNAVAL DE LUZ" -ForegroundColor Cyan
if ((Test-Path $Dest) -and -not $Force) {
  Write-Host "[OK] A imagem já existe em assets\photos\carnaval-cinema-hero.jpg" -ForegroundColor Green
  Read-Host "Pressione ENTER para fechar"
  exit 0
}
try {
  Invoke-WebRequest -Uri $Url -OutFile $Dest -MaximumRedirection 10 -UseBasicParsing -UserAgent $UserAgent -Headers @{"Referer"="https://www.u2.com/"}
  $len=(Get-Item $Dest).Length
  if ($len -lt 20000) { throw "arquivo recebido é pequeno demais ($len bytes)" }
  $bytes=[IO.File]::ReadAllBytes($Dest)
  if ($bytes.Length -lt 2 -or $bytes[0] -ne 0xFF -or $bytes[1] -ne 0xD8) { throw "o arquivo recebido não parece ser JPEG" }
  Write-Host "[OK] Imagem oficial salva localmente:" -ForegroundColor Green
  Write-Host "     assets\photos\carnaval-cinema-hero.jpg"
} catch {
  if (Test-Path $Dest) { Remove-Item $Dest -Force -ErrorAction SilentlyContinue }
  Write-Host "[ERRO] Não foi possível baixar automaticamente." -ForegroundColor Red
  Write-Host $_.Exception.Message
  Write-Host ""
  Write-Host "Baixe manualmente esta imagem e salve com o nome:" -ForegroundColor Yellow
  Write-Host "assets\photos\carnaval-cinema-hero.jpg"
  Write-Host $Url
}
Write-Host ""
Read-Host "Pressione ENTER para fechar"
