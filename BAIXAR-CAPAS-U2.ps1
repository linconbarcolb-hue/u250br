param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$CoverDir = Join-Path $Root "assets\covers"
New-Item -ItemType Directory -Force -Path $CoverDir | Out-Null

$UserAgent = "U250CoverDownloader/1.0 (https://www.u250.com.br; independent fan project)"

$Albums = @(
  @{ File="01-boy.jpg";        Title="Boy";                                  Year=1980 },
  @{ File="02-october.jpg";    Title="October";                              Year=1981 },
  @{ File="03-war.jpg";        Title="War";                                  Year=1983 },
  @{ File="04-fire.jpg";       Title="The Unforgettable Fire";               Year=1984 },
  @{ File="05-joshua.jpg";     Title="The Joshua Tree";                      Year=1987 },
  @{ File="06-rattle.jpg";     Title="Rattle and Hum";                       Year=1988 },
  @{ File="07-achtung.jpg";    Title="Achtung Baby";                         Year=1991 },
  @{ File="08-zooropa.jpg";    Title="Zooropa";                              Year=1993 },
  @{ File="09-pop.jpg";        Title="Pop";                                  Year=1997 },
  @{ File="10-leave.jpg";      Title="All That You Can't Leave Behind";      Year=2000 },
  @{ File="11-bomb.jpg";       Title="How to Dismantle an Atomic Bomb";      Year=2004 },
  @{ File="12-horizon.jpg";    Title="No Line on the Horizon";               Year=2009 },
  @{ File="13-innocence.jpg";  Title="Songs of Innocence";                   Year=2014 },
  @{ File="14-experience.jpg"; Title="Songs of Experience";                  Year=2017 },
  @{ File="15-surrender.jpg";  Title="Songs of Surrender";                   Year=2023 },
  @{ File="16-carnaval.jpg";   Title="Carnaval De Luz";                      Year=2026 }
)

function Normalize-Title([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
  $d = $Text.Normalize([Text.NormalizationForm]::FormD)
  $sb = New-Object Text.StringBuilder
  foreach ($c in $d.ToCharArray()) {
    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$sb.Append($c)
    }
  }
  return (($sb.ToString().ToLowerInvariant()) -replace '[^a-z0-9]', '')
}

function Find-ReleaseGroup($Album) {
  $query = 'releasegroup:"' + $Album.Title + '" AND artist:"U2" AND primarytype:album'
  $url = "https://musicbrainz.org/ws/2/release-group/?query=$([uri]::EscapeDataString($query))&fmt=json&limit=10"
  $headers = @{ "User-Agent"=$UserAgent; "Accept"="application/json" }
  $data = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
  Start-Sleep -Milliseconds 1100

  $groups = @($data.'release-groups')
  if ($groups.Count -eq 0) { return $null }

  $wanted = Normalize-Title $Album.Title
  $exact = @($groups | Where-Object { (Normalize-Title $_.title) -eq $wanted })
  if ($exact.Count -eq 0) { $exact = $groups }

  $best = $exact | Sort-Object @{ Expression = {
    $d = $_.'first-release-date'
    if ($d -match '^(\d{4})') { [math]::Abs([int]$Matches[1] - [int]$Album.Year) } else { 9999 }
  }}, @{Expression={ -1 * [int]$_.score }} | Select-Object -First 1
  return $best
}

function Download-Cover($Album, $Group) {
  $dest = Join-Path $CoverDir $Album.File
  $sizes = @("1200", "500")
  foreach ($size in $sizes) {
    $uri = "https://coverartarchive.org/release-group/$($Group.id)/front-$size"
    try {
      Invoke-WebRequest -Uri $uri -OutFile $dest -MaximumRedirection 10 -UseBasicParsing -UserAgent $UserAgent
      if ((Test-Path $dest) -and ((Get-Item $dest).Length -gt 5000)) { return $true }
    } catch {
      if (Test-Path $dest) { Remove-Item $dest -Force -ErrorAction SilentlyContinue }
    }
  }
  return $false
}

Write-Host ""
Write-Host "U250 - DOWNLOAD DAS CAPAS" -ForegroundColor Cyan
Write-Host "Fonte: MusicBrainz + Cover Art Archive (frente / 1200 px quando disponível)."
Write-Host "Destino: $CoverDir"
Write-Host ""

$ok = 0
$missing = @()
foreach ($album in $Albums) {
  $dest = Join-Path $CoverDir $album.File
  if ((Test-Path $dest) -and -not $Force) {
    Write-Host "[OK] $($album.Title) - já existe" -ForegroundColor DarkGreen
    $ok++
    continue
  }

  Write-Host "[BUSCANDO] $($album.Title) ($($album.Year))..." -NoNewline
  try {
    $group = Find-ReleaseGroup $album
    if ($null -eq $group) { throw "release group não encontrado" }
    if (Download-Cover $album $group) {
      Write-Host " OK" -ForegroundColor Green
      $ok++
    } else {
      throw "capa frontal não disponível no Cover Art Archive"
    }
  } catch {
    Write-Host " NÃO ENCONTRADA" -ForegroundColor Yellow
    $missing += $album
  }
}

Write-Host ""
Write-Host "$ok de $($Albums.Count) capas disponíveis." -ForegroundColor Cyan
if ($missing.Count -gt 0) {
  Write-Host ""
  Write-Host "Estas capas precisam ser colocadas manualmente em assets\covers com o nome indicado:" -ForegroundColor Yellow
  foreach ($m in $missing) { Write-Host " - $($m.Title) -> $($m.File)" }
  Write-Host ""
  Write-Host "Para Carnaval De Luz, a referência oficial atual está em:"
  Write-Host "https://www.u2.com/products/carnaval-de-luz"
}

Write-Host ""
Write-Host "Concluído. Abra index.html para conferir." -ForegroundColor Green
Write-Host "Se alguma capa estiver errada, apague apenas o JPG correspondente e salve a capa correta com o mesmo nome."
Write-Host ""
Read-Host "Pressione ENTER para fechar"
