import { SiteFooter } from "@/components/footer/site-footer";
import { MarketingNav } from "@/components/marketing/marketing-nav";
import { PageSection } from "@/components/marketing/page-layout";
import { WaitlistForm } from "./waitlist-form";

const reasons = [
  "Shared contribution records",
  "Clear group goals",
  "Accountable lending flows",
];

export default function WaitlistPage() {
  return (
    <main className="min-h-screen bg-cream text-ink">
      <header className="bg-cream">
        <MarketingNav />
        <div className="mx-auto grid max-w-7xl gap-12 px-6 pb-20 pt-14 lg:grid-cols-[0.85fr_1.15fr] lg:items-center lg:px-10">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
              Join the waitlist
            </p>
            <h1 className="mt-5 max-w-4xl text-5xl font-bold leading-[1.05] text-ink md:text-7xl">
              Be first to build your trusted money circle.
            </h1>
            <p className="mt-7 max-w-2xl text-lg leading-8 text-muted md:text-xl md:leading-9">
              Tell us who you are and how you plan to use Tugetha. We will use
              this to prioritize early access groups.
            </p>
            <div className="mt-10 divide-y divide-line rounded-lg border border-line bg-white">
              {reasons.map((reason) => (
                <div className="px-5 py-4 font-semibold" key={reason}>
                  {reason}
                </div>
              ))}
            </div>
          </div>
          <WaitlistForm />
        </div>
      </header>

      <PageSection className="bg-white">
        <div className="grid gap-10 rounded-lg border border-line bg-cream p-8 lg:grid-cols-[0.75fr_1.25fr] lg:p-12">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
              Early access
            </p>
            <h2 className="mt-4 text-4xl font-bold leading-tight">
              Designed for circles that already move money together.
            </h2>
          </div>
          <p className="leading-8 text-muted">
              Chamas, families, trip groups, school-fee groups and welfare funds
              are the first circles we want to learn from.
          </p>
        </div>
      </PageSection>

      <SiteFooter />
    </main>
  );
}
