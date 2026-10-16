$ErrorActionPreference = 'Stop'
# Reuse the browser connection and CDP helpers without repeating the full responsive run.
$helpers = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'verify.ps1'))
$helpers = $helpers.Substring(0, $helpers.IndexOf("CDP 'Page.enable'"))
$helpers = $helpers.Replace('$PSScriptRoot', ("'" + $PSScriptRoot.Replace("'", "''") + "'"))
Invoke-Expression $helpers
CDP 'Page.enable' @{} | Out-Null
$results = Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'results.json') | ConvertFrom-Json
foreach ($entry in $manifest) {
    $r = ($results | Where-Object page -eq $entry.slug | Select-Object -First 1).result
    $post = $r.schema[0].'@graph' | Where-Object { $_.'@type' -eq 'BlogPosting' }
    if ($post.headline -cne $entry.title -or $post.description -cne $entry.description -or $post.datePublished -ne '2026-10-15' -or $post.dateModified -ne '2026-10-15' -or $post.image.url -cne ('https://paradigmjanitorial.net/' + $entry.image)) { throw "Article schema mismatch: $($entry.slug)" }
    $urls = [regex]::Matches($entry.article, '\[([^\]]+)\]\(([^)]+)\)')
    for ($i=0; $i -lt $urls.Count; $i++) {
        if ($r.resourceLinks[$i].url -cne $urls[$i].Groups[2].Value -or $r.resourceLinks[$i].label -cne $urls[$i].Groups[1].Value) { throw 'Citation mismatch' }
    }
}
$listing = ($results | Where-Object page -eq 'blog.html' | Select-Object -First 1).result.schema[0].'@graph' | Where-Object { $_.'@type' -eq 'ItemList' }
if ($listing.numberOfItems -ne 12 -or $listing.itemListElement.Count -ne 12) { throw 'Index schema mismatch' }
foreach ($width in @(1440,768,390)) {
    CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=1000;deviceScaleFactor=1;mobile=($width -eq 390)} | Out-Null
    for ($i=0; $i -lt 3; $i++) {
        CDP 'Page.navigate' @{url=('file:///' + $root.Replace('\','/') + '/blog.html')} | Out-Null
        Start-Sleep -Milliseconds 400
        Eval "document.querySelectorAll('.blog-card .text-link')[$i].click();true" | Out-Null
        Start-Sleep -Milliseconds 400
        $loaded = Eval '({path:decodeURIComponent(location.pathname),title:document.querySelector("h1")?.textContent})'
        if (!$loaded.path.EndsWith($manifest[$i].slug) -or $loaded.title -cne $manifest[$i].title) { throw "Read More navigation failed: $width $i" }
        Eval "document.documentElement.style.scrollBehavior='auto';true" | Out-Null
        $clip = Eval '(()=>{const r=document.querySelector(".blog-references").getBoundingClientRect();return {x:r.x+scrollX,y:r.y+scrollY,width:r.width,height:r.height,scale:1}})()'
        Shot ($manifest[$i].slug.Replace('.html','') + "-$width-resources.png") $clip
    }
}
$template = [IO.File]::ReadAllText((Join-Path $root 'blog-office-flu-season-2026.html'))
foreach ($entry in $manifest) {
    $page = [IO.File]::ReadAllText((Join-Path $root $entry.slug))
    foreach ($pattern in @('<style id="site-initial-layout">.*?</style>', '<header class="site-header".*?</header>', '<footer class="footer">.*?</footer>')) {
        if (!$page.Contains([regex]::Match($template,$pattern,'Singleline').Value)) { throw 'Shared template changed' }
    }
    if ($page -match 'Production notes|Photo prompt|Implementation notes|Related cleaning service') { throw 'Non-article material found' }
}
$original = (git -C $root show HEAD:blog.html | Out-String).Replace("`r`n", "`n")
$current = [IO.File]::ReadAllText((Join-Path $root 'blog.html')).Replace("`r`n", "`n")
$oldCards = [regex]::Matches($original, '(?s)<article class="blog-card">.*?</article>')
foreach ($card in $oldCards) { if (!$current.Contains($card.Value)) { throw 'Original card changed' } }
Write-Output 'PASS: all 9 Read More clicks, exact citation labels and URLs, article/index schemas, preserved templates and all 9 original cards.'
$socket.Dispose()
