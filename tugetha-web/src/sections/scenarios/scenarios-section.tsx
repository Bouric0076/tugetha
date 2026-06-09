const scenarios = [
  {
    title: "Planning a trip with friends?",
    problem: "Group chats make it hard to know who has paid and what is left.",
    solution: "Set the trip goal, invite the group and track contributions openly.",
    outcome: "Everyone sees the same balance before booking.",
  },
  {
    title: "Managing a chama?",
    problem: "Manual contribution books create delays, doubt and duplicated work.",
    solution: "Run cycles, member records and activity history from one circle.",
    outcome: "Treasurers spend less time reconciling.",
  },
  {
    title: "Saving for school fees?",
    problem: "Families often coordinate money across many people and timelines.",
    solution: "Create a shared goal with a target date and contribution visibility.",
    outcome: "The whole family knows the progress early.",
  },
  {
    title: "Running a welfare fund?",
    problem: "Support requests need speed, accountability and clear records.",
    solution: "Collect, lend or disburse from a transparent member circle.",
    outcome: "Help moves faster with fewer disputes.",
  },
];

export function ScenariosSection() {
  return (
    <section id="scenarios" className="bg-white px-6 py-28 lg:px-10">
      <div className="mx-auto max-w-7xl">
        <div className="grid gap-12 lg:grid-cols-[0.65fr_1.35fr]">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
              Built for every circle
            </p>
            <h2 className="mt-4 text-4xl font-extrabold leading-tight text-ink md:text-5xl">
              Different goals. One trusted place.
            </h2>
            <p className="mt-6 text-lg leading-8 text-muted">
              Tugetha works because it starts from real shared-money moments,
              not abstract financial dashboards.
            </p>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            {scenarios.map((scenario) => (
              <article
                className="rounded-lg border border-line bg-cream p-6"
                key={scenario.title}
              >
                <h3 className="text-2xl font-extrabold leading-tight text-ink">
                  {scenario.title}
                </h3>
                <div className="mt-7 space-y-5">
                  {[
                    ["Problem", scenario.problem],
                    ["Solution", scenario.solution],
                    ["Outcome", scenario.outcome],
                  ].map(([label, text]) => (
                    <div className="border-t border-line pt-4" key={label}>
                      <p className="text-xs font-bold uppercase tracking-[0.14em] text-primary">
                        {label}
                      </p>
                      <p className="mt-2 text-sm leading-6 text-muted">
                        {text}
                      </p>
                    </div>
                  ))}
                </div>
              </article>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
