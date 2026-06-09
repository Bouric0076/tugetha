const testimonials = [
  {
    quote:
      "Tugetha transformed how our chama operates. No more WhatsApp confusion or lost records.",
    name: "Brian M.",
    role: "Chama treasurer",
  },
  {
    quote:
      "We saved for our Diani trip in three months. Everything was transparent and stress-free.",
    name: "Mercy A.",
    role: "Circle member",
  },
  {
    quote:
      "Lending within our circle is now simple and trustworthy. Repayments are easy to track.",
    name: "Kevin O.",
    role: "Circle member",
  },
];

export function TestimonialsSection() {
  return (
    <section className="bg-white px-6 py-28 lg:px-10">
      <div className="mx-auto max-w-7xl">
        <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
          Loved by circles
        </p>
        <h2 className="mt-4 text-4xl font-extrabold leading-tight text-ink md:text-5xl">
          Real people. Real impact.
        </h2>

        <div className="mt-12 grid gap-5 md:grid-cols-3">
          {testimonials.map((testimonial) => (
            <figure
              className="rounded-lg border border-line bg-cream p-7"
              key={testimonial.name}
            >
              <div
                aria-hidden="true"
                className="text-6xl font-extrabold leading-none text-gold"
              >
                “
              </div>
              <blockquote className="mt-2 min-h-28 text-base leading-7 text-ink">
                {testimonial.quote}
              </blockquote>
              <figcaption className="mt-8 flex items-center gap-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-full bg-primary text-sm font-bold text-white">
                  {testimonial.name[0]}
                </div>
                <div>
                  <p className="font-bold text-ink">{testimonial.name}</p>
                  <p className="text-sm text-muted">{testimonial.role}</p>
                </div>
              </figcaption>
            </figure>
          ))}
        </div>
      </div>
    </section>
  );
}
