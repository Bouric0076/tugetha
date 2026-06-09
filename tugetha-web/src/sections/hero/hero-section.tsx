import { MarketingNav } from "@/components/marketing/marketing-nav";

const trustPoints = [
  {
    title: "Shared visibility",
    text: "Everyone sees the same records.",
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
      <div className="mx-auto w-full max-w-7xl px-6 py-6 lg:px-10">
        <div className="-mx-6 -my-6 lg:-mx-10">
          <MarketingNav />
        </div>

        <div className="grid items-center gap-14 py-16 md:py-20 lg:grid-cols-[1fr_0.95fr] lg:py-24">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
              The trusted circle for shared money goals
            </p>

            <h1 className="mt-5 max-w-4xl text-5xl font-extrabold leading-[1.02] text-ink md:text-7xl lg:text-[84px]">
              Money works better when your circle works together.
            </h1>

            <p className="mt-7 max-w-2xl text-lg leading-8 text-muted md:text-xl md:leading-9">
              Manage shared savings, group goals, peer lending and chama
              contributions from one trusted platform.
            </p>

            <div className="mt-10 flex flex-col gap-4 sm:flex-row">
              <a
                href="/waitlist"
                className="inline-flex min-h-12 items-center justify-center gap-3 rounded-lg bg-primary px-7 text-sm font-bold text-white hover:bg-ink"
              >
                Join waitlist
                <span aria-hidden="true">→</span>
              </a>
              <a
                href="#how-it-works"
                className="inline-flex min-h-12 items-center justify-center gap-3 rounded-lg border border-line bg-white px-7 text-sm font-bold text-ink hover:border-primary hover:text-primary"
              >
                See how it works
                <span aria-hidden="true">↓</span>
              </a>
            </div>
          </div>

          <div className="mx-auto w-full max-w-[560px]">
            <div className="relative aspect-square min-h-[360px]">
              <div className="absolute inset-[9%] rounded-full border border-dashed border-gold/45" />
              <div className="absolute inset-[23%] rounded-full border-[10px] border-line" />
              <svg className="absolute inset-[23%]" viewBox="0 0 220 220">
                <circle
                  cx="110"
                  cy="110"
                  fill="none"
                  r="96"
                  stroke="#2D1B8C"
                  strokeDasharray="434 604"
                  strokeLinecap="round"
                  strokeWidth="10"
                  transform="rotate(-90 110 110)"
                />
                <circle
                  cx="110"
                  cy="110"
                  fill="none"
                  r="96"
                  stroke="#D4A017"
                  strokeDasharray="124 604"
                  strokeLinecap="round"
                  strokeWidth="10"
                  transform="rotate(168 110 110)"
                />
              </svg>

              <div className="absolute left-1/2 top-1/2 flex h-40 w-40 -translate-x-1/2 -translate-y-1/2 flex-col items-center justify-center rounded-full bg-white text-center">
                <div className="mb-3 flex h-10 w-10 items-center justify-center rounded-full bg-cream text-primary">
                  <Icon path="M8 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm8 0a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM3 21a5 5 0 0 1 10 0m-2 0a5 5 0 0 1 10 0" />
                </div>
                <p className="text-xs font-semibold text-muted">
                  Diani Trip Fund
                </p>
                <p className="mt-1 text-2xl font-extrabold text-ink">
                  KES 80,000
                </p>
                <p className="mt-1 text-sm font-bold text-emerald">
                  72% funded
                </p>
              </div>

              {[
                ["Mercy", "top-0 left-1/2 -translate-x-1/2", "bg-gold"],
                ["Brian", "left-0 top-1/2 -translate-y-1/2", "bg-emerald"],
                ["Kevin", "right-0 top-1/2 -translate-y-1/2", "bg-primary"],
                ["Amina", "bottom-7 left-[13%]", "bg-primary-light"],
                ["James", "bottom-7 right-[13%]", "bg-ink"],
              ].map(([name, position, color]) => (
                <div
                  className={`absolute ${position} flex items-center gap-3`}
                  key={name}
                >
                  <span
                    className={`flex h-14 w-14 items-center justify-center rounded-full border-4 border-cream ${color} text-sm font-bold text-white`}
                  >
                    {name[0]}
                  </span>
                  <span className="hidden text-sm font-semibold text-ink sm:block">
                    {name}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="mb-4 rounded-lg border border-line bg-white px-6 py-8 md:px-10">
          <p className="text-center text-lg font-bold text-ink">
            Trusted by circles, families and chama groups
          </p>
          <div className="mt-8 grid gap-6 md:grid-cols-4">
            {trustPoints.map((point) => (
              <div className="flex gap-4" key={point.title}>
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-cream text-primary">
                  <Icon path={point.icon} />
                </div>
                <div>
                  <p className="font-bold text-ink">{point.title}</p>
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
