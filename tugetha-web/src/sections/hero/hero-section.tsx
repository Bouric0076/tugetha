import Image from "next/image";
import { MarketingNav } from "@/components/marketing/marketing-nav";

const trustPoints = [
  {
    title: "Shared visibility",
    text: "Everyone works from the same record.",
    icon: "M4 17v-1a4 4 0 0 1 4-4h1m7 5v-1a4 4 0 0 0-4-4h-1M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6Zm8 0a3 3 0 1 0 0-6 3 3 0 0 0 0 6Zm-4 12v-7m-3 3.5h6",
  },
  {
    title: "Secure payments",
    text: "Protected contribution flows.",
    icon: "M12 3 5 6v5c0 4.5 3 7.5 7 9 4-1.5 7-4.5 7-9V6l-7-3Zm-2 9 1.5 1.5L15 10",
  },
  {
    title: "Transparent records",
    text: "Every activity is recorded.",
    icon: "M7 3h10v18H7V3Zm3 5h4m-4 4h4m-4 4h2",
  },
  {
    title: "Goal tracking",
    text: "Progress stays visible.",
    icon: "M4 17 9 12l3 3 7-8m0 0v5m0-5h-5",
  },
];

function Icon({ path }: { path: string }) {
  return (
    <svg
      aria-hidden="true"
      className="h-5 w-5"
      fill="none"
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth="1.7"
      viewBox="0 0 24 24"
    >
      <path d={path} />
    </svg>
  );
}

export function HeroSection() {
  return (
    <section className="bg-cream">
      <div className="relative min-h-[780px] overflow-hidden bg-ink text-white">
        <Image
          alt="A close circle of hands stacked together, representing shared trust and community support"
          className="object-cover object-center"
          fill
          priority
          sizes="100vw"
          src="/brand/tugetha-hero-community.jpg"
        />
        <div className="absolute inset-0 bg-[var(--hero-overlay)]" />

        <div className="relative z-10">
          <MarketingNav tone="dark" />

          <div className="mx-auto flex min-h-[660px] max-w-7xl items-center px-6 pb-20 pt-16 lg:px-10">
            <div className="max-w-4xl">
              <p className="text-xs font-semibold uppercase tracking-[0.16em] text-gold">
                The trusted circle for shared money goals
              </p>

              <h1 className="mt-5 max-w-4xl text-5xl font-bold leading-[1.05] md:text-7xl lg:text-[84px]">
                Your circle. Your goals. Better together.
              </h1>

              <p className="mt-7 max-w-2xl text-lg leading-8 text-neutral md:text-xl md:leading-9">
                Manage shared savings, group goals, peer lending and chama
                contributions from one trusted platform.
              </p>

              <div className="mt-10 flex flex-col gap-4 sm:flex-row">
                <a
                  href="/waitlist"
                  className="inline-flex min-h-12 items-center justify-center gap-3 rounded-lg bg-white px-7 text-sm font-semibold text-primary hover:bg-gold hover:text-ink"
                >
                  Join waitlist
                  <span aria-hidden="true">→</span>
                </a>
                <a
                  href="#how-it-works"
                  className="inline-flex min-h-12 items-center justify-center gap-3 rounded-lg border border-white bg-transparent px-7 text-sm font-semibold text-white hover:bg-white hover:text-primary"
                >
                  See how it works
                  <span aria-hidden="true">↓</span>
                </a>
              </div>

              <div className="mt-12 grid max-w-xl grid-cols-3 border-y border-primary-light py-6">
                {[
                  ["Save", "together"],
                  ["Lend", "responsibly"],
                  ["Grow", "steadily"],
                ].map(([value, label]) => (
                  <div
                    className="border-r border-primary-light pr-4 last:border-r-0"
                    key={value}
                  >
                    <p className="text-lg font-semibold text-white">{value}</p>
                    <p className="mt-1 text-sm text-neutral">{label}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="mx-auto w-full max-w-7xl px-6 py-16 lg:px-10">
        <div className="rounded-lg border border-line bg-white px-6 py-8 md:px-10">
          <p className="text-center text-lg font-semibold text-ink">
            Trusted by circles, families and chama groups
          </p>
          <div className="mt-8 grid gap-6 md:grid-cols-4">
            {trustPoints.map((point) => (
              <div className="flex gap-4" key={point.title}>
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-soft text-primary">
                  <Icon path={point.icon} />
                </div>
                <div>
                  <p className="font-semibold text-ink">{point.title}</p>
                  <p className="mt-1 text-sm leading-6 text-muted">
                    {point.text}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
