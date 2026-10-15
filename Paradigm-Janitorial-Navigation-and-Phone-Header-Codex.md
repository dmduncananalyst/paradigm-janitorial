# Paradigm Janitorial — Responsive Navigation and Click-to-Call Header

## Objective
Fix the **existing Paradigm Janitorial website** so visitors on desktop computers, laptops, and tablets see the regular, horizontal navigation rather than an unnecessary hamburger menu. Add the business's **actual phone number prominently at the top**, with a working click-to-call link. Keep the existing image-based dropdown menus and all other website design and content intact.

The current problem is apparent on the local `power-washing.html` preview: at a reasonably wide VS Code browser viewport, the site already shows only a small logo and hamburger icon. That presentation is not acceptable for non-phone screens.

**This task is for the `paradigm-janitorial` project ONLY. Do not edit StartWeb7 or DommyDom.**

## 1. Examine the current implementation first

1. Identify the files controlling the shared header, navigation, dropdowns, responsive breakpoints, and mobile menu. Determine whether the header is reused or copied across HTML pages.
2. Identify all existing top-level navigation items, their exact order, and all dropdown links. **Do not invent, delete, rename, or reorder them.**
3. Inspect the existing dropdown menus with pictures, including their width, image size, layout, keyboard behavior, and pointer/touch behavior. **Preserve those dropdowns.**
4. Find the real Paradigm Janitorial business phone number in the current contact page, footer, or other approved business contact information. Use that verified number; **do not invent one**. If multiple different numbers appear and the primary number is genuinely unclear, report the ambiguity before choosing one.
5. Check why the hamburger breakpoint activates so early, and whether the menu can fit when the header is laid out sensibly. Do not guess or apply a generic breakpoint without testing.

## 2. Regular horizontal navigation on non-phone screens

- Keep the full **horizontal menu visible on desktops, laptops, and tablets**, including the screen size shown in the `power-washing.html` preview. **Do not use a hamburger on those layouts.**
- Keep the menu to **one horizontal row of navigation items**; do not split the items into two rows and do not compress their lettering until it becomes unreadable.
- If necessary to create room, place the **logo and phone number on a compact top header row** and the **horizontal navigation on a separate full-width row beneath**. This is acceptable: it is a two-part *header*, **not** two rows of menu buttons.
- Use the available width responsibly: balanced link widths, modest horizontal padding, consistent alignment, and the site's existing brand typography, colors, and sizing. The menu should look deliberately designed at both 960px and larger desktop sizes.
- Do not let items overlap, wrap within a button, get clipped, or extend beyond the viewport. Do not cause page-wide horizontal scrolling.
- Keep the existing image-based dropdowns anchored to the correct parent item and fully usable. **Dropdown content may be wider than the parent navigation item**, so photographs and labels remain comfortably readable. Keep dropdown panels within the visible screen.
- Only genuine **phone-width layouts** should use the current hamburger menu. Preserve all categories, images, and links within the phone menu. Do not change the existing mobile menu design unless a small accessibility or functionality correction is required.
- If fitting the full menu on a narrow tablet is genuinely impossible without unreadably small text, **report that constraint and show options rather than silently substituting a tablet hamburger or a double-row navigation**.

## 3. Clearly visible clickable phone number

- Put the verified **primary business phone number in the top header**, easy to notice without scrolling, on every page using this header.
- Use a real `tel:` anchor containing the correct dialable number (not just plain text). Example format only: `href="tel:+1XXXXXXXXXX"`; replace Xs with the actual verified number.
- Display the phone number in a clean, professional size and weight that suits Paradigm Janitorial's existing branding. It must remain distinct from navigation links and must not squeeze the menu.
- On phones, retain a visible tap-to-call phone number or clearly labeled accessible call control in the header alongside the mobile navigation, where space allows. Do not obscure the logo or hamburger control.
- Preserve any phone numbers already displayed in the footer or contact page. Do not change business information or invent a second number.

## 4. Preserve the site's appearance and functionality

**Do not redesign the website.** Keep the established Paradigm Janitorial colors, logo, photography, videos, hero sections, page wording, blogs, SEO metadata, forms, and service pages. Preserve the dropdown menu's image cards, labels, links, hover styles, and overall visual appearance. Do not replace picture dropdowns with plain-text lists.

Avoid sweeping rewrites of unrelated CSS or JavaScript. Make focused, consistent changes to the shared header/navigation implementation where possible; if page-specific copies exist, ensure the correction is applied consistently without changing unrelated page content.

**Do not add a hamburger to desktop or tablet views; do not create two stacked rows of menu buttons.**

## 5. Verify the actual rendered website

Use a local web server or an appropriate real browser preview. Test these viewport widths: **1920, 1440, 1366, 1280, 1024, 960, 820, 768, 600, and 390 pixels**, and also test a typical laptop at **125% browser zoom**.

Confirm visually:

1. Desktop and tablet layouts show the full horizontal navigation rather than the hamburger.
2. Navigation labels fit in a single row without cramming, overlap, or page-wide horizontal scrolling.
3. Each picture dropdown opens under its own item, remains on-screen, displays its images, and has working links.
4. Hover, click, keyboard navigation, and touch interaction work where applicable; dropdowns do not flicker or unexpectedly close.
5. The correct phone number is visible in the top header and the `tel:` link is properly formed.
6. The logo, header, and primary navigation remain aligned and attractive in resized windows.
7. The phone menu works on actual narrow phone widths.
8. No unstyled-text flash, layout jump, or new console error was introduced.
9. The same behavior works on the homepage and representative interior pages, including `power-washing.html`.

Report tests that could not be performed; never describe them as passed. If browser screenshots are available, show at least **960px, 768px, and 390px** previews for approval.

## 6. Final handoff

When done, report: the verified phone number and where it came from, the old and new menu breakpoint behavior, the specific files changed, any dropdown changes, the viewports actually checked, and any unresolved limitations.

**DO NOT commit, push, deploy, or publish to GitHub. Wait for my review and approval.**
