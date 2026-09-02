import type { Metadata } from "next";
import { Icon } from "@/components/icon";
import {
  Avatar,
  Button,
  ButtonLink,
  Card,
  PageHeading,
  Progress,
  Tag,
} from "@/components/ui";
import { BADGES, CONTRIBUTIONS } from "@/lib/data";

export const metadata: Metadata = { title: "Profile" };

const SKILLS = [
  { name: "React", level: 88 },
  { name: "IoT & Embedded", level: 74 },
  { name: "Data Analytics", level: 69 },
  { name: "Community Facilitation", level: 82 },
];

const TONES: Record<string, string> = {
  navy: "bg-navy-soft text-navy",
  impact: "bg-impact-soft/60 text-impact-deep",
  community: "bg-community-soft/70 text-community-deep",
};

export default function ProfilePage() {
  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-6">
      <PageHeading
        actions={
          <>
            <Button icon="download" tone="outline">
              Export impact résumé
            </Button>
            <ButtonLink href="/collaborate/new" icon="plus">
              New Collaboration
            </ButtonLink>
          </>
        }
        subtitle="Your verified record of societal contribution across Jharkhand."
        title="Profile"
      />

      <Card className="flex flex-wrap items-center gap-6 p-6">
        <Avatar name="Aisha Patel" size={80} tone="navy" />
        <div className="min-w-0 flex-1">
          <h2 className="headline-lg text-ink">Aisha Patel</h2>
          <p className="text-sm text-ink-muted">
            B.Tech Student, Social Innovator · BIT Mesra
          </p>
          <div className="mt-3 flex flex-wrap gap-2">
            <Tag icon="check-circle" tone="impact">
              Verified Innovator
            </Tag>
            <Tag icon="map-pin" tone="neutral">
              Ranchi, Jharkhand
            </Tag>
            <Tag icon="star" tone="community">
              842 Impact Points
            </Tag>
          </div>
        </div>
      </Card>

      <div className="grid gap-6 lg:grid-cols-[1.4fr_1fr]">
        <Card className="p-6">
          <h2 className="headline-lg text-ink">Skill Signal</h2>
          <p className="mt-1 text-sm text-ink-muted">
            Derived from verified project contributions, not self-declared tags.
          </p>
          <ul className="mt-5 flex flex-col gap-4">
            {SKILLS.map((skill) => (
              <li key={skill.name}>
                <div className="flex items-center justify-between text-sm">
                  <span className="font-semibold text-ink">{skill.name}</span>
                  <span className="mono-data text-ink-muted">{skill.level}%</span>
                </div>
                <Progress className="mt-2" tone="navy" value={skill.level} />
              </li>
            ))}
          </ul>
        </Card>

        <Card className="p-6">
          <h2 className="headline-lg text-ink">Badges</h2>
          <div className="mt-4 flex flex-col gap-3">
            {BADGES.map((badge) => (
              <div
                className="flex items-center gap-3 rounded-md border border-line px-4 py-3"
                key={badge.label}
              >
                <span
                  className={`flex size-10 items-center justify-center rounded-full ${TONES[badge.tone]}`}
                >
                  <Icon name={badge.icon} size={19} />
                </span>
                <span className="text-sm font-semibold text-ink">
                  {badge.label}
                </span>
              </div>
            ))}
          </div>
        </Card>
      </div>

      <Card className="p-6">
        <h2 className="headline-lg text-ink">Contribution History</h2>
        <ul className="mt-2 divide-y divide-line">
          {CONTRIBUTIONS.map((item) => (
            <li className="flex gap-4 py-4" key={item.title}>
              <span
                className={`flex size-11 shrink-0 items-center justify-center rounded-full ${TONES[item.tone]}`}
              >
                <Icon name={item.icon} size={20} />
              </span>
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-baseline justify-between gap-2">
                  <h3 className="font-bold text-ink">{item.title}</h3>
                  <span className="mono-data text-ink-faint">{item.date}</span>
                </div>
                <p className="mt-1 text-sm text-ink-muted">{item.body}</p>
                <div className="mt-3 flex flex-wrap gap-2">
                  <Tag tone="neutral">{item.kind}</Tag>
                  <Tag tone="impact">{item.points}</Tag>
                </div>
              </div>
            </li>
          ))}
        </ul>
      </Card>
    </div>
  );
}
