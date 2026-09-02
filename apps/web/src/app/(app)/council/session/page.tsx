"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";
import { Icon } from "@/components/icon";
import { Avatar, Button, Tag } from "@/components/ui";
import { INSIGHTS, TRANSCRIPT } from "@/lib/data";

type Message = {
  id: string;
  author: string;
  role: string;
  time: string;
  tone: "navy" | "impact" | "community";
  quote?: string;
  body: string;
  tags: { label: string; tone: "neutral" | "danger"; icon: "globe" | "zap" }[];
};

const ACCENTS: Record<Message["tone"], string> = {
  navy: "border-l-navy",
  impact: "border-l-impact-deep",
  community: "border-l-community",
};

function Bubble({ message }: { message: Message }) {
  return (
    <article className="flex gap-3">
      <Avatar name={message.author} size={40} tone="muted" />
      <div
        className={`flex-1 rounded-lg border border-line border-l-4 bg-card p-5 shadow-level1 ${ACCENTS[message.tone]}`}
      >
        <div className="flex flex-wrap items-center gap-3">
          <h3 className="font-bold text-ink">{message.author}</h3>
          <Tag tone="neutral">{message.role}</Tag>
          <span className="mono-data ml-auto text-ink-faint">{message.time}</span>
        </div>

        {message.quote ? (
          <p className="mt-3 border-l-2 border-line-strong bg-card-muted px-4 py-2.5 text-sm text-ink-muted">
            {message.quote}
          </p>
        ) : null}

        <p className="mt-3 text-[15px] leading-relaxed text-ink">{message.body}</p>

        {message.tags.length > 0 ? (
          <div className="mt-4 flex flex-wrap gap-2">
            {message.tags.map((tag) => (
              <Tag icon={tag.icon} key={tag.label} tone={tag.tone}>
                {tag.label}
              </Tag>
            ))}
          </div>
        ) : null}
      </div>
    </article>
  );
}

