# Paradigm Janitorial — SEO and AEO master audit

Audit date: October 15, 2026 (America/Los_Angeles). Project: the open paradigm-janitorial repository. **Audit only. No corrections, commits, pushes, deployment or publication.**

Read in full: Universal-SEO-AEO-Website-Audit-Codex (3).md. This is the actual filename in the repository, with a space before (3), corresponding to the requested instructions. The small Contact dropdown in the supplied screenshot is included as D01. The later explicit audit-only instruction governs: menu resizing is a proposed correction, not work performed in this audit.

## Results and scope

The local site has **145 main website HTML pages**, comprising **70 preferred canonical indexable pages**, **10 duplicate aliases pointing to preferred canonicals**, and **65 explicitly noindex answer articles**. Another **18 HTML review harness/results files** exist under handoff/navigation-review. All **163 local HTML routes** were inspected at source level. Three separately observed URL variants (/ preferred home, www home, and the older www /about route) are recorded as separate inventory rows: **166 rows total**. These counts are repository/observed-route counts, not Google indexing counts.

The main confirmed issues are a collapsing Contact dropdown, two orphaned indexable pages, a homepage sitemap/canonical mismatch, a Clean Spaces list/schema discrepancy, and small copy defects. No confirmed sitewide crawl blocker or Critical issue was established locally. The 65 noindex directives need an intent decision; they are **not assumed to be mistakes**. Live deployment, Search Console, backlinks and field performance remain explicitly unverified.

Only these three deliverables are created in the repository:

- [SEO-AEO-Master-Audit.md](SEO-AEO-Master-Audit.md)
- [SEO-AEO-Page-Inventory.csv](SEO-AEO-Page-Inventory.csv)
- [SEO-AEO-Priority-Fix-List.csv](SEO-AEO-Priority-Fix-List.csv)

The checklist contains **28 tasks: seven confirmed findings, ten verification tasks, and eleven optional opportunities**. Every checklist status is Not Started. Priority indicates the order of attention, not proof of a ranking penalty. Page-level priority also includes unresolved external checks; a High noindex row does not mean a confirmed defect.

## Methodology and limitations

1. Established business/domain from CNAME, HTML canonicals/schema, published footer identity and git remote. CNAME contains paradigmjanitorial.net; the remote is https://github.com/dmduncananalyst/paradigm-janitorial.git. This is a static HTML/CSS/JavaScript site with flat root HTML routes, not an identified application router. CNAME and the git remote suggest a GitHub-hosted publishing workflow; current hosting, branch, DNS and publish artifact were not independently established. No deployment workflow/configuration was found in the inspected root configuration.
2. Recursively enumerated all local .html files with rg, including review artifacts. Parsed titles, descriptions, robots, canonical URLs, headings, all main text, anchor destinations/fragments, img attributes/files, JSON-LD and referenced scripts/styles. Compared preferred routes with sitemap.xml and constructed both an incoming-link graph and a homepage reachability graph. Review harness links were excluded from production discoverability counts.
3. Analyzed full main-text strings for exact duplicates, repeated paragraph blocks, topical headings/introduction, service/location references, citations and editorial/date patterns; reviewed introductions/headings and identified copy issues across the inventory. This is not an expert factual review of every sentence, independent proof of business claims or a replacement for legal/medical/industrial advice. Word counts are diagnostics, never automatic thin-content failures.
4. Loaded **all 145 main pages** in local Chrome at **1440x900 and 390x900**: **290 page/viewport checks**. No document horizontal overflow, captured window JavaScript errors or already-loaded broken img resources were observed; each main was visible. This does not certify every console/network event, all lazy-image loads, every focus/touch state or physical devices. All declared local img src paths exist. Local file checks do not expose origin status/headers or public performance.
5. Measured homepage dropdowns at **1440, 960, 820, 768, 601 and 390 pixels**. The three newly supplied blog articles/cards also have earlier local visual/source verification at desktop, tablet and mobile in the existing handoff; this audit did not modify that evidence or rely on it instead of checking all pages.
6. Attempted **all 55 distinct static outbound anchor URLs** (325 occurrences including footer credits) through the web tool: **48 returned content; seven require a direct-client retry**. Availability through a retrieval tool is not raw HTTP status proof, continuous availability, or a backlink measurement. Script-generated Google Voice, analytics and form endpoints are outside this static outbound citation count and were inspected as code rather than submitted to.
7. Attempted live homepage/robots/sitemap and representative local .html paths. Most direct fetches failed in the available environment; a www homepage response reported a redirect to the bare host and returned a snapshot different from local content. The extensionless www /about response was an older cached page. These are evidence of version/routing uncertainty, **not proof that the current origin serves the old version, is down, or returns 404**.
8. No authenticated GSC, GBP, backlink-provider export, CrUX dataset, PSI results or Lighthouse run was available. No indexing count, keyword ranking, review count, domain authority or CWV score is invented. Temporary helper scripts/results are outside the repository. Final integrity verification compared SHA-256 hashes for all 621 pre-existing files: every hash remained unchanged. The only new repository files are the three requested deliverables. Both CSVs round-trip through Import-Csv: 166 unique URL rows, 28 unique issue IDs, allowed priority/type values and all statuses Not Started.

## Complete inventory summary

| Main-file group | Count | Interpretation |
|---|---:|---|
| Homepage | 1 | index.html physically serves the preferred / route |
| About / contact / FAQ | 3 | Distinct user purposes; contact is interactive |
| Service files | 19 | Includes two canonicalized legacy aliases |
| County/location hubs | 3 | Los Angeles County, San Bernardino County, Cities We Clean |
| City service pages | 8 | Beverly Hills, Calabasas, La Cañada Flintridge, San Marino, Chino Hills, Rancho Cucamonga, Big Bear Lake, Lake Arrowhead |
| Blog index | 1 | 12 cards and 12 corresponding ItemList entries |
| Blog articles | 13 | Office Checklist is missing from index links |
| Clean Spaces answer files | 86 | 20 preferred articles, 65 noindex articles, one service-content alias |
| Clean Spaces/category files | 11 | Four preferred hubs/categories, seven alias copies |
| **Main pages** | **145** | 70 preferred + 10 duplicates + 65 noindex |
| Review HTML | 18 | Included in CSV, excluded from production browser tests |
| Observed root/host/legacy URL variants | 3 | Included with live unknowns, not invented source files |
| **Inventory rows** | **166** | One per local HTML route or separately observed variant |

All local sitemap destinations exist. The XML parses and has **70 URL entries**: 69 preferred local canonical URLs and the noncanonical index.html entry for the homepage. The 10 aliases and 65 noindex articles are excluded under their own URLs; this is coherent with their current treatment. The preferred homepage / is missing as a sitemap loc even though its physical file is listed. No requirement is made to index review files or aliases.

