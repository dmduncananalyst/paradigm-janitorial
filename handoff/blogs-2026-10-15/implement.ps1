$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$utf8 = New-Object Text.UTF8Encoding($false)
function Read($path) { [IO.File]::ReadAllText((Join-Path $root $path), [Text.Encoding]::UTF8) }
function Save-File($path, $value) { [IO.File]::WriteAllText((Join-Path $root $path), $value, $utf8) }
function Escape($value) { [Net.WebUtility]::HtmlEncode($value) }
$source = (Read 'paradigm_blogs_2026_10_15.md').Replace("`r`n", "`n")
if ((Read 'blog.html').Contains('href="blog-worship-weekend-cleaning-2026.html"')) { throw 'These articles are already installed. This one-time import will not append duplicate cards.' }
$sections = [regex]::Matches($source, '(?ms)^# (?!Paradigm|Production)([^\n]+)\n(.*?)(?=^# |\z)')
if ($sections.Count -ne 3) { throw 'Expected exactly three articles' }
$slugs = @('blog-worship-weekend-cleaning-2026.html', 'blog-warehouse-break-room-cleaning-2026.html', 'blog-apartment-garage-stairwell-cleaning-2026.html')
$services = @('commercial.html', 'warehouse-industrial-cleaning.html', 'apartment-buildings.html')
$template = Read 'blog-office-flu-season-2026.html'
$base = 'https://paradigmjanitorial.net/'
$schemaPattern = '(?s)(<script type="application/ld\+json">)(.*?)(</script>)'
$cards = @()
$manifest = @()
for ($i = 0; $i -lt 3; $i++) {
    $title = $sections[$i].Groups[1].Value
    $section = $sections[$i].Groups[2].Value
    $photo = [regex]::Match($section, 'Photo filename: `([^`]+)`').Groups[1].Value
    $alt = [regex]::Match($section, 'Image description: ([^\n]+)').Groups[1].Value
    $description = [regex]::Match($section, 'Meta description: ([^\n]+)').Groups[1].Value
    $article = ($section -split "## Article`n`n", 2)[1].Trim()
    $blocks = $article -split "`n`n"
    $lead = $blocks[0]
    $body = ''
    $inResources = $false
    foreach ($block in $blocks[1..($blocks.Count - 1)]) {
        if ($block -eq '## Resources') {
            $body += '<section aria-label="Resources" class="blog-references"><h2>Resources</h2>'
            $inResources = $true
        } elseif ($block.StartsWith('## ')) {
            $body += '<h2>' + (Escape $block.Substring(3)) + '</h2>'
        } elseif ($block -match '^\[([^\]]+)\]\(([^)]+)\)$') {
            $body += '<p><a href="' + (Escape $Matches[2]) + '" rel="noopener noreferrer" target="_blank">' + (Escape $Matches[1]) + '</a></p>'
        } else {
            $body += '<p>' + (Escape $block) + '</p>'
        }
    }
    if ($inResources) { $body += '</section>' }
    # Link existing copy without changing or adding any visible article text.
    $body = $body.Replace('Los Angeles County', '<a href="los-angeles-county.html">Los Angeles County</a>').Replace('San Bernardino County', '<a href="san-bernardino-county.html">San Bernardino County</a>')
    $body = $body.Replace('Paradigm Janitorial', ('<a href="' + $services[$i] + '">Paradigm Janitorial</a>'))
    $image = 'assets/images/blog-previews/' + $photo
    $slug = $slugs[$i]
    $page = $template.Replace('blog-office-flu-season-2026.html', $slug).Replace('assets/images/office-flu.png', $image)
    $oldTitle = 'When Flu Season Moves Through Your Office One Desk at a Time'
    $oldDescription = 'Office flu season puts pressure on shared spaces. Learn how cleaning, hygiene supplies, cleaner air and clear responsibilities support workplace care.'
    $oldAlt = 'Cleaner wiping a refrigerator handle in a shared office break room'
    $page = $page.Replace($oldTitle, (Escape $title)).Replace($oldDescription, (Escape $description)).Replace($oldAlt, (Escape $alt)).Replace('2026-10-14', '2026-10-15')
    $schemaMatch = [regex]::Match($template, $schemaPattern)
    $schema = $schemaMatch.Groups[2].Value | ConvertFrom-Json
    $posting = $schema.'@graph' | Where-Object { $_.'@type' -eq 'BlogPosting' }
    $posting.'@id' = $base + $slug + '#article'
    $posting.headline = $title
    $posting.description = $description
    $posting.url = $base + $slug
    $posting.mainEntityOfPage = $base + $slug
    $posting.image.url = $base + $image
    $posting.datePublished = '2026-10-15'
    $posting.dateModified = '2026-10-15'
    $crumb = ($schema.'@graph' | Where-Object { $_.'@type' -eq 'BreadcrumbList' }).itemListElement[2]
    $crumb.name = $title
    $crumb.item = $base + $slug
    $newSchema = '<script type="application/ld+json">' + ($schema | ConvertTo-Json -Depth 30 -Compress) + '</script>'
    $page = [regex]::Replace($page, $schemaPattern, [Text.RegularExpressions.MatchEvaluator]{ param($m) $newSchema })
    $main = '<main id="main-content"><article class="blog-article"><header class="blog-article-header"><time class="blog-date" datetime="2026-10-15">October 15, 2026</time><h1>' + (Escape $title) + '</h1><p class="blog-lead">' + (Escape $lead) + '</p></header><img alt="' + (Escape $alt) + '" class="blog-featured-image" decoding="sync" fetchpriority="high" height="1086" loading="eager" src="' + $image + '" style="display:block;width:100% !important;height:auto !important;max-height:none !important;aspect-ratio:1448/1086 !important;object-fit:contain !important;object-position:center !important;" width="1448" onload="this.classList.add(&apos;photo-ready&apos;)"/><div class="blog-body">' + $body + '</div></article></main>'
    $page = [regex]::Replace($page, '(?s)<main.*?</main>', [Text.RegularExpressions.MatchEvaluator]{ param($m) $main })
    Save-File $slug $page
    $cards += '<article class="blog-card"><a href="' + $slug + '"><img alt="' + (Escape $alt) + '" decoding="sync" fetchpriority="high" height="1086" loading="eager" src="' + $image + '" style="display:block;width:100% !important;height:auto !important;max-height:none !important;aspect-ratio:4/3 !important;object-fit:contain !important;object-position:center !important;background:#fff;" width="1448" onload="this.classList.add(&apos;photo-ready&apos;)"/></a><div class="blog-card-copy"><h2><a href="' + $slug + '">' + (Escape $title) + '</a></h2><p class="blog-date-line">Published <time class="blog-date" datetime="2026-10-15">October 15, 2026</time></p><p>' + (Escape $description) + '</p><a class="text-link" href="' + $slug + '">Read More</a></div></article>'
    $manifest += @{ slug = $slug; title = $title; image = $image; description = $description; alt = $alt; article = $article }
}
$index = Read 'blog.html'
$index = $index.Replace('<div class="blog-grid">', ('<div class="blog-grid">' + ($cards -join '')))
# Preload the new first row; retain all original cards and their markup.
$oldPreloads = [regex]::Matches($index, '<link rel="preload" as="image" href="assets/images/blog-previews/[^"]+" fetchpriority="high"/>')
for ($i = 0; $i -lt 3; $i++) { $index = $index.Replace($oldPreloads[$i].Value, ('<link rel="preload" as="image" href="' + $manifest[$i].image + '" fetchpriority="high"/>')) }
$schema = [regex]::Match($index, $schemaPattern).Groups[2].Value | ConvertFrom-Json
$list = $schema.'@graph' | Where-Object { $_.'@type' -eq 'ItemList' }
$allCards = [regex]::Matches($index, '(?s)<article class="blog-card">.*?<h2><a href="([^"]+)">(.*?)</a></h2>')
$entries = @()
for ($i = 0; $i -lt $allCards.Count; $i++) { $entries += @{ '@type' = 'ListItem'; position = $i + 1; url = $base + $allCards[$i].Groups[1].Value; name = [Net.WebUtility]::HtmlDecode($allCards[$i].Groups[2].Value) } }
$list.numberOfItems = $entries.Count
$list.itemListElement = $entries
$newSchema = '<script type="application/ld+json">' + ($schema | ConvertTo-Json -Depth 30 -Compress) + '</script>'
$index = [regex]::Replace($index, $schemaPattern, [Text.RegularExpressions.MatchEvaluator]{ param($m) $newSchema })
Save-File 'blog.html' $index
$sitemap = Read 'sitemap.xml'
$sitemap = $sitemap.Replace('<loc>https://paradigmjanitorial.net/blog.html</loc><lastmod>2026-10-14</lastmod>', '<loc>https://paradigmjanitorial.net/blog.html</loc><lastmod>2026-10-15</lastmod>')
$urls = ($slugs | ForEach-Object { '<url><loc>' + $base + $_ + '</loc><lastmod>2026-10-15</lastmod></url>' }) -join ''
Save-File 'sitemap.xml' ($sitemap.Replace('</urlset>', $urls + '</urlset>'))
Save-File 'handoff/blogs-2026-10-15/manifest.json' ($manifest | ConvertTo-Json -Depth 10)
Write-Output "Created three articles and cards; blog schema now lists $($entries.Count) articles."
