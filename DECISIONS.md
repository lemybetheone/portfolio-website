# Decision log

What was chosen, what was rejected, why. Newest last.
Entries are short on purpose; if one needs more than a paragraph it is
probably two decisions.

---

## 1 — Plain HTML and CSS, no framework, no build step

**Chosen:** hand-written HTML and CSS, served as files.

**Rejected:** Next.js, Astro, Eleventy, any static site generator.

A generator earns itself by removing duplication. At one page there is no
duplication to remove, so it would add a dependency tree, a build step and
an upgrade obligation in exchange for nothing. The site must still work,
untouched, in six months.

Revisit if the site reaches roughly four pages sharing a header and footer.

---

## 2 — Vercel as the host

**Chosen:** Vercel, deploying from the GitHub repository on push.

**Rejected:** GitHub Pages, Cloudflare Pages, Netlify — all of which would
also work. This is a preference, not a technical win.

Vercel gives deploy-on-push, per-pull-request preview URLs and one-click
rollback, which matches the PR-based workflow already in use elsewhere.

**Explicitly not adopted:** Next.js. Vercel's documentation funnels toward
it. The framework selection on import is "Other". See decision 1.

---

## 3 — Deploy a stub before writing real content

**Chosen:** publish a headline-only page to the final host first.

The path from local file to public URL is where website projects stall.
Proving it while the stakes are zero means every later change is a push,
not an expedition.

---

## 4 — No numbers on the site that live in the repository

**Chosen:** the site describes the F1 project qualitatively and links out;
row counts, dbt node counts and decision-log lengths stay in the README
where they are generated.

Two conflicting node counts and two conflicting decision-log lengths were
already found across existing documents while drafting. Every number copied
onto the site is a number that can quietly go stale, and a portfolio that
contradicts itself is worse than one that says less.

The same rule drives "analytics since 2022" rather than "3 years of
experience".

**Clarified after the build.** The rule is *no number that drifts*, not *no
numbers*. Fixed points are fine and carry weight: `2022`, `2026`, the 437
against 399 reconciliation, DNF rates by decade. Two violations were caught
on the live site and fixed — "seventy-seven seasons" (78 next year) became
"every season since 1950", and "13% today" became "13% in the 2020s".

The test: read the sentence as though it is 2028. If it is wrong, rewrite it
now.

---

## 5 — One project on the site, not two

> **Superseded by 9.** The reasoning still holds for the dota2 pipeline,
> which remains off the site. It did not anticipate the work project.

**Chosen:** the F1 pipeline only.

**Rejected:** also featuring the dota2 pipeline.

Two projects of unequal depth invite comparison and average the impression
down. One project told well is the stronger claim.

---

## 6 — No contact form

**Chosen:** a mailto link and profile links.

A form needs somewhere to post to, which means a backend, which breaks the
"works with zero maintenance" constraint for the sake of saving a visitor
one click.

---

## 7 — The employer is not named on the site

**Chosen:** describe the work, not the company. "The company's first data
warehouse" rather than a name, and no internal project or system names.

**Rejected:** naming the employer; naming the internal project.

The CV and LinkedIn carry the name — one goes to named recruiters, the other
is an employment record by nature. A public page anyone can find is a
different audience, and he still works there. An unnamed employer costs a
reader nothing.

The same caution applies to LinkedIn, where the employer is named by
definition: keep the architecture description at the same level there.

---

## 8 — Availability lives in two places, worded differently

**Chosen:** a neutral badge on the site — "Open to data engineering roles" —
and LinkedIn's Open-to-work set to **recruiters only**.

**Rejected:** "Available for work" as a public badge. It is visible to
colleagues and reads as active job hunting, which undoes the point of the
recruiters-only setting.

**Also rejected:** a dated availability line ("from November 2026"). It is
the one claim guaranteed to go stale, and a date on a page cannot negotiate
the way a conversation can.

The badge must be removed when he stops looking. That is the cost of having
it at all, and it is accepted knowingly.

---

## 9 — Two projects: the F1 pipeline and the work warehouse

