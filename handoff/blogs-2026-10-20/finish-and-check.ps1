$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$utf8=New-Object Text.UTF8Encoding($false)
function Read($file){[IO.File]::ReadAllText((Join-Path $root $file))}
function Save($file,$text){[IO.File]::WriteAllText((Join-Path $root $file),$text,$utf8)}
function Plain($text){$text=[regex]::Replace($text,'</(?:p|h[1-6]|section)>',' ');[regex]::Replace([Net.WebUtility]::HtmlDecode([regex]::Replace($text,'<[^>]+>','')),'\s+',' ').Trim()}
$index=Read 'blog.html'
$schemaPattern='(?s)<script type="application/ld\+json">(.*?)</script>'
if(!$index.Contains('href="blog-office-checklist-workplace-essentials.html"')){
    $card='<article class="blog-card"><a href="blog-office-checklist-workplace-essentials.html"><img alt="Black professional organizing a well stocked office supply cabinet" decoding="async" loading="lazy" width="1200" height="1000" src="assets/images/blog-office-checklist-2026.jpg" style="display:block;width:100% !important;height:auto !important;max-height:none !important;aspect-ratio:6/5 !important;object-fit:contain !important;"/></a><div class="blog-card-copy"><h2><a href="blog-office-checklist-workplace-essentials.html">Office Checklist</a></h2><p class="blog-date-line">Published <time class="blog-date" datetime="2026-10-06">October 6, 2026</time></p><p>A practical office checklist explaining why workplaces should keep first aid supplies, emergency basics, chargers, tools, breakroom items, restroom backups, and everyday essentials ready.</p><a class="text-link" href="blog-office-checklist-workplace-essentials.html">Read More</a></div></article>'
    $index=$index.Replace('</div></section></main>',$card+'</div></section></main>')
}
# Match the archive's high priority image hints to the new first row.
$manifest=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'manifest.json') | ConvertFrom-Json
$preloads=[regex]::Matches($index,'<link rel="preload" as="image" href="assets/images/blog-previews/[^"]+" fetchpriority="high"/>')
for($i=0;$i -lt [Math]::Min(3,$preloads.Count);$i++){$index=$index.Replace($preloads[$i].Value,('<link rel="preload" as="image" href="'+$manifest[$i].image+'" fetchpriority="high"/>'))}
$schema=[regex]::Match($index,$schemaPattern).Groups[1].Value | ConvertFrom-Json
$list=$schema.'@graph' | Where-Object {$_.'@type' -eq 'ItemList'}
$cards=[regex]::Matches($index,'(?s)<article class="blog-card">.*?<h2><a href="([^"]+)">(.*?)</a></h2>')
$entries=@();for($i=0;$i -lt $cards.Count;$i++){$entries+=@{'@type'='ListItem';position=$i+1;url='https://paradigmjanitorial.net/'+$cards[$i].Groups[1].Value;name=[Net.WebUtility]::HtmlDecode($cards[$i].Groups[2].Value)}}
$list.numberOfItems=$entries.Count;$list.itemListElement=$entries
$schemaText='<script type="application/ld+json">'+($schema | ConvertTo-Json -Depth 30 -Compress)+'</script>'
$index=[regex]::Replace($index,$schemaPattern,[Text.RegularExpressions.MatchEvaluator]{param($m)$schemaText})
Save 'blog.html' $index
Save 'sitemap.xml' ((Read 'sitemap.xml').Replace('<loc>https://paradigmjanitorial.net/index.html</loc>','<loc>https://paradigmjanitorial.net/</loc>'))
$checks=@()
$original=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'original-blog-hashes.json') | ConvertFrom-Json
foreach($old in $original){if($old.file -ne 'blog.html' -and (Get-FileHash (Join-Path $root $old.file)).Hash -ne $old.hash){throw "Existing article changed: $($old.file)"}}
$git='C:\Program Files\Git\cmd\git.exe'
$oldIndex=(& $git -C $root show HEAD:blog.html | Out-String).Replace("`r`n","`n")
foreach($card in [regex]::Matches($oldIndex,'(?s)<article class="blog-card">.*?</article>')){if(!$index.Replace("`r`n","`n").Contains($card.Value)){throw 'Original archive card changed'}}
Add-Type -AssemblyName System.Drawing
foreach($entry in $manifest){
    $page=Read $entry.slug
    $main=[regex]::Match($page,'(?s)<main.*?</main>').Value
    $expected=Plain ($entry.article.Replace('## ','').Replace('**',''))
    $actual=Plain ([regex]::Match($main,'(?s)<p class="blog-lead">(.*?)</p>').Groups[1].Value+' '+[regex]::Match($main,'(?s)<div class="blog-body">(.*?)</div>').Groups[1].Value)
    if($actual -cne $expected){throw "Content mismatch: $($entry.slug)"}
    if([regex]::Matches($main,'<h1>').Count -ne 1){throw 'H1 count'}
    foreach($heading in [regex]::Matches($entry.article,'(?m)^## (.+)$')){if(!(Plain $main).Contains($heading.Groups[1].Value)){throw 'Missing heading'}}
    $post=([regex]::Match($page,$schemaPattern).Groups[1].Value | ConvertFrom-Json).'@graph' | Where-Object {$_.'@type' -eq 'BlogPosting'}
    if($post.headline -cne $entry.title -or $post.description -cne $entry.description -or $post.datePublished -ne '2026-10-20' -or $post.dateModified -ne '2026-10-20' -or $post.image.url -ne ('https://paradigmjanitorial.net/'+$entry.image)){throw 'Article schema mismatch'}
    if(!$page.Contains('<title>'+[Net.WebUtility]::HtmlEncode($entry.title)+' | Paradigm Janitorial</title>')){throw 'SEO title mismatch'}
    if(!$page.Contains('content="'+[Net.WebUtility]::HtmlEncode($entry.description)+'" name="description"')){throw 'Meta description mismatch'}
    $img=[Drawing.Image]::FromFile((Join-Path $root $entry.image));if($img.Width -ne 1536 -or $img.Height -ne 1024){throw 'Image dimensions'};$img.Dispose()
    if((Get-FileHash (Join-Path $root $entry.image)).Hash -ne (Get-FileHash (Join-Path 'C:\Users\Owner\Downloads' $entry.attachment)).Hash){throw 'Image modified'}
    $card=[regex]::Match($index,'(?s)<article class="blog-card"><a href="'+[regex]::Escape($entry.slug)+'">.*?</article>').Value
    if(!$card.Contains('src="'+$entry.image+'"') -or !$main.Contains('src="'+$entry.image+'"') -or !$card.Contains('aspect-ratio:3/2') -or !$main.Contains('object-fit:contain')){throw 'Image card/article mismatch'}
    foreach($pattern in @('(?s)<style id="site-initial-layout">.*?</style>','(?s)<header class="site-header">.*?</header>','(?s)<footer class="footer">.*?</footer>')){if([regex]::Match($page,$pattern).Value -cne [regex]::Match((Read 'blog-warehouse-break-room-cleaning-2026.html'),$pattern).Value){throw 'Template mismatch'}}
    foreach($m in [regex]::Matches($page,'(?:href|src)="([^"#]+)"')){$target=[Net.WebUtility]::HtmlDecode($m.Groups[1].Value);if($target -match '^(https?:|tel:|mailto:|data:|javascript:)'){continue};$target=($target -split '[?#]')[0];if(!(Test-Path -LiteralPath (Join-Path $root $target))){throw "Missing local target: $target"}}
    if($main -match '(?i)FAQ|next steps|book a consultation|[\u2013\u2014]'){throw 'Unrequested writing found'}
    $checks+=@{page=$entry.slug;content='exact match';image='original PNG, 1536 by 1024, same card and article';schema='pass';metadata='pass';localLinks='pass';sharedTemplate='unchanged'}
}
[xml]$map=Read 'sitemap.xml';$urls=@($map.urlset.url | ForEach-Object {$_.loc})
if(($urls | Select-Object -Unique).Count -ne $urls.Count){throw 'Duplicate sitemap URLs'}
foreach($entry in $manifest){if($urls -notcontains ('https://paradigmjanitorial.net/'+$entry.slug)){throw 'Missing sitemap entry'}}
if($list.numberOfItems -ne 16 -or $cards.Count -ne 16){throw 'Archive/schema count mismatch'}
if(($entries.url | Select-Object -Unique).Count -ne 16){throw 'Duplicate archive entry'}
foreach($path in $urls){$file=$path.Replace('https://paradigmjanitorial.net/','');if(!$file){$file='index.html'};if(!(Test-Path (Join-Path $root $file))){throw "Sitemap missing file $file"}}
Save 'handoff/blogs-2026-10-20/local-check-results.json' (@{checks=$checks;archiveCount=16;existingArticles='unchanged';existingCards='unchanged';sitemap='valid XML, unique URLs, all local targets exist';browser='not run: launch permission declined';audit='PDF read as reference only; restored orphan article archive card and canonical homepage sitemap URL'} | ConvertTo-Json -Depth 10)
Write-Output 'PASS: full content, headings, sources, SEO metadata, original photos, internal links, shared design, schema, sitemap, duplicate checks, and preservation of existing articles and archive cards.'