The homepage graph reaches **68 main routes**. Two preferred canonical pages are unreachable: Office Checklist and Cities We Clean. The remaining unreachable main routes are the 65 noindex articles and 10 aliases. An article can have links from other excluded pages and still be unreachable from homepage; this audit does not confuse those graph concepts.

## What is working in the local source

- All 145 main pages have one SEO title, one description, one canonical, a viewport declaration, language attribute and one H1. No skipped H1-H6 levels were detected in main content. The 70 preferred canonicals have distinct titles and descriptions; duplicate title/description/body groups correspond to aliases rather than 10 new canonical failures.
- No missing local img src target or missing alt attribute was found in main-page img tags. Empty alt on the aria-hidden decorative homepage video fallback is appropriate. All loaded resources sampled in browser were intact. Subject-specific image descriptions are present; alt quality was assessed in context rather than keyword-counted.
- All resolved local anchor file targets exist; no same-page fragment failure was found. Cross-page fragment behavior and public HTTP 404s still require live crawl verification. Static content and anchor links do not depend on client-side rendering; JS primarily enhances navigation, carousels, quote forms and video.
- robots.txt allows crawling and references the correct intended sitemap domain. There is no source-level global noindex directive. X-Robots-Tag, authentication/CDN blocks, soft 404s, redirect chains and server canonical headers cannot be inferred from files.
- All discovered main-page JSON-LD blocks parse. Referenced same-domain schema paths exist. Stable LocalBusiness definitions use consistent name, telephone, address and hours. No fabricated aggregateRating/review data was found in the inspected graphs.
- FAQ schema corresponds to eight visible FAQ answers. FAQ markup does not establish that a janitorial business qualifies for a Google FAQ rich result. No forced FAQ additions are proposed.
- Blogs retain publication/modified dates. For all 12 displayed cards, titles match article H1s and card datetime matches BlogPosting datePublished. The October 15 articles match their exact PNG filenames and date; their source copy/citations were preserved. Blog ItemList count/order match the displayed cards.
- Related service pairs already include intent distinctions and crosslinks; no actual keyword cannibalization was proven. Local city pages contain distinct locality paragraphs and public sources, with a shared service matrix. A city context citation is not a claim that the cited institution is a client or that Paradigm has an office there.

## Confirmed findings

Each issue below gives evidence, impact, a proposed future repair and verification. **None of these repairs has been implemented.**
### D01 — High — Contact dropdown collapses and does not match Clean Spaces

Affected: assets/site.js:570-588; assets/header-navigation.css; index.html (shared navigation on all 145 main pages)

Evidence: At 768px: Contact width 74.59px, images 36.59px; Clean Spaces 242px, images 204px. At 820px: Contact 82.13px versus Clean Spaces 242px. At 601px: Contact 38px with zero-width images. placeDropdowns caps width at twice the trigger-center distance from the nearest viewport edge.

Estimated impact: Restores quote/FAQ discovery and requested menu sizing; no ranking change is assumed.

Proposed repair: After approval, match the intended Contact panel/card sizing to Clean Spaces at each breakpoint and clamp panel position within the viewport; preserve photos, typography and content. Check other affected dropdowns.

Verification: Open menus at 1440,960,820,768,601,390px; compare widths, images, keyboard/touch, bounds and scrolling.

### D02 — Medium — Office Checklist is absent from the blog listing and internal link graph

Affected: blog-office-checklist-workplace-essentials.html; blog.html

Evidence: 13 BlogPosting files exist; blog.html has 12 cards. Office Checklist has zero incoming main-site HTML links, is unreachable from homepage, and is indexable/in sitemap.

Estimated impact: Makes existing article discoverable.

Proposed repair: After approval, restore its card in the existing design, preserving copy, date, image and metadata; synchronize blog ItemList order.

Verification: Crawl from homepage; compare listing cards with schema and article inventory.

### D03 — Medium — Cities We Clean hub has no incoming main-site HTML link

Affected: locations.html

Evidence: Zero incoming links from other main pages; unreachable from homepage. Sitemap and llms.txt mention it but do not supply normal browsing navigation.

Estimated impact: Improves hub discovery.

Proposed repair: After approval, add a relevant link from an existing county/location context while retaining current links and design.

Verification: Crawl homepage and confirm a meaningful incoming HTML link.

### D04 — Medium — Sitemap submits index.html instead of declared homepage canonical /

Affected: sitemap.xml; index.html

Evidence: Sitemap loc is https://paradigmjanitorial.net/index.html; homepage canonical and WebPage identity prefer https://paradigmjanitorial.net/. Other 69 loc values match preferred local canonicals.

Estimated impact: Aligns canonical signals.

Proposed repair: After approval, submit the preferred root URL; keep physical index.html. Verify live redirects before any hosting change.

Verification: Compare sitemap loc to page canonical; inspect / and /index.html via live HTTP and URL Inspection.

### D06 — Medium — Clean Spaces ItemList does not match the current on-page list

Affected: clean-spaces.html

Evidence: ItemList #articles lists 16 individual articles; main content links only two individual articles and three categories. Fifteen schema article items are not represented by on-page article links. JSON itself parses.

Estimated impact: Aligns structured collection information with visible content.

Proposed repair: After approval, align ItemList with the actual displayed collection, or expose the intended list using the existing layout.

Verification: Compare each schema ListItem to the rendered main collection and its links.

### D05 — Low — Category descriptions duplicate the word Cleaning

Affected: business-commercial-questions.html; window-cleaning-questions.html; restaurant-cleaning-questions.html; residential-apartment-questions.html; power-washing-questions.html; porter-service-questions.html; office-cleaning-questions.html; floor-care-questions.html; estates-apartment-questions.html; construction-renovation-questions.html

Evidence: 10 files start their description with Cleaning cleaning topics and detailed articles: three preferred category pages and seven alias copies.

Estimated impact: Improves snippet clarity without artificial length targets.

Proposed repair: After approval, remove the accidental repeated word and align applicable social/schema descriptions without changing meaning.

Verification: Inspect descriptions and corresponding social/schema copies on all affected files.

### D07 — Low — Excluded answer articles contain awkward guides wording

Affected: clean-spaces-floor-care-how-long-for-floors-to-dry-after-cleaning.html; clean-spaces-office-cleaning-are-commercial-cleaning-companies-licensed.html; clean-spaces-office-cleaning-can-a-cleaning-company-provide-references.html

Evidence: Examples include different guides in floor drying/licensing copy and may not answer the guides of a manager in references copy. All three have noindex,follow.

Estimated impact: Improves clarity if retained/reintroduced.

Proposed repair: After approval and indexing-intent decision, correct these specific sentences in context; avoid global replacement.

Verification: Review exact sentences and confirm unrelated copy and indexability are preserved.

### D01 measured panel comparison

