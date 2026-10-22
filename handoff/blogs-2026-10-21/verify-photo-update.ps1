$code=[IO.File]::ReadAllText((Join-Path $pwd 'handoff/blogs-2026-10-21/verify.ps1'))
Invoke-Expression ($code.Substring(0,$code.IndexOf('$results=@()')))
$results=@()
foreach($width in @(1440,1100,768,390)){
 CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=1000;deviceScaleFactor=1;mobile=$false}|Out-Null
 CDP 'Page.navigate' @{url=('file:///'+$root.Replace('\','/')+'/blog.html')}|Out-Null
 Start-Sleep -Milliseconds 350
 Eval 'Promise.all(Array.from(document.querySelectorAll(".blog-card img")).map(i=>{i.loading="eager";return i.decode().catch(()=>{})})).then(()=>true)'|Out-Null
 $data=Eval 'JSON.stringify(Array.from(document.querySelectorAll(".blog-card")).slice(0,4).map(c=>{const i=c.querySelector("img"),r=i.getBoundingClientRect(),a=i.parentElement.getBoundingClientRect();return {src:decodeURIComponent(i.getAttribute("src")),width:r.width,height:r.height,containerHeight:a.height,ratio:r.width/r.height,fit:getComputedStyle(i).objectFit,loaded:i.naturalWidth>0}}))'|ConvertFrom-Json
 foreach($photo in $data){if(!$photo.loaded -or [Math]::Abs($photo.ratio-1.5) -gt .01 -or [Math]::Abs($photo.containerHeight-$photo.height) -gt 1){throw "Photo size mismatch at $width"}}
 if([Math]::Abs($data[3].height-$data[2].height) -gt 1){throw 'Office and studio image heights differ'}
 if($data[1].src -ne 'assets/images/blog-previews/Serene Funeral Home Visitation Parlor.png'){throw 'Funeral card photo mismatch'}
 Eval 'document.querySelector("a[href=\"blog-studio-floor-every-class.html\"]").scrollIntoView({block:"start"})'|Out-Null
 $shot=CDP 'Page.captureScreenshot' @{format='png';captureBeyondViewport=$false}
 [IO.File]::WriteAllBytes((Join-Path $root "handoff/blogs-2026-10-21/card-photo-update-$width.png"),[Convert]::FromBase64String($shot.data))
 $results+=@{width=$width;passed=$true;photos=$data}
}
$results|ConvertTo-Json -Depth 10|Set-Content -Encoding UTF8 handoff/blogs-2026-10-21/card-photo-update-results.json
$socket.Dispose()
'PASS: matching photo heights and no strips at 1440, 1100, 768 and 390 pixels; replacement memorial parlor photo loaded.'
