import { SiteFooter } from "@/components/footer/site-footer";
import { CompactPageHero, PageSection } from "@/components/marketing/page-layout";

const securityItems = [
  {
    title: "Data security",
    text: "Circle records are treated as sensitive financial information, with access scoped to the people who need visibility.",
  },
  {
    title: "Payment security",
    text: "Contribution and repayment flows are designed around traceability, confirmation and clear transaction status.",
  },
  {
    title: "Privacy",
    text: "Member information should support accountability without exposing private data outside the circle context.",
  },
  {
    title: "Accountability",
    text: "Every important money movement should leave a record that members can understand later.",
  },
];

export default function SecurityPage() {
  return (
    <main className="min-h-screen bg-cream text-ink">
      <CompactPageHero
        eyebrow="Security"
        title="Financial confidence starts with protection."
        body="Tugetha is designed for shared money, so security, privacy and records are treated as core product requirements."
      />

      <PageSection className="bg-white">
        <div className="grid gap-5 md:grid-cols-2">
          {securityItems.map((item) => (
            <article
              className="rounded-lg border border-line bg-cream p-7"
              key={item.title}
            >
              <h2 className="text-2xl font-semibold">{item.title}</h2>
              <p className="mt-4 leading-7 text-muted">{item.text}</p>
            </article>
          ))}
        </div>
      </PageSection>

      <PageSection>
        <div className="rounded-lg border border-primary-light bg-ink p-8 text-white lg:p-12">
          <p className="text-xs font-semibold uppercase tracking-[0.16em] text-gold">
            Security posture
          </p>
          <h2 className="mt-4 max-w-3xl text-4xl font-bold leading-tight">
            Trustworthy groups need records that are clear before, during and
            after money moves.
          </h2>
        </div>
      </PageSection>

      <SiteFooter />
    </main>
  );
}
