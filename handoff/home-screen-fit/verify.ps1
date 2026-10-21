$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$helpers=[IO.File]::ReadAllText((Join-Path $root 'handoff/blogs-2026-10-20/verify.ps1'))
$helpers=$helpers.Substring($helpers.IndexOf('$created ='),$helpers.IndexOf("CDP 'Page.enable'")-$helpers.IndexOf('$created =')).Replace('$PSScriptRoot',("'"+$PSScriptRoot.Replace("'","''")+"'"))
Invoke-Expression $helpers
CDP 'Page.enable' @{}|Out-Null
$results=@()
foreach($size in @(@(1920,1080),@(1440,800),@(1366,768),@(1200,534),@(1536,640),@(1280,600),@(1810,588),@(1206,534),@(768,1024),@(390,844),@(390,667))){
 CDP 'Emulation.setDeviceMetricsOverride' @{width=$size[0];height=$size[1];deviceScaleFactor=1;mobile=($size[0] -eq 390)}|Out-Null
 CDP 'Page.navigate' @{url=('file:///'+$root.Replace('\','/')+'/index.html')}|Out-Null
 Start-Sleep -Milliseconds 500
 Eval "new Promise(r=>{if(document.readyState==='complete')r();else addEventListener('load',r,{once:true})})"|Out-Null
 $r=Eval @'
(()=>{const hero=document.querySelector('.home-page-hero'),r=hero.getBoundingClientRect(),overlay=hero.querySelector('.hero-overlay').getBoundingClientRect();const mobile=document.querySelector('.mobile-home-cta');const bottom=getComputedStyle(mobile).display!=='none'?mobile.getBoundingClientRect().bottom:r.bottom;return {width:innerWidth,height:innerHeight,heroWidth:r.width,viewport:document.documentElement.clientWidth,heroBottom:r.bottom,videoBottom:hero.querySelector('video').getBoundingClientRect().bottom,sectionBottom:bottom,overlayTop:overlay.top,heroTop:r.top,overlayBottom:overlay.bottom,overflow:document.documentElement.scrollWidth>innerWidth}})()
'@
 if($r.videoBottom -gt $r.height+1 -or $r.sectionBottom -gt $r.height+1 -or [Math]::Abs($r.heroWidth-$r.viewport) -gt 1 -or $r.overflow -or $r.overlayTop -lt $r.heroTop-1 -or $r.overlayBottom -gt $r.heroBottom+1){throw ($r|ConvertTo-Json -Compress)}
 $results+=$r
 Shot "home-$($size[0])-$($size[1]).png" $null
}
$results|ConvertTo-Json|Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'results.json')
$socket.Dispose()
Write-Output 'PASS: full-width home hero, visible text and controls, and complete opening section within the initial viewport at all six desktop, tablet, and mobile sizes.'
