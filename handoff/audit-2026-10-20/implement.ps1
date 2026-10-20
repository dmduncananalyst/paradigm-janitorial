$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$utf8=New-Object Text.UTF8Encoding($false)
function Read($p){[IO.File]::ReadAllText((Join-Path $root $p))}
function Save($p,$s){[IO.File]::WriteAllText((Join-Path $root $p),$s,$utf8)}
function E($s){[Net.WebUtility]::HtmlEncode($s)}
$changes=@()
$short=@{
'clean-spaces-medical-dental-daytime-cleaning.html'='Medical and Dental Office Cleaning During Patient Hours'
'post-construction-renovation-cleaning.html'='Post Construction and Renovation Cleaning in LA County'
'blog-office-entryways-rainy-season-2026.html'='Office Entryway Cleaning for the LA Rainy Season'
'blog-retail-holiday-cleaning-2026.html'='Retail Store Cleaning for the Holiday Shopping Season'
'blog-apartment-garage-stairwell-cleaning-2026.html'='Apartment Parking Garage and Stairwell Cleaning'
'blog-apartment-move-out-cleaning-2026.html'='Apartment Move Out Cleaning in LA and San Bernardino'
'blog-warehouse-break-room-cleaning-2026.html'='Warehouse Break Room and Restroom Cleaning'
'blog-worship-weekend-cleaning-2026.html'='Place of Worship Cleaning After the Weekend'
'clean-spaces-kitchen-staff-or-cleaning-service.html'='Restaurant Staff and Professional Kitchen Cleaning'
}
$descriptions=@{
'medical-dental-office-cleaning.html'='Medical and dental office cleaning in Los Angeles County and San Bernardino County, with defined scopes for reception areas, restrooms, offices, and floors.'
'blog-office-checklist-workplace-essentials.html'='A practical office checklist covering first aid, emergency supplies, chargers, tools, breakroom essentials, and restroom backups for a prepared workplace.'
'retail-storefront-cleaning.html'='Retail and storefront cleaning in Los Angeles County and San Bernardino County for entrances, shopping areas, fitting rooms, restrooms, and shared surfaces.'
'post-construction-renovation-cleaning.html'='Post construction and renovation cleaning in Los Angeles County and San Bernardino County for dust, debris, floors, windows, and spaces ready for occupancy.'
'clean-spaces-medical-dental-daytime-cleaning.html'='Keep medical and dental waiting rooms, restrooms, and shared areas maintained during patient hours with clear cleaning schedules and defined responsibilities.'
'clean-spaces-retail-storefront-daytime-cleaning.html'='Maintain retail entrances, sales floors, fitting rooms, and restrooms during business hours with daytime cleaning schedules that account for customer traffic.'
}
$cities=@{'la-canada-flintridge'='La Cañada Flintridge';'rancho-cucamonga'='Rancho Cucamonga';'lake-arrowhead'='Lake Arrowhead';'big-bear-lake'='Big Bear Lake';'beverly-hills'='Beverly Hills';'chino-hills'='Chino Hills';'san-marino'='San Marino';'calabasas'='Calabasas'}
foreach($city in $cities.Keys){$county=if($city -in @('rancho-cucamonga','lake-arrowhead','big-bear-lake','chino-hills')){'San Bernardino County'}else{'Los Angeles County'};$descriptions['cleaning-services-'+$city+'.html']='Cleaning services in '+$cities[$city]+', '+$county+', for estates, offices, and businesses. Scheduled janitorial care with defined cleaning scopes.'}
$protected=@('blog-auto-repair-waiting-room-tells-customers.html','blog-law-office-conference-room-looks-tired.html','blog-physical-therapy-equipment-patients-share.html')
[xml]$sitemap=Read 'sitemap.xml'
$indexed=@($sitemap.urlset.url | ForEach-Object {$_.loc.Replace('https://paradigmjanitorial.net/','')} | ForEach-Object {if($_){$_}else{'index.html'}})
foreach($file in Get-ChildItem (Join-Path $root '*.html')){
    $page=Read $file.Name
    if(!$page.Contains('rel="icon"')){$page=$page.Replace('</head>','<link rel="icon" href="favicon.ico" sizes="32x32"/><link rel="icon" type="image/png" href="assets/images/favicon-32.png" sizes="32x32"/><link rel="apple-touch-icon" href="assets/images/apple-touch-icon.png" sizes="180x180"/></head>')}
    if(!$page.Contains('class="quote-script-fallback"')){
        $fallback='<aside class="quote-script-fallback" aria-label="Quote assistance"><p>For a cleaning quote, call <a href="tel:+18187465432" data-native-call="true">818-746-5432</a>. We are available Monday through Sunday, 8am to 8pm.</p></aside>'
        $page=$page.Replace('</main>',$fallback+'</main>')
        $page=$page.Replace('</head>','<style id="quote-fallback-style">.quote-script-fallback{max-width:920px;margin:24px auto;padding:18px 24px;background:#f4f7fa}.quote-script-fallback a{text-decoration:underline;font-weight:700}html.quote-flow-ready .quote-script-fallback{display:none}</style></head>')
    }
    $page=[regex]::Replace($page,'<div class="footer-locations"><h3>Locations</h3>(?!<a href="locations.html">)','<div class="footer-locations"><h3>Locations</h3><a href="locations.html">Cities We Clean</a>')
    if($file.Name -in @('index.html','los-angeles-county.html','san-bernardino-county.html') -and !$page.Contains('class="all-service-locations"')){$page=$page.Replace('</main>','<p class="all-service-locations" style="padding:0 5vw 24px"><a class="text-link" href="locations.html">View all cities we clean</a></p></main>')}
    if($file.Name -in $indexed -and $file.Name -notin $protected){
        $oldTitle=[Net.WebUtility]::HtmlDecode([regex]::Match($page,'<title>(.*?)</title>').Groups[1].Value)
        $newTitle=$oldTitle
        if($oldTitle.Length -gt 60){
            $topic=($oldTitle -split ' \| ')[0]
            if($short.ContainsKey($file.Name)){$topic=$short[$file.Name]}
            if($topic.Length -gt 60){throw "Needs curated title: $($file.Name)"}
            $newTitle=if(($topic+' | Paradigm Janitorial').Length -le 60){$topic+' | Paradigm Janitorial'}else{$topic}
            foreach($pair in @(@('<title>'+ (E $oldTitle)+'</title>','<title>'+(E $newTitle)+'</title>'),@('content="'+(E $oldTitle)+'"','content="'+(E $newTitle)+'"'))){$page=$page.Replace($pair[0],$pair[1])}
            # Some original tags use literal Unicode rather than HTML entities.
            $page=$page.Replace('<title>'+$oldTitle+'</title>','<title>'+(E $newTitle)+'</title>').Replace('content="'+$oldTitle+'"','content="'+(E $newTitle)+'"')
            $changes+=@{page=$file.Name;field='title';before=$oldTitle;after=$newTitle}
        }
        if($descriptions.ContainsKey($file.Name)){
            $old=[Net.WebUtility]::HtmlDecode([regex]::Match($page,'<meta content="([^"]*)" name="description"').Groups[1].Value)
            $new=$descriptions[$file.Name]
            if($new.Length -gt 160 -or $new.Length -lt 70){throw "Description length $($new.Length): $($file.Name)"}
            $page=$page.Replace('content="'+(E $old)+'"','content="'+(E $new)+'"').Replace('content="'+$old+'"','content="'+(E $new)+'"')
            $changes+=@{page=$file.Name;field='description';before=$old;after=$new}
        }
        # Keep WebPage/CollectionPage names and all schema descriptions consistent with metadata.
        $pattern='(?s)<script type="application/ld\+json">(.*?)</script>'
        $page=[regex]::Replace($page,$pattern,[Text.RegularExpressions.MatchEvaluator]{param($m)
            $schema=$m.Groups[1].Value | ConvertFrom-Json
            foreach($node in $schema.'@graph'){
                if($node.'@type' -in @('WebPage','CollectionPage') -and $node.name -eq $oldTitle){$node.name=$newTitle}
                if($descriptions.ContainsKey($file.Name) -and $node.description -eq $old){$node.description=$new}
            }
            '<script type="application/ld+json">'+($schema | ConvertTo-Json -Depth 40 -Compress)+'</script>'
        })
    }
    $page=$page.Replace('assets/site.js?v=restore-navigation-20261014','assets/site.js?v=audit-20261020')
    Save $file.Name $page
}
$js=Read 'assets/site.js'
$js=[regex]::Replace($js,'(?s)  function makeQuoteForm\(.*?  if \(contact\) makeQuoteForm\(contact, ''contact''\);\r?\n','')
$needle='      if (isPhone) { contactPhone=value; contactEmail='''' ; }'
$anchor="      if (isPhone) { contactPhone=value; contactEmail=''; } else { contactEmail=value; contactPhone=''; }"
$validation="      if (isPhone && !isValidQuotePhone(value)) { const error=composer.querySelector('.chat-form-error'); error.textContent='Please enter a valid phone number with at least 10 digits.'; error.hidden=false; input.setAttribute('aria-invalid','true'); input.focus(); return; }`n"
if(!$js.Contains('function isValidQuotePhone')){
    $js=$js.Replace('  function renderContact()',"  function isValidQuotePhone(value) {`n    const digits = value.replace(/\D/g, '');`n    return /^[+()\d\s.\-]+$/.test(value) && digits.length >= 10 && digits.length <= 15;`n  }`n`n  function renderContact()")
    if(!$js.Contains('function isValidQuotePhone')){throw 'Phone helper insertion failed'}
    if(!$js.Contains($anchor)){throw 'Phone validation anchor missing'}
    $js=$js.Replace($anchor,$validation+$anchor)
}
# Hide the permanent, no-script call fallback only after the quote interface initializes.
if(!$js.Contains("classList.add('quote-flow-ready')")){$js += "`n// A failed or blocked quote script leaves the static call instructions visible.`ndocument.documentElement.classList.add('quote-flow-ready');`n"}
Save 'assets/site.js' $js
# Reuse the existing layout for a branded host-served error page.
$template=Read 'contact.html'
$errorMain='<main id="main-content"><section class="section"><div class="section-heading"><h1>Page Not Found</h1><p>The address may have changed, or the page may no longer be available.</p></div><p><a class="button" href="index.html">Home</a> <a class="button" href="commercial.html">Cleaning Services</a> <a class="button" href="contact.html">Get a Quote</a></p><p>Call <a href="tel:+18187465432" data-native-call="true">818-746-5432</a> for help.</p></section></main>'
$errorPage=[regex]::Replace($template,'(?s)<main.*?</main>',$errorMain)
$errorPage=[regex]::Replace($errorPage,'<title>.*?</title>','<title>Page Not Found | Paradigm Janitorial</title>')
$errorPage=[regex]::Replace($errorPage,'<meta content="[^"]*" name="robots"/>','<meta content="noindex,follow" name="robots"/>')
$errorPage=$errorPage.Replace('https://paradigmjanitorial.net/contact.html','https://paradigmjanitorial.net/404.html')
$errorPage=[regex]::Replace($errorPage,'(?s)<script type="application/ld\+json">.*?</script>','')
$errorPage=[regex]::Replace($errorPage,'<meta content="[^"]*" (?:name|property)="(?:description|og:description|twitter:description)"/>','<meta name="description" content="Find Paradigm Janitorial cleaning services, return home, or contact us for a quote."/>',1)
$errorPage=$errorPage.Replace('aria-current="page" ','')
Save '404.html' $errorPage
# Resize the real logo onto white square icons, preserving its proportions.
Add-Type -AssemblyName System.Drawing
$logo=[Drawing.Image]::FromFile((Join-Path $root 'assets/images/paradigm-logo.png'))
foreach($size in @(32,180)){
    $bitmap=New-Object Drawing.Bitmap($size,$size);$g=[Drawing.Graphics]::FromImage($bitmap);$g.Clear([Drawing.Color]::White);$g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $height=[int]($size*$logo.Height/$logo.Width);$g.DrawImage($logo,0,[int](($size-$height)/2),$size,$height)
    $filename=if($size -eq 32){'assets/images/favicon-32.png'}else{'assets/images/apple-touch-icon.png'}
    $bitmap.Save((Join-Path $root $filename),[Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$bitmap.Dispose()
}
$logo.Dispose()
$png=[IO.File]::ReadAllBytes((Join-Path $root 'assets/images/favicon-32.png'));$stream=New-Object IO.MemoryStream;$writer=New-Object IO.BinaryWriter($stream)
$writer.Write([uint16]0);$writer.Write([uint16]1);$writer.Write([uint16]1);$writer.Write([byte]32);$writer.Write([byte]32);$writer.Write([byte]0);$writer.Write([byte]0);$writer.Write([uint16]1);$writer.Write([uint16]32);$writer.Write([uint32]$png.Length);$writer.Write([uint32]22);$writer.Write($png);[IO.File]::WriteAllBytes((Join-Path $root 'favicon.ico'),$stream.ToArray());$writer.Dispose();$stream.Dispose()
Save 'handoff/audit-2026-10-20/metadata-changes.json' ($changes | ConvertTo-Json -Depth 10)
Write-Output "Audit code changes applied; $($changes.Count) metadata updates."
