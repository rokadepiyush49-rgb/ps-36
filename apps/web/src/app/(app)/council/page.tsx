import type { Metadata } from "next";
import { Icon } from "@/components/icon";
import { ButtonLink, Card } from "@/components/ui";

export const metadata: Metadata = { title: "AI Project Council" };

const SATELLITES = [
  { icon: "scale", label: "Policy", x: -132 },
  { icon: "trending-up", label: "Feasibility", x: 132 },
] as const;

export default function CouncilPage() {
  return (
    <div className="mx-auto flex min-h-[70vh] max-w-3xl flex-col items-center justify-center gap-10 py-8">
      {/* Orbit diagram: the council core flanked by two advisory lenses. */}
      <div className="relative flex h-72 w-full items-center justify-center">
        <span className="absolute size-72 rounded-full border border-dashed border-line-strong/70" />
        <span className="absolute size-52 rounded-full border border-dashed border-line-strong/50" />
        <span className="absolute h-px w-64 bg-line" />

        {SATELLITES.map((sat) => (
          <div
            className="absolute flex flex-col items-center gap-2"
            key={sat.label}
            style={{ transform: `translateX(${sat.x}px)` }}
          >
            <span className="flex size-14 items-center justify-center rounded-full border border-line bg-card-muted text-ink-muted shadow-level1">
              <Icon name={sat.icon} size={24} />
            </span>
            <span className="label-caps text-ink-muted">{sat.label}</span>
          </div>
        ))}

        <div className="absolute flex flex-col items-center gap-2">
          <span className="flex size-20 items-center justify-center rounded-full bg-navy text-white shadow-level2">
            <Icon name="bot" size={34} />
          </span>
          <span className="label-caps text-ink">Council Core</span>
        </div>
      </div>

      <Card className="w-full px-8 py-10 text-center">
        <span className="label-caps inline-flex items-center gap-2 rounded-full border border-line bg-card-muted px-3 py-2 text-ink-muted">
          <span className="size-2 rounded-full bg-impact-deep" />
          Workspace Ready
        </span>

        <h1 className="headline-xl mt-6 text-ink sm:text-4xl">
          Bring your project to the council.
        </h1>
        <p className="mx-auto mt-4 max-w-md text-base leading-relaxed text-ink-muted">
          Let specialized AI agents challenge your assumptions, identify risks,
          and help turn your idea into a stronger, more feasible project.
        </p>

        <ButtonLink
          className="mt-8"
          href="/council/new"
          icon="sparkles"
          size="lg"
        >
          Start New Analysis
        </ButtonLink>

        <p className="mt-5 flex items-center justify-center gap-2 text-sm text-ink-faint">
          <Icon name="lock" size={15} />
          Private workspace. Insights are generated securely.
        </p>
      </Card>
    </div>
  );
}
