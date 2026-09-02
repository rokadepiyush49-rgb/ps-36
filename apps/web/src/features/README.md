# Features

Role-specific functionality for the unified web application. One folder per
role: `student`, `industry`, `faculty`, `mentor`, `ngo`, `university`.

After the common login, the authenticated user's role decides which of these
feature areas is used. Anything shared by more than one role belongs in
`src/components/` or `src/lib/` instead — or in the repo-level `packages/` if
the Citizen mobile app needs it too.

Folders are intentionally empty; they establish the architecture. Existing
student routes still live under `src/app/(app)/` and `src/app/collaborate/`
and are unchanged.
