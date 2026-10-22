$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$utf8=[Text.UTF8Encoding]::new($false)
function Write-Local($path,$text){[IO.File]::WriteAllText((Join-Path $root $path),$text,$utf8)}
function E($text){[Net.WebUtility]::HtmlEncode($text)}
$blocks=Get-Content "$env:TEMP\paradigm-oct21-blocks.json" -Raw | ConvertFrom-Json
$specs=@(
 @{first=2;last=4;slug='blog-assisted-living-dining-room-tour.html';photo='Professional Cleaner in Upscale Dining Room.png';alt='Professional cleaner wiping a dining table in an upscale dining room'},
 @{first=5;last=7;slug='blog-funeral-home-visitation-room.html';photo='Professional Restroom Cleaning in Action.png';alt='Professional cleaner wiping a restroom counter beside sinks and mirrors'},
 @{first=8;last=10;slug='blog-studio-floor-every-class.html';photo='Professional Office Cleaning in Action.png';alt='Professional cleaner vacuuming a rug in a modern office lounge'}
)
$template=[IO.File]::ReadAllText((Join-Path $root 'blog-auto-repair-waiting-room-tells-customers.html'))
$oldTitle='Your Auto Repair Waiting Room Tells Customers How You Will Treat Their Car'
$oldDesc='Discover why a clean auto repair waiting room matters for customer confidence, comfort, and the overall service experience.'
$oldPhoto='assets/images/blog-previews/wide_realistic_interior_photo_of_an_auto_repair_s.png'
$oldAlt='Modern auto repair waiting lounge with clean seating and a view into the service bay'
$cards='';$manifest=@()
foreach($spec in $specs){
 $selected=@($blocks | Where-Object {$_.page -ge $spec.first -and $_.page -le $spec.last})
 $title=$selected[0].text;$desc=$selected[2].text.Substring('SEO description: '.Length)
 if(Test-Path $spec.slug){throw "Duplicate article: $($spec.slug)"}
 $parts=New-Object 'System.Collections.Generic.List[object]'
 foreach($b in $selected[3..($selected.Count-1)]){
  $tag=if($b.bold){'h2'}else{'p'}
  if($parts.Count -gt 0 -and $b.page -gt $parts[$parts.Count-1].page -and !$b.bold -and $parts[$parts.Count-1].tag -eq 'p' -and !$parts[$parts.Count-1].text.StartsWith('https://')){
   $parts[$parts.Count-1].text+=' '+$b.text;$parts[$parts.Count-1].page=$b.page
  }else{$parts.Add(@{tag=$tag;text=$b.text;page=$b.page})}
 }
 $imagePath='assets/images/blog-previews/'+$spec.photo
 Copy-Item -LiteralPath (Join-Path 'C:\Users\Owner\OneDrive\Desktop' $spec.photo) -Destination (Join-Path $root $imagePath)
 $sourceHash=(Get-FileHash -LiteralPath (Join-Path 'C:\Users\Owner\OneDrive\Desktop' $spec.photo)).Hash
 if((Get-FileHash -LiteralPath $imagePath).Hash -ne $sourceHash){throw 'Photo mismatch'}
 $img='<img src="'+(E $imagePath)+'" alt="'+(E $spec.alt)+'" width="1536" height="1024" loading="eager" decoding="sync" fetchpriority="high" style="display:block;width:100% !important;height:auto !important;max-height:none !important;aspect-ratio:3/2 !important;object-fit:contain !important;"/>'
 $article='<article class="blog-article"><header class="blog-article-header"><time class="blog-date" datetime="2026-10-21">October 21, 2026</time><h1>'+(E $title)+'</h1><p class="blog-lead">'+(E $parts[0].text)+'</p></header>'+$img.Replace('<img ','<img class="blog-featured-image" ')+'<div class="blog-body">'
 $sources=@();$references=$false
 foreach($part in $parts.ToArray()[1..($parts.Count-1)]){
  if($part.text -eq 'Sources and references'){$article+='<section aria-label="Sources and references" class="blog-references"><h2>Sources and references</h2>';$references=$true;continue}
  if($references){$sources+=$part.text;$article+='<p><a href="'+(E $part.text)+'" target="_blank" rel="noopener noreferrer">'+(E $part.text)+'</a></p>';continue}
  $text=E $part.text
  $text=$text.Replace('Paradigm Janitorial','<a href="commercial.html">Paradigm Janitorial</a>').Replace('Los Angeles County','<a href="los-angeles-county.html">Los Angeles County</a>').Replace('San Bernardino County','<a href="san-bernardino-county.html">San Bernardino County</a>')
  $article+='<'+$part.tag+'>'+$text+'</'+$part.tag+'>'
 }
 $article+='</section></div></article>'
 $html=$template.Replace($oldTitle,(E $title)).Replace($oldDesc,(E $desc)).Replace('blog-auto-repair-waiting-room-tells-customers.html',$spec.slug).Replace($oldPhoto,$imagePath.Replace(' ','%20')).Replace($oldAlt,(E $spec.alt)).Replace('2026-10-20','2026-10-21')
 $html=[regex]::Replace($html,'(?s)<article class="blog-article">.*?</article>',[Text.RegularExpressions.MatchEvaluator]{param($m) $article})
 $jsonMatch=[regex]::Match($html,'<script type="application/ld\+json">(.*?)</script>')
 $schema=[Net.WebUtility]::HtmlDecode($jsonMatch.Groups[1].Value)|ConvertFrom-Json
 $posting=$schema.'@graph'|Where-Object {$_.'@type' -eq 'BlogPosting'}
 $posting.citation=$sources
 $json=$schema|ConvertTo-Json -Depth 25 -Compress
 $html=$html.Replace($jsonMatch.Value,('<script type="application/ld+json">'+$json+'</script>'))
 Write-Local $spec.slug $html
 $cards+='<article class="blog-card blog-card-oct21"><a href="'+$spec.slug+'">'+$img+'</a><div class="blog-card-copy"><h2><a href="'+$spec.slug+'">'+(E $title)+'</a></h2><p class="blog-date-line">Published <time class="blog-date" datetime="2026-10-21">October 21, 2026</time></p><p>'+(E $desc)+'</p><a class="text-link" href="'+$spec.slug+'">Read More</a></div></article>'
 $manifest+=@{title=$title;description=$desc;file=$spec.slug;url=('https://paradigmjanitorial.net/'+$spec.slug);photo=$spec.photo;sha256=$sourceHash;parts=$parts.ToArray();sources=$sources}
}
$archive=[IO.File]::ReadAllText((Join-Path $root 'blog.html'))
$archive=$archive.Replace('<div class="blog-grid">',('<div class="blog-grid">'+$cards))
$css='<style id="oct21-full-photos">#full-photo-layout.page-blog-index .blog-card-oct21>a:first-child{height:auto!important;max-height:none!important;min-height:0!important;aspect-ratio:3/2!important;padding:0!important;background:transparent!important}#full-photo-layout.page-blog-index .blog-card-oct21>a:first-child img{height:auto!important;max-height:none!important;aspect-ratio:3/2!important;object-fit:contain!important}</style>'
$archive=$archive.Replace('</head>',($css+'</head>'))
Write-Local 'blog.html' $archive
$sitemap=[IO.File]::ReadAllText((Join-Path $root 'sitemap.xml'))
$entries='';foreach($s in $specs){$entries+="  <url>`n    <loc>https://paradigmjanitorial.net/$($s.slug)</loc>`n    <lastmod>2026-10-21</lastmod>`n  </url>`n"}
$sitemap=$sitemap.Replace('</urlset>',($entries+'</urlset>'))
Write-Local 'sitemap.xml' $sitemap
Write-Local 'handoff/blogs-2026-10-21/approved-content.json' ($manifest|ConvertTo-Json -Depth 15)
'Created all three articles, exact original photos, archive cards and sitemap entries.'
