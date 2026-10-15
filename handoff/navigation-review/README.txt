Paradigm navigation review - local changes only

Phone: 818-746-5432, verified against contact.html Contact footer and existing footer links. Header uses tel:+18187465432.

Changes: assets/header-navigation.css (new shared header rules); assets/site.js (phone breakpoint and viewport-clamped picture dropdown placement); all 142 root HTML pages (shared stylesheet reference and static phone anchor). Existing main navigation markup is preserved.

Old breakpoint: hamburger through 1400px. New breakpoint: hamburger through 600px; horizontal single-row navigation above 600px. Logo and phone occupy the upper row; navigation occupies the lower row. Homepage retains its existing logo-free header.

Headless Chrome rendered checks: index.html, power-washing.html, contact.html at 1920, 1440, 1366, 1280, 1024, 960, 820, 768, 600, 390 CSS pixels (30 cases). Checked expected menu mode, single navigation row, adjacent label overlap, document horizontal overflow, dropdown visibility and bounds, loaded dropdown images, keyboard ArrowDown/Escape events, mobile click expansion, and correct phone link. All 30 cases returned no issues. See results.json and check.html.

Visual previews: 960.png, 768.png, 390.png. The narrow previews use a fixed-width iframe because headless Chrome clamps its outer window minimum width; gray space outside the iframe is review canvas only.

Limitations: real touch hardware, actual 125% browser zoom, OS dialer launch, console error regression, and startup flash/layout-shift recording were not verified. Browser checks used local file previews rather than HTTP. Only the listed viewport widths were checked.

No commit, push, deployment, or publication was performed.