| Viewport | Contact width | Clean Spaces width | Contact image widths |
|---:|---:|---:|---|
| 1440px | 462px | 682px | 204, 204px |
| 960px | 238.38px | 462px | 200.38, 200.38px |
| 820px | 82.12px | 242px | 44.12, 44.12px |
| 768px | 74.59px | 242px | 36.59, 36.59px |
| 601px | 38px | 105.48px | 0, 0px |
| 390px | 338px | 338px | 143, 143px |

The source formula centers a panel under its trigger while shrinking available width near the viewport edge. Contact is the rightmost trigger. At 601px its calculated inner image space reaches zero; at 390px the mobile layout uses a separate full-width treatment and both panels measure 338px. This explains the screenshot without assuming that changing photographs or typography is required.

## External checks required before a complete live audit

The following are verification tasks, not diagnosed public failures. Read-only exports or access are sufficient for most of them; setup changes are not authorized.

### V01 — High — Live deployment and HTTP/canonical routing are not fully verified

Affected: CNAME; https://paradigmjanitorial.net/; https://www.paradigmjanitorial.net/; https://www.paradigmjanitorial.net/about; all canonical routes in inventory

Evidence/limitation: Local CNAME/canonicals identify the bare domain. Web fetch through www reported a redirect and a different homepage H1/navigation. Cached /about has older content. Direct .html/robots/sitemap retrieval was unavailable and shell could not connect. Fetch failure does not prove a 404 or downtime.

Estimated impact: Establishes actual public crawl/index blockers and whether local findings apply live.

Next verification: Run a read-only live crawl from an unrestricted client and establish which version is deployed. Record status, chain, final canonical, meta robots and X-Robots-Tag for every preferred URL. No deployment without approval.

Completion check: Inspect all preferred URLs, http/https, www/bare, index.html, legacy /about, slash variants and a nonexistent URL; compare local metadata.

### V02 — High — 65 answer articles are explicitly noindex; exclusion intent is unconfirmed

Affected: clean-spaces-floor-care-how-long-for-floors-to-dry-after-cleaning.html; clean-spaces-floor-care-do-you-do-floor-care-after-hours.html; clean-spaces-floor-care-are-your-floor-technicians-certified.html; clean-spaces-porter-service-difference-between-porter-service-and-janitorial-service.html; clean-spaces-restaurant-cleaning-does-professional-cleaning-help-pass-health-inspections.html; clean-spaces-porter-service-can-porter-schedules-fit-busiest-hours.html; clean-spaces-office-cleaning-will-the-same-cleaning-team-come-each-visit.html; clean-spaces-office-cleaning-who-do-i-contact-after-hours-for-urgent-cleaning.html; clean-spaces-office-cleaning-what-training-does-cleaning-staff-receive.html; clean-spaces-office-cleaning-what-is-the-difference-between-office-cleaning-and-janitorial-services.html; clean-spaces-office-cleaning-should-office-cleaning-happen-during-or-after-hours.html; clean-spaces-office-cleaning-how-often-should-an-office-be-professionally-cleaned.html; clean-spaces-office-cleaning-how-do-you-handle-keys-fobs-and-alarm-codes.html; clean-spaces-office-cleaning-how-do-cleaning-companies-inspect-work-quality.html; clean-spaces-office-cleaning-do-you-use-green-cleaning-products.html; clean-spaces-office-cleaning-do-you-use-employees-or-subcontractors.html; clean-spaces-office-cleaning-do-cleaning-companies-do-background-checks.html; clean-spaces-office-cleaning-do-cleaning-companies-bring-their-own-supplies.html; clean-spaces-restaurant-cleaning-do-you-move-equipment-during-deep-cleaning.html; clean-spaces-restaurant-cleaning-do-you-clean-exhaust-hoods-and-grease-behind-appliances.html; clean-spaces-restaurant-cleaning-difference-between-deep-cleaning-and-regular-restaurant-cleaning.html; clean-spaces-restaurant-cleaning-can-restaurant-cleaning-be-scheduled-around-operating-hours.html; clean-spaces-restaurant-cleaning-can-cleaning-help-prepare-for-health-inspection.html; clean-spaces-residential-apartment-which-apartment-spaces-do-you-clean.html; clean-spaces-residential-apartment-what-is-included-vs-billed-separately.html; clean-spaces-residential-apartment-what-is-included-in-apartment-common-area-cleaning.html; clean-spaces-residential-apartment-how-often-should-apartment-common-areas-be-cleaned.html; clean-spaces-residential-apartment-do-you-handle-emergency-cleanups.html; clean-spaces-residential-apartment-do-you-do-turnover-cleaning-between-tenants.html; clean-spaces-residential-apartment-do-you-do-post-renovation-cleaning-for-apartments.html; clean-spaces-residential-apartment-do-you-clean-vacant-apartment-properties.html; clean-spaces-power-washing-what-surfaces-can-be-power-washed.html; clean-spaces-power-washing-what-is-soft-washing-and-when-is-it-used.html; clean-spaces-power-washing-what-is-included-in-commercial-power-washing.html; clean-spaces-power-washing-is-power-washing-environmentally-safe.html; clean-spaces-power-washing-how-often-should-a-commercial-building-be-power-washed.html; clean-spaces-power-washing-how-long-does-power-washing-take.html; clean-spaces-power-washing-does-power-washing-prevent-mold-and-mildew.html; clean-spaces-power-washing-can-power-washing-damage-building-surfaces.html; clean-spaces-power-washing-best-time-of-year-for-power-washing.html; clean-spaces-porter-service-which-properties-need-a-day-porter.html; clean-spaces-porter-service-what-should-be-in-porter-scope-of-work.html; clean-spaces-porter-service-what-does-a-day-porter-do.html; clean-spaces-porter-service-how-many-hours-of-porter-coverage.html; clean-spaces-porter-service-full-time-or-part-time-porter-service.html; clean-spaces-porter-service-does-porter-service-include-restroom-restocking.html; clean-spaces-porter-service-do-you-offer-evening-porter-service.html; clean-spaces-floor-care-will-floor-care-disrupt-business-operations.html; clean-spaces-floor-care-what-types-of-flooring-do-you-maintain.html; clean-spaces-floor-care-how-often-should-tile-be-stripped-waxed-and-polished.html; clean-spaces-floor-care-how-often-should-commercial-carpets-be-deep-cleaned.html; clean-spaces-office-cleaning-are-commercial-cleaning-companies-licensed.html; clean-spaces-office-cleaning-can-a-cleaning-company-provide-references.html; clean-spaces-window-cleaning-what-methods-for-commercial-window-cleaning.html; clean-spaces-window-cleaning-how-often-should-commercial-windows-be-cleaned.html; clean-spaces-window-cleaning-do-you-clean-interior-and-exterior-windows.html; clean-spaces-window-cleaning-do-storefronts-need-more-frequent-window-cleaning.html; clean-spaces-window-cleaning-do-i-need-to-be-present-during-window-cleaning.html; clean-spaces-window-cleaning-can-you-remove-hard-water-stains.html; clean-spaces-window-cleaning-can-window-cleaning-scratch-glass.html; clean-spaces-window-cleaning-bad-weather-policy-for-window-cleaning.html; clean-spaces-window-cleaning-are-frames-screens-tracks-and-sills-included.html; clean-spaces-restaurant-cleaning-which-kitchen-areas-get-deep-cleaned.html; clean-spaces-restaurant-cleaning-how-often-should-a-restaurant-kitchen-be-deep-cleaned.html; clean-spaces-restaurant-cleaning-how-long-does-restaurant-deep-cleaning-take.html

