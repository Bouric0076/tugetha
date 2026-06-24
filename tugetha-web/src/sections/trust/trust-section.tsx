const trustItems = [
  {
    title: "Transparent records",
    text: "Every contribution, repayment and withdrawal is captured.",
    icon: "M7 3h10v18H7V3Zm3 5h4m-4 4h4m-4 4h2",
  },
  {
    title: "Verified activity",
    text: "Members see activity tied to the circle record.",
    icon: "M20 6 9 17l-5-5",
  },
  {
    title: "Secure transactions",
    text: "Payment flows are designed around protection and traceability.",
    icon: "M12 3 5 6v5c0 4.5 3 7.5 7 9 4-1.5 7-4.5 7-9V6l-7-3",
  },
  {
    title: "Member visibility",
    text: "Everyone understands what is paid, pending and next.",
    icon: "M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12Zm10 3a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z",
  },
];

export function TrustSection() {
  return (
    <section id="trust" className="bg-primary px-6 py-24 text-white lg:px-10">
      <div className="mx-auto grid max-w-7xl gap-14 lg:grid-cols-[0.9fr_1.1fr] lg:items-center">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.16em] text-gold">
            Trust & security
          </p>
          <h2 className="mt-4 text-4xl font-bold leading-tight md:text-6xl">
            Trust is not a feature. It is the foundation.
          </h2>
          <p className="mt-7 max-w-xl text-lg leading-8 text-neutral">
            Shared money only works when people can see the same truth. Tugetha
            is built around records, visibility and accountable activity from
            the first contribution.
          </p>
        </div>

        <div className="grid gap-4 sm:grid-cols-2">
          {trustItems.map((item) => (
            <div
              key={item.title}
              className="rounded-lg border border-primary-light bg-ink p-6"
            >
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary-light text-gold">
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
                  <path d={item.icon} />
                </svg>
              </div>
              <p className="mt-8 text-lg font-semibold">{item.title}</p>
              <p className="mt-3 text-sm leading-6 text-neutral">
                {item.text}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
