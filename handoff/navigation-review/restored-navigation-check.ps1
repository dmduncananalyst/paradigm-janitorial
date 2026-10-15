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
$probe=Send-CDP 'Page.addScriptToEvaluateOnNewDocument' @{source="window.__pageErrors=[];window.addEventListener('error',e=>window.__pageErrors.push(e.message));"}
$results=@()
foreach($width in @(1920,1366,960,768,390)){
 Send-CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=900;deviceScaleFactor=1;mobile=($width -eq 390)}|Out-Null
 foreach($name in @('index.html','about.html')){
  Send-CDP 'Page.navigate' @{url=('file:///'+$pwd.Path.Replace('\','/')+'/'+$name)}|Out-Null
  Start-Sleep -Milliseconds 1200
  $expression=@"
+(()=>{const nav=document.querySelector('.main-nav');const groups=[...nav.querySelectorAll('.nav-group')];if(innerWidth<=600)document.querySelector('.menu-button').click();const panels=groups.map(g=>{g.classList.add('expanded');const p=g.querySelector('.nav-panel'),r=p.getBoundingClientRect();const a={width:r.width,columns:getComputedStyle(p.querySelector('.commercial-mega-featured')).gridTemplateColumns,left:r.left,right:r.right,cards:p.querySelectorAll('.commercial-mega-card').length};g.classList.remove('expanded');return a});return {errors:window.__pageErrors,panels,navAlignment:getComputedStyle(nav).justifyContent,navGap:getComputedStyle(nav).gap,overflow:document.documentElement.scrollWidth>innerWidth}})()
"@
  $expression=$expression.TrimStart('+')
  $r=Send-CDP 'Runtime.evaluate' @{expression=$expression;returnByValue=$true}
  $results+=@{page=$name;width=$width;result=$r.result.value;exception=$r.exceptionDetails}
  if($width -eq 1920 -and $name -eq 'index.html'){
   Send-CDP 'Runtime.evaluate' @{expression="document.querySelector('.nav-group:not(.residential-mega)').classList.remove('expanded');document.querySelector('.nav-panel.commercial-mega:not(.residential-mega):not(.contact-mega):not(.clean-spaces-mega)').parentElement.classList.add('expanded')"}|Out-Null
   $shot=Send-CDP 'Page.captureScreenshot' @{format='png'}
   [IO.File]::WriteAllBytes((Join-Path $pwd 'handoff/navigation-review/restored-navigation-1920.png'),[Convert]::FromBase64String($shot.data))
  }
 }
}
Send-CDP 'Page.removeScriptToEvaluateOnNewDocument' @{identifier=$probe.identifier}|Out-Null
$results|ConvertTo-Json -Depth 10|Set-Content -Encoding utf8 handoff/navigation-review/restored-navigation-results.json
$results|ForEach-Object {"$($_.page) $($_.width): errors=$($_.result.errors.Count), overflow=$($_.result.overflow), commercialWidth=$($_.result.panels[1].width)"}
$socket.Dispose()