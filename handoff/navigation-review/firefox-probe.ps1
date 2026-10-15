$socket=New-Object System.Net.WebSockets.ClientWebSocket
$socket.ConnectAsync([uri]'ws://127.0.0.1:9226/session',[Threading.CancellationToken]::None).GetAwaiter().GetResult()
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
Send-CDP 'session.new' @{capabilities=@{}}|ConvertTo-Json -Depth 8
Send-CDP 'browsingContext.getTree' @{}|ConvertTo-Json -Depth 8
$socket.Dispose()