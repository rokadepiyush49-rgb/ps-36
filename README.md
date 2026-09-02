# Problem Statement 36 — Jan Setu

One unified web platform plus one Citizen mobile app, sharing common packages
and an independent backend.

## Structure

```
Problem Statement 36/
├── apps/
│   ├── web/          # THE unified website (Next.js) — all roles, one login
│   └── citizen-app/  # Citizen mobile application (not implemented yet)
├── packages/         # Shared code, reusable by web and mobile
│   ├── models/       # Shared domain types / schemas
│   ├── api/          # Shared API client
│   ├── auth/         # Shared authentication logic
│   ├── ui/           # Shared UI primitives
│   └── utils/        # Shared helpers
├── backend/          # Independent backend service
│   ├── api/          # Route/controller layer
│   ├── services/     # Business logic
│   ├── models/       # Persistence models
│   └── database/     # Migrations, seeds, connection setup
└── docs/             # Architecture and product documentation
```

## Architecture rules

1. There is exactly **one** web application: `apps/web`. There is no
   `student-web`, `industry-web`, `faculty-web`, `mentor-web`, `ngo-web`, or
   `university-web`.
2. `apps/web` has a common login/authentication entry point. After login the
   user's role decides which dashboard and features are shown.
3. Role-specific functionality lives in `apps/web/src/features/<role>/`
   (`student`, `industry`, `faculty`, `mentor`, `ngo`, `university`).
4. There is no student mobile app. The only mobile app is `apps/citizen-app`.
5. Code shared between web and mobile belongs in `packages/`, not duplicated.
6. Backend code stays in `backend/` and is never moved into the frontend.

## Running the web app

```bash
cd apps/web
npm install
npm run dev
```

See [apps/web/README.md](apps/web/README.md) for routes and app-level details.
