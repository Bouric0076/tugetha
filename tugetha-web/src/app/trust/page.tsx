import { SiteFooter } from "@/components/footer/site-footer";
import { PageSection, PhotoPageHero } from "@/components/marketing/page-layout";

const trustFlows = [
  ["How contributions are recorded", "Every contribution is attached to a goal, member and activity trail."],
  ["How disputes are handled", "Members can review the same records instead of reconstructing events from chat."],
  ["How repayments work", "Loan terms, status and repayments are visible so lending stays accountable."],
  ["How funds move", "Money movement is designed to be confirmed, traceable and understandable."],
  ["How data is protected", "Circle visibility and privacy are balanced around member trust."],
];

export default function TrustPage() {
  return (
    <main className="min-h-screen bg-cream text-ink">
      <PhotoPageHero
        eyebrow="Trust Center"
        title="The clearest record should be the one everyone shares."
        body="Tugetha’s biggest job is helping people feel confident putting group money into a shared system. The Trust Center explains the records, flows and protections behind that confidence."
        imageAlt="Hands stacked together to represent shared trust and accountability"
        imageSrc="/brand/tugetha-hero-community.jpg"
      />

      <PageSection className="bg-white">
        <div className="grid gap-4">
          {trustFlows.map(([title, text], index) => (
            <article
              className="grid gap-5 rounded-lg border border-line bg-cream p-6 md:grid-cols-[80px_0.8fr_1.2fr] md:items-center"
              key={title}
            >
              <p className="text-2xl font-bold text-primary">
                0{index + 1}
              </p>
              <h2 className="text-2xl font-semibold">{title}</h2>
              <p className="leading-7 text-muted">{text}</p>
            </article>
          ))}
        </div>
      </PageSection>

      <SiteFooter />
    </main>
  );
}
