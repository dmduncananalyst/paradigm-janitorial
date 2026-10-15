$ErrorActionPreference='Stop'
$socket=New-Object System.Net.WebSockets.ClientWebSocket
$socket.ConnectAsync([uri]'ws://127.0.0.1:9227/session',[Threading.CancellationToken]::None).GetAwaiter().GetResult()
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

Send-CDP 'session.new' @{capabilities=@{}}|Out-Null
Send-CDP 'network.setCacheBehavior' @{cacheBehavior='bypass'}|Out-Null
$tree=Send-CDP 'browsingContext.getTree' @{};$context=$tree.contexts[0].context
$probe="()=>{window.__blogLoads=[];window.__errors=[];window.addEventListener('error',e=>window.__errors.push(e.message));const sample=()=>document.querySelectorAll('.blog-card img').forEach((i,index)=>{const r=i.getBoundingClientRect(),v={index,width:r.width,height:r.height,complete:i.complete,natural:i.naturalWidth,noPlaceholder:getComputedStyle(i).backgroundImage===String.fromCharCode(110,111,110,101)};const k=JSON.stringify(v);if(i.dataset.probeKey!==k){window.__blogLoads.push(v);i.dataset.probeKey=k}});new MutationObserver(sample).observe(document,{subtree:true,childList:true,attributes:true});document.addEventListener('load',sample,true)}"
Send-CDP 'script.addPreloadScript' @{functionDeclaration=$probe}|Out-Null
$results=@()
foreach($width in @(1920,960,390)){
 Send-CDP 'browsingContext.setViewport' @{context=$context;viewport=@{width=$width;height=900};devicePixelRatio=1}|Out-Null
 Send-CDP 'browsingContext.navigate' @{context=$context;url=('file:///'+$pwd.Path.Replace('\','/')+'/blog.html');wait='complete'}|Out-Null
 Send-CDP 'script.evaluate' @{expression="document.querySelectorAll('.blog-card img').forEach(i=>i.loading='eager')";target=@{context=$context};awaitPromise=$false}|Out-Null
 Start-Sleep -Seconds 2
 $r=Send-CDP 'script.evaluate' @{expression='JSON.stringify({samples:window.__blogLoads,errors:window.__errors})';target=@{context=$context};awaitPromise=$false}
 $value=$r.result.value|ConvertFrom-Json
 $results+=@{width=$width;value=$value}
}
$results|ConvertTo-Json -Depth 10|Set-Content -Encoding utf8 handoff/navigation-review/firefox-blog-after.json
$results|ForEach-Object {$first=@($_.value.samples|Where-Object index -eq 0);"Width $($_.width) errors=$($_.value.errors.Count) first card:";$first|ConvertTo-Json -Depth 5}
Send-CDP 'session.end' @{}|Out-Null
$socket.Dispose()