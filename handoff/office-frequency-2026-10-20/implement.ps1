$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$utf8=New-Object Text.UTF8Encoding($false)
function Read($p){[IO.File]::ReadAllText((Join-Path $root $p))}
function Save($p,$s){[IO.File]::WriteAllText((Join-Path $root $p),$s,$utf8)}
function E($s){[Net.WebUtility]::HtmlEncode($s)}
$data=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'content.json') | ConvertFrom-Json
if(Test-Path (Join-Path $root $data.slug)){throw 'Article already exists; refusing duplicate import'}
foreach($file in Get-ChildItem (Join-Path $root 'blog*.html')){if((Read $file.Name).Contains((E $data.title))){throw 'Duplicate title already exists'}}
$baseline=@(Get-ChildItem (Join-Path $root '*.html') | ForEach-Object {@{file=$_.Name;hash=(Get-FileHash $_.FullName).Hash}})
Save 'handoff/office-frequency-2026-10-20/baseline.json' ($baseline | ConvertTo-Json)
$source='C:\Users\Owner\OneDrive\Desktop\Professional Office Cleaning Team.png'
Copy-Item -LiteralPath $source -Destination (Join-Path $root $data.image)
Add-Type -AssemblyName System.Drawing
$image=[Drawing.Image]::FromFile((Join-Path $root $data.image));$width=$image.Width;$height=$image.Height;$image.Dispose()
$base='https://paradigmjanitorial.net/'
$template=Read 'blog-physical-therapy-equipment-patients-share.html'
$pattern='(?s)<script type="application/ld\+json">(.*?)</script>'
$schema=[regex]::Match($template,$pattern).Groups[1].Value | ConvertFrom-Json
$post=$schema.'@graph' | Where-Object {$_.'@type' -eq 'BlogPosting'}
$oldSlug=$post.url.Substring($base.Length);$oldImage=$post.image.url.Substring($base.Length)
$page=$template.Replace($oldSlug,$data.slug).Replace($oldImage,$data.image)
$page=[regex]::Replace($page,'<title>.*?</title>',('<title>'+(E $data.title)+' | Paradigm Janitorial</title>'))
$seoTitle=$data.title+' | Paradigm Janitorial'
$values=@{'name:description'=$data.description;'property:og:title'=$seoTitle;'property:og:description'=$data.description;'name:twitter:title'=$seoTitle;'name:twitter:description'=$data.description;'property:og:image:alt'=$data.alt;'name:twitter:image:alt'=$data.alt;'property:og:image:width'=[string]$width;'property:og:image:height'=[string]$height}
foreach($key in $values.Keys){$parts=$key -split ':',2;$tagPattern='<meta content="[^"]*" '+[regex]::Escape($parts[0]+'="'+$parts[1]+'"')+'/>';$replacement='<meta content="'+(E $values[$key])+'" '+$parts[0]+'="'+$parts[1]+'"/>';$page=[regex]::Replace($page,$tagPattern,[Text.RegularExpressions.MatchEvaluator]{param($m)$replacement})}
$post.'@id'=$base+$data.slug+'#article';$post.headline=$data.title;$post.description=$data.description;$post.url=$base+$data.slug;$post.mainEntityOfPage=$base+$data.slug;$post.image.url=$base+$data.image;$post.image.width=$width;$post.image.height=$height;$post.citation=@($data.references.url)
$crumb=($schema.'@graph' | Where-Object {$_.'@type' -eq 'BreadcrumbList'}).itemListElement[2];$crumb.name=$data.title;$crumb.item=$base+$data.slug
$schemaText='<script type="application/ld+json">'+($schema | ConvertTo-Json -Depth 40 -Compress)+'</script>'
$page=[regex]::Replace($page,$pattern,[Text.RegularExpressions.MatchEvaluator]{param($m)$schemaText})
$body=''
foreach($section in $data.sections){$body+='<h2>'+(E $section.heading)+'</h2>';foreach($paragraph in $section.paragraphs){$body+='<p>'+(E $paragraph)+'</p>'}}
$body=$body.Replace('professional cleaning several times per week','<a href="office-cleaning.html">professional cleaning several times per week</a>').Replace('commercial cleaning plan','<a href="commercial.html">commercial cleaning plan</a>')
$body+='<section class="blog-references" aria-label="Sources and References"><h2>Sources and References</h2><p>Verified source links supporting the factual context of the article.</p>'
foreach($reference in $data.references){$body+='<p><a href="'+(E $reference.url)+'" target="_blank" rel="noopener noreferrer">'+(E $reference.title)+'</a></p><p>'+(E $reference.description)+'</p>'}
$body+='</section>'
$img='<img class="blog-featured-image" src="'+$data.image+'" alt="'+(E $data.alt)+'" width="'+$width+'" height="'+$height+'" loading="eager" decoding="sync" fetchpriority="high" style="display:block;width:100% !important;height:auto !important;max-height:none !important;aspect-ratio:'+$width+'/'+$height+' !important;object-fit:contain !important;" onload="this.classList.add(&apos;photo-ready&apos;)"/>'
$fallback=[regex]::Match($template,'(?s)<aside class="quote-script-fallback".*?</aside>').Value
$main='<main id="main-content"><article class="blog-article"><header class="blog-article-header"><time class="blog-date" datetime="2026-10-20">October 20, 2026</time><h1>'+(E $data.title)+'</h1></header>'+$img+'<div class="blog-body">'+$body+'</div><p><a class="text-link" href="blog.html">Back to Blog</a></p></article>'+$fallback+'</main>'
$page=[regex]::Replace($page,'(?s)<main.*?</main>',[Text.RegularExpressions.MatchEvaluator]{param($m)$main})
Save $data.slug $page
$cardImage=$img.Replace(' class="blog-featured-image"','').Replace(('aspect-ratio:'+$width+'/'+$height+' !important'),'aspect-ratio:4/3 !important')
$card='<article class="blog-card"><a href="'+$data.slug+'">'+$cardImage+'</a><div class="blog-card-copy"><h2><a href="'+$data.slug+'">'+(E $data.title)+'</a></h2><p class="blog-date-line">Published <time class="blog-date" datetime="2026-10-20">October 20, 2026</time></p><p>'+(E $data.description)+'</p><a class="text-link" href="'+$data.slug+'">Read More</a></div></article>'
$index=(Read 'blog.html').Replace('<div class="blog-grid">','<div class="blog-grid">'+$card)
$firstPreload=[regex]::Match($index,'<link rel="preload" as="image" href="assets/images/blog-previews/[^"]+" fetchpriority="high"/>')
if($firstPreload.Success){$index=$index.Replace($firstPreload.Value,('<link rel="preload" as="image" href="'+$data.image+'" fetchpriority="high"/>'))}
$schema=[regex]::Match($index,$pattern).Groups[1].Value | ConvertFrom-Json
$list=$schema.'@graph' | Where-Object {$_.'@type' -eq 'ItemList'}
$cards=[regex]::Matches($index,'(?s)<article class="blog-card">.*?<h2><a href="([^"]+)">(.*?)</a></h2>')
$entries=@();for($i=0;$i -lt $cards.Count;$i++){$entries+=@{'@type'='ListItem';position=$i+1;url=$base+$cards[$i].Groups[1].Value;name=[Net.WebUtility]::HtmlDecode($cards[$i].Groups[2].Value)}}
$list.numberOfItems=$entries.Count;$list.itemListElement=$entries
$schemaText='<script type="application/ld+json">'+($schema | ConvertTo-Json -Depth 40 -Compress)+'</script>'
$index=[regex]::Replace($index,$pattern,[Text.RegularExpressions.MatchEvaluator]{param($m)$schemaText})
Save 'blog.html' $index
[xml]$map=Read 'sitemap.xml';$ns=$map.DocumentElement.NamespaceURI
$url=$map.CreateElement('url',$ns);$loc=$map.CreateElement('loc',$ns);$loc.InnerText=$base+$data.slug;[void]$url.AppendChild($loc);$lastmod=$map.CreateElement('lastmod',$ns);$lastmod.InnerText='2026-10-20';[void]$url.AppendChild($lastmod);[void]$map.DocumentElement.AppendChild($url);$map.Save((Join-Path $root 'sitemap.xml'))
Write-Output "Created article and archive card with the original ${width}x${height} PNG and four references."
