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
$results=@()
foreach($width in @(1366,390)){
 Send-CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=900;deviceScaleFactor=1;mobile=($width -eq 390)}|Out-Null
 Send-CDP 'Page.navigate' @{url=('file:///'+$pwd.Path.Replace('\','/')+'/index.html')}|Out-Null
 Send-CDP 'Page.bringToFront' @{}|Out-Null
 Start-Sleep -Seconds 4
 $expression="(()=>{const v=document.querySelector('.home-page-hero video');const original=window.matchMedia.bind(window);window.matchMedia=q=>q==='(hover: hover) and (pointer: fine)'?{matches:true}:original(q);window.dispatchEvent(new Event('resize'));return {frames:v.getVideoPlaybackQuality().totalVideoFrames,paused:v.paused,rate:v.playbackRate,duration:v.duration,time:v.currentTime,readyState:v.readyState,error:v.error?.message||null,opacity:getComputedStyle(v).opacity,playButton:!!document.querySelector('.home-page-hero .video-toggle'),callHref:document.querySelector('.header-phone').href,callDialog:!!document.querySelector('.desktop-call-dialog')};})()"
 $r=Send-CDP 'Runtime.evaluate' @{expression=$expression;returnByValue=$true}
 $before=$r.result.value.frames
 Start-Sleep -Seconds 2
 $r=Send-CDP 'Runtime.evaluate' @{expression=$expression;returnByValue=$true}
 $r.result.value|Add-Member -NotePropertyName advancing -NotePropertyValue ($r.result.value.frames -gt $before)
 $results+=@{width=$width;result=$r.result.value}
}
$results|ConvertTo-Json -Depth 10 | Set-Content -Encoding utf8 handoff/navigation-review/real-playback-results.json
$results|ConvertTo-Json -Depth 10
$socket.Dispose()
