$ErrorActionPreference='Stop'
$pages=Invoke-RestMethod 'http://127.0.0.1:9223/json/list'
$page=$pages[0]
$socket=New-Object System.Net.WebSockets.ClientWebSocket
$socket.ConnectAsync([uri]$page.webSocketDebuggerUrl,[Threading.CancellationToken]::None).GetAwaiter().GetResult()
$script:messageId=0
function Send-CDP($method,$params){
 $script:messageId++;$id=$script:messageId
 $payload=@{id=$id;method=$method;params=$params}|ConvertTo-Json -Depth 12 -Compress
 $bytes=[Text.Encoding]::UTF8.GetBytes($payload)
 $socket.SendAsync([ArraySegment[byte]]::new($bytes),[Net.WebSockets.WebSocketMessageType]::Text,$true,[Threading.CancellationToken]::None).GetAwaiter().GetResult()|Out-Null
 do {
  $stream=New-Object IO.MemoryStream
  do {$buffer=New-Object byte[] 65536;$received=$socket.ReceiveAsync([ArraySegment[byte]]::new($buffer),[Threading.CancellationToken]::None).GetAwaiter().GetResult();$stream.Write($buffer,0,$received.Count)}until($received.EndOfMessage)
  $reply=[Text.Encoding]::UTF8.GetString($stream.ToArray())|ConvertFrom-Json
 }until($reply.id -eq $id)
 if($reply.error){throw ($reply.error|ConvertTo-Json)}
 return $reply.result
}
Send-CDP 'Page.enable' @{}|Out-Null
$probe="window.__heroSamples=[];const sampleHero=()=>{const h=document.querySelector('.hero,.page-hero');if(!h)return;const r=h.getBoundingClientRect(),i=h.querySelector('img,video');if(!i)return;const ir=i.getBoundingClientRect();const v={x:r.x,width:r.width,height:r.height,imageX:ir.x,imageWidth:ir.width,background:getComputedStyle(i).backgroundImage==='none'};const key=JSON.stringify(v);if(key!==window.__lastHeroSample){window.__heroSamples.push(v);window.__lastHeroSample=key}};new MutationObserver(sampleHero).observe(document,{subtree:true,childList:true,attributes:true});document.addEventListener('DOMContentLoaded',sampleHero);window.addEventListener('load',sampleHero);"
$probeId=Send-CDP 'Page.addScriptToEvaluateOnNewDocument' @{source=$probe}
$results=@()
foreach($width in @(1366,960,390)){
 Send-CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=900;deviceScaleFactor=1;mobile=($width -eq 390)}|Out-Null
 foreach($name in @('about.html','power-washing.html','index.html')){
  Send-CDP 'Page.navigate' @{url=('file:///'+$pwd.Path.Replace('\','/')+'/'+$name)}|Out-Null
  Start-Sleep -Milliseconds 1200
  $r=Send-CDP 'Runtime.evaluate' @{expression='window.__heroSamples';returnByValue=$true}
  $results+=@{page=$name;width=$width;samples=$r.result.value}
 }
}
Send-CDP 'Page.removeScriptToEvaluateOnNewDocument' @{identifier=$probeId.identifier}|Out-Null
$results|ConvertTo-Json -Depth 8|Set-Content -Encoding utf8 handoff/navigation-review/hero-stability-results.json
$results|ConvertTo-Json -Depth 8
$socket.Dispose()