import { SiteFooter } from "@/components/footer/site-footer";
import { PageSection, PhotoPageHero } from "@/components/marketing/page-layout";

const problems = [
  "WhatsApp groups where contribution records disappear",
  "Chamas that rely on manual books and screenshots",
  "Family funds coordinated across many people",
  "Trip contributions that need trust before booking",
  "School fee goals that need early visibility",
];

export default function AboutPage() {
  return (
    <main className="min-h-screen bg-cream text-ink">
      <PhotoPageHero
        eyebrow="About Tugetha"
        title="Built for the money circles people already trust."
        body="Tugetha exists to help friends, families and chama groups manage shared money with the clarity they expect from a serious financial platform."
        imageAlt="Community members standing together as a trusted circle"
        imageSrc="/brand/tugetha-community-members.jpg"
      />

      <PageSection className="bg-white">
        <div className="grid gap-12 lg:grid-cols-[0.8fr_1.2fr]">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
              Why it exists
            </p>
            <h2 className="mt-4 text-4xl font-bold leading-tight md:text-5xl">
              Group money should not depend on memory.
            </h2>
          </div>
          <div className="grid gap-4">
            {problems.map((problem) => (
              <div
                className="rounded-lg border border-line bg-cream p-5 text-lg font-semibold"
                key={problem}
              >
                {problem}
              </div>
            ))}
          </div>
        </div>
      </PageSection>

      <PageSection>
        <div className="grid gap-10 rounded-lg border border-line bg-white p-8 lg:grid-cols-2 lg:p-12">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
              Mission
            </p>
            <h2 className="mt-4 text-4xl font-bold leading-tight">
              Helping trusted circles manage money transparently.
            </h2>
          </div>
          <p className="text-lg leading-8 text-muted">
            Tugetha does not replace community trust. It gives that trust a
            structure: shared goals, visible contributions, recorded activity
            and accountable lending. The result is less chasing, fewer disputes
            and more confidence when people pool money together.
          </p>
        </div>
      </PageSection>

      <SiteFooter />
    </main>
  );
}