Evidence/limitation: All 65 have noindex,follow, self canonicals and no sitemap entry. This is a real exclusion directive, but it is not proven accidental. Some supporting paragraphs repeat across the group.

Estimated impact: Avoids suppressing wanted content or indexing unwanted legacy duplicates.

Next verification: Confirm a per-URL plan to retain exclusion, consolidate or maintain distinct indexable content. Keep noindex pending approval; do not bulk remove it.

Completion check: Approved indexing matrix, deployed directives and GSC URL Inspection for retained targets.

### V03 — Medium — Seven outbound resources could not be retrieved independently

Affected: https://publichealth.lacounty.gov/eh/inspection/grading-posting-requirements-retail-food-facilities.htm; https://publichealth.lacounty.gov/eh/inspection/restaurant-retail-food-inspection.htm; https://publichealth.lacounty.gov/eh/inspection/retail-food-inspection-guide.htm; https://publichealth.lacounty.gov/eh/i-want-to/view-inspection-results.htm; https://selfhelp.courts.ca.gov/guide-security-deposits-california; https://www.cityofcalabasas.com/our-city/about-us/history/historic-landmarks; https://www.ready.gov/business

Evidence/limitation: 55 distinct outbound anchor URLs were attempted: 48 returned content; seven were unavailable to the web tool. Raw origin status was not exposed, so none is a confirmed broken link.

Estimated impact: Protects reference access without discarding valid sources.

Next verification: Check seven URLs manually and through a direct status/redirect crawler; replace only confirmed broken or irrelevant citations after approval.

Completion check: Record status, final destination and relevance; retry bot-blocked sites manually.

### V04 — Medium — Eight Article image URLs differ from displayed article images

Affected: clean-spaces-estate-delicate-finishes.html; clean-spaces-construction-dust-building-ready.html; clean-spaces-painted-apartment-cleaning-before-move-in.html; clean-spaces-office-front-warehouse-back.html; clean-spaces-new-office-affordable-cleaning.html; clean-spaces-medical-dental-daytime-cleaning.html; clean-spaces-seasonal-estate-cleaning.html; clean-spaces-retail-storefront-daytime-cleaning.html

Evidence/limitation: Schema assets exist but do not occur as page img src. Estate example: estate-finishes-v32.webp in schema versus updated-recovered-10.webp displayed. Medical example: industry-medical-dental-article.webp versus industry-medical-dental-question.webp.

Estimated impact: Prevents misleading article-image associations; alternate renditions may be valid.

Next verification: Check whether these are equivalent renditions. Align stale/different structured/social images with the approved feature image only after approval; preserve photography.

Completion check: Visually compare assets and primary/OG/Twitter image values.

### V05 — Medium — Local identity and operational claims need owner-backed verification

Affected: faq.html; about.html; contact.html; all 8 cleaning-services-*.html pages; 62 LocalBusiness definitions

Evidence/limitation: 62 LocalBusiness nodes consistently give Paradigm Janitorial, 818-746-5432, 7108 De Soto Avenue Ste.201A Canoga Park CA 91303, daily 08:00-20:00. FAQ states insured/bonded and window work up to four stories. Consistency does not verify real-world accuracy or storefront eligibility.

Estimated impact: Supports verifiable local identity and accurate service expectations.

Next verification: Compare with owner-confirmed NAP/hours/coverage, current insurance/bonding and registration evidence; review authenticated GBP settings.

Completion check: Owner records and GBP dashboard/export; Google Maps only if review counts are necessary. No invented reviews or locations.

### V06 — Medium — Actual backlinks, referring domains, anchor patterns and broken incoming links are unknown

Affected: https://paradigmjanitorial.net/ (off-page)

Evidence/limitation: No GSC Links export, backlink-provider data or server logs were available. The 325 outbound anchor occurrences across 55 URLs are not backlinks; StartWeb7 footer credit is outgoing.

Estimated impact: Creates evidence-based off-page plan and protects useful legacy incoming links.

Next verification: Obtain GSC Links and an available named backlink dataset; map referring domains, destinations, lost links and legacy incoming URLs. Research legitimate local/industry mentions.

Completion check: Name dataset/date; deduplicate real referring domains and check incoming destinations. No spam purchases or bulk directories.

### V07 — Medium — Actual Google indexing and organic performance are unknown

Affected: Google Search Console domain property

Evidence/limitation: No authenticated GSC data. Sitemap presence and limited search observations do not establish indexed/excluded counts, queries, clicks, impressions, CTR, positions or manual-action status.

Estimated impact: Separates real search problems from source possibilities.

Next verification: Review Pages/Indexing, sitemap processing, URL Inspection, manual actions/security and query/page performance for the correct property.

Completion check: Dated GSC exports, correct property/window and URL-level reasons; publish actual data only.

### V08 — Medium — Live Core Web Vitals and network performance have not been measured

Affected: index.html; blog.html; all canonical production pages

Evidence/limitation: 290 local Chrome viewport cases ran. File URLs cannot establish public compression, caching, CDN effects, LCP/INP/CLS field distributions or Lighthouse/PageSpeed scores.

Estimated impact: Quantifies impact before changing stable visual behavior.

Next verification: After confirming live version, run Lighthouse/PageSpeed mobile/desktop for templates and heavy pages, inspect waterfalls and CrUX/GSC CWV groups.

Completion check: Record real URL/date/tool settings/lab values and field availability; no invented scores.

### V09 — Medium — 18 review HTML files might be included in a root-upload deployment

Affected: handoff/navigation-review/video-results.html; handoff/navigation-review/video-check.html; handoff/navigation-review/stability-results.html; handoff/navigation-review/stability-check.html; handoff/navigation-review/single-logo-results.html; handoff/navigation-review/single-logo-check.html; handoff/navigation-review/preview.html; handoff/navigation-review/mobile-menu-call-results.html; handoff/navigation-review/mobile-menu-call-check.html; handoff/navigation-review/logo-results.html; handoff/navigation-review/logo-load-results.html; handoff/navigation-review/logo-load-check.html; handoff/navigation-review/check.html; handoff/navigation-review/call-options-results.html; handoff/navigation-review/call-options-check.html; handoff/navigation-review/browser-results.html; handoff/navigation-review/alignment-results.html; handoff/navigation-review/alignment-check.html

