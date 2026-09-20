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

---

## 5 — One project on the site, not two

**Chosen:** the F1 pipeline only.

**Rejected:** also featuring the dota2 pipeline.

Two projects of unequal depth invite comparison and average the impression
down. One project told well is the stronger claim.

Revisit only if a second project surpasses the first.

---

## 6 — No contact form

**Chosen:** a mailto link and profile links.

A form needs somewhere to post to, which means a backend, which breaks the
"works with zero maintenance" constraint for the sake of saving a visitor
one click.
