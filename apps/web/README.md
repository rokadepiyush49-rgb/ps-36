# Jan Setu — Jharkhand's Societal Innovation OS

The unified web application for the platform — one site, one login, all six
web roles (student, industry, faculty, mentor, NGO, university). Role-specific
code belongs in `src/features/<role>/`; see [../../docs/structure.md](../../docs/structure.md).
The routes below are the existing student experience and are unchanged.

Built from the Stitch design export
(`stitch_jansetu_jharkhand_s_innovation_os`). Next.js 16 (App Router) +
React 19 + Tailwind CSS v4 + TypeScript.

## Run

```bash
npm run dev
```

Then open http://localhost:3000 — `/` redirects to `/dashboard`.

## Routes

| Route | Reference screen |
| --- | --- |
| `/dashboard` | `student_hub_dashboard_desktop` |
| `/problem-explorer` | `problem_explorer_personalized_recommendations` |
| `/impact-hub` | `impact_hub_desktop` |
| `/industry-hub` | new — extends the sidebar's Industry Hub entry |
| `/profile` | new — impact résumé view |
| `/council` | `ai_project_council_get_started` |
| `/council/new` | `ai_project_council_setup_selection` |
| `/council/session` | `ai_project_council_live_session` |
| `/council/verdict` | `ai_project_council_verdict_improvement` |
| `/collaborate/new` | `new_collaboration_setup_team_formation` (step 1) |
| `/collaborate/team` | `new_collaboration_team_formation` (step 2) |
| `/collaborate/review` | new — completes the 3-step wizard |

## Structure

```
src/
  app/
    layout.tsx              root layout, Inter font, metadata
    globals.css             design tokens (@theme) from DESIGN.md
    (app)/layout.tsx        sidebar + topbar shell
    (app)/…                 the six shell pages
    collaborate/            wizard flow with its own minimal chrome
  components/
    icon.tsx                inline SVG icon set (no icon-font dependency)
    ui.tsx                  Card, Button, Tag, Progress, Avatar, StatTile…
    shell.tsx               sidebar, topbar, mobile drawer
    stepper.tsx             3-step wizard indicator
  lib/data.ts               all page fixtures — replace with API calls
```

## Design system

Tokens live in `src/app/globals.css` under `@theme`, transcribed from the
export's `DESIGN.md`:

- **Deep Navy** `#002147` for institutional weight, near-black `#000a1e` for
  primary buttons
- **Impact Green** `#10b981` for success and progress
- **Community Orange** `#f97316` for social pulses and student-led accents
- White cards on an `#f8f9ff` ground, 1px `#e2e8f0` borders, 4px baseline
  spacing, 8px button radius / 16px card radius / 24px banner radius
- Inter throughout, with `headline-xl`/`headline-lg`/`headline-md`/`label-caps`/
  `mono-data` utilities matching the spec's type scale

## Data

Everything renders from `src/lib/data.ts` — no backend calls yet. Interactive
state (filters, agent selection, team invites, council interjections) is local
component state.
