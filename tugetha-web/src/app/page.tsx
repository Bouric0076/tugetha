import { SiteFooter } from "@/components/footer/site-footer";
import { FinalCta } from "@/sections/cta/final-cta";
import { FeaturePillars } from "@/sections/features/feature-pillars";
import { HowItWorks } from "@/sections/features/how-it-works";
import { HeroSection } from "@/sections/hero/hero-section";
import { ScenariosSection } from "@/sections/scenarios/scenarios-section";
import { TestimonialsSection } from "@/sections/testimonials/testimonials-section";
import { TrustSection } from "@/sections/trust/trust-section";

export default function Home() {
  return (
    <main className="min-h-screen overflow-hidden bg-cream text-ink">
      <HeroSection />
      <HowItWorks />
      <FeaturePillars />
      <ScenariosSection />
      <TrustSection />
      <TestimonialsSection />
      <FinalCta />
      <SiteFooter />
    </main>
  );
}
