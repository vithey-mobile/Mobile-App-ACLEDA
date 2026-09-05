# Vithey App — Slide Presentation Prompt

Use this file when generating or updating `presentations/Vithey_App_Presentation.Rmd`.

**Goal:** ACLEDA Orientation-style slides — dark theme, gradient titles, **image + bullet points**, ACLEDA logo top-right on every slide.

---

## Files

| File | Purpose |
|------|---------|
| `presentations/Vithey_App_Presentation.Rmd` | Slide source (Xaringan / remark.js) |
| `presentations/custom.css` | All styles — **never** put `<style>` in `.Rmd` |
| `presentations/assets/` | Images (PNG/JPG) |
| `presentations/preview-slides.ps1` | Render + open browser |

**Preview:** `.\presentations\preview-slides.ps1` → press **F** (fullscreen) or **F11**

**Reference deck:** `presentations/Slide - Orientation Session Final.pptm`

---

## Project info

| Item | Value |
|------|-------|
| Project | **Vithey App** |
| Team | **Vithey** (7 members) |
| Competition | ACLEDA Bank AUB App Competition 2026 |
| Tagline | Organize · Share · Learn · Career |

**Content sources:** `prompt/_shared/SERVICE_REGISTRY.md`, `prompt/Prompt Frontend/00-project-summary.md`

---

## Design system (ACLEDA Orientation)

### Colors

| Role | Hex | Use |
|------|-----|-----|
| Dark background | `#01192D` | Slide base |
| Blue | `#0367FD` | Gradient start |
| Cyan | `#40FBC6` | Gradient end, accents |
| Gold | `#C5A021` | Highlights |
| White | `#FFFFFF` | Body text |

### Fonts

Montserrat / Nunito (loaded in `custom.css`)

### Auto branding (CSS — no HTML needed)

- **ACLEDA logo** top-right: `assets/image.png` (every slide via `::before`)
- **Geometric accent** bottom-right (every slide via `::after`)
- **Page number** bottom-right: add `<div class="slide-footer"><div class="page-num">N / TOTAL</div></div>`

### Slide types — when to use

| Class | Best for | Image? | Bullets? |
|-------|----------|--------|----------|
| `title-slide` | Opening, Thank you | Yes (background) | Title + meta lines |
| `section-slide` | TOC, Conclusion, chapter divider | No | Short subtitle text |
| `content-slide` | Tables, cards, bullet lists | Optional | Yes (markdown `-`) |
| `split-slide` | **Image + bullets** (recommended) | Yes (left 40%) | Yes (HTML `<ul>`) |
| `image-bg-slide` | Architecture, big diagram | Yes (faded bg) | Yes (markdown `.pull-left`) |

### Rules (important)

1. **Max 5–6 bullets** per slide — split into 2 slides if more
2. **Never put markdown inside `<div>`** — remark.js will show raw `#` and `**`
3. **Markdown bullets** → use on `content-slide` and `image-bg-slide` only (outside HTML)
4. **HTML bullets** → use inside `split-slide` `.split-content` only
5. **Every slide** ends with `---` separator and page footer
6. **Images:** 16:9, dark blue/cyan theme, no readable text in AI images
7. Update **TOTAL** in all `page-num` when adding/removing slides

---

## How to add a new slide (3 steps)

### Step 1 — Pick layout + image

| Need | Use class | Image file |
|------|-----------|------------|
| Title only | `section-slide` | — |
| Bullets only | `content-slide` | — |
| **Image + bullets** | `split-slide` | `assets/XX_name.png` |
| Big diagram + bullets | `image-bg-slide` | `assets/04_architecture.png` |
| Table | `content-slide` | — |
| Cards (team, journey) | `content-slide` | — |

### Step 2 — Copy template below into `.Rmd`

Paste before the last slide (or anywhere), separated by `---`.

### Step 3 — Register new split image (if new file)

Add to `presentations/custom.css`:

```css
.split-slide .split-image.img-YOUR-NAME {
  background-image: url('assets/YOUR-FILE.png');
}
```

