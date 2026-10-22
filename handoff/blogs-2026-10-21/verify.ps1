$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$manifest=Get-Content handoff/blogs-2026-10-21/approved-content.json -Raw|ConvertFrom-Json
$targets=Invoke-RestMethod http://127.0.0.1:9231/json/list; $target=$targets | Where-Object type -eq page | Select-Object -First 1
$socket=[Net.WebSockets.ClientWebSocket]::new()
$socket.ConnectAsync([uri]$target.webSocketDebuggerUrl,[Threading.CancellationToken]::None).GetAwaiter().GetResult()
$script:messageId=0
function CDP($method,$params){
 $script:messageId++;$id=$script:messageId
 $bytes=[Text.Encoding]::UTF8.GetBytes((@{id=$id;method=$method;params=$params}|ConvertTo-Json -Depth 20 -Compress))
 $socket.SendAsync([ArraySegment[byte]]::new($bytes),[Net.WebSockets.WebSocketMessageType]::Text,$true,[Threading.CancellationToken]::None).GetAwaiter().GetResult()|Out-Null
 do{$stream=[IO.MemoryStream]::new();do{$buf=New-Object byte[] 65536;$r=$socket.ReceiveAsync([ArraySegment[byte]]::new($buf),[Threading.CancellationToken]::None).GetAwaiter().GetResult();$stream.Write($buf,0,$r.Count)}until($r.EndOfMessage);$reply=[Text.Encoding]::UTF8.GetString($stream.ToArray())|ConvertFrom-Json}until($reply.id -eq $id)
 if($reply.error){throw ($reply.error|ConvertTo-Json)};return $reply.result
}
function Eval($js){$r=CDP 'Runtime.evaluate' @{expression=$js;returnByValue=$true;awaitPromise=$true};if($r.exceptionDetails){throw ($r.exceptionDetails|ConvertTo-Json -Depth 5)};return $r.result.value}
CDP 'Page.enable' @{}|Out-Null
CDP 'Network.enable' @{}|Out-Null
CDP 'Network.setBlockedURLs' @{urls=@('http://*','https://*')}|Out-Null
$results=@()
foreach($width in @(1440,768,390)){
 CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=1000;deviceScaleFactor=1;mobile=$false}|Out-Null
 foreach($file in @('blog.html')+@($manifest|ForEach-Object file)){
  CDP 'Page.navigate' @{url=('file:///'+$root.Replace('\','/')+'/'+$file)}|Out-Null
  Start-Sleep -Milliseconds 450
  Eval 'new Promise(resolve=>{document.querySelectorAll("img").forEach(i=>i.loading="eager");Promise.all(Array.from(document.images).map(i=>i.decode().catch(()=>{}))).then(()=>resolve(true))})'|Out-Null
  $data=Eval 'JSON.stringify({title:document.title,description:document.querySelector("meta[name=description]").content,h1:Array.from(document.querySelectorAll("h1")).map(x=>x.textContent),overflow:document.documentElement.scrollWidth>innerWidth,paragraphs:Array.from(document.querySelectorAll(".blog-lead,.blog-body p,.blog-body h2,.blog-body h3")).map(x=>x.textContent),photos:Array.from(document.querySelectorAll(".blog-card-oct21 img,.blog-featured-image")).map(i=>{let r=i.getBoundingClientRect(),a=i.parentElement.getBoundingClientRect();return {src:decodeURIComponent(i.getAttribute("src")),width:r.width,height:r.height,naturalWidth:i.naturalWidth,naturalHeight:i.naturalHeight,fit:getComputedStyle(i).objectFit,containerHeight:a.height}}),links:Array.from(document.querySelectorAll("main a")).map(a=>a.getAttribute("href")),cards:document.querySelectorAll(".blog-card").length})'|ConvertFrom-Json
  if($data.overflow){throw "Horizontal overflow: $file at $width"}
  if($data.h1.Count -ne 1){throw 'H1 count'}
  foreach($photo in $data.photos){if($photo.naturalWidth -ne 1536 -or [Math]::Abs($photo.width/$photo.height-1.5) -gt .01 -or $photo.fit -ne 'contain'){throw "Photo fit: $file at $width"};if($file -eq 'blog.html' -and [Math]::Abs($photo.containerHeight-$photo.height) -gt 1){throw 'Photo strips'}}
  if($file -ne 'blog.html'){
   $expected=$manifest|Where-Object file -eq $file
   if($data.title -ne ($expected.title+' | Paradigm Janitorial') -or $data.description -cne $expected.description -or $data.h1[0] -cne $expected.title){throw 'SEO mismatch'}
   $actualText=($data.paragraphs -join ' ') -replace '\s+',' '
   $expectedText=($expected.parts.text -join ' ') -replace '\s+',' '
   if($actualText -cne $expectedText){throw "Approved content mismatch: $file"}
   foreach($source in $expected.sources){if($source -cnotin $data.links){throw 'Missing source'}}
   if($data.photos[0].src -cne ('assets/images/blog-previews/'+$expected.photo)){throw 'Assignment mismatch'}
   $raw=[IO.File]::ReadAllText((Join-Path $root $file));$schema=[regex]::Match($raw,'<script type="application/ld\+json">(.*?)</script>').Groups[1].Value|ConvertFrom-Json
   $posting=$schema.'@graph'|Where-Object {$_.'@type' -eq 'BlogPosting'}
   if($posting.url -ne $expected.url -or $posting.datePublished -ne '2026-10-21' -or $posting.headline -cne $expected.title -or ($posting.citation -join '|') -cne ($expected.sources -join '|')){throw 'Schema mismatch'}
  }else{foreach($entry in $manifest){if(@($data.links|Where-Object {$_ -eq $entry.file}).Count -ne 3){throw 'Archive links'}}}
  foreach($link in $data.links){if($link -notmatch '^(https?:|tel:|mailto:|#|javascript:)'){if(!(Test-Path -LiteralPath (Join-Path $root ([uri]::UnescapeDataString(($link -split '#')[0]))))){throw "Broken internal link: $link"}}}
  $shot=CDP 'Page.captureScreenshot' @{format='png';captureBeyondViewport=$false}
  [IO.File]::WriteAllBytes((Join-Path $root ('handoff/blogs-2026-10-21/'+$file.Replace('.html','')+'-'+$width+'.png')),[Convert]::FromBase64String($shot.data))
  $results+=@{file=$file;width=$width;passed=$true;photos=$data.photos;archiveCards=$data.cards}
 }
}
[xml]$xml=Get-Content sitemap.xml -Raw
foreach($entry in $manifest){if(@($xml.urlset.url|Where-Object {$_.loc -eq $entry.url}).Count -ne 1){throw 'Sitemap entry'};if((Get-FileHash -LiteralPath ('assets/images/blog-previews/'+$entry.photo)).Hash -ne $entry.sha256){throw 'Image bytes changed'}}
$results|ConvertTo-Json -Depth 10|Set-Content -Encoding UTF8 handoff/blogs-2026-10-21/test-results.json
$socket.Dispose()
'PASS: 12 responsive page checks; exact approved content, assignments, original photo bytes, full-frame images without strips, SEO/schema, all local links, archive links and sitemap.'
