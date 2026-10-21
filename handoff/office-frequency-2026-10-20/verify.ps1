$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$data=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'content.json') | ConvertFrom-Json
function Read($p){[IO.File]::ReadAllText((Join-Path $root $p))}
function Assert($ok,$message){if(!$ok){throw $message}}
function Plain($s){$s=[regex]::Replace($s,'</(?:p|h[1-6])>',' ');[regex]::Replace([Net.WebUtility]::HtmlDecode([regex]::Replace($s,'<[^>]+>','')),'\s+',' ').Trim()}
$page=Read $data.slug;$index=Read 'blog.html'
$baseline=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'baseline.json') | ConvertFrom-Json
foreach($entry in $baseline){if($entry.file -ne 'blog.html'){Assert ((Get-FileHash (Join-Path $root $entry.file)).Hash -eq $entry.hash) "Existing page changed: $($entry.file)"}}
$body=[regex]::Match($page,'(?s)<div class="blog-body">(.*?)<section class="blog-references"').Groups[1].Value
$expected=($data.sections | ForEach-Object {$_.heading; $_.paragraphs}) -join ' '
Assert ((Plain $body) -ceq $expected) 'Article text differs from supplied content'
Assert ([regex]::Matches($body,'<h2>').Count -eq 5) 'Expected all five headings'
foreach($ref in $data.references){Assert ($page.Contains($ref.url) -and (Plain $page).Contains($ref.title) -and (Plain $page).Contains($ref.description)) 'Missing source content'}
Assert ((Get-FileHash (Join-Path $root $data.image)).Hash -eq (Get-FileHash 'C:\Users\Owner\OneDrive\Desktop\Professional Office Cleaning Team.png').Hash) 'Image bytes changed'
Assert ($body.Contains('href="office-cleaning.html"') -and $body.Contains('href="commercial.html"')) 'Missing required service links'
$main=[regex]::Match($page,'(?s)<main.*?</main>').Value
Assert (!(Plain $main).Contains('Developer instructions')) 'Developer notes leaked'
Assert (!(Plain $main).Contains('Developer placement')) 'Developer placement leaked'
Assert (!(Plain $body).Contains('-') -and !(Plain $body).Contains([string][char]0x2014)) 'Editorial dash introduced'
$pattern='(?s)<script type="application/ld\+json">(.*?)</script>'
$post=([regex]::Match($page,$pattern).Groups[1].Value | ConvertFrom-Json).'@graph' | Where-Object {$_.'@type' -eq 'BlogPosting'}
Assert ($post.headline -ceq $data.title -and $post.description -ceq $data.description -and $post.image.width -eq 1672 -and $post.image.height -eq 941 -and $post.citation.Count -eq 4) 'Article schema mismatch'
$list=([regex]::Match($index,$pattern).Groups[1].Value | ConvertFrom-Json).'@graph' | Where-Object {$_.'@type' -eq 'ItemList'}
Assert ($list.numberOfItems -eq 17 -and $list.itemListElement.Count -eq 17) 'Archive schema mismatch'
[xml]$map=Read 'sitemap.xml';Assert (@($map.urlset.url | Where-Object {$_.loc -eq ('https://paradigmjanitorial.net/'+$data.slug)}).Count -eq 1) 'Sitemap entry missing or duplicated'
foreach($patternPart in @('(?s)<header class="site-header">.*?</header>','(?s)<footer class="footer">.*?</footer>')){Assert ([regex]::Match($page,$patternPart).Value -ceq [regex]::Match((Read 'blog-physical-therapy-equipment-patients-share.html'),$patternPart).Value) 'Shared navigation or footer changed'}
foreach($targetPage in @($data.slug,'blog.html')){foreach($match in [regex]::Matches((Read $targetPage),'(?:href|src)="([^"#]+)"')){$target=[Net.WebUtility]::HtmlDecode($match.Groups[1].Value);if($target -match '^(?:https?:|tel:|mailto:|data:|javascript:)'){continue};$target=($target -split '[?#]')[0];Assert (Test-Path -LiteralPath (Join-Path $root $target)) "Missing local link $target"}}
# Reuse the repository's existing local Chrome protocol helpers.
$helpers=Read 'handoff/blogs-2026-10-20/verify.ps1'
$helpers=$helpers.Substring($helpers.IndexOf('$created ='),$helpers.IndexOf("CDP 'Page.enable'")-$helpers.IndexOf('$created ='))
$helpers=$helpers.Replace('$PSScriptRoot',("'"+$PSScriptRoot.Replace("'","''")+"'"))
Invoke-Expression $helpers
CDP 'Page.enable' @{} | Out-Null
CDP 'Page.addScriptToEvaluateOnNewDocument' @{source="window.__errors=[];addEventListener('error',e=>{if(e.message)window.__errors.push(e.message)})"} | Out-Null
$results=@()
foreach($width in @(1440,768,390)){
    CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=1000;deviceScaleFactor=1;mobile=($width -eq 390)} | Out-Null
    foreach($file in @('blog.html',$data.slug)){
        CDP 'Page.navigate' @{url=('file:///'+$root.Replace('\','/')+'/'+$file)} | Out-Null
        Start-Sleep -Milliseconds 600
        Eval "new Promise(r=>{if(document.readyState==='complete')r();else addEventListener('load',r,{once:true})})" | Out-Null
        Eval "Promise.all([...document.querySelectorAll('main img')].map(i=>{i.loading='eager';return i.decode().catch(()=>{})})).then(()=>true)" | Out-Null
        $result=Eval @'
(()=>{const cards=[...document.querySelectorAll('.blog-card')];const image=document.querySelector('.blog-featured-image')||cards[0].querySelector('img');return {overflow:document.documentElement.scrollWidth>innerWidth,errors:window.__errors,cardCount:cards.length,h1:document.querySelector('h1').textContent,image:{loaded:image.complete&&image.naturalWidth===1672&&image.naturalHeight===941,fit:getComputedStyle(image).objectFit,ratio:image.getBoundingClientRect().width/image.getBoundingClientRect().height,src:image.getAttribute('src')},referenceCount:document.querySelectorAll('.blog-references a').length,description:document.querySelector('meta[name="description"]').content,quoteReady:document.documentElement.classList.contains('quote-flow-ready')}})()
'@
        Assert (!$result.overflow -and $result.errors.Count -eq 0 -and $result.image.loaded -and $result.image.fit -eq 'contain' -and $result.quoteReady) "Browser check failed for $file at $width"
        if($file -eq 'blog.html'){Assert ($result.cardCount -eq 17) 'Browser archive card count';Assert ([Math]::Abs($result.image.ratio-4/3) -lt .01) 'Archive image frame mismatch'}else{Assert ($result.h1 -ceq $data.title -and $result.referenceCount -eq 4 -and $result.description -ceq $data.description) 'Rendered article incomplete'}
        $results+=@{page=$file;width=$width;result=$result}
        Shot (($file.Replace('.html',''))+"-$width.png") $null
        if($file -eq $data.slug){
            Eval "document.documentElement.style.scrollBehavior='auto';document.querySelector('.blog-references').scrollIntoView();true" | Out-Null
            Shot "references-$width.png" $null
            if($width -eq 390){
                Eval "document.querySelector('.menu-button').click();true" | Out-Null
                Assert (Eval "document.querySelector('.menu-button').getAttribute('aria-expanded')==='true'") 'Mobile navigation failed'
                Eval "document.querySelector('.menu-button').click();true" | Out-Null
            }
            Eval "document.querySelector('.blog-article .text-link').click();true" | Out-Null
            Start-Sleep -Milliseconds 350
            Assert (Eval "location.pathname.endsWith('/blog.html')") 'Back to Blog failed'
            Eval "document.querySelector('.blog-card .text-link').click();true" | Out-Null
            Start-Sleep -Milliseconds 350
            Assert (Eval ('location.pathname.endsWith('+('"'+$data.slug+'"')+')')) 'Read More failed'
        }
    }
}
$socket.Dispose()
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'results.json'),($results | ConvertTo-Json -Depth 20),(New-Object Text.UTF8Encoding($false)))
Write-Output 'PASS: exact supplied article, five headings, four complete references, original PNG, SEO/schema, sitemap, 17 archive cards, unchanged existing pages/navigation, all local links, desktop/tablet/mobile rendering, mobile menu, quote initialization, Read More, and Back to Blog.'
