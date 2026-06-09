import { SiteFooter } from "@/components/footer/site-footer";
import { PageHero, PageSection } from "@/components/marketing/page-layout";
import { ContactForm } from "./contact-form";

const channels = [
  ["Support", "support@tugetha.co.ke"],
  ["Partnerships", "partners@tugetha.co.ke"],
  ["Business inquiries", "hello@tugetha.co.ke"],
];

export default function ContactPage() {
  return (
    <main className="min-h-screen bg-cream text-ink">
      <PageHero
        eyebrow="Contact"
        title="Talk to the Tugetha team."
        body="Reach us for support, partnerships, business inquiries or early customer conversations."
      />

      <PageSection className="bg-white">
        <div className="grid gap-10 lg:grid-cols-[0.8fr_1.2fr]">
          <div className="space-y-4">
            {channels.map(([label, email]) => (
              <a
                className="block rounded-lg border border-line bg-cream p-5 hover:border-primary"
                href={`mailto:${email}`}
                key={label}
              >
                <p className="font-bold">{label}</p>
                <p className="mt-1 text-sm text-muted">{email}</p>
              </a>
            ))}
          </div>
          <ContactForm />
        </div>
      </PageSection>

      <SiteFooter />
    </main>
  );
}
