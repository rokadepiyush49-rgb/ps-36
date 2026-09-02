import type { Metadata } from "next";
import { Icon } from "@/components/icon";
import { ButtonLink, Card, PageHeading, Tag } from "@/components/ui";
import { CONCERNS, STRENGTHS, VERDICT_SCORES } from "@/lib/data";

export const metadata: Metadata = { title: "Verdict & Analysis" };

const BAR_TONES = {
  impact: "bg-impact",
  community: "bg-community",
  navy: "bg-navy",
} as const;

function ReadinessRing({ score }: { score: number }) {
  const radius = 52;
  const circumference = 2 * Math.PI * radius;
  return (
    <div className="relative flex size-36 items-center justify-center">
      <svg className="-rotate-90" height="144" viewBox="0 0 144 144" width="144">
        <circle
          cx="72"
          cy="72"
          fill="none"
          r={radius}
          stroke="var(--color-line)"
          strokeWidth="12"
        />
        <circle
          cx="72"
          cy="72"
          fill="none"
          r={radius}
          stroke="var(--color-impact-deep)"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - score / 100)}
          strokeLinecap="round"
          strokeWidth="12"
        />
      </svg>
      <span className="absolute text-center">
        <span className="block text-4xl font-bold text-ink tabular-nums">
          {score}
        </span>
        <span className="mono-data text-ink-faint">/100</span>
      </span>
    </div>
  );
}

export default function VerdictPage() {
  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-6">
      <PageHeading
        actions={
          <>
            <ButtonLink href="/council/new" tone="outline">
              Restart for New Iteration
            </ButtonLink>
            <ButtonLink href="/impact-hub" icon="download">
              Export Final Report
            </ButtonLink>
          </>
        }
        breadcrumb={["AI Project Council", "Council Verdict"]}
        subtitle="Review the AI Council's comprehensive assessment of your proposal."
        title="Verdict & Analysis"
      />

      <Card className="grid gap-8 p-6 md:grid-cols-[auto_1fr] md:gap-10">
        <div className="flex flex-col items-center gap-3 md:border-r md:border-line md:pr-10">
          <p className="text-sm font-semibold text-ink-muted">Overall Readiness</p>
          <ReadinessRing score={78} />
          <Tag icon="check-circle" tone="impact">
            Viable with Edits
          </Tag>
        </div>

        <ul className="flex flex-col justify-center gap-6">
          {VERDICT_SCORES.map((score) => (
            <li key={score.label}>
              <div className="flex items-baseline justify-between">
                <span className="font-semibold text-ink">{score.label}</span>
                <span className="text-lg font-bold text-ink tabular-nums">
                  {score.value}/100
                </span>
              </div>
              <div className="mt-2 h-2.5 w-full rounded-full bg-line">
                <div
                  className={`h-full rounded-full ${BAR_TONES[score.tone]}`}
                  style={{ width: `${score.value}%` }}
                />
              </div>
            </li>
          ))}
        </ul>
      </Card>

      <div className="grid gap-6 lg:grid-cols-2">
        <section className="rounded-lg border border-impact bg-impact-wash/60 p-6">
          <h2 className="headline-lg flex items-center gap-2 text-impact-deep">
            <Icon name="thumbs-up" size={22} />
            Strongest Areas
          </h2>
          <ul className="mt-4 flex flex-col gap-3">
            {STRENGTHS.map((item) => (
              <li className="flex gap-3 text-[15px] text-ink" key={item}>
                <Icon
                  className="mt-0.5 shrink-0 text-impact-deep"
                  name="check"
                  size={18}
                />
                {item}
              </li>
            ))}
          </ul>
        </section>

        <section className="rounded-lg border border-danger/40 bg-danger-soft/60 p-6">
          <h2 className="headline-lg flex items-center gap-2 text-danger">
            <Icon name="warning" size={22} />
            Major Concerns
          </h2>
          <ul className="mt-4 flex flex-col gap-3">
            {CONCERNS.map((item) => (
              <li className="flex gap-3 text-[15px] text-danger" key={item}>
                <Icon
                  className="mt-0.5 shrink-0"
                  name="alert-circle"
                  size={18}
                />
                {item}
              </li>
            ))}
          </ul>
        </section>
      </div>

      <Card className="p-6">
        <h2 className="headline-lg text-ink">Project Improvement Loop</h2>
        <p className="mt-2 text-sm text-ink-muted">
          Review the specific narrative enhancements suggested by the AI Council
          to strengthen your proposal&apos;s impact.
        </p>

        <div className="mt-5 grid overflow-hidden rounded-md border border-line lg:grid-cols-2">
          <div className="bg-card-muted/60 p-5">
            <p className="label-caps text-ink-faint">Original Proposal (Excerpt)</p>
            <p className="mt-3 text-[15px] leading-relaxed text-ink-faint line-through decoration-ink-faint/60">
              We will build an app to help people report trash. Users can take
              pictures and send them to the city. We hope this makes the streets
              cleaner.
            </p>
          </div>

          <div className="border-t border-l-4 border-l-primary bg-navy-soft/40 p-5 lg:border-t-0">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <p className="label-caps text-ink">Refined Proposal</p>
              <Tag tone="navy">Agent: Gov-Tech Analyst</Tag>
            </div>
            <p className="mt-3 text-[15px] leading-relaxed text-ink">
              We propose developing a{" "}
              <mark className="rounded bg-impact-soft px-1 text-ink">
                geo-tagged civic reporting platform
              </mark>{" "}
              empowering citizens to directly log sanitation issues. This
              establishes a{" "}
              <mark className="rounded bg-impact-soft px-1 text-ink">
                quantifiable feedback loop
              </mark>{" "}
              with municipal waste management, driving measurable improvements in
              urban hygiene.
            </p>
          </div>
        </div>

        <div className="mt-5 flex flex-wrap gap-3">
          <ButtonLink href="/collaborate/new" icon="users">
            Take it to team formation
          </ButtonLink>
          <ButtonLink href="/council/session" tone="outline">
            Back to session
          </ButtonLink>
        </div>
      </Card>
    </div>
  );
}
