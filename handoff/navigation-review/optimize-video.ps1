$ErrorActionPreference='Stop'
$pages=Invoke-RestMethod 'http://127.0.0.1:9224/json/list'
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
Send-CDP 'Page.navigate' @{url=('file:///'+$pwd.Path.Replace('\','/')+'/index.html')}|Out-Null
Send-CDP 'Page.bringToFront' @{}|Out-Null
Start-Sleep -Seconds 2
$expression=@"
(async()=>{
 document.querySelectorAll('video').forEach(v=>v.pause());
 const image=new Image();image.src='assets/images/home-video-poster-stable.png';await image.decode();
 const poster=document.createElement('canvas');poster.width=1280;poster.height=720;poster.getContext('2d').drawImage(image,0,0,1280,720);
 const v=document.createElement('video');v.muted=true;v.playsInline=true;v.preload='auto';v.src='assets/videos/home-hero-stable.mp4';document.body.append(v);
 await new Promise((resolve,reject)=>{v.onloadeddata=resolve;v.onerror=()=>reject(new Error('Source video failed'));});
 const c=document.createElement('canvas');c.width=1280;c.height=720;const ctx=c.getContext('2d');ctx.drawImage(v,0,0,1280,720);
 const stream=c.captureStream(30),chunks=[];
 const recorder=new MediaRecorder(stream,{mimeType:'video/mp4;codecs=avc1.42001E',videoBitsPerSecond:1800000});
 recorder.ondataavailable=e=>{if(e.data.size)chunks.push(e.data)};
 const stopped=new Promise(resolve=>recorder.onstop=resolve);
 let drawing=true;const draw=()=>{if(!drawing)return;ctx.drawImage(v,0,0,1280,720);requestAnimationFrame(draw)};
 v.onended=()=>{drawing=false;recorder.stop()};recorder.start();draw();await v.play();await stopped;
 stream.getTracks().forEach(t=>t.stop());
 const blob=new Blob(chunks,{type:'video/mp4'});
 const video=await new Promise(resolve=>{const r=new FileReader();r.onload=()=>resolve(r.result);r.readAsDataURL(blob)});
 v.remove();return {video,poster:poster.toDataURL('image/webp',.78),bytes:blob.size};
})()
"@
$r=Send-CDP 'Runtime.evaluate' @{expression=$expression;awaitPromise=$true;returnByValue=$true}
if($r.exceptionDetails){throw ($r.exceptionDetails|ConvertTo-Json -Depth 8)}
[IO.File]::WriteAllBytes((Join-Path $pwd 'assets/videos/home-hero-optimized.mp4'),[Convert]::FromBase64String($r.result.value.video.Split(',')[1]))
[IO.File]::WriteAllBytes((Join-Path $pwd 'assets/images/home-video-poster-optimized.webp'),[Convert]::FromBase64String($r.result.value.poster.Split(',')[1]))
"Optimized video bytes: $($r.result.value.bytes)"
$socket.Dispose()