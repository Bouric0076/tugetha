import { SiteFooter } from "@/components/footer/site-footer";
import { PageHero, PageSection } from "@/components/marketing/page-layout";
import { WaitlistForm } from "./waitlist-form";

export default function WaitlistPage() {
  return (
    <main className="min-h-screen bg-cream text-ink">
      <PageHero
        eyebrow="Join the waitlist"
        title="Be first to build your trusted money circle."
        body="Tell us who you are and how you plan to use Tugetha. We will use this to prioritize early access groups."
        image
      />

      <PageSection className="bg-white">
        <div className="grid gap-10 lg:grid-cols-[0.75fr_1.25fr]">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
              Early access
            </p>
            <h2 className="mt-4 text-4xl font-extrabold leading-tight">
              Designed for circles that already move money together.
            </h2>
            <p className="mt-6 leading-8 text-muted">
              Chamas, families, trip groups, school-fee groups and welfare funds
              are the first circles we want to learn from.
            </p>
          </div>
          <WaitlistForm />
        </div>
      </PageSection>

      <SiteFooter />
    </main>
  );
}
