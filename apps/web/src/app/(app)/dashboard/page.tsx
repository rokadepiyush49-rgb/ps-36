import type { Metadata } from "next";
import Link from "next/link";
import { Icon } from "@/components/icon";
import {
  Avatar,
  Button,
  ButtonLink,
  Card,
  PageHeading,
  StatTile,
  Tag,
} from "@/components/ui";
import {
  ACTIVE_PROJECTS,
  LEADERBOARD,
  QUICK_ACTIONS,
  RECOMMENDED,
  STAGES,
} from "@/lib/data";

export const metadata: Metadata = { title: "Student Hub" };

const TILE_TONES: Record<string, string> = {
  navy: "bg-navy-soft text-navy",
  impact: "bg-impact-soft/60 text-impact-deep",
  community: "bg-community-soft/70 text-community-deep",
  danger: "bg-danger-soft text-danger",
};

function StageTrack({ stage, percent }: { stage: number; percent: number }) {
  return (
    <div>
      <div className="flex items-center justify-between text-sm font-semibold text-ink">
        <span>
          Stage {stage}/{STAGES.length}
        </span>
        <span className="tabular-nums">{percent}%</span>
      </div>
      <div className="mt-2 flex gap-1">
        {STAGES.map((_, i) => (
          <span
            className={`h-2 flex-1 rounded-full ${i < stage ? "bg-primary" : "bg-line"}`}
            key={i}
          />
        ))}
      </div>
      <div className="mt-2 flex gap-1">
        {STAGES.map((label) => (
          <span
            className="flex-1 text-center text-[11px] font-medium text-ink-faint"
            key={label}
          >
            {label}
          </span>
        ))}
      </div>
    </div>
  );
}

export default function DashboardPage() {
  return (
    <div className="mx-auto flex max-w-7xl flex-col gap-6">
      <PageHeading
        subtitle="Welcome back, Scholar. Here's your impact overview for this week."
        title="Student Hub"
      />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <StatTile icon="rocket" label="Total Impact" tone="navy" value="2,450" />
        <StatTile icon="clipboard" label="Active Projects" tone="impact" value="04" />
        <StatTile icon="user-plus" label="Team Invites" tone="community" value="02" />
      </div>

      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4 xl:grid-cols-8">
        {QUICK_ACTIONS.map((action) => (
          <Card
            className="flex flex-col items-center gap-3 p-4 transition-shadow hover:shadow-level2"
            key={action.label}
          >
            <span
              className={`flex size-12 items-center justify-center rounded-full ${TILE_TONES[action.tone]}`}
            >
              <Icon name={action.icon} size={22} />
            </span>
            <span className="text-center text-sm font-semibold text-ink">
              {action.label}
            </span>
          </Card>
        ))}
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.6fr_1fr]">
        <Card className="p-6">
          <div className="flex items-center justify-between">
            <h2 className="headline-lg text-ink">Active Projects</h2>
            <Link
              className="text-sm font-semibold text-navy hover:underline"
              href="/impact-hub"
            >
              View All
            </Link>
          </div>

          <div className="mt-5 flex flex-col gap-4">
            {ACTIVE_PROJECTS.map((project) => (
              <article
                className="rounded-md border border-line p-4"
                key={project.id}
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex flex-wrap items-center gap-3">
                    <Tag tone={project.statusTone}>{project.status}</Tag>
                    <span className="text-sm text-ink-muted">{project.note}</span>
                  </div>
                  <button
                    aria-label="Project options"
                    className="text-ink-faint hover:text-ink"
                    type="button"
                  >
                    <Icon name="more-vertical" size={18} />
                  </button>
                </div>
                <h3 className="mt-3 mb-4 text-lg font-bold text-ink">
                  {project.title}
                </h3>
                <StageTrack percent={project.percent} stage={project.stage} />
              </article>
            ))}
          </div>

          <ButtonLink
            className="mt-5 w-full"
            href="/collaborate/new"
            icon="plus"
            tone="outline"
          >
            Start a new collaboration
          </ButtonLink>
        </Card>

        <div className="flex flex-col gap-6">
          <Card className="p-6">
            <div className="flex items-center gap-2">
              <Icon className="text-community" name="trophy" size={22} />
              <h2 className="headline-lg text-ink">Leaderboard</h2>
            </div>
            <ol className="mt-4 flex flex-col gap-2">
              {LEADERBOARD.map((row) => (
                <li
                  className={`flex items-center gap-3 rounded-md px-3 py-2.5 ${
                    row.rank === 1 ? "bg-navy-soft" : ""
                  }`}
                  key={row.name}
                >
                  <span className="w-4 text-base font-bold text-ink tabular-nums">
                    {row.rank}
                  </span>
                  <Avatar name={row.short} size={34} tone="muted" />
                  <span className="flex-1 text-sm font-semibold text-ink">
                    {row.name}
                  </span>
                  <span className="mono-data text-ink-muted">{row.points}</span>
                </li>
              ))}
            </ol>
            <Button className="mt-4 w-full" tone="outline">
              Full Rankings
            </Button>
          </Card>

          <Card className="p-6">
            <h2 className="headline-lg text-ink">Recommended for You</h2>
            <div className="mt-4 flex flex-col gap-3">
              {RECOMMENDED.map((item) => (
                <div
                  className="flex items-center gap-3 rounded-md border border-line p-3"
                  key={item.title}
                >
                  <span className="flex size-11 shrink-0 items-center justify-center rounded-[0.5rem] bg-navy text-white">
                    <Icon name={item.icon} size={20} />
                  </span>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-bold text-ink">
                      {item.title}
                    </p>
                    <p className="text-xs text-ink-muted">{item.meta}</p>
                  </div>
                  <Tag tone={item.badgeTone}>{item.badge}</Tag>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