Evidence/limitation: handoff/navigation-review HTML files have no local noindex/canonical. robots.txt allows all paths; upload notes describe uploading folder contents. Actual publish inclusion is unknown.

Estimated impact: Avoids publicly crawlable test content.

Next verification: Confirm publish artifact and live access. After approval, exclude review artifacts or apply suitable access/index controls; retain audit evidence.

Completion check: Inspect artifact/live URLs; verify private/unavailable or correctly excluded. Robots disallow alone is not deindexing.

### V10 — Medium — Quote delivery and conversion tracking require a controlled end-to-end check

Affected: contact.html; assets/site.js:204-250; assets/site.js:490

Evidence/limitation: site.js enhances the quote flow and posts to HubSpot integration; GA4 loader exists. No quote or fabricated customer record was submitted during audit.

Estimated impact: Confirms real conversion delivery.

Next verification: Only after approval for a labeled test lead, verify validation, failure states, HubSpot receipt and analytics events; assess JS-disabled fallback.

Completion check: Approved test plus owner dashboard evidence; distinguish HTTP success from CRM receipt.

## Optional improvements

These opportunities are supported by source observations but are not proven ranking penalties, mandatory rich-result requirements or measured CWV failures. Each requires approval before changes.

### O01 — Medium — Reduce eager image payload while retaining complete photos

Affected: blog.html; index.html; shared navigation on all 145 main HTML pages; assets/images/blog-previews/paradigm_*_2026_10_15.png

Evidence: Homepage: 20 unique eager img sources totaling 16,168,152 local bytes. Blog: 25 totaling 21,392,837 bytes. Three new PNGs alone: 6,439,955 bytes. These are source sizes, not measured transfer or first-load totals.

Potential impact: Potentially lowers bandwidth and competition with main content.

Proposed work: After approval/measurement, use responsive modern-format alternatives and defer closed-menu/below-fold images; retain originals, exact photo associations and full proportions/frame geometry.

Verification: Compare waterfalls/LCP and startup stability; verify full photos and all cards/menus at multiple widths.

### O02 — Medium — Consolidate repeated embedded CSS without losing first-paint stability

Affected: all 145 main HTML pages; assets/header-navigation.css

Evidence: Inline style source characters range 128,584-293,684 per main page, sum 29,321,775. Home/blog each embed 7,023 header CSS characters identical to separately loaded header-navigation.css. Characters are not compressed transfer bytes.

Potential impact: May reduce repeated HTML parse/download work.

Proposed work: After approval, profile duplicate/unused rules, preserve critical geometry and cache shareable CSS in a versioned asset; preserve precedence.

Verification: Measure compressed/cache reuse; compare menu/hero startup and all template layouts.

### O03 — Medium — Evaluate lighter existing homepage video

Affected: index.html; assets/videos/home-hero-stable.mp4; assets/videos/home-hero-optimized.mp4

Evidence: Active stable video: 6,853,954 bytes, autoplay and preload=auto. Unused optimized video: 477,321 bytes. Content/quality equivalence was not established.

Potential impact: Potentially reduces mobile transfer.

Proposed work: After approval, compare duration, full composition, quality, first frame and playback before selecting any lighter rendition; preserve approved poster/animation behavior.

Verification: Side-by-side review and waterfalls; no crop, flash or autoplay regression.

### O04 — Medium — Monitor related service intent; cannibalization is unproven

Affected: retail-cleaning.html; retail-storefront-cleaning.html; construction-cleaning.html; post-construction-renovation-cleaning.html

Evidence: Pairs have separate self canonicals; current copy distinguishes retail scope from storefront operations and construction stages from final cleanup. Main text is not an exact duplicate.

Potential impact: Concentrates useful coverage without premature removal.

Proposed work: Use GSC query/landing evidence to assess differentiation. Adjust or consolidate only after demonstrated competing intent and approval.

Verification: Compare real query/page behavior and intent; protect important incoming links.

### O05 — Low — Some main service/about/FAQ content has no contextual anchor links

Affected: window-cleaning.html; power-washing.html; learning-facility-cleaning.html; floor-care.html; faq.html; apartment-buildings.html; about.html

Evidence: Affected canonical pages have zero static main-content anchors to other local pages. Shared navigation/footer and quote buttons remain available; this is not a broken CTA claim.

Potential impact: Improves topic relationships and browsing.

Proposed work: After approval, link useful existing phrases to related service, county or guidance pages without repetitive anchors or design changes.

Verification: Verify relevance, destinations and original CTA behavior.

### O06 — Low — No article-to-article contextual links in blog bodies

Affected: blog-worship-weekend-cleaning-2026.html; blog-what-is-porter-service.html; blog-warehouse-break-room-cleaning-2026.html; blog-retail-holiday-cleaning-2026.html; blog-restaurant-grease-dining-room.html; blog-restaurant-cleaning-after-closing.html; blog-power-washing-dirty-storefront.html; blog-office-flu-season-2026.html; blog-office-entryways-rainy-season-2026.html; blog-office-checklist-workplace-essentials.html; blog-apartment-trash-areas-resident-satisfaction.html; blog-apartment-move-out-cleaning-2026.html; blog-apartment-garage-stairwell-cleaning-2026.html

Evidence: All 13 BlogPosting pages have zero main-content blog-*.html links; most have service/contact links and all retain shared Blog navigation.

Potential impact: Connects related property-care topics.

Proposed work: After approval, add genuinely useful contextual related-article links using existing text or an approved existing pattern; preserve every word/date unless separately authorized.

Verification: Check relevance and resolution of each contextual article link.

### O07 — Low — Strengthen verifiable experience and editorial accountability

Affected: about.html; all 13 blog articles; all 8 city pages

Evidence: About explains values/process; schema uses an Organization author. Named reviewer credentials and documented local job case studies are not established by reviewed content. Local city citations are context, not evidence of Paradigm client work.

Potential impact: Adds context for evaluating business expertise.

Proposed work: After approval, use owner-supplied verifiable team/reviewer information and permission-cleared cases. Never present generated illustrative photos as documented client evidence or invent credentials/ratings.

Verification: Owner evidence/permissions; visible attribution consistent with schema.

### O08 — Low — Legacy duplicates already canonicalize; redirects are optional pending link research

Affected: window-cleaning-questions.html; single-family-homes.html; restaurant-cleaning-questions.html; residential-apartment-questions.html; power-washing-questions.html; porter-service-questions.html; office-cleaning-questions.html; floor-care-questions.html; duplexes.html; clean-spaces-house-renovation-what-to-expect.html

Evidence: 10 index,follow aliases form five duplicate body/title groups and point to existing preferred URLs. They are excluded from sitemap under their own URLs; these are not ten missing independent canonical pages.

