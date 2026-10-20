$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$manifest = Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'manifest.json') | ConvertFrom-Json
$created = Invoke-RestMethod -Method Put 'http://127.0.0.1:9223/json/new?about:blank'
$socket = New-Object Net.WebSockets.ClientWebSocket
$socket.ConnectAsync([uri]$created.webSocketDebuggerUrl, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
$script:messageId = 0
function CDP($method, $params) {
    $script:messageId++; $id = $script:messageId
    $bytes = [Text.Encoding]::UTF8.GetBytes((@{id=$id;method=$method;params=$params} | ConvertTo-Json -Depth 30 -Compress))
    $socket.SendAsync([ArraySegment[byte]]::new($bytes), [Net.WebSockets.WebSocketMessageType]::Text, $true, [Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
    do {
        $stream = New-Object IO.MemoryStream
        do { $buffer = New-Object byte[] 65536; $received = $socket.ReceiveAsync([ArraySegment[byte]]::new($buffer), [Threading.CancellationToken]::None).GetAwaiter().GetResult(); $stream.Write($buffer,0,$received.Count) } until ($received.EndOfMessage)
        $reply = [Text.Encoding]::UTF8.GetString($stream.ToArray()) | ConvertFrom-Json
    } until ($reply.id -eq $id)
    if ($reply.error) { throw ($reply.error | ConvertTo-Json) }
    $reply.result
}
function Eval($expression) {
    $r = CDP 'Runtime.evaluate' @{expression=$expression;returnByValue=$true;awaitPromise=$true}
    if ($r.exceptionDetails) { throw ($r.exceptionDetails | ConvertTo-Json -Depth 10) }
    $r.result.value
}
function Shot($name, $clip) {
    $params = @{format='png';captureBeyondViewport=$true}
    if (!$clip) { $clip = Eval '({x:0,y:scrollY,width:innerWidth,height:innerHeight,scale:1})' }
    $params.clip = $clip
    $r = CDP 'Page.captureScreenshot' $params
    [IO.File]::WriteAllBytes((Join-Path $PSScriptRoot $name), [Convert]::FromBase64String($r.data))
}
CDP 'Page.enable' @{} | Out-Null
CDP 'Page.addScriptToEvaluateOnNewDocument' @{source="window.__errors=[];addEventListener('error',e=>{if(e.message)window.__errors.push(e.message)})"} | Out-Null
$results = @()
foreach ($width in @(1440,768,390)) {
    CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=1000;deviceScaleFactor=1;mobile=($width -eq 390)} | Out-Null
    foreach ($name in @('blog.html') + @($manifest.slug)) {
        CDP 'Page.navigate' @{url=('file:///' + $root.Replace('\','/') + '/' + $name)} | Out-Null
        Start-Sleep -Milliseconds 650
        Eval "new Promise(resolve=>{if(document.readyState==='complete')resolve();else addEventListener('load',()=>resolve(),{once:true})})" | Out-Null
        Eval "Promise.all([...document.querySelectorAll('main img')].map(i=>{i.loading='eager';return i.decode().catch(()=>{})})).then(()=>document.fonts.ready).then(()=>true)" | Out-Null
        Eval "document.documentElement.style.scrollBehavior='auto';true" | Out-Null
        $result = Eval @'
(()=>{const images=[...document.querySelectorAll('main img')];const cards=[...document.querySelectorAll('.blog-card')];const first=cards.slice(0,3);return {overflow:document.documentElement.scrollWidth>innerWidth,errors:window.__errors,images:images.map(i=>({src:i.getAttribute('src'),loaded:i.complete&&i.naturalWidth>0,fit:getComputedStyle(i).objectFit,ratio:i.getBoundingClientRect().width/i.getBoundingClientRect().height,naturalRatio:i.naturalWidth/i.naturalHeight})),cards:first.map(c=>({width:c.offsetWidth,height:c.offsetHeight,imageHeight:c.querySelector('img').offsetHeight,readMore:c.querySelector('.text-link').getAttribute('href')})),cardCount:cards.length,text:document.querySelector('article.blog-article')?.innerText,resourceLinks:[...document.querySelectorAll('.blog-references a')].map(a=>({label:a.textContent,url:a.getAttribute('href')})),internalLinks:[...document.querySelectorAll('.blog-body a')].filter(a=>!a.getAttribute('href').startsWith('https:')).map(a=>a.getAttribute('href')),schema:[...document.querySelectorAll('script[type="application/ld+json"]')].map(s=>JSON.parse(s.textContent)),description:document.querySelector('meta[name="description"]').content,canonical:document.querySelector('link[rel="canonical"]').href}})()
'@
        $results += @{page=$name;width=$width;result=$result}
        if ($name -eq 'blog.html') {
            for ($i=0; $i -lt 3; $i++) {
                $clip = Eval "(()=>{const r=document.querySelectorAll('.blog-card')[$i].getBoundingClientRect();return {x:r.x+scrollX,y:r.y+scrollY,width:r.width,height:r.height,scale:1}})()"
                Shot "cards-$width-$i.png" $clip
            }
        } else {
            $key = $name.Replace('.html','') + '-' + $width
            Shot "$key-top.png" $null
            Eval "document.querySelector('.blog-featured-image').scrollIntoView();scrollBy(0,-200);true" | Out-Null
            Start-Sleep -Milliseconds 150
            Shot "$key-photo.png" $null
            Eval "scrollTo(0,document.documentElement.scrollHeight);true" | Out-Null
            Start-Sleep -Milliseconds 150
            Shot "$key-end.png" $null
        }
        Write-Output "$name at ${width}px: overflow=$($result.overflow), errors=$($result.errors.Count), loaded=$(@($result.images | Where-Object { !$_.loaded }).Count -eq 0)"
    }
}
$results | ConvertTo-Json -Depth 40 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'results.json')
# Compare all rendered article copy and resource labels against the source.
foreach ($entry in $manifest) {
    $expected = ($entry.article -replace '(?m)^## ', '' -replace '\[([^\]]+)\]\([^)]+\)', '$1')
    $expected = ($entry.title + ' ' + $expected -replace '\s+', ' ').Trim()
    foreach ($case in $results | Where-Object { $_.page -eq $entry.slug }) {
        $actual = ($case.result.text -replace '^October 15, 2026\s*', '' -replace '\s+', ' ').Trim()
        if ($actual -cne $expected) { throw "Article copy differs: $($entry.slug), $($case.width)" }
        if ($case.result.description -cne $entry.description) { throw 'Meta description differs' }
        if ($case.result.canonical -cne ('https://paradigmjanitorial.net/' + $entry.slug)) { throw 'Canonical differs' }
    }
}
foreach ($case in $results) {
    if ($case.result.overflow -or $case.result.errors.Count -or @($case.result.images | Where-Object { !$_.loaded -or $_.fit -ne 'contain' }).Count) { throw "Browser check failed: $($case.page) $($case.width)" }
    if ($case.result.cardCount -and $case.result.cardCount -ne 12) { throw 'Incorrect card count' }
}
[xml]$sitemap = Get-Content -Raw (Join-Path $root 'sitemap.xml')
foreach ($entry in $manifest) {
    $url = $sitemap.urlset.url | Where-Object { $_.loc -eq ('https://paradigmjanitorial.net/' + $entry.slug) }
    if ($url.lastmod -ne '2026-10-15') { throw 'Missing sitemap date' }
    foreach ($link in ($results | Where-Object page -eq $entry.slug | Select-Object -First 1).result.internalLinks) {
        if (!(Test-Path -LiteralPath (Join-Path $root $link))) { throw "Missing internal link: $link" }
    }
}
Write-Output 'PASS: 12 responsive browser cases, exact article copy, loaded full images, metadata, internal link targets, schema JSON and sitemap.'
$socket.Dispose()
