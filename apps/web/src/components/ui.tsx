import Link from "next/link";
import type { ComponentProps, ReactNode } from "react";
import { Icon, type IconName } from "./icon";

function cx(...parts: Array<string | false | null | undefined>) {
  return parts.filter(Boolean).join(" ");
}

/* ---------------------------------------------------------------- Card --- */

export function Card({
  className,
  children,
  ...rest
}: ComponentProps<"section">) {
  return (
    <section
      className={cx(
        "rounded-lg border border-line bg-card shadow-level1",
        className,
      )}
      {...rest}
    >
      {children}
    </section>
  );
}

export function CardHeader({
  title,
  subtitle,
  icon,
  action,
}: {
  title: string;
  subtitle?: string;
  icon?: IconName;
  action?: ReactNode;
}) {
  return (
    <div className="flex items-start justify-between gap-4 px-6 pt-6">
      <div className="flex gap-3">
        {icon ? (
          <span className="mt-0.5 flex size-10 shrink-0 items-center justify-center rounded-md border border-line bg-card-muted text-navy">
            <Icon name={icon} size={20} />
          </span>
        ) : null}
        <div>
          <h2 className="headline-md text-ink">{title}</h2>
          {subtitle ? (
            <p className="mt-1 text-sm text-ink-muted">{subtitle}</p>
          ) : null}
        </div>
      </div>
      {action}
    </div>
  );
}

/* -------------------------------------------------------------- Button --- */

type ButtonTone = "primary" | "outline" | "impact" | "ghost" | "danger";

const TONES: Record<ButtonTone, string> = {
  primary: "bg-primary text-white hover:bg-navy",
  outline: "border border-primary/25 bg-card text-ink hover:border-primary/60",
  impact: "bg-impact text-white hover:bg-impact-deep",
  ghost: "text-ink-muted hover:bg-card-muted hover:text-ink",
  danger: "bg-danger text-white hover:bg-danger/90",
};

const SIZES = {
  sm: "h-9 px-3.5 text-sm gap-1.5",
  md: "h-11 px-5 text-sm gap-2",
  lg: "h-13 px-7 text-base gap-2.5",
};

type ButtonBase = {
  tone?: ButtonTone;
  size?: keyof typeof SIZES;
  icon?: IconName;
  iconAfter?: IconName;
  children: ReactNode;
  className?: string;
};

function buttonClass({ tone = "primary", size = "md", className }: ButtonBase) {
  return cx(
    "inline-flex items-center justify-center rounded-[0.5rem] font-semibold transition-colors",
    "disabled:pointer-events-none disabled:opacity-45",
    TONES[tone],
    SIZES[size],
    className,
  );
}

export function Button({
  tone,
  size,
  icon,
  iconAfter,
  children,
  className,
  ...rest
}: ButtonBase & Omit<ComponentProps<"button">, "children" | "className">) {
  return (
    <button className={buttonClass({ tone, size, className, children })} {...rest}>
      {icon ? <Icon name={icon} size={18} /> : null}
      {children}
      {iconAfter ? <Icon name={iconAfter} size={18} /> : null}
    </button>
  );
}

export function ButtonLink({
  tone,
  size,
  icon,
  iconAfter,
  children,
  className,
  ...rest
}: ButtonBase & Omit<ComponentProps<typeof Link>, "children" | "className">) {
  return (
    <Link className={buttonClass({ tone, size, className, children })} {...rest}>
      {icon ? <Icon name={icon} size={18} /> : null}
      {children}
      {iconAfter ? <Icon name={iconAfter} size={18} /> : null}
    </Link>
  );
}

/* ----------------------------------------------------------------- Tag --- */

type TagTone = "neutral" | "navy" | "impact" | "community" | "danger" | "soft";

const TAG_TONES: Record<TagTone, string> = {
  neutral: "border-line bg-card-muted text-ink-muted",
  navy: "border-navy/15 bg-navy-soft text-navy",
  impact: "border-impact/25 bg-impact-soft/50 text-impact-deep",
  community: "border-community/25 bg-community-soft/60 text-community-deep",
  danger: "border-danger/25 bg-danger-soft text-danger",
  soft: "border-transparent bg-primary text-white",
};