Then use `<div class="split-image img-YOUR-NAME"></div>` in the slide.

---

## Copy-paste slide templates

### A) Title slide (opening)

```markdown
class: title-slide

<div class="slide-bg hero"></div>
<div class="slide-overlay"></div>
<div class="slide-inner">
<h1>SLIDE TITLE</h1>
<div class="subtitle">Subtitle here</div>
<div class="meta">ACLEDA Bank AUB App Competition 2026</div>
<div class="meta">Team <strong>Vithey</strong></div>
<div class="tagline">Organize · Share · Learn · Career</div>
</div>
<div class="hint">Press <strong>F</strong> for fullscreen</div>
<div class="slide-footer"><div class="page-num">1 / 20</div></div>
```

Background image: `assets/acleda_title_bg.jpg` (class `hero` in CSS)

---

### B) Section divider (TOC, Conclusion)

```markdown
---

class: section-slide

<div class="slide-inner">
<h1>SECTION TITLE</h1>
<div class="gold-line"></div>
<p>Short description or list of topics · separated · by · dots</p>
</div>

<div class="slide-footer"><div class="page-num">N / 20</div></div>
```

---

### C) Content slide — bullets only (markdown)

**Use when:** list points, no side image.

```markdown
---

class: content-slide

## Slide Title

- **Point 1** — short description
- **Point 2** — short description
- **Point 3** — short description
- **Point 4** — short description

<div class="slide-footer"><div class="page-num">N / 20</div></div>
```

---

### D) Content slide — two columns of bullets

```markdown
---

class: content-slide

## Slide Title

<div class="cols-2">
<div>
<ul>
<li><strong>Left 1</strong> — text</li>
<li><strong>Left 2</strong> — text</li>
</ul>
</div>
<div>
<ul>
<li><strong>Right 1</strong> — text</li>
<li><strong>Right 2</strong> — text</li>
</ul>
</div>
</div>

<div class="slide-footer"><div class="page-num">N / 20</div></div>
```

---

### E) Split slide — image left + bullets right (recommended)

**Use when:** you want a visual + list points (Problem, Features, Security, etc.)

```markdown
---

class: split-slide

<div class="slide-inner">
<div class="split-image img-YOUR-CLASS"></div>
<div class="split-content">
<h2>Slide Title</h2>
<ul>
<li><strong>Point 1</strong> — description</li>
<li><strong>Point 2</strong> — description</li>
<li><strong>Point 3</strong> — description</li>
<li><strong>Point 4</strong> — description</li>
</ul>
</div>
</div>

<div class="slide-footer"><div class="page-num">N / 20</div></div>
```

**Existing image classes in CSS:**

| CSS class | Image file |
|-----------|------------|
| `img-problem` | `assets/02_problem_solution.png` |
| `img-features` | `assets/03_app_features.png` |
| `img-security` | `assets/06_security.png` |

**Split with Problem + Solution (two bullet groups):**

```markdown
<div class="split-content">
<h2>Problem & Solution</h2>
<p><strong>Problem</strong></p>
<ul>
<li>Bullet 1</li>
<li>Bullet 2</li>
</ul>
<p><strong>Solution</strong></p>
<ul>
<li><strong>Vithey App</strong> — one super app</li>
<li>Social, career, finance, chat & AI</li>
</ul>
</div>
```

---

### F) Image background + bullets (architecture style)

```markdown
---

class: image-bg-slide

<div class="slide-bg"></div>
<div class="slide-overlay"></div>

## System Architecture

.pull-left[
- **Flutter** mobile client
- **API Gateway** — port 8080
- **10 microservices** — own PostgreSQL
]

.pull-right[
- **RabbitMQ** — async events
- **Eureka** — service discovery
- **MinIO** — file storage
]

<div class="slide-footer"><div class="page-num">N / 20</div></div>
```

Background: `assets/04_architecture.png` (set in CSS for `image-bg-slide`)

---

### G) Content slide — table