**Chosen:** feature both. F1 first.

They cover each other's gaps. The work warehouse is current and real, but it
is a team build where his personal scope is one data mart. F1 is the
unambiguous evidence he can do the whole thing alone — ingestion, modelling,
testing, orchestration, serving.

Neither alone answers "can this person build a pipeline end to end, and are
they doing it now". Together they do.

Supersedes 5.

---

## 10 — Claims are scoped to what is actually his

**Chosen:** state the scope of every claim explicitly — "a team portfolio of
10 to 20 dashboards", "helped design and build", "delivered one data mart end
to end on my own".

**Rejected:** "owns a production data warehouse end to end", which an early
draft carried. It was not true: the warehouse work began in 2026 and is a
team build.

Precision is the credential. A document that distinguishes team work from
solo work makes its solo claims believable, and every claim survives being
asked about in an interview.

---

## 11 — Design direction: monospace, dark by default, numbered sections

**Chosen:** a technical, dense, monospace-led layout, dark by default with a
manual light toggle. Derived from a reference site the author liked.

**Rejected:** the reference site's information architecture — blog,
certifications, recommendations, affiliations. Those sections work because
that author has the content to fill them. Empty sections read worse than
absent ones.

Also rejected: a monospace webfont. The system stack costs no network
request. Revisit only if the type genuinely needs to be distinctive.

---

## 12 — A theme toggle, and the JavaScript it costs

**Chosen:** a manual light/dark toggle, ~20 lines of JavaScript, state in
`localStorage`, applied before paint by an inline script in `<head>`.

`prefers-color-scheme` alone handles the common case, but a toggle is what
was asked for and it is the only script on the page. The pre-paint script
exists so a saved light theme does not flash dark on load.

Every `localStorage` access is wrapped in try/catch — it throws in private
browsing, and a theme toggle must not take the page down.

---

## 13 — Two CVs: one private, one public

**Chosen:** the full CV carries a phone number and goes to named recruiters.
A stripped copy without it lives at `assets/lemuel-calinog-cv.pdf` and is the
one the site links.

`.gitignore` excludes `*.pdf`, with a single negation for the public file.
This was found the hard way: the résumé link would have deployed as a 404,
because the file existed locally and was excluded from the repository.

**Check `git add -n`, not `git check-ignore`,** when a negation is involved.

---

## 14 — Open Graph URLs are absolute, and that has a cost

**Chosen:** `og:url` and `og:image` are absolute URLs, with explicit 1200×630
dimensions and alt text.

A relative `og:image` is not reliably resolved — LinkedIn in particular will
render a card with no image, or no card at all. The dimensions stop scrapers
guessing and falling back to a small thumbnail.

**The cost:** these two lines hardcode the domain. They must be updated when
the site moves to a custom domain. See the checklist below.

---

## 15 — Domain: a free rename now, a bought domain in October

**Chosen:** `lemybetheone.vercel.app` today. Buy a custom domain during the
October refresher, before the first application goes out.

Both older Vercel addresses still resolve — one redirects, one serves — so
nothing already shared is broken.

The argument for a custom domain is portability, not looks: a `*.vercel.app`
address is borrowed, and every CV already sent would carry a dead link if the
host ever changed. Buying it before applications start means every
application carries the same URL.

---

## 16 — The "how I work" section was removed

**Chosen:** four sections — projects, stack, experience, contact.

**Rejected:** a fifth section listing engineering practice (version control and
review, idempotent loads, tests that are business rules, decisions written
down).

The case for keeping it was that it was the only section answering "what will
this person be like on my team" rather than "what have they done". The case
against won: it was assertion rather than evidence, and self-description is
the weakest form of persuasion. Two of its five points also duplicated the F1
project section directly above it.

The practices themselves are unchanged and visible in the F1 repository,
which is where a reader can verify them rather than take his word for it.

---

## 17 — A second page for the projects

**Chosen:** a second page, `projects.html`, holding both builds in full. The
home page keeps a short summary of each.

