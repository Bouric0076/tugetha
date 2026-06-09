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
    <section id="how-it-works" className="bg-white px-6 py-28 lg:px-10">
      <div className="mx-auto max-w-7xl">
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
            How it works
          </p>
          <h2 className="mt-4 text-4xl font-extrabold leading-tight text-ink md:text-5xl">
            Simple steps. Powerful impact.
          </h2>
          <p className="mt-5 text-lg leading-8 text-muted">
            Tugetha turns the informal trust your circle already has into a
            clear flow for saving, lending and tracking progress.
          </p>
        </div>

        <div className="relative mt-20 grid gap-10 md:grid-cols-2 lg:grid-cols-4 lg:gap-8">
          <div className="absolute left-[12%] right-[12%] top-8 hidden border-t border-dashed border-primary/35 lg:block" />
          {steps.map((step, index) => (
            <div
              key={step.title}
              className="relative text-center md:text-left lg:text-center"
            >
              <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-primary text-lg font-extrabold text-white md:mx-0 lg:mx-auto">
                {step.number}
              </div>
              {index < steps.length - 1 ? (
                <div className="mx-auto mt-5 h-12 border-l border-dashed border-primary/30 md:hidden" />
              ) : null}
              <h3 className="mt-7 text-xl font-bold text-ink">{step.title}</h3>
              <p className="mx-auto mt-3 max-w-xs text-sm leading-7 text-muted md:mx-0 lg:mx-auto">
                {step.text}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
