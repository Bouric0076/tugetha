const steps = [
  {
    number: "01",
    title: "Create a circle",
    text: "Start a trusted group for friends, family, chama members, or a shared goal.",
  },
  {
    number: "02",
    title: "Invite members",
    text: "Bring people in using a simple invite link or code. Everyone sees the same records.",
  },
  {
    number: "03",
    title: "Set a money goal",
    text: "Create savings goals, chama cycles, or lending requests with clear expectations.",
  },
  {
    number: "04",
    title: "Track progress",
    text: "Contributions, repayments, and activity stay visible so trust does not depend on memory.",
  },
];

export function HowItWorks() {
  return (
    <section id="how-it-works" className="bg-white px-6 py-24 lg:px-10">
      <div className="mx-auto max-w-7xl">
        <div className="grid gap-8 lg:grid-cols-[0.75fr_1.25fr] lg:items-end">
          <div>
          <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
            How it works
          </p>
          <h2 className="mt-4 text-4xl font-bold leading-tight text-ink md:text-5xl">
            Simple steps. Powerful impact.
          </h2>
          </div>
          <p className="mt-5 text-lg leading-8 text-muted">
            Tugetha turns the informal trust your circle already has into a
            clear flow for saving, lending and tracking progress.
          </p>
        </div>

        <div className="relative mt-16 grid gap-5 md:grid-cols-2 lg:grid-cols-4">
          {steps.map((step, index) => (
            <div
              key={step.title}
              className="relative rounded-lg border border-line bg-cream p-6"
            >
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary text-sm font-semibold text-white">
                {step.number}
              </div>
              {index < steps.length - 1 ? (
                <div className="mt-6 h-px w-full bg-line lg:hidden" />
              ) : null}
              <h3 className="mt-7 text-xl font-semibold text-ink">{step.title}</h3>
              <p className="mt-3 text-sm leading-7 text-muted">
                {step.text}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
