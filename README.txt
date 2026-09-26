PARADIGM JANITORIAL SERVICES, CORRECTED WEBSITE, REVISION 24

This revision includes the supplied v22 website, PDF audit, screenshot corrections
and the subsequent SEO/AEO request.
Open index.html to preview. For hosting, upload the contents of this folder,
including assets/, to the website's document root. No build step is required.

Included changes
- Original full, multi-scene Home video retained without re-encoding.
- Every hero fits below the header within one screen, keeping the complete
  image/video frame, title and quote button visible. Full-photo fitting uses
  side margins on wide screens as selected, rather than cropping the source.
- The Power Washing hero shows the sidewalk; its title and button sit at the top.
- Photo rows use matching dimensions and aligned card heights across the site.
- FAQ has a distinct new consultation photo, separate from the Duplex photo.
- Home headline, quote button and service links stay inside the hero.
- No menu arrows. Desktop dropdowns open on hover; keyboard navigation works.
  On mobile, open the main menu and tap a parent item to show its submenu.
  The second tap on that parent follows its overview link.
- Clean white/light neutral section separation and reduced empty card space.
- Distinct service photo pairs, clean window photos, and text-free replacement
  photos featuring Mexican cleaning professionals.
- Specific quote buttons, centered page-specific chats, and article answers.
- Complete page metadata, social previews, breadcrumbs, linked structured data,
  direct service summaries, internal links and XML image sitemap. See
  SEO-AEO-NOTES.txt and SEO-AEO-AUDIT.csv for details and publishing steps.
- Dedicated Locations footer column.

Forms
The contact page and the last step of every chat show Name, Phone, Email and
Message. Name is mapped to HubSpot First Name/Last Name. Chat answers and their
source page are included in Message, which the visitor can edit.

Both entry points submit to the existing published HubSpot chat form:
Portal: 247103073
Form: b90d8e3d-5896-4bc1-b73a-69cdb94e51ec
This form has the matching contact fields, including the contact Phone property.
The old separate contact form remains unchanged in HubSpot. If any automation
was attached only to that old form, attach it to the chat form as well.
The site uses HubSpot's public Forms submission API. No secret keys are embedded.
Internet access is required to send a request.

Verification
- 33 pages checked at six sizes: 1920x950, 1440x800, 1024x650, 390x844,
  320x568 and 844x390. All 22 heroes fit within the first screen.
- SEO metadata, schema relationships, visible answers, internal links and
  sitemap coverage checked on all 33 pages.
- All pages checked again at 320x568 after adding breadcrumbs and SEO summaries.
- No horizontal overflow, missing local assets or broken internal page links.
- 32 page-specific chat flows and the contact form checked.
- Four-field layouts, preserved chat answers, Back, modal close, validation,
  successful response handling and failed-request retry checked locally.
- HubSpot published field definitions were verified read-only.
- Submission requests were intercepted during testing. No test leads were sent.
  Verify actual HubSpot receipt with a real request after publishing.

The supplied source ZIP was preserved. This package has not been deployed.
