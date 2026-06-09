import { SiteFooter } from "@/components/footer/site-footer";
import { PageHero, PageSection } from "@/components/marketing/page-layout";

const terms = [
  ["Early access", "Joining the waitlist does not guarantee immediate access. Tugetha may invite groups in phases as the product matures."],
  ["Acceptable use", "Users should provide accurate information and must not use Tugetha for unlawful, fraudulent or misleading activity."],
  ["Financial responsibility", "Tugetha helps circles record and coordinate shared money activity. Members remain responsible for their own financial decisions."],
  ["Changes", "These terms may evolve as Tugetha moves from waitlist to live product. Material changes will be communicated clearly."],
];

export default function TermsPage() {
  return (
    <main className="min-h-screen bg-cream text-ink">
      <PageHero
        eyebrow="Terms of Service"
        title="Clear terms for a product built on shared trust."
        body="These launch-stage terms cover Tugetha’s waitlist, website and early access communications."
      />
      <PageSection className="bg-white">
        <div className="space-y-5">
          {terms.map(([title, text]) => (
            <section className="rounded-lg border border-line bg-cream p-6" key={title}>
              <h2 className="text-2xl font-extrabold">{title}</h2>
              <p className="mt-3 leading-7 text-muted">{text}</p>
            </section>
          ))}
        </div>
      </PageSection>
      <SiteFooter />
    </main>
  );
}