**Rejected:** keeping everything on one page; a separate case-study page per
project.

Decision 1 says revisit a generator at roughly four pages sharing a header and
footer. Two pages do not meet that bar, so the header, footer and pre-paint
script are duplicated by hand and only the CSS and JS are shared (decision 18).
The home summary keeps the 437-against-399 result rather than deferring it: the
strongest sentence on the site should not sit behind a click.

---

## 18 — One stylesheet and one script, shared by both pages

**Chosen:** `assets/style.css` and `assets/site.js`, linked from both pages.

**Rejected:** copying the inline `<style>` and `<script>` blocks into the second
page.

Two copies of three hundred lines of CSS drift the moment one is edited. An
external file is not a build step, so decision 1 is untouched, and it costs one
extra request that is cached from the second page onward. The theme script in
`<head>` stays inline in both pages, because moving it out reintroduces the
flash of the wrong theme it exists to prevent.

A relative `url()` inside a stylesheet resolves against the stylesheet, not the
page. The portrait paths had to drop their `assets/` prefix in the move, and
they failed silently until the network panel was read.

---

## 19 — The schema diagram is of the F1 model, not of the site

**Chosen:** draw the real star schema, inside the F1 project.

**Rejected:** an entity diagram of the site itself — `engineer`, `project`,
`experience`, with foreign keys — as a new section on the home page.

The site-as-schema diagram was the more striking of the two, and it was
invented: no such database exists and nothing was modelled. "Every claim must
be true" makes that a harder failure than a plain page, and decision 16 had
already removed a section for being assertion rather than evidence. The F1
schema makes the same point about how he thinks, and a reader can check it
against the repository.

---

## 20 — The schema figure is cards in a grid, not a drawn diagram

**Chosen:** entity cards in a CSS grid. The snowflake is shown by nesting
`dim_circuit` under `dim_race`; the joins by naming the table each foreign key
points at.

**Rejected:** the positioned diagram with elbow connectors and crow's feet.

The design placed six cards at fixed pixel coordinates inside a 1312px frame.
The page is fluid to 58rem and has to survive a 375px phone, so those
coordinates had nowhere to go. Cards reflow, stay selectable and readable, and
have no geometry to break. The relationships move into the text, which is also
what a screen reader gets — the diagram is decorative to it either way.

---

## 21 — No visual tiering in the stack list

**Chosen:** every tool in the stack list reads the same.

**Rejected:** accent-coloured markers on the tools used most.

The first version marked Python, SQL, Dataform, dbt and Airflow in the accent
colour and left the rest muted, meaning "what I write" against "where it runs".
Nothing on the page said so, and the natural reading of two unexplained tiers in
a skills list is a self-rating — which is exactly what the private profile is
kept off the site to avoid.

---

## 22 — The Open Graph card has a generator

**Chosen:** `tools/make-og.ps1` rebuilds `assets/og.png`, and is committed
beside it.

**Rejected:** recording the recipe here in prose, and leaving the image as a
file nobody can rebuild.

The card's first version had no source. Retitling the site to Data
Engineering meant regenerating it, because its text is part of the image
rather than markup, and nothing recorded how it had been made. The design had
to be read back out of the pixels: the colours sampled, the rules and margins
located, and the type sizes derived from the measured width of each line.

All of that was recovering something that had simply never been written down.
A prose recipe would have helped, but it cannot be checked. The script can: it
reproduces the committed PNG byte for byte, so the image in the repository and
the script that makes it cannot drift apart without a `cmp` catching it.

**The cost:** a `tools/` directory and a Windows-only script in a repository
that is otherwise plain HTML and CSS. It is a tool rather than a build step,
so the site still compiles to nothing and deploys by pushing, and the script
runs by hand on the rare occasion the card's wording changes.

Font sizes are fitted to measured target widths rather than set directly. A
missing font is then substituted and scaled to fill the same space, so the
layout degrades instead of breaking on a machine without Georgia.

## 23 — The F1 header sits on a photo, and its text goes to full ink

