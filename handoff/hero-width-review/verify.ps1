$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$helpers=[IO.File]::ReadAllText((Join-Path $root 'handoff/blogs-2026-10-20/verify.ps1'))
$helpers=$helpers.Substring($helpers.IndexOf('$created ='),$helpers.IndexOf("CDP 'Page.enable'")-$helpers.IndexOf('$created ='))
$helpers=$helpers.Replace('$PSScriptRoot',("'"+$PSScriptRoot.Replace("'","''")+"'"))
Invoke-Expression $helpers
CDP 'Page.enable' @{} | Out-Null
$results=@()
foreach($width in @(1920,1440,768,390)){
 CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=1000;deviceScaleFactor=1;mobile=($width -eq 390)} | Out-Null
 foreach($file in @('index.html','office-cleaning.html','los-angeles-county.html')){
  CDP 'Page.navigate' @{url=('file:///'+$root.Replace('\','/')+'/'+$file)} | Out-Null
  Start-Sleep -Milliseconds 500
  Eval "new Promise(r=>{if(document.readyState==='complete')r();else addEventListener('load',r,{once:true})})" | Out-Null
  $r=Eval @'
(()=>{const h=document.querySelector('.hero,.page-hero');const media=h.querySelector('video,img');const rect=h.getBoundingClientRect();const m=media.getBoundingClientRect();return {viewport:document.documentElement.clientWidth,heroWidth:rect.width,heroHeight:rect.height,mediaWidth:m.width,mediaHeight:m.height,fit:getComputedStyle(media).objectFit,overflow:document.documentElement.scrollWidth>innerWidth,videoReady:h.querySelector('video')?.readyState}})()
'@
  if([Math]::Abs($r.heroWidth-$r.viewport) -gt 1 -or [Math]::Abs($r.mediaWidth-$r.heroWidth) -gt 1 -or $r.overflow){throw "Hero check failed: $file at $width : $($r|ConvertTo-Json -Compress)"}
  $results+=@{file=$file;width=$width;result=$r}
  if($file -eq 'index.html'){Shot "home-$width.png" $null}
 }
}
$socket.Dispose()
$results|ConvertTo-Json -Depth 10|Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'results.json')
Write-Output 'PASS: full viewport hero and media widths on home, office, and county pages at 1920, 1440, 768, and 390 pixels, with no horizontal overflow.'