Potential impact: May simplify crawling and URL maintenance.

Proposed work: Keep existing canonicals pending live/backlink checks. Consider permanent redirects only after an approved legacy URL plan; no mass deletion.

Verification: Check each status/redirect/canonical and useful incoming links.

### O09 — Low — One footer logo lacks intrinsic width/height attributes

Affected: contact.html (footer logo)

Evidence: Contact footer img assets/images/paradigm-logo.png has alt but no width/height. Other main-page img tags have both; existing CSS may reserve space and CLS impact is unknown.

Potential impact: Could reduce load-time movement.

Proposed work: After approval and measurement, reserve accurate geometry if needed without changing display size.

Verification: Slow-image and layout-shift recording before/after.

### O10 — Low — Some indexable answer Articles lack publication dates

Affected: clean-spaces-estate-staff-cleaning-schedules.html; clean-spaces-estate-delicate-finishes.html; clean-spaces-estate-cleaning-zones.html; clean-spaces-construction-dust-building-ready.html; clean-spaces-cleaning-throughout-the-day.html; clean-spaces-business-open-late-opens-early.html; clean-spaces-apartment-common-area-responsibility.html; clean-spaces-painted-apartment-cleaning-before-move-in.html; clean-spaces-office-kitchen-accountability.html; clean-spaces-office-front-warehouse-back.html; clean-spaces-new-office-affordable-cleaning.html; clean-spaces-medical-dental-daytime-cleaning.html; clean-spaces-kitchen-staff-or-cleaning-service.html; clean-spaces-tenants-different-cleanliness.html; clean-spaces-seasonal-estate-cleaning.html; clean-spaces-retail-storefront-daytime-cleaning.html

Evidence: 16 preferred indexable Clean Spaces Article nodes omit datePublished and retain dateModified=2026-10-12. Not invalid JSON; original publication dates were not established.

Potential impact: Improves freshness context when evidence exists.

Proposed work: After approval, use authentic historical dates if available; otherwise retain unknown publication timing. Do not infer publication from sitemap lastmod.

Verification: Editorial history and visible/schema date consistency.

### O11 — Low — Optional llms.txt does not list later blog additions

Affected: llms.txt

Evidence: Lists three October 12 posts, with no October 14/15 posts; normal blog navigation/sitemap contain later articles. Google AI features do not require llms.txt.

Potential impact: Keeps optional reference directory current without promising AI citations.

Proposed work: If this selected directory is maintained, update its approved canonical links after approval; prioritize crawlable content/internal links first.

Verification: Compare selected links with editorial inventory and verify canonical destinations.

## Technical access, URL consistency and performance interpretation

The local framework is plain HTML with shared assets and extensive inline styling. Main text is present in the HTML. There is no discovered client-side route generator, paginated search-result route, portfolio section or project index to add to the inventory. Carousel arrows move through existing HTML cards; their 1 of N labels do not create N separate indexable page URLs. Review harnesses sometimes embed pages in iframes; they are not business landing pages.

All preferred local canonical tags use HTTPS and the bare host. Some same-site navigation links use index.html rather than /, which can be functional while still requiring canonical/redirect verification (D04/V01). A physical CNAME file does not prove SSL validity, HTTPS enforcement, www consolidation, trailing-slash handling, cache policy, X-Robots-Tag, or production error handling. No claim is made that all live .html routes work based on their local files.

System Arial/Helvetica fonts avoid a required external web-font download. Async GA4 is present; actual analytics/conversion delivery is V10. Shared navigation images use eager loading even while their panels are closed. Source-size totals show a clear delivery opportunity, but HTML references do not prove every image is transferred on an initial request. Homepage image sources total 51,172,106 unique local bytes across img tags, while the eager subset is 16,168,152; blog img sources total 21,903,657, with eager subset 21,392,837. Lazy loading and caching must be evaluated through an actual waterfall.

The homepage video is 6.85 MB and preloads automatically. CSS includes explicit hero geometry and initial image handling, so a performance change must retain first-paint stability. No fabricated Lighthouse score, network timing, field CLS, LCP or INP is reported. All document-width checks passed at the two full-site viewport sizes, while the independently measured Contact-panel bug remains real: document overflow alone would not reveal a panel being shrunk to fit.

## On-page content and AEO assessment

Who/what/where is clear in the preferred home, service, city and county content: Paradigm provides defined cleaning services across Los Angeles County and San Bernardino County, with scope/access/scheduling emphasized. Answer articles generally begin with a direct natural explanation and use supporting headings. They distinguish cleaning from repairs, security, medical prevention, hazardous work and food-operator responsibilities instead of promising universal results. The newer survey and historical resident-complaint discussions identify their limits.

The main content weaknesses are discoverability (D02/D03), correspondence of collection schema (D06), limited experience evidence (O07), and selected linking opportunities (O05/O06). Broad service overlap is O04, pending query evidence rather than a generic cannibalization accusation. A short contact or category page is evaluated by task usefulness, form behavior and linked content, not arbitrary word-count thresholds.

The 65 excluded question articles have distinct introductions and topic headings but repeated supporting material. A complete paragraph beginning For a property in Los Angeles County or San Bernardino County appears in all 65; the closing resources context paragraph also repeats across all 65. This supports a selective editorial/indexing review, not automatic deletion or mass indexing. Some narrow provider questions are answered with general advice to confirm the provider's actual practice; owner-confirmed policies would be needed before presenting those answers as definitive Paradigm commitments.

For AI answer systems, crawlable textual explanations, coherent local identity, relevant citations and connected pages are useful foundations. No observed schema guarantees inclusion in Google AI Overviews, ChatGPT Search or Perplexity. No external AI citation presence was measured. Google's [AI features guidance](https://developers.google.com/search/docs/appearance/ai-features) says ordinary SEO practices remain relevant and indexed/snippet-eligible content is required for Google supporting links; it does not require special AI files or invented FAQ content. This guidance is about Google; it is not evidence of inclusion rules or actual citation outcomes in other systems.

The optional llms.txt directory is partly outdated (O11), but that is lower priority than real crawlability, content correspondence and useful internal links. No forced question titles, new FAQ boxes or unsupported schema are recommended.

## Schema inventory and validation limits

The following counts are top-level JSON-LD nodes across main files, not counts of rich results or independently verified entities. Alias copies and excluded pages remain in the node counts. Nested Person/Organization/Question objects are not counted as separate top-level nodes.

| Top-level schema type | Nodes |
|---|---:|
| Article | 85 |
| LocalBusiness | 62 |
| WebPage | 47 |
| BreadcrumbList | 46 |
| WebSite | 43 |
| ImageObject | 38 |
| Service | 31 |
| BlogPosting | 13 |
| CollectionPage | 13 |
| ItemList | 2 |
| AboutPage | 1 |
| ContactPage | 1 |
| FAQPage | 1 |