```markdown
---

class: content-slide

## Microservices (1/2)

| Service | Port | Responsibility |
|---------|------|----------------|
| API Gateway | 8080 | Routing, auth filter |
| Auth Service | 8081 | Login, JWT, OTP |
| Profile Service | 8082 | User profiles |

<div class="slide-footer"><div class="page-num">N / 20</div></div>
```

---

### H) Content slide — card grid (team / journeys / impact)

**Team:**

```markdown
class: content-slide

## Team Members

<div class="team-grid">
  <div class="team-card lead">Name<br/><span style="font-weight:400;font-size:14px;opacity:0.7;">Team Lead</span></div>
  <div class="team-card">Name</div>
</div>

<div class="slide-footer"><div class="page-num">N / 20</div></div>
```

**Journey cards (3 columns):**

```markdown
<div class="journey-row">
  <div class="journey-card">
    <h3>Persona Name</h3>
    <p>Step 1 → Step 2 → Step 3</p>
  </div>
</div>
```

**Impact grid (2 columns):**

```markdown
<div class="impact-grid">
  <div class="impact-item"><span class="impact-icon">🎓</span> Benefit text</div>
  <div class="impact-item"><span class="impact-icon">💼</span> Benefit text</div>
</div>
```

---

### I) Thank you slide

```markdown
---

class: title-slide, thank-slide

<div class="slide-bg"></div>
<div class="slide-overlay"></div>
<div class="slide-inner">
<h1>Thank You</h1>
<div class="contact">Team Vithey · Vithey App · ACLEDA AUB 2026</div>
<div class="tagline">Questions?</div>
</div>

<div class="slide-footer"><div class="page-num">20 / 20</div></div>
```

Background: `assets/07_thank_you.png`

---

## Image catalog + AI prompts

Save all images to `presentations/assets/`. Use **16:9**, ACLEDA colors (`#01192D`, `#0367FD`, `#40FBC6`), **no readable text**.

| File | Used on | AI prompt |
|------|---------|-----------|
| `image.png` | Logo (top-right, all slides) | ACLEDA Bank logo — use provided file |
| `acleda_title_bg.jpg` | Title slide bg | Fintech phone 3D render, dark blue, banking app UI (from orientation deck) |
| `02_problem_solution.png` | Split: Problem | Fragmented app icons left, one glowing super app right. Dark navy, blue/cyan accents, 16:9, no text |
| `03_app_features.png` | Split: Overview | Three phone screens: social feed, job apply, finance. Edtech/fintech UI, dark blue cyan, 16:9 |
| `04_architecture.png` | Image-bg: Architecture | Isometric microservices: mobile, gateway, services, PostgreSQL Redis RabbitMQ MinIO. Navy, blue cyan, 16:9 |
| `06_security.png` | Split: Security | Shield, lock, JWT, mobile + cloud. Dark blue cyan vector, 16:9, no text |
| `07_thank_you.png` | Thank you bg | Navy gradient, gold light rays, geometric shapes, 16:9, no text |
| `logo_app.png` | Vithey app icon | From `vithey_app/assets/images/brand/app_logo.png` |

### Optional app screenshots

| File | Slide topic |
|------|-------------|
| `screen_home.png` | Frontend / demo |
| `screen_profile.png` | User profile |
| `screen_finance.png` | Finance module |
| `screen_chatbot.png` | AI module |

### New image checklist

1. Generate or export image (16:9)
2. Save as `presentations/assets/XX_topic.png`
3. Add CSS class in `custom.css` (for split slides)
4. Use template **E** or **F** in `.Rmd`
5. Re-run `preview-slides.ps1`

---

## Full deck outline (21 slides)

