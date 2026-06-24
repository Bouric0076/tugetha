import Image from "next/image";
import { MarketingNav } from "./marketing-nav";

type PageHeroProps = {
  eyebrow: string;
  title: string;
  body: string;
  image?: boolean;
};

type PhotoPageHeroProps = {
  eyebrow: string;
  title: string;
  body: string;
  imageSrc: string;
  imageAlt: string;
};

export function PageHero({ eyebrow, title, body, image }: PageHeroProps) {
  return (
    <header className="bg-cream">
      <MarketingNav />
      <div className="mx-auto grid max-w-7xl gap-12 px-6 pb-24 pt-14 lg:grid-cols-[0.9fr_1.1fr] lg:items-center lg:px-10">
        <div className="min-w-0">
          <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
            {eyebrow}
          </p>
          <h1 className="mt-5 max-w-4xl text-5xl font-bold leading-[1.05] text-ink md:text-7xl">
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
              src="/brand/tugetha-product-visual.png"
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
                    <p className="font-semibold text-ink">{item}</p>
                    <p className="mt-1 text-sm text-muted">
                      Built for circles that manage money together.
                    </p>
                  </div>
                  <span className="text-sm font-semibold text-primary">
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

export function PhotoPageHero({
  eyebrow,
  title,
  body,
  imageSrc,
  imageAlt,
}: PhotoPageHeroProps) {
  return (
    <header className="relative min-h-[640px] overflow-hidden bg-ink text-white">
      <Image
        alt={imageAlt}
        className="object-cover object-center"
        fill
        priority
        sizes="100vw"
        src={imageSrc}
      />
      <div className="absolute inset-0 bg-[var(--hero-overlay)]" />
      <div className="relative z-10">
        <MarketingNav tone="dark" />
        <div className="mx-auto flex min-h-[520px] max-w-7xl items-center px-6 pb-20 pt-14 lg:px-10">
          <div className="max-w-4xl">
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-gold">
              {eyebrow}
            </p>
            <h1 className="mt-5 max-w-4xl text-5xl font-bold leading-[1.05] md:text-7xl">
              {title}
            </h1>
            <p className="mt-7 max-w-2xl text-lg leading-8 text-neutral md:text-xl md:leading-9">
              {body}
            </p>
          </div>
        </div>
      </div>
    </header>
  );
}

export function CompactPageHero({
  eyebrow,
  title,
  body,
}: Omit<PageHeroProps, "image">) {
  return (
    <header className="bg-cream">
      <MarketingNav />
      <div className="mx-auto max-w-7xl px-6 pb-20 pt-14 lg:px-10">
        <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
          {eyebrow}
        </p>
        <h1 className="mt-5 max-w-4xl text-5xl font-bold leading-[1.05] text-ink md:text-7xl">
          {title}
        </h1>
        <p className="mt-7 max-w-2xl text-lg leading-8 text-muted md:text-xl md:leading-9">
          {body}
        </p>
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
