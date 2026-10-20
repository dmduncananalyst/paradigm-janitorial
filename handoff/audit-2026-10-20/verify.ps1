param([switch]$UseVerifiedPhoneResults)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$utf8=New-Object Text.UTF8Encoding($false)
function Read($p){[IO.File]::ReadAllText((Join-Path $root $p))}
function Assert($condition,$message){if(!$condition){throw $message}}
function Decode($s){[Net.WebUtility]::HtmlDecode($s)}
$protected=@('blog-auto-repair-waiting-room-tells-customers.html','blog-law-office-conference-room-looks-tired.html','blog-physical-therapy-equipment-patients-share.html')
$manifest=Get-Content -Raw -Encoding UTF8 (Join-Path $root 'handoff/blogs-2026-10-20/manifest.json') | ConvertFrom-Json
[xml]$map=Read 'sitemap.xml';$titles=@();$descriptions=@();$checked=0;$metadata=@()
foreach($entry in $map.urlset.url){
    $file=$entry.loc.Replace('https://paradigmjanitorial.net/','');if(!$file){$file='index.html'}
    $page=Read $file
    $title=Decode ([regex]::Match($page,'<title>(.*?)</title>').Groups[1].Value)
    $desc=Decode ([regex]::Match($page,'<meta content="([^"]+)" name="description"').Groups[1].Value)
    Assert ($title.Length -gt 0) "Missing title $file"
    Assert ($desc.Length -ge 70 -and $desc.Length -le 160) "Description length $($desc.Length): $file"
    if($file -notin $protected){Assert ($title.Length -le 60) "Title length $file"}
    Assert ($titles -notcontains $title) "Duplicate title $file"; $titles+=$title
    Assert ($descriptions -notcontains $desc) "Duplicate description $file"; $descriptions+=$desc
    Assert ($page.Contains('href="'+$entry.loc+'" rel="canonical"')) "Canonical mismatch $file"
    Assert ([regex]::Matches($page,'<h1(?:\s|>)').Count -eq 1) "H1 count $file"
    $entryNode=$map.CreateElement('lastmod',$map.DocumentElement.NamespaceURI)
    if(!$entry.lastmod){$entryNode.InnerText='2026-10-20';[void]$entry.AppendChild($entryNode)}else{$entry.lastmod='2026-10-20'}
    $checked++
    if($file -in $protected){continue}
    $old=(& 'C:\Program Files\Git\cmd\git.exe' -C $root show ('HEAD:'+$file) | Out-String)
    if($LASTEXITCODE -eq 0){$oldTitle=Decode ([regex]::Match($old,'<title>(.*?)</title>').Groups[1].Value);$oldDesc=Decode ([regex]::Match($old,'<meta content="([^"]+)" name="description"').Groups[1].Value);if($oldTitle -cne $title -or $oldDesc -cne $desc){$metadata+=@{page=$file;oldTitle=$oldTitle;title=$title;oldDescription=$oldDesc;description=$desc}}}
}
$map.Save((Join-Path $root 'sitemap.xml'))
$all=Get-ChildItem (Join-Path $root '*.html');$links=0
foreach($file in $all){
    $page=Read $file.Name
    Assert ($page.Contains('href="favicon.ico"')) "Favicon missing $($file.Name)"
    Assert ($page.Contains('href="assets/images/apple-touch-icon.png"')) "Touch icon missing $($file.Name)"
    Assert ($page.Contains('href="locations.html"')) "Locations unreachable $($file.Name)"
    if($file.Name -ne '404.html'){
        Assert ($page.Contains('class="quote-script-fallback"')) "Fallback missing $($file.Name)"
        Assert ([regex]::Matches($page,'class="quote-script-fallback"').Count -eq 1) 'Duplicate fallback'
    }
    foreach($match in [regex]::Matches($page,'(?:href|src)="([^"#]+)"')){
        $target=Decode $match.Groups[1].Value
        if($target -match '^(?:https?:|tel:|mailto:|data:|javascript:)'){continue}
        $target=($target -split '[?#]')[0]
        if(!$target){continue}
        Assert (Test-Path -LiteralPath (Join-Path $root $target)) "Broken local target $target in $($file.Name)";$links++
    }
    foreach($match in [regex]::Matches($page,'(?s)<script type="application/ld\+json">(.*?)</script>')){[void]($match.Groups[1].Value | ConvertFrom-Json)}
    Assert (![regex]::IsMatch($page,'href="[^" ]*audit-paradigm[^" ]*\.pdf')) 'Audit PDF linked on website'
}
$blog=Read 'blog.html';$cards=[regex]::Matches($blog,'(?s)<article class="blog-card">.*?</article>')
Assert ($cards.Count -eq 16) 'Archive count changed'
Assert ($blog.Contains('href="blog-office-checklist-workplace-essentials.html"')) 'Checklist article missing'
foreach($card in $cards){Assert ($card.Value.Contains('aspect-ratio:4/3 !important') -and $card.Value.Contains('object-fit:cover !important')) 'Card proportions differ'}
foreach($article in $manifest){$page=Read $article.slug;Assert ($page.Contains('<title>'+[Net.WebUtility]::HtmlEncode($article.title)+' | Paradigm Janitorial</title>')) 'Supplied title changed';Assert ($page.Contains('content="'+$article.description+'" name="description"')) 'Supplied description changed'}
$errorPage=Read '404.html';Assert ($errorPage.Contains('noindex,follow') -and $errorPage.Contains('<h1>Page Not Found</h1>') -and $errorPage.Contains('href="contact.html"')) '404 missing required content'
Assert ([regex]::Matches($errorPage,'name="description"').Count -eq 1) '404 description count'
$js=Read 'assets/site.js';Assert (!$js.Contains('makeQuoteForm') -and !$js.Contains('.hubspot-contact-form')) 'Unused form builder remains'
Assert ($js.Contains('if (isPhone && !isValidQuotePhone(value))')) 'Phone check not connected'
Assert ($js.Contains("if (!isPhone && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value))")) 'Email check changed'
$helper=[regex]::Match($js,'(?s)function isValidQuotePhone\(value\) \{.*?\n  \}').Value.Replace('const digits','var digits')
$tests=$helper+@'