**Chosen:** `assets/f1-banner.jpg` behind the F1 case-study header, under a
scrim of the page colour at 0.62. The deck and the `.meta` labels switch from
`--muted` to `--ink` there. `background-position` is `66% 50%` at every width.

**Rejected:** keeping `--muted` and strengthening the scrim until it passed,
and a separate mobile `background-position` behind a media query.

Contrast was measured, not judged by eye. Across 7,811 pixels sampled where
the text sits, the brightest is the white kerb (luminance 0.73). Against it at
0.62, `--muted` reaches only 2.09:1 dark and 2.06:1 light, far under the 4.5:1
AA floor. Saving `--muted` would need 0.82 dark and 0.90 light, which leaves
the photo a ghost. `--ink` gives 6.05:1 and 6.59:1. On a phone the text covers
different pixels, so the check was repeated against the brightest pixel in the
whole image, a highlight on the car (luminance 0.85). It still passes: 5.52:1
dark, 6.54:1 light. The bound holds wherever the crop lands.

The car's centre is 62% across the banner. A phone header is about 1:2, so
`cover` shows only the middle quarter of the image's width, and `50%` cut the
car in half. At desktop width the header matches the banner's own 2.13:1, and
the x value has no effect. So one value serves every width, and the media
query would have been code that does nothing.

**The cost:** the car sits partly behind the button on a phone. The whole car
is 39% of the banner's width against the quarter a phone shows, so no position
fits it all. `tools/make-banner.ps1` reproduces the committed JPEG byte for
byte, but its source photo is gitignored like the other source photography.
Only a machine that has `assets/source-f1.jpg` can rebuild it.

## 24 — The warehouse header gets a photo too, through a shared `.photo` class

**Chosen:** a warehouse aisle by Ruchindra Gunasekara (Unsplash License,
[GK8x_XCcDZg](https://unsplash.com/photos/large-warhause-GK8x_XCcDZg)) behind
the warehouse case study. The scrim and text rules from decision 23 move onto
`.casehead.photo`, and each project sets only its own image.

**Rejected:** photos of server racks and cabling, a vendor's illustrated blog
header, and copying the F1 rules under a second ID.

Server hardware says on-premises, and this warehouse is serverless BigQuery,
so the picture would describe the wrong system. The best-known of those
photos is also among the most reused tech images there are. The illustrated
header belonged to a training company, carried its watermark, and was very
likely licensed stock itself: there was no right to use it, and cropping the
watermark off would have made that worse. An aisle of racked shelving is a
real warehouse without claiming anything about the technology.

The aisle's vanishing point is centred, so the default `50% 50%` holds at
every width with no offset, unlike the F1 car. The source is portrait
(3024×4032), so the desktop band is cut around that point:
`make-banner.ps1 -Src assets/source-warehouse.jpg -Out
assets/warehouse-banner.jpg -CropTop 1390`.

The contrast check turned into a general result. At a 0.62 scrim, `--ink`
over pure white is 5.00:1 in the dark theme, and over pure black 6.54:1 in the
light theme. No pixel can be brighter or darker than those, so the rule
passes AA on any photo. A future photo header needs no pixel sampling, only a
look at the crop.

**The cost:** the banner is 302 KB against the F1 banner's 118 KB. The shelves
are dense detail and JPEG pays for it. Quality 55 only reached 230 KB, so it
stays at the script's default of 72, the same recipe as F1.

---

## October checklist — the custom domain switch

Five things change together. Missing any one leaves a broken or inconsistent
link somewhere:

1. `index.html` — `og:url` and `og:image` (decision 14)
2. `projects.html` — `og:url` and `og:image` (decision 14)
3. The CV — add the site URL if it is going on there
4. LinkedIn — Featured section and Contact info website entry
5. Vercel — keep the `.vercel.app` address redirecting, do not remove it

That is four absolute URLs across two files, not two across one, which is what
this list said until the second page was added. Rather than trust the count,
find them:

```
grep -rn 'lemybetheone\.vercel\.app' index.html projects.html
```
