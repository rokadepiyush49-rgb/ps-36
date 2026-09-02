import { Icon } from "./icon";

export const WIZARD_STEPS = [
  { n: 1, label: "Project Details" },
  { n: 2, label: "Team Formation" },
  { n: 3, label: "Review & Launch" },
];

export function Stepper({ current }: { current: number }) {
  return (
    <ol className="flex flex-wrap items-center gap-x-4 gap-y-3">
      {WIZARD_STEPS.map((step, i) => {
        const done = step.n < current;
        const active = step.n === current;
        return (
          <li className="flex items-center gap-3" key={step.n}>
            {i > 0 ? (
              <span
                className={`hidden h-px w-10 sm:block ${done || active ? "bg-primary" : "bg-line"}`}
              />
            ) : null}
            <span
              className={`flex size-8 items-center justify-center rounded-full text-sm font-bold ${
                done || active
                  ? "bg-primary text-white"
                  : "bg-card-muted text-ink-faint"
              }`}
            >
              {done ? <Icon name="check" size={16} /> : step.n}
            </span>
            <span
              className={`text-sm font-semibold ${
                active ? "text-ink" : "text-ink-muted"
              }`}
            >
              Step {step.n}: {step.label}
            </span>
          </li>
        );
      })}
    </ol>
  );
}
