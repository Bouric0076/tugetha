import { SiteFooter } from "@/components/footer/site-footer";
import { CompactPageHero, PageSection } from "@/components/marketing/page-layout";

const sections = [
  ["Information we collect", "We collect the details needed to provide early access, communicate with interested users and understand how groups want to use Tugetha."],
  ["How we use information", "We use information to respond to inquiries, manage the waitlist, improve the product and prepare relevant onboarding support."],
  ["Data sharing", "We do not sell personal information. Service providers may process information only to help operate Tugetha."],
  ["Your choices", "You can request correction or deletion of your waitlist/contact information by emailing hello@tugetha.co.ke."],
];

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-cream text-ink">
      <CompactPageHero
        eyebrow="Privacy Policy"
        title="Privacy should support trust, not create confusion."
        body="This launch-stage policy explains how Tugetha handles waitlist and contact information before the full product is publicly available."
      />
      <PageSection className="bg-white">
        <div className="space-y-5">
          {sections.map(([title, text]) => (
            <section className="rounded-lg border border-line bg-cream p-6" key={title}>
              <h2 className="text-2xl font-semibold">{title}</h2>
              <p className="mt-3 leading-7 text-muted">{text}</p>
            </section>
          ))}
        </div>
      </PageSection>
      <SiteFooter />
    </main>
  );
}