export function Tag({
  tone = "neutral",
  icon,
  children,
  className,
}: {
  tone?: TagTone;
  icon?: IconName;
  children: ReactNode;
  className?: string;
}) {
  return (
    <span
      className={cx(
        "inline-flex items-center gap-1.5 rounded-[0.5rem] border px-2.5 py-1 text-xs font-semibold whitespace-nowrap",
        TAG_TONES[tone],
        className,
      )}
    >
      {icon ? <Icon name={icon} size={13} /> : null}
      {children}
    </span>
  );
}

/* ------------------------------------------------------------ Progress --- */

export function Progress({
  value,
  tone = "navy",
  className,
}: {
  value: number;
  tone?: "navy" | "impact" | "community";
  className?: string;
}) {
  const fill = {
    navy: "bg-navy",
    impact: "bg-impact",
    community: "bg-community",
  }[tone];
  return (
    <div className={cx("h-2 w-full rounded-full bg-line", className)}>
      <div
        className={cx("h-full rounded-full transition-[width]", fill)}
        style={{ width: `${Math.min(100, Math.max(0, value))}%` }}
      />
    </div>
  );
}

/* ---------------------------------------------------------------- Misc --- */

export function StatTile({
  icon,
  label,
  value,
  tone = "navy",
}: {
  icon: IconName;
  label: string;
  value: string;
  tone?: "navy" | "impact" | "community";
}) {
  const chip = {
    navy: "bg-navy-soft text-navy",
    impact: "bg-impact-soft/60 text-impact-deep",
    community: "bg-community-soft/70 text-community-deep",
  }[tone];
  return (
    <Card className="flex items-center gap-4 p-4">
      <span className={cx("flex size-12 items-center justify-center rounded-full", chip)}>
        <Icon name={icon} size={22} />
      </span>
      <div>
        <p className="text-sm text-ink-muted">{label}</p>
        <p className="headline-lg text-ink tabular-nums">{value}</p>
      </div>
    </Card>
  );
}

export function Avatar({
  name,
  tone = "navy",
  size = 40,
}: {
  name: string;
  tone?: "navy" | "impact" | "community" | "muted";
  size?: number;
}) {
  const words = name.trim().split(/\s+/);
  // Short codes ("RU", "VB") are already initials — pass them through.
  const initials =
    words.length === 1 && name.length <= 3
      ? name.toUpperCase()
      : words
          .slice(0, 2)
          .map((w) => w[0])
          .join("")
          .toUpperCase();
  const chip = {
    navy: "bg-navy text-white",
    impact: "bg-impact-soft text-impact-deep",
    community: "bg-community-soft text-community-deep",
    muted: "bg-card-muted text-ink-muted",
  }[tone];
  return (
    <span
      aria-hidden="true"
      className={cx(
        "inline-flex shrink-0 items-center justify-center rounded-full font-semibold",
        chip,
      )}
      style={{ width: size, height: size, fontSize: size * 0.36 }}
    >
      {initials}
    </span>
  );
}

export function PageHeading({
  title,
  subtitle,
  breadcrumb,
  actions,
}: {
  title: string;
  subtitle?: string;
  breadcrumb?: string[];
  actions?: ReactNode;
}) {
  return (
    <div className="flex flex-wrap items-end justify-between gap-4">
      <div>
        {breadcrumb ? (
          <nav className="label-caps mb-2 flex items-center gap-2 text-ink-faint">
            {breadcrumb.map((crumb, i) => (
              <span className="flex items-center gap-2" key={crumb}>
                {i > 0 ? <Icon name="chevron-right" size={12} /> : null}
                {crumb}
              </span>
            ))}
          </nav>
        ) : null}
        <h1 className="headline-xl text-ink">{title}</h1>
        {subtitle ? (
          <p className="mt-2 max-w-2xl text-base text-ink-muted">{subtitle}</p>
        ) : null}
      </div>
      {actions ? <div className="flex flex-wrap gap-3">{actions}</div> : null}
    </div>
  );
}

export function EmptyNote({ icon, children }: { icon: IconName; children: ReactNode }) {
  return (
    <div className="flex flex-col items-center gap-3 rounded-lg border border-dashed border-line-strong px-6 py-10 text-center">
      <Icon className="text-ink-faint" name={icon} size={26} />
      <p className="max-w-xs text-sm text-ink-faint">{children}</p>
    </div>
  );
}
