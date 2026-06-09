const features = [
  {
    eyebrow: "Shared savings",
    title: "A clearer way to collect and grow money together.",
    text: "Create circles, set contribution rules, track who has paid and keep progress visible without chasing screenshots in group chats.",
    metric: "KES 24,560",
    label: "this month",
    accent: "bg-primary",
    rows: ["Monthly contribution", "Member status", "Upcoming collection"],
  },
  {
    eyebrow: "Trusted lending",
    title: "Peer lending with expectations everyone can see.",
    text: "Members can request, approve and repay loans with clear terms, repayment dates and activity history attached to the circle.",
    metric: "KES 15,000",
    label: "approved",
    accent: "bg-emerald",
    rows: ["Loan request", "Approval trail", "Repayment schedule"],
  },
  {
    eyebrow: "Goal tracking",
    title: "Every shared goal gets a visible path to completion.",
    text: "Plan for trips, school fees, emergencies or investments with funded amounts, target dates and milestone progress in one place.",
    metric: "72%",
    label: "funded",
    accent: "bg-gold",
    rows: ["Target amount", "Progress history", "Next milestone"],
  },
  {
    eyebrow: "Circle accountability",
    title: "Trust grows when every member works from the same record.",
    text: "Contribution history, repayments, withdrawals and member activity stay transparent so disputes are easier to prevent.",
    metric: "100%",
    label: "visible",
    accent: "bg-ink",
    rows: ["Activity feed", "Member visibility", "Ledger records"],
  },
];

export function FeaturePillars() {
  return (
    <section id="features" className="bg-cream px-6 py-28 lg:px-10">
      <div className="mx-auto max-w-7xl">
        <div className="grid gap-12 lg:grid-cols-[0.8fr_1.2fr] lg:items-end">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
              Feature pillars
            </p>
            <h2 className="mt-4 text-4xl font-extrabold leading-tight text-ink md:text-5xl">
              Built around the way people already support each other.
            </h2>
          </div>

          <p className="max-w-2xl text-lg leading-8 text-ink/60">
            Tugetha does not try to replace trust. It gives trusted groups the
            structure, visibility, and records they need to manage money better.
          </p>
        </div>

        <div className="mt-20 space-y-20 lg:space-y-28">
          {features.map((feature, index) => (
            <div
              key={feature.eyebrow}
              className={`grid min-h-[520px] gap-10 rounded-lg border border-line bg-white p-6 md:p-10 lg:grid-cols-2 lg:items-center ${
                index % 2 === 1 ? "lg:[&>div:first-child]:order-2" : ""
              }`}
            >
              <div>
                <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
                  {feature.eyebrow}
                </p>
                <h3 className="mt-4 max-w-xl text-4xl font-extrabold leading-tight text-ink md:text-5xl">
                  {feature.title}
                </h3>
                <p className="mt-6 max-w-xl text-lg leading-8 text-muted">
                  {feature.text}
                </p>
              </div>

              <div className="rounded-lg border border-line bg-cream p-5 md:p-7">
                <div className="rounded-lg bg-white p-6">
                  <div className="flex items-start justify-between gap-5">
                    <div>
                      <p className="text-sm font-semibold text-muted">
                        {feature.eyebrow}
                      </p>
                      <p className="mt-3 text-4xl font-extrabold text-ink">
                        {feature.metric}
                      </p>
                      <p className="mt-1 text-sm font-bold text-emerald">
                        {feature.label}
                      </p>
                    </div>
                    <div
                      className={`flex h-14 w-14 items-center justify-center rounded-lg ${feature.accent} text-white`}
                    >
                      <svg
                        aria-hidden="true"
                        className="h-7 w-7"
                        fill="none"
                        stroke="currentColor"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="1.7"
                        viewBox="0 0 24 24"
                      >
                        <path d="M4 17 9 12l3 3 7-8m0 0v5m0-5h-5" />
                      </svg>
                    </div>
                  </div>

                  <div className="mt-8 space-y-4">
                    {feature.rows.map((row, rowIndex) => (
                      <div
                        className="flex items-center justify-between border-t border-line pt-4"
                        key={row}
                      >
                        <div>
                          <p className="font-bold text-ink">{row}</p>
                          <p className="mt-1 text-sm text-muted">
                            {rowIndex === 0
                              ? "Recorded today"
                              : "Visible to every member"}
                          </p>
                        </div>
                        <span className="text-sm font-bold text-primary">
                          {rowIndex === 0 ? "Active" : "Clear"}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
