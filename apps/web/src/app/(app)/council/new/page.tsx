"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { Icon } from "@/components/icon";
import {
  Button,
  ButtonLink,
  Card,
  CardHeader,
  PageHeading,
  Tag,
} from "@/components/ui";
import { AGENTS, PHASES } from "@/lib/data";

const AGENT_TONES: Record<string, string> = {
  navy: "bg-navy text-white",
  impact: "bg-impact-soft text-impact-deep",
  community: "bg-community-soft text-community-deep",
  muted: "bg-card-muted text-ink-faint",
};

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block">
      <span className="mb-2 block text-sm font-semibold text-ink">{label}</span>
      {children}
    </label>
  );
}

const inputClass =
  "w-full rounded-[0.5rem] border border-line bg-card px-4 py-3 text-sm text-ink placeholder:text-ink-faint focus:border-navy focus:border-2 focus:outline-none";

export default function CouncilSetupPage() {
  const router = useRouter();
  const [selected, setSelected] = useState<string[]>(
    AGENTS.filter((a) => a.defaultOn).map((a) => a.id),
  );
  const [files, setFiles] = useState<string[]>([
    "baseline-survey-ranchi.csv",
  ]);

  function toggle(id: string) {
    setSelected((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id],
    );
  }

  function submit(event: FormEvent) {
    event.preventDefault();
    router.push("/council/session");
  }

  return (
    <form className="mx-auto flex max-w-7xl flex-col gap-6" onSubmit={submit}>
      <PageHeading
        breadcrumb={["Problem Explorer", "AI Project Council"]}
        subtitle="Define your project parameters and select the specialized AI agents to form your advisory council for comprehensive analysis."
        title="Council Initialization"
      />

      <div className="grid gap-6 xl:grid-cols-[1.5fr_1fr]">
        <div className="flex flex-col gap-6">
          <Card>
            <CardHeader
              icon="file-pen"
              subtitle="Core structural information for the council to analyze."
              title="Project Details"
            />
            <div className="mt-5 flex flex-col gap-5 border-t border-line px-6 pt-5 pb-6">
              <Field label="Project Title">
                <input
                  className={inputClass}
                  name="title"
                  placeholder="e.g., Rural Broadband Initiative"
                  required
                />
              </Field>
              <Field label="Problem Statement">
                <textarea
                  className={inputClass}
                  name="problem"
                  placeholder="Describe the specific problem this project aims to solve…"
                  rows={4}
                />
              </Field>
              <Field label="Proposed Solution">
                <textarea
                  className={inputClass}
                  name="solution"
                  placeholder="Detail your approach and methodology…"
                  rows={5}
                />
              </Field>
              <div className="grid gap-5 sm:grid-cols-2">
                <Field label="Target Demographic">
                  <input
                    className={inputClass}
                    name="demographic"
                    placeholder="e.g., Students, Farmers"
                  />
                </Field>
                <Field label="Current Phase">
                  <div className="relative">
                    <select
                      className={`${inputClass} appearance-none pr-10 font-semibold`}
                      defaultValue={PHASES[0]}
                      name="phase"
                    >
                      {PHASES.map((phase) => (
                        <option key={phase} value={phase}>
                          {phase}
                        </option>
                      ))}
                    </select>
                    <Icon
                      className="pointer-events-none absolute top-1/2 right-3 -translate-y-1/2 text-ink-muted"
                      name="chevron-down"
                      size={16}
                    />
                  </div>
                </Field>
              </div>
            </div>
          </Card>

          <Card>
            <CardHeader
              action={
                <Button
                  icon="plus"
                  onClick={() =>
                    setFiles((prev) => [...prev, `attachment-${prev.length + 1}.pdf`])
                  }
                  size="sm"
                  tone="ghost"
                  type="button"
                >
                  Add
                </Button>
              }
              icon="folder"
              subtitle="Upload research, whitepapers, or data sets."
              title="Supporting Documents"
            />
            <div className="mt-5 border-t border-line px-6 pt-5 pb-6">
              <div className="flex flex-col items-center gap-2 rounded-md border border-dashed border-line-strong px-6 py-10 text-center">
                <Icon className="text-ink-faint" name="upload" size={28} />
                <p className="text-sm font-semibold text-ink">
                  Click to select files
                </p>
                <p className="text-xs text-ink-faint">
                  PDF, DOCX, CSV or XLSX up to 25 MB each
                </p>
              </div>

              {files.length > 0 ? (
                <ul className="mt-4 flex flex-col gap-2">
                  {files.map((file) => (
                    <li
                      className="flex items-center gap-3 rounded-[0.5rem] border border-line px-4 py-3"
                      key={file}
                    >
                      <Icon className="text-navy" name="paperclip" size={17} />
                      <span className="flex-1 truncate text-sm text-ink">
                        {file}
                      </span>
                      <button
                        aria-label={`Remove ${file}`}
                        className="text-ink-faint hover:text-danger"
                        onClick={() =>
                          setFiles((prev) => prev.filter((f) => f !== file))
                        }
                        type="button"
                      >
                        <Icon name="x" size={16} />
                      </button>
                    </li>
                  ))}
                </ul>
              ) : null}
            </div>
          </Card>
        </div>

        <Card className="h-fit xl:sticky xl:top-24">
          <div className="flex items-start justify-between gap-4 px-6 pt-6">
            <div>
              <h2 className="headline-md flex items-center gap-2 text-ink">
                <Icon className="text-navy" name="users" size={22} />
                Council Assembly
              </h2>
              <p className="mt-2 text-sm text-ink-muted">
                Select AI personas to review your project from multiple critical
                perspectives.
              </p>
            </div>
            <Tag tone="navy">{selected.length} Selected</Tag>
          </div>

          <ul className="mt-5 flex flex-col gap-2 border-t border-line px-3 py-4">
            {AGENTS.map((agent) => {
              const on = selected.includes(agent.id);
              return (
                <li key={agent.id}>
                  <button
                    aria-pressed={on}
                    className={`flex w-full items-start gap-3 rounded-md border p-3 text-left transition-colors ${
                      on
                        ? "border-line bg-card shadow-level1"
                        : "border-transparent bg-card-muted/60 hover:bg-card-muted"
                    }`}
                    onClick={() => toggle(agent.id)}
                    type="button"
                  >
                    <span
                      className={`flex size-11 shrink-0 items-center justify-center rounded-full ${
                        on ? AGENT_TONES[agent.tone] : AGENT_TONES.muted
                      }`}
                    >
                      <Icon name={agent.icon} size={20} />
                    </span>
                    <span className="min-w-0 flex-1">
                      <span
                        className={`block font-bold ${on ? "text-ink" : "text-ink-muted"}`}
                      >
                        {agent.name}
                      </span>
                      <span className="mt-0.5 block text-xs leading-relaxed text-ink-muted">
                        {agent.blurb}
                      </span>
                    </span>
                    <span
                      className={`mt-1 flex h-6 w-11 shrink-0 items-center rounded-full px-0.5 transition-colors ${
                        on ? "bg-primary" : "bg-line-strong"
                      }`}
                    >
                      <span
                        className={`size-5 rounded-full bg-white transition-transform ${
                          on ? "translate-x-5" : ""
                        }`}
                      />
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>

          <div className="flex flex-col gap-3 border-t border-line px-6 py-5">
            <Button
              className="w-full"
              disabled={selected.length === 0}
              icon="sparkles"
              type="submit"
            >
              Convene the Council
            </Button>
            <ButtonLink className="w-full" href="/council" tone="ghost">
              Cancel
            </ButtonLink>
          </div>
        </Card>
      </div>
    </form>
  );
}
