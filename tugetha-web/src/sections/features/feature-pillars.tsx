const features = [
  {
    eyebrow: "Shared savings",
    title: "Collect contributions without chasing screenshots.",
    text: "Create circles, set contribution rules, track who has paid and keep progress visible to every member.",
    metric: "KES 24,560",
    label: "collected this month",
    status: "12 active members",
    progress: "w-[68%]",
    icon: "M4 17v-1a4 4 0 0 1 4-4h1m7 5v-1a4 4 0 0 0-4-4h-1M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6Zm8 0a3 3 0 1 0 0-6 3 3 0 0 0 0 6Zm-4 12v-7m-3 3.5h6",
  },
  {
    eyebrow: "Trusted lending",
    title: "Make peer lending clear before money moves.",
    text: "Members can request, approve and repay loans with terms, dates and activity history attached to the circle.",
    metric: "KES 15,000",
    label: "approved request",
    status: "Due in 30 days",
    progress: "w-[45%]",
    icon: "M7 11h10m-8 4h6M5 5h14v14H5V5Zm3-3v3m8-3v3",
  },
  {
    eyebrow: "Goal tracking",
    title: "Give every shared goal a visible path.",
    text: "Plan for trips, school fees, emergencies or investments with funded amounts, target dates and milestones.",
    metric: "72%",
    label: "Diani Trip Fund",
    status: "KES 57,600 of 80,000",
    progress: "w-[72%]",
    icon: "M4 17 9 12l3 3 7-8m0 0v5m0-5h-5",
  },
  {
    eyebrow: "Circle accountability",
    title: "Keep one shared record for the whole group.",
    text: "Contribution history, repayments, withdrawals and member activity stay transparent so disputes are easier to prevent.",
    metric: "100%",
    label: "activity visibility",
    status: "Ledger always available",
    progress: "w-full",
    icon: "M7 3h10v18H7V3Zm3 5h4m-4 4h4m-4 4h2",
  },
];

function FeatureIcon({ path }: { path: string }) {
  return (
    <svg
      aria-hidden="true"
      className="h-6 w-6"
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

export function FeaturePillars() {
  return (
    <section id="features" className="bg-cream px-6 py-24 lg:px-10">
      <div className="mx-auto max-w-7xl">
        <div className="grid gap-8 lg:grid-cols-[0.8fr_1.2fr] lg:items-end">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
              Feature pillars
            </p>
            <h2 className="mt-4 text-4xl font-bold leading-tight text-ink md:text-5xl">
              Built around how people already support each other.
            </h2>
          </div>

          <p className="max-w-2xl text-lg leading-8 text-muted">
            Tugetha does not replace trust. It gives trusted groups the
            structure, visibility and records they need to manage money better.
          </p>
        </div>

        <div className="mt-16 divide-y divide-line rounded-lg border border-line bg-white">
          {features.map((feature) => (
            <article
              className="grid gap-8 p-6 md:p-8 lg:grid-cols-[0.95fr_1.05fr] lg:items-center"
              key={feature.eyebrow}
            >
              <div className="grid gap-5 sm:grid-cols-[64px_1fr]">
                <div className="flex h-14 w-14 items-center justify-center rounded-lg bg-soft text-primary">
                  <FeatureIcon path={feature.icon} />
                </div>
                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
                    {feature.eyebrow}
                  </p>
                  <h3 className="mt-3 max-w-xl text-2xl font-semibold leading-snug text-ink md:text-3xl">
                    {feature.title}
                  </h3>
                  <p className="mt-4 max-w-2xl text-base leading-7 text-muted">
                    {feature.text}
                  </p>
                </div>
              </div>

              <div className="border-t border-line pt-6 lg:border-l lg:border-t-0 lg:pl-10 lg:pt-0">
                <div className="flex flex-wrap items-end justify-between gap-5">
                  <div>
                    <p className="text-sm font-medium text-muted">
                      {feature.label}
                    </p>
                    <p className="mt-2 text-4xl font-bold text-ink">
                      {feature.metric}
                    </p>
                  </div>
                  <p className="rounded-md bg-soft px-3 py-2 text-sm font-medium text-primary">
                    {feature.status}
                  </p>
                </div>
                <div className="mt-6 h-2 overflow-hidden rounded-md bg-neutral">
                  <div className={`h-full rounded-md bg-primary ${feature.progress}`} />
                </div>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
