# Project structure

This document records the monorepo layout and the reasoning behind it, so new
code lands in the right place.

## apps/web — the unified website

The single website used by all six web roles: student, industry, faculty,
mentor, NGO, university. It is a Next.js App Router project.

```
apps/web/
├── src/
│   ├── app/          # Routes (App Router). Login and dashboards live here.
│   ├── features/     # Role-specific functionality, one folder per role
│   │   ├── student/
│   │   ├── industry/
│   │   ├── faculty/
│   │   ├── mentor/
│   │   ├── ngo/
│   │   └── university/
│   ├── components/   # Shared, role-agnostic UI used across the app
│   └── lib/          # App-level data, helpers, clients
├── public/
└── package.json
```

The `@/*` TypeScript path alias resolves to `apps/web/src/*`, so role code is
imported as `@/features/student/...`.

### Where does new code go?

| Kind of code | Location |
| --- | --- |
| A route/page | `src/app/...` |
| Logic or components only one role uses | `src/features/<role>/` |
| UI or logic several roles in the web app share | `src/components/` or `src/lib/` |
| Code the Citizen mobile app also needs | `packages/` |
| Server-side logic, persistence | `backend/` |

Current routes were built for the student experience and still live under
`src/app/(app)/` and `src/app/collaborate/`. They keep working unchanged;
`src/features/student/` is where student-specific code moves as the other
roles are added.

## apps/citizen-app — the Citizen mobile app

The only mobile application. Not implemented yet; the folder exists to fix its
place in the architecture.

## packages/ — shared code

Consumed by both `apps/web` and `apps/citizen-app`. Empty until there is real
shared code to put there — nothing is duplicated here from the web app.

| Package | Responsibility |
| --- | --- |
| `models` | Domain types and schemas shared by every surface |
| `api` | API client and request/response contracts |
| `auth` | Authentication and role resolution |
| `ui` | Cross-platform UI primitives and design tokens |
| `utils` | Framework-agnostic helpers |

## backend/ — independent service

Stays independent of the frontends. `api/` exposes routes, `services/` holds
business logic, `models/` the persistence layer, `database/` migrations, seeds
and connection setup.
