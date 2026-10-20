$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$utf8 = New-Object Text.UTF8Encoding($false)
function Read($path) { [IO.File]::ReadAllText((Join-Path $root $path), [Text.Encoding]::UTF8) }
function Save-File($path, $value) { [IO.File]::WriteAllText((Join-Path $root $path), $value, $utf8) }
function Escape($value) { [Net.WebUtility]::HtmlEncode($value) }
$source = [IO.File]::ReadAllText('C:\Users\Owner\Downloads\paradigm_janitorial_blogs_with_photo_assignments.md').Replace("`r`n", "`n")
$sections = [regex]::Matches($source, '(?ms)^# (?!Paradigm)([^\n]+)\n(.*?)(?=^# |\z)')
if ($sections.Count -ne 3) { throw 'Expected three articles' }
$attachments = @('Modern Auto Shop Waiting Lounge.png','Modern Law Office Conference Room.png','Modern Physical Therapy Clinic Interior.png')
$alts = @('Modern auto repair waiting lounge with clean seating and a view into the service bay','Modern law office conference room with a polished table and clean seating','Bright physical therapy clinic with treatment tables and shared exercise equipment')
$services = @('commercial.html','office-cleaning.html','medical-dental-office-cleaning.html')
$template = Read 'blog-warehouse-break-room-cleaning-2026.html'
$base = 'https://paradigmjanitorial.net/'
$schemaPattern = '(?s)<script type="application/ld\+json">(.*?)</script>'
$manifest = @(); $cards = @()
$originalBlogs = @(Get-ChildItem (Join-Path $root 'blog*.html') | ForEach-Object { @{file=$_.Name;hash=(Get-FileHash $_.FullName).Hash} })
for ($i=0; $i -lt 3; $i++) {
    $title = $sections[$i].Groups[1].Value.Trim()
    $section = $sections[$i].Groups[2].Value
    $slug = [regex]::Match($section, '\*\*Suggested file:\*\* `([^`]+)`').Groups[1].Value
    if ((Test-Path (Join-Path $root $slug)) -or (Read 'blog.html').Contains($title)) { throw "Duplicate article: $title" }
    foreach ($existing in Get-ChildItem (Join-Path $root 'blog*.html')) { if ([IO.File]::ReadAllText($existing.FullName).Contains((Escape $title))) { throw "Duplicate title: $title" } }
}
for ($i=0; $i -lt 3; $i++) {
    $title = $sections[$i].Groups[1].Value.Trim(); $section = $sections[$i].Groups[2].Value
    $slug = [regex]::Match($section, '\*\*Suggested file:\*\* `([^`]+)`').Groups[1].Value
    $photo = [regex]::Match($section, '\*\*Featured image and blog card image:\*\* `([^`]+)`').Groups[1].Value
    $description = [regex]::Match($section, '\*\*Meta description:\*\* ([^\n]+)').Groups[1].Value.Trim()
    $article = [regex]::Replace($section, '(?s)^.*?\*\*Meta description:\*\* [^\n]+\n', '').Trim()
    $article = [regex]::Replace($article, '(?m)^---\s*$', '').Trim()
    # The editorial note is retained as supplied content, not executed as an instruction.
    $blocks = $article -split '\n\s*\n'; $lead = $blocks[0]; $body = ''; $sources = $false
    foreach ($block in $blocks[1..($blocks.Count-1)]) {
        if ($block -eq '**Sources**') { $body += '<section aria-label="Sources" class="blog-references"><h2>Sources</h2>'; $sources=$true }
        elseif ($block.StartsWith('## ')) { $body += '<h2>' + (Escape $block.Substring(3)) + '</h2>' }
        elseif ($block -match '^https://\S+$') { $body += '<p><a href="' + (Escape $block) + '" rel="noopener noreferrer" target="_blank">' + (Escape $block) + '</a></p>' }
        else { $text = Escape $block; $text = [regex]::Replace($text, '\*\*([^*]+)\*\*', '<strong>$1</strong>'); $body += '<p>' + $text + '</p>' }
    }
    if ($sources) { $body += '</section>' }
    $body = $body.Replace('Los Angeles County','<a href="los-angeles-county.html">Los Angeles County</a>').Replace('San Bernardino County','<a href="san-bernardino-county.html">San Bernardino County</a>').Replace('Paradigm Janitorial',('<a href="'+$services[$i]+'">Paradigm Janitorial</a>'))
    $image = 'assets/images/blog-previews/' + $photo
    $attachmentPath = Join-Path 'C:\Users\Owner\OneDrive\Desktop' $attachments[$i]
    if (!(Test-Path -LiteralPath $attachmentPath)) { $attachmentPath = Join-Path 'C:\Users\Owner\Downloads' $attachments[$i] }
    Copy-Item -LiteralPath $attachmentPath -Destination (Join-Path $root $image)
    $oldSchema = [regex]::Match($template,$schemaPattern).Groups[1].Value | ConvertFrom-Json
    $post = $oldSchema.'@graph' | Where-Object { $_.'@type' -eq 'BlogPosting' }
    $oldTitle=$post.headline; $oldDescription=$post.description; $oldImage=$post.image.url.Substring($base.Length)
    $oldAlt = [regex]::Match($template,'<img alt="([^"]+)" class="blog-featured-image"').Groups[1].Value
    $page = $template.Replace('blog-warehouse-break-room-cleaning-2026.html',$slug).Replace($oldTitle,(Escape $title)).Replace($oldDescription,(Escape $description)).Replace($oldImage,$image).Replace($oldAlt,(Escape $alts[$i])).Replace('2026-10-15','2026-10-20').Replace('content="1448"','content="1536"').Replace('content="1086"','content="1024"')
    $post.'@id'=$base+$slug+'#article'; $post.headline=$title; $post.description=$description; $post.url=$base+$slug; $post.mainEntityOfPage=$base+$slug; $post.image.url=$base+$image; $post.image.width=1536; $post.image.height=1024; $post.datePublished='2026-10-20'; $post.dateModified='2026-10-20'
    $post | Add-Member citation @([regex]::Matches($article,'(?m)^https://\S+$') | ForEach-Object {$_.Value})
    $crumb=($oldSchema.'@graph' | Where-Object {$_.'@type' -eq 'BreadcrumbList'}).itemListElement[2]; $crumb.name=$title; $crumb.item=$base+$slug
    $schemaText='<script type="application/ld+json">'+($oldSchema | ConvertTo-Json -Depth 30 -Compress)+'</script>'
    $page=[regex]::Replace($page,$schemaPattern,[Text.RegularExpressions.MatchEvaluator]{param($m) $schemaText})
    $img='<img alt="'+(Escape $alts[$i])+'" class="blog-featured-image" decoding="sync" fetchpriority="high" loading="eager" width="1536" height="1024" src="'+$image+'" style="display:block;width:100% !important;height:auto !important;max-height:none !important;aspect-ratio:3/2 !important;object-fit:contain !important;" onload="this.classList.add(&apos;photo-ready&apos;)"/>'
    $main='<main id="main-content"><article class="blog-article"><header class="blog-article-header"><time class="blog-date" datetime="2026-10-20">October 20, 2026</time><h1>'+(Escape $title)+'</h1><p class="blog-lead">'+(Escape $lead)+'</p></header>'+$img+'<div class="blog-body">'+$body+'</div><p><a class="text-link" href="blog.html">Back to Blog</a></p></article></main>'
    $page=[regex]::Replace($page,'(?s)<main.*?</main>',[Text.RegularExpressions.MatchEvaluator]{param($m) $main})
    Save-File $slug $page
    $cardImg=$img.Replace(' class="blog-featured-image"','')
    $cards += '<article class="blog-card"><a href="'+$slug+'">'+$cardImg+'</a><div class="blog-card-copy"><h2><a href="'+$slug+'">'+(Escape $title)+'</a></h2><p class="blog-date-line">Published <time class="blog-date" datetime="2026-10-20">October 20, 2026</time></p><p>'+(Escape $description)+'</p><a class="text-link" href="'+$slug+'">Read More</a></div></article>'
    $manifest += @{slug=$slug;title=$title;description=$description;image=$image;article=$article;attachment=$attachments[$i]}
}
$index=(Read 'blog.html').Replace('<div class="blog-grid">',('<div class="blog-grid">'+($cards -join '')))
$schema=[regex]::Match($index,$schemaPattern).Groups[1].Value | ConvertFrom-Json
$list=$schema.'@graph' | Where-Object {$_.'@type' -eq 'ItemList'}
$allCards=[regex]::Matches($index,'(?s)<article class="blog-card">.*?<h2><a href="([^"]+)">(.*?)</a></h2>')
$entries=@(); for($i=0;$i -lt $allCards.Count;$i++){ $entries+=@{'@type'='ListItem';position=$i+1;url=$base+$allCards[$i].Groups[1].Value;name=[Net.WebUtility]::HtmlDecode($allCards[$i].Groups[2].Value)} }
$list.numberOfItems=$entries.Count; $list.itemListElement=$entries
$schemaText='<script type="application/ld+json">'+($schema | ConvertTo-Json -Depth 30 -Compress)+'</script>'
$index=[regex]::Replace($index,$schemaPattern,[Text.RegularExpressions.MatchEvaluator]{param($m) $schemaText})
Save-File 'blog.html' $index
$sitemap=(Read 'sitemap.xml').Replace('<loc>https://paradigmjanitorial.net/blog.html</loc><lastmod>2026-10-15</lastmod>','<loc>https://paradigmjanitorial.net/blog.html</loc><lastmod>2026-10-20</lastmod>')
$urls=($manifest | ForEach-Object {'<url><loc>'+$base+$_.slug+'</loc><lastmod>2026-10-20</lastmod></url>'}) -join ''
Save-File 'sitemap.xml' ($sitemap.Replace('</urlset>',$urls+'</urlset>'))
Save-File 'handoff/blogs-2026-10-20/manifest.json' ($manifest | ConvertTo-Json -Depth 10)
Save-File 'handoff/blogs-2026-10-20/original-blog-hashes.json' ($originalBlogs | ConvertTo-Json)
Write-Output 'Created three articles, original PNG assets, archive cards, schema, and sitemap entries.'
