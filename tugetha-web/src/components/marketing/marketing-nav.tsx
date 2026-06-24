import Image from "next/image";
import Link from "next/link";

const navLinks = [
  { href: "/#features", label: "Features" },
  { href: "/#how-it-works", label: "How it works" },
  { href: "/trust", label: "Trust" },
  { href: "/security", label: "Security" },
  { href: "/about", label: "About" },
];

type MarketingNavProps = {
  tone?: "light" | "dark";
};

export function MarketingNav({ tone = "light" }: MarketingNavProps) {
  const isDark = tone === "dark";

  return (
    <nav className="mx-auto flex w-full max-w-7xl items-center justify-between px-6 py-5 lg:px-10">
      <Link
        href="/"
        className="flex items-center rounded-lg border border-line bg-white px-3 py-2"
        aria-label="Tugetha home"
      >
        <Image
          alt="Tugetha"
          className="h-auto w-[128px]"
          height={72}
          priority
          src="/brand/tugetha-logo.png"
          width={260}
        />
      </Link>

      <div
        className={`hidden items-center gap-8 text-sm font-medium lg:flex ${
          isDark ? "text-white" : "text-muted"
        }`}
      >
        {navLinks.map((link) => (
          <Link
            className={isDark ? "hover:text-gold" : "hover:text-ink"}
            href={link.href}
            key={link.href}
          >
            {link.label}
          </Link>
        ))}
      </div>

      <Link
        href="/waitlist"
        className={`inline-flex min-h-11 items-center rounded-lg px-5 text-sm font-semibold ${
          isDark
            ? "bg-white text-primary hover:bg-gold hover:text-ink"
            : "bg-primary text-white hover:bg-ink"
        }`}
      >
        Join waitlist
      </Link>
    </nav>
  );
}