| # | Title | Template | Image |
|---|-------|----------|-------|
| 1 | Vithey App (title) | A | `acleda_title_bg.jpg` + `logo_app.png` |
| 2 | Team Members | H (team-grid) | `logo_app.png` |
| 3 | Table of Contents | B + toc-grid | — |
| 4 | Problem & Solution | E (split, 2 groups) | `02_problem_solution.png` |
| 5 | Project Overview | E (split) | `03_app_features.png` |
| 6 | User Journeys | H (journey-row) | — |
| 7 | System Architecture | F (image-bg) | `04_architecture.png` |
| 8 | Microservices (1/2) | G (table) | — |
| 9 | Microservices (2/2) | G (table) | — |
| 10 | API Gateway | D (cols-2) | — |
| 11 | Frontend Architecture | E (split) | `03_app_features.png` |
| 12 | Backend Architecture | E (split) | `04_architecture.png` |
| 13 | Infrastructure & Data | G (table) | — |
| 14 | DevOps & Docker | E (split) | `04_architecture.png` |
| 15 | Event-Driven Integration | G + bullets | — |
| 16 | Security Design | E (split) | `06_security.png` |
| 17 | Development Plan | G (table) | — |
| 18 | Impact & Benefits | H (impact-grid) | — |
| 19 | ACLEDA Competition Requirements | G (table) | — |
| 20 | Conclusion | B | — |
| 21 | Thank You | I | `07_thank_you.png` |

---

## Bullet content reference (copy into slides)

### Tech stack

- **Frontend:** Flutter, GetX, Dio, Hive, Firebase FCM
- **Backend:** Java 21, Spring Boot 3.3.5, Spring Cloud
- **DevOps:** Docker per-service, `vithey-network`, `start-all.ps1`

### Microservices (8080–8089)

Gateway, Auth, Profile, File, Content, Career, Finance, Chat, Notification, AI

### Infrastructure ports

Eureka 8761 · Config 8888 · PostgreSQL 5432 · Redis 6379 · RabbitMQ 5672 · MinIO 9000

### Team

Moeng Kimheang (Lead), Khorn Molika, Heng Liza, Ponleong Bora, Nam Ayheng, Nao Soksovannarith, Phon Dyna

---

## R Markdown header (required)

```yaml
---
title: "Vithey App"
output:
  xaringan::moon_reader:
    lib_dir: libs
    css: ["default", "custom.css"]
    nature:
      ratio: '16:9'
      highlightStyle: github
      countIncrementalSlides: false
    seal: false
---

```{r setup, include=FALSE}
options(htmltools.dir.version = FALSE)
knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE)
```
```

---

## Common mistakes (avoid)

| Mistake | Result | Fix |
|---------|--------|-----|
| `<style>` block in `.Rmd` | Raw text on slide | Put CSS in `custom.css` only |
| `## Title` inside `<div>` | Shows `## Title` literally | Put markdown **outside** HTML blocks |
| Missing `---` between slides | Slides merge | Add `---` before each new slide |
| `class:` not first line | Class shows as text | `class: content-slide` must be line 1 after `---` |
| Live Server on old HTML | Stale/broken view | Run `preview-slides.ps1` instead |

---

## AI generation prompt (give this to AI)

When asking AI to create or update slides, include:

```
Read prompt/Slide_Prompt.md fully.

Update presentations/Vithey_App_Presentation.Rmd using ACLEDA Orientation style:
- Dark theme from custom.css (do not add inline <style>)
- ACLEDA logo is automatic (assets/image.png)
- Use split-slide (template E) when slide needs image + bullet points
- Use content-slide (template C) for bullets only
- Use HTML <ul><li> inside split-content; use markdown - only outside <div>
- Max 5-6 bullets per slide
- End every slide with slide-footer page-num
- Images in presentations/assets/, 16:9, #01192D #0367FD #40FBC6 theme

Slides to create/update: [LIST YOUR SLIDES HERE]

After editing, run: presentations/preview-slides.ps1
```

---

## Workflow

1. Plan slide in table above (title, template, image)
2. Generate/copy image → `presentations/assets/`
3. Add CSS class if new split image
4. Copy template from this file → paste into `.Rmd`
5. Fill title + bullets + page number
6. Update total in all footers if slide count changed
7. `cd presentations; .\preview-slides.ps1`
8. Press **F** for fullscreen
