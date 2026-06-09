import Image from "next/image";
import { MarketingNav } from "./marketing-nav";

type PageHeroProps = {
  eyebrow: string;
  title: string;
  body: string;
  image?: boolean;
};

export function PageHero({ eyebrow, title, body, image }: PageHeroProps) {
  return (
    <header className="bg-cream">
      <MarketingNav />
      <div className="mx-auto grid max-w-7xl gap-12 px-6 pb-24 pt-14 lg:grid-cols-[0.9fr_1.1fr] lg:items-center lg:px-10">
        <div className="min-w-0">
          <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
            {eyebrow}
          </p>
          <h1 className="mt-5 max-w-4xl text-5xl font-extrabold leading-[1.05] text-ink md:text-7xl">
            {title}
          </h1>
          <p className="mt-7 max-w-2xl text-lg leading-8 text-muted md:text-xl md:leading-9">
            {body}
          </p>
        </div>
        {image ? (
          <div className="min-w-0 overflow-hidden rounded-lg border border-line bg-white">
            <Image
              alt="Tugetha shared money circle product visual"
              className="h-auto w-full"
              height={900}
              priority
              src="/brand/tugetha-3d-circle.png"
              width={1800}
            />
          </div>
        ) : (
          <div className="min-w-0 rounded-lg border border-line bg-white p-8">
            <div className="grid gap-4">
              {[
                "Shared visibility",
                "Secure payments",
                "Transparent records",
              ].map((item, index) => (
                <div
                  className="flex items-center justify-between border-b border-line pb-4 last:border-b-0 last:pb-0"
                  key={item}
                >
                  <div>
                    <p className="font-bold text-ink">{item}</p>
                    <p className="mt-1 text-sm text-muted">
                      Built for circles that manage money together.
                    </p>
                  </div>
                  <span className="text-sm font-extrabold text-primary">
                    0{index + 1}
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </header>
  );
}

export function PageSection({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <section className={`px-6 py-24 lg:px-10 ${className}`}>
      <div className="mx-auto min-w-0 max-w-7xl">{children}</div>
    </section>
  );
}