export default function CouncilSessionPage() {
  const [messages, setMessages] = useState<Message[]>(TRANSCRIPT as Message[]);
  const [draft, setDraft] = useState("");
  const [paused, setPaused] = useState(false);

  function submit(event: FormEvent) {
    event.preventDefault();
    const text = draft.trim();
    if (!text) return;
    setMessages((prev) => [
      ...prev,
      {
        id: `you-${prev.length}`,
        author: "Aisha Patel",
        role: "Proposer",
        time: new Date().toLocaleTimeString([], {
          hour: "2-digit",
          minute: "2-digit",
        }),
        tone: "community",
        body: text,
        tags: [],
      },
    ]);
    setDraft("");
  }

  return (
    <div className="mx-auto -my-8 flex max-w-7xl flex-col xl:h-[calc(100vh-4.5rem)] xl:flex-row">
      {/* Transcript column */}
      <div className="flex min-w-0 flex-1 flex-col border-line xl:border-r">
        <div className="flex flex-wrap items-center gap-3 border-b border-line px-5 py-4">
          <span
            className={`size-2.5 rounded-full ${paused ? "bg-community" : "bg-impact-deep"}`}
          />
          <p className="text-sm font-bold text-ink">
            {paused ? "Council paused" : "Council is active"}
          </p>
          <span className="hidden h-4 w-px bg-line sm:block" />
          <p className="hidden text-sm text-ink-muted sm:block">
            {paused
              ? "Deliberation held for your input…"
              : "Technical Agent is reviewing constraints…"}
          </p>
          <div className="ml-auto flex gap-2">
            <Tag tone="navy">Project Alpha</Tag>
            <Tag tone="neutral">Live Sync</Tag>
          </div>
        </div>

        <div className="flex-1 space-y-5 overflow-y-auto px-5 py-6">
          <p className="mx-auto flex w-fit items-center gap-2 rounded-full border border-line bg-card px-4 py-2 text-sm text-ink-muted">
            <Icon name="alert-circle" size={16} />
            Session initialized. AI Council analyzing feasibility constraints.
          </p>

          {messages.map((message) => (
            <Bubble key={message.id} message={message} />
          ))}

          {!paused ? (
            <div className="flex items-center gap-3">
              <Avatar name="Legal Agent" size={40} tone="muted" />
              <p className="flex items-center gap-3 rounded-full border border-line bg-card px-5 py-3 text-sm text-ink-faint">
                <span className="flex gap-1">
                  {[0, 1, 2].map((i) => (
                    <span
                      className="size-1.5 animate-pulse rounded-full bg-ink-faint"
                      key={i}
                      style={{ animationDelay: `${i * 0.18}s` }}
                    />
                  ))}
                </span>
                Legal Agent drafting response…
              </p>
            </div>
          ) : null}
        </div>

        <form
          className="border-t border-line bg-surface px-5 py-4"
          onSubmit={submit}
        >
          <div className="flex flex-col gap-3 sm:flex-row sm:items-end">
            <div className="flex-1 rounded-md border border-line bg-card p-3 focus-within:border-navy">
              <label>
                <span className="sr-only">Your response to the council</span>
                <textarea
                  className="w-full resize-none text-sm text-ink placeholder:text-ink-faint focus:outline-none"
                  onChange={(e) => setDraft(e.target.value)}
                  placeholder="Add your response or explain your approach to the Council…"
                  rows={2}
                  value={draft}
                />
              </label>
              <div className="mt-2 flex items-center gap-3 text-ink-faint">
                <Icon name="paperclip" size={17} />
                <span className="text-sm font-bold">B</span>
                <span className="mono-data">{"{ }"}</span>
                <span className="ml-auto text-xs">Press Enter to interject</span>
              </div>
            </div>

            <div className="flex gap-2">
              <Button
                aria-label={paused ? "Resume council" : "Pause council"}
                className="!px-3"
                onClick={() => setPaused((p) => !p)}
                tone="outline"
                type="button"
              >
                <Icon name={paused ? "refresh" : "pause"} size={18} />
              </Button>
              <Button disabled={!draft.trim()} iconAfter="send" type="submit">
                Submit
              </Button>
            </div>
          </div>
        </form>
      </div>

      {/* Insights column */}
      <aside className="w-full shrink-0 overflow-y-auto border-t border-line bg-surface px-5 py-6 xl:w-96 xl:border-t-0">
        <div className="flex items-center justify-between">
          <h2 className="headline-lg text-ink">Council Insights</h2>
          <Icon className="text-ink-faint" name="arrow-up-right" size={18} />
        </div>

        <div className="mt-5 flex flex-col gap-4">
          {INSIGHTS.map((insight) => (
            <section
              className={`rounded-lg border border-line border-l-4 bg-card p-5 shadow-level1 ${insight.accent}`}
              key={insight.title}
            >
              <h3 className="flex items-center gap-2 font-bold text-ink">
                <Icon className="text-navy" name={insight.icon} size={19} />
                {insight.title}
              </h3>
              <div className="mt-3 flex flex-wrap gap-2">
                {insight.chips.map((chip) => (
                  <Tag key={chip.label} tone={chip.tone}>
                    {chip.label}
                  </Tag>
                ))}
              </div>
              <ul className="mt-4 flex list-disc flex-col gap-2 pl-4 text-sm leading-relaxed text-ink marker:text-ink-faint">
                {insight.points.map((point) => (
                  <li key={point.text}>
                    {point.lead ? (
                      <strong
                        className={point.danger ? "text-danger" : "text-ink"}
                      >
                        {point.lead}{" "}
                      </strong>
                    ) : null}
                    <span className={point.danger ? "text-danger" : undefined}>
                      {point.text}
                    </span>
                  </li>
                ))}
              </ul>
            </section>
          ))}

          <div className="flex flex-col items-center gap-2 rounded-lg border border-dashed border-line-strong px-6 py-8 text-center">
            <Icon className="text-ink-faint" name="scale" size={24} />
            <p className="text-sm text-ink-faint">
              Legal Agent insights pending current analysis…
            </p>
          </div>

          <Link
            className="flex h-12 items-center justify-center gap-2 rounded-[0.5rem] bg-primary text-sm font-semibold text-white transition-colors hover:bg-navy"
            href="/council/verdict"
          >
            Close session & view verdict
            <Icon name="arrow-right" size={18} />
          </Link>
        </div>
      </aside>
    </div>
  );
}