var cases = [
 ['8187465432',true], ['(818) 746-5432',true], ['+1 818 746 5432',true],
 ['818.746.5432',true], ['+44 20 7946 0958',true], ['',false], ['a',false],
 ['123',false], ['818746543',false], ['1234567890123456',false],
 ['call 8187465432',false], ['8187465432<script>',false]
];
for(var i=0;i<cases.length;i++) {if(isValidQuotePhone(cases[i][0])!==cases[i][1]) {throw new Error('Phone validation failed: '+cases[i][0]);}}
WScript.Echo('PASS: '+cases.length+' phone validation cases, using the production helper.');
'@
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'phone-tests.js'),$tests,$utf8)
if($UseVerifiedPhoneResults){
    $verified=Get-Content -Raw (Join-Path $PSScriptRoot 'phone-test-result.json') | ConvertFrom-Json
    Assert ($verified.hash -eq (Get-FileHash (Join-Path $PSScriptRoot 'phone-tests.js')).Hash -and $verified.passed -eq 12) 'Phone test evidence does not match current tests'
}else{
    & cscript.exe //nologo (Join-Path $PSScriptRoot 'phone-tests.js')
    Assert ($LASTEXITCODE -eq 0) 'Phone tests failed'
}
Add-Type -AssemblyName System.Drawing
foreach($item in @(@('assets/images/favicon-32.png',32),@('assets/images/apple-touch-icon.png',180))){$img=[Drawing.Image]::FromFile((Join-Path $root $item[0]));Assert ($img.Width -eq $item[1] -and $img.Height -eq $item[1]) 'Icon size';$img.Dispose()}
$icon=[IO.File]::ReadAllBytes((Join-Path $root 'favicon.ico'));Assert ($icon[2] -eq 1 -and $icon[4] -eq 1) 'Invalid ICO header'
$report=@{indexedPages=$checked;htmlPages=$all.Count;localTargetsChecked=$links;archiveCards=$cards.Count;metadataChanges=$metadata.Count;checks='PASS: metadata, canonical URLs, headings, unique titles/descriptions, local links, JSON schema, icons, fallbacks, archive reachability, consistent preview images, protected supplied metadata, phone validation';pending=@('Visual browser testing: previous browser launch permission declined','HubSpot delivery and notifications: no external submission made','Hosted HTTP 404 status and published favicon URLs: local only, no deployment');protectedLongTitles=$protected}
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'results.json'),($report | ConvertTo-Json -Depth 10),$utf8)
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'metadata-changes.json'),($metadata | ConvertTo-Json -Depth 10),$utf8)
Write-Output ($report | ConvertTo-Json -Depth 10)