Parsing and local URL checks passed; this is not the same as validating every vocabulary constraint in Schema.org Validator or every Google feature requirement. Visible FAQ answers match the schema; no fabricated ratings were found. LocalBusiness identity is consistent across 62 nodes. Some older BlogPosting nodes contain Organization author but no publisher/breadcrumb; those optional additions are not called invalid schema. A real Person author is appropriate only if the person and contribution are established. Current Organization authorship should not be replaced with an invented expert.

D06 flags a concrete list/content discrepancy. V04 records eight image-source differences without assuming different filenames necessarily mean different subjects. O10 identifies 16 preferred answer Article nodes with unknown publication dates; their modified dates do not authorize backdating. Service nodes describe existing visible services and use the same business identity. After approved repairs, use [Google's structured-data policies](https://developers.google.com/search/docs/appearance/structured-data/sd-policies) and relevant feature tests, preserving correspondence with visible content and avoiding claims of automatic rich-result eligibility.

## Every blog article

All 13 article sources were included in metadata/link/text/schema checks and full-site desktop/mobile rendering. All have Organization author information in BlogPosting schema, local indexable directives and sitemap entries. Twelve have listing cards; those titles/dates match their articles. No blog has a contextual blog-to-blog body link (O06). Shared navigation still links back to Blog.

| Article source | Card present | Published / modified in schema | Finding or interpretation |
|---|---|---|---|
| blog-apartment-garage-stairwell-cleaning-2026.html | Yes | 2026-10-15 / 2026-10-15 | Exact October 15 source copy/PNG; date consistent; full photo |
| blog-apartment-move-out-cleaning-2026.html | Yes | 2026-10-12 / 2026-10-12 | Separates ordinary wear from cleaning; current legal applicability still needs authoritative review |
| blog-apartment-trash-areas-resident-satisfaction.html | Yes | 2026-10-14 / 2026-10-14 | No structural/date mismatch found; keep scope/limitations and sources |
| blog-office-checklist-workplace-essentials.html | No — D02 | 2026-10-06 / 2026-10-06 | Orphan despite sitemap; emergency/first-aid references present |
| blog-office-entryways-rainy-season-2026.html | Yes | 2026-10-12 / 2026-10-12 | No structural/date mismatch found; keep scope/limitations and sources |
| blog-office-flu-season-2026.html | Yes | 2026-10-14 / 2026-10-14 | CDC sources; separates respiratory prevention from surface care |
| blog-power-washing-dirty-storefront.html | Yes | 2026-10-11 / 2026-10-11 | No structural/date mismatch found; keep scope/limitations and sources |
| blog-restaurant-cleaning-after-closing.html | Yes | 2026-10-11 / 2026-10-11 | No structural/date mismatch found; keep scope/limitations and sources |
| blog-restaurant-grease-dining-room.html | Yes | 2026-10-14 / 2026-10-14 | No structural/date mismatch found; keep scope/limitations and sources |
| blog-retail-holiday-cleaning-2026.html | Yes | 2026-10-12 / 2026-10-12 | Seasonal context; NRF source retrieved; related store-service scope |
| blog-warehouse-break-room-cleaning-2026.html | Yes | 2026-10-15 / 2026-10-15 | Exact October 15 source copy/PNG; date consistent; full photo |
| blog-what-is-porter-service.html | Yes | 2026-10-09 / 2026-10-11 | No structural/date mismatch found; keep scope/limitations and sources |
| blog-worship-weekend-cleaning-2026.html | Yes | 2026-10-15 / 2026-10-15 | Exact October 15 source copy/PNG; date consistent; full photo |

The warehouse article's reported sample (1,000 full-time workers) and 29%, 19%, 69% figures correspond to the retrieved [October 6 CMM report](https://cmmonline.com/news/workers-most-often-identify-restrooms-as-the-dirtiest-area); the article correctly contextualizes a commissioned general-workplace survey rather than local warehouse outcomes. The apartment garage article identifies its source as an April 18, 2018 sponsored industry article, consistent with [the retrieved resource](https://www.multihousingnews.com/sponsored-post-the-top-resident-complaints-and-how-to-respond-to-them/), and does not present it as a current local survey. These selected checks do not certify every statement on every page.

The October 15 image filenames and complete compositions were preserved. Generated illustrative photographs must not be used as proof of actual clients or completed jobs. No new categories, cards, source copy, dates, photographs or layouts were added in this audit.

## Local SEO, trust and off-page readiness

The footer, phone and structured business definitions are internally consistent. City pages target eight distinct places in the two stated counties; they are not eight separate business locations. No separate city office, GBP profile, review count or service proof is invented. Only the owner can establish the actual office/public-service model, GBP address eligibility, coverage and availability; those checks are V05.

Source citations to cities, agencies, industry resources and manufacturers help contextualize claims but are outgoing references, not verified endorsements or incoming backlinks. No referring-domain count, link authority score or competitor rank can be derived from the repository. V06 specifies the needed datasets. Once evidence exists, investigate legitimate local chamber/industry memberships, supplier relationships, property-management partnerships and permission-cleared editorial case studies where they actually apply; first validate existing mentions and destination URLs. Do not buy spam links, mass-submit low-quality directories, invent partnerships or send outreach as part of this audit.

A complete off-page analysis needs real referring domains, target URLs/anchors, link dates/losses and old-route response checks. It should include the observed extensionless /about legacy route, while recognizing its retrieved snapshot may be cached. GBP status/reviews require the authenticated owner view or, when necessary for actual review-count research, Google Maps. No review count was necessary or collected here.

## Outbound link verification ledger

Each distinct static outbound URL was attempted on the audit date. Retrieved means content was returned through the web tool; unknown means the tool could not retrieve it. These labels do not represent origin HTTP status codes. Outgoing resources are not counted as backlinks. Source-page associations are retained in the page inventory where retry is required.

| URL | Retrieval result |
|---|---|
| https://carpet-rug.org/carpet-for-business/cleaning-and-maintenance/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://carpet-rug.org/carpet-for-homes/cleaning-and-maintenance/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://carpet-rug.org/carpet-for-homes/installation-tips/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://carpet-rug.org/resources/cleaning-standards/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://cmmonline.com/news/workers-most-often-identify-restrooms-as-the-dirtiest-area | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://cms9files.revize.com/cityofsanmarino/planning/Historic%20Survey/San%20Marino%20Historic%20Context%20Statement%20Draft%204.1.19.pdf | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://codelibrary.amlegal.com/codes/los_angeles/latest/lamc/0-0-0-162721 | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://lcf.ca.gov/downtown-village-specific-plan/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://mapeihome.com/blog/2026/09/17/what-is-grout-haze-and-how-do-you-remove-it/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://nrf.com/research-insights/holiday-data-and-trends/winter-holidays | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://publichealth.lacounty.gov/eh/inspection/grading-posting-requirements-retail-food-facilities.htm | requires_verification: web tool could not retrieve; no HTTP failure proven |
| https://publichealth.lacounty.gov/eh/inspection/restaurant-retail-food-inspection.htm | requires_verification: web tool could not retrieve; no HTTP failure proven |
| https://publichealth.lacounty.gov/eh/inspection/retail-food-inspection-guide.htm | requires_verification: web tool could not retrieve; no HTTP failure proven |
| https://publichealth.lacounty.gov/eh/i-want-to/view-inspection-results.htm | requires_verification: web tool could not retrieve; no HTTP failure proven |
| https://selfhelp.courts.ca.gov/guide-security-deposits-california | requires_verification: web tool could not retrieve; no HTTP failure proven |
| https://startweb7.com/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://woodfloors.org/maintenance/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.beverlyhills.org/819/Commercial-Business-Regulations | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.bigbear.com/things-to-do/the-village/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.cdc.gov/flu/prevention/actions-prevent-flu.html | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.cdc.gov/flu/spread/index.html | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.cdc.gov/hygiene/about/when-and-how-to-clean-and-disinfect-a-facility.html | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.chinohills.org/798/Shopping-Center-Office-Directory | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.cityofcalabasas.com/our-city/about-us/history/historic-landmarks | requires_verification: web tool could not retrieve; no HTTP failure proven |
| https://www.cityofrc.us/news/create-destinations | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.dir.ca.gov/dlse/Janitorial_Providers_Contractors.html | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.dir.ca.gov/dlse/Janitorial_Registration_FAQs.html | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.dir.ca.gov/Title8/3282.html | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.dir.ca.gov/title8/3287.html | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.dre.ca.gov/publications/ResourceGuidebook/gb10_movingout.html | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.epa.gov/iaq-schools/controlling-pollutants-and-sources-indoor-air-quality-design-tools-schools | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.epa.gov/indoor-air-quality-iaq/best-practices-indoor-air-quality-when-remodeling-your-home | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.epa.gov/mold/brief-guide-mold-moisture-and-your-home | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.epa.gov/mold/how-do-i-get-rid-mold | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.epa.gov/safepestcontrol/pest-control-resources-housing-managers | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.epa.gov/safepestcontrol/resources-residents-multi-family-housing | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.epa.gov/saferchoice/frequently-asked-questions-safer-choice | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.epa.gov/saferchoice/products | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.hse.gov.uk/pubns/cais6.pdf | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.jameshardie.com/blog/siding-durability/tips-for-cleaning-your-siding/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.jameshardie.com/faq/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.lakearrowheadchamber.com/population/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.multihousingnews.com/sponsored-post-the-top-resident-complaints-and-how-to-respond-to-them/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.mytee.com/why-are-spots-and-stains-reappearing-after-ive-cleaned-them/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.naturalstoneinstitute.org/consumers/care/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.nps.gov/orgs/1739/upload/preservation-brief-18-interiors.pdf | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.osha.gov/emergency-preparedness/getting-started | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.osha.gov/etools/young-workers-restaurant-safety/clean-up | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.1200 | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.151 | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.22 | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.22/ | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.38 | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.osha.gov/sites/default/files/publications/OSHA3512.pdf | retrievable via web tool; origin HTTP status/redirect chain not exposed |
| https://www.ready.gov/business | requires_verification: web tool could not retrieve; no HTTP failure proven |

The seven unknowns are four Los Angeles County Public Health paths, the California Courts security-deposit guide, the Calabasas historic-landmarks path, and Ready.gov Business. Do not replace them just because a retrieval tool failed. All 55 URLs remain unchanged. Other resource fetches, including the DRE moving-out chapter, returned relevant content even when the page title was generic.

## External source basis and verification access

- [Google: canonicalization signals](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls) supports aligning sitemap/canonical preferences. Canonical selection by Google still needs GSC evidence.
- [Google: build and submit a sitemap](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap) supports submitting desired canonical URLs; a sitemap is not proof of indexing.
- [Google: AI features and your website](https://developers.google.com/search/docs/appearance/ai-features) supports ordinary crawl/content foundations and explicitly does not guarantee indexing or appearance.
- [Google: general structured-data policies](https://developers.google.com/search/docs/appearance/structured-data/sd-policies) supports correspondence with visible content; syntax alone does not prove rich-result eligibility.
- Web-tool observations: [www home](https://www.paradigmjanitorial.net/), [legacy www About](https://www.paradigmjanitorial.net/about). Their returned snapshots are not an authoritative current live crawl. Direct robots/sitemap/local .html fetches were unavailable.

Needed for completion of the external checks: read-only live HTTP crawling from an unrestricted environment; GSC exports/access for the correct property and period; owner GBP/NAP/credential evidence; a named backlink dataset or GSC Links export; actual PSI/Lighthouse and field-data observations; deployment artifact/hosting configuration. A controlled quote submission requires separate approval because it creates an external lead record. No connection setup, outreach or external write was performed.

## Proposed order of operations — approval required before corrections

1. **Establish crawl/index access first (V01/V07/V09):** confirm current deployment, status/redirect behavior, robots/sitemap access, X-Robots-Tag and public artifact scope. If a real live blocker is found, prioritize that measured blocker before content refinements. No Critical blocker is asserted from unavailable fetches.
2. **Decide URL/indexing intent (V02/O08):** approve per-URL treatment for all 65 noindex articles and the 10 canonicalized aliases; inspect legacy backlinks before redirect/deletion decisions. Preserve exclusions until approved.
3. **Address the confirmed menu defect (D01):** match Contact to Clean Spaces with positional clamping rather than edge-based size collapse; preserve all design/content. Validate six measured viewport sizes, keyboard and touch.
4. **Repair preferred-page discovery and canonical/list correspondence (D02/D03/D04/D06):** restore Office Checklist discovery, link Cities We Clean, align homepage sitemap canonical and current collection schema. Keep all existing article text, dates and assets.
5. **Complete source/entity/image checks (V03/V04/V05):** retry seven resources, compare eight structured/displayed images, verify real business claims/GBP. Apply small copy fixes D05/D07 only after approval and the legacy indexing decision.
6. **Measure before optimizing delivery (V08/O01/O02/O03/O09):** collect real network/CWV evidence, then test optimized delivery against startup layout, whole-photo and video requirements.
7. **Confirm conversion delivery (V10):** perform only an approved labeled test lead and analytics validation.
8. **Pursue evidence-backed editorial/internal-link/off-page work (O04/O05/O06/O07/O10/O11/V06):** retain differentiated services, improve useful contextual links, add real expertise evidence where supplied, maintain honest dates and build legitimate external relationships without invented results.

All 28 checklist rows remain **Not Started**. The previously implemented local blog changes were retained exactly as they stood before this audit. Existing SEO audit files were not overwritten. **Awaiting approval before any website corrections, commit, push or publication.**
