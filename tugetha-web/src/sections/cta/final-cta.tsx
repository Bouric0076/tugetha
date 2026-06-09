import Link from "next/link";

export function FinalCta() {
  return (
    <section id="waitlist" className="bg-cream px-6 py-28 lg:px-10">
      <div className="mx-auto grid max-w-7xl gap-10 rounded-lg bg-ink px-6 py-12 text-white md:px-12 lg:grid-cols-[0.9fr_1.1fr] lg:items-center lg:py-16">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.18em] text-gold">
          Early access
          </p>
          <h2 className="mt-4 max-w-2xl text-4xl font-extrabold leading-tight md:text-5xl">
            Ready to build your trusted money circle?
          </h2>
        </div>
        <div>
          <p className="max-w-2xl text-lg leading-8 text-white/70">
            Join the waitlist and be among the first circles to experience
            Tugetha.
          </p>

          <Link
            className="mt-8 inline-flex min-h-14 items-center justify-center rounded-lg bg-gold px-7 text-sm font-bold text-ink hover:bg-white"
            href="/waitlist"
          >
            Join waitlist
          </Link>
        </div>
      </div>
    </section>
  );
}
