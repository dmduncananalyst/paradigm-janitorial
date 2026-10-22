$code=[IO.File]::ReadAllText((Join-Path $pwd 'handoff/blogs-2026-10-21/verify.ps1'))
Invoke-Expression ($code.Substring(0,$code.IndexOf('$results=@()')))
foreach($entry in $manifest){
 CDP 'Page.navigate' @{url=('file:///'+$root.Replace('\','/')+'/blog.html')}|Out-Null
 Start-Sleep -Milliseconds 300
 Eval ('document.querySelector('+(('a[href="'+$entry.file+'"]')|ConvertTo-Json -Compress)+').click()')|Out-Null
 Start-Sleep -Milliseconds 300
 $location=Eval 'decodeURIComponent(location.pathname).split("/").pop()'
 if($location -ne $entry.file){throw 'Card click failed'}
}
CDP 'Emulation.setDeviceMetricsOverride' @{width=390;height=900;deviceScaleFactor=1;mobile=$false}|Out-Null
Eval 'document.querySelector(".menu-button").click()'|Out-Null
if(!(Eval 'document.querySelector(".main-nav").classList.contains("open")')){throw 'Mobile menu failed'}
Eval 'document.querySelector(".menu-button").click()'|Out-Null
if(Eval 'document.querySelector(".main-nav").classList.contains("open")'){throw 'Mobile menu closing failed'}
$archive=[IO.File]::ReadAllText((Join-Path $root 'blog.html'));$schema=[regex]::Match($archive,'<script type="application/ld\+json">(.*?)</script>').Groups[1].Value|ConvertFrom-Json
$list=$schema.'@graph'|Where-Object {$_.'@type' -eq 'ItemList'}
if($list.numberOfItems -ne 20 -or $list.itemListElement.Count -ne 20){throw 'Archive schema count'}
$old=git show HEAD:blog.html|Out-String
$oldCards=[regex]::Matches($old,'(?s)<article class="blog-card">.*?</article>')
foreach($card in $oldCards){if(!$archive.Contains($card.Value)){throw 'Existing card changed'}}
$template=[IO.File]::ReadAllText((Join-Path $root 'blog-auto-repair-waiting-room-tells-customers.html'))
foreach($entry in $manifest){$article=[IO.File]::ReadAllText((Join-Path $root $entry.file));foreach($pattern in @('(?s)<header class="site-header">.*?</header>','(?s)<footer class="footer">.*?</footer>')){if([regex]::Match($article,$pattern).Value -cne [regex]::Match($template,$pattern).Value){throw 'Shared layout changed'}}}
$socket.Dispose()
'PASS: all three card clicks, mobile menu opening and closing, 20 archive schema entries, 17 unchanged existing cards, unchanged shared header and footer.'|Set-Content handoff/blogs-2026-10-21/interaction-results.txt
Get-Content handoff/blogs-2026-10-21/interaction-results.txt
