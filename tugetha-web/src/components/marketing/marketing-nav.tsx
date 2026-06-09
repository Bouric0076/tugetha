import Image from "next/image";
import Link from "next/link";

const navLinks = [
  { href: "/#features", label: "Features" },
  { href: "/#how-it-works", label: "How it works" },
  { href: "/trust", label: "Trust" },
  { href: "/security", label: "Security" },
  { href: "/about", label: "About" },
];

export function MarketingNav() {
  return (
    <nav className="mx-auto flex w-full max-w-7xl items-center justify-between px-6 py-6 lg:px-10">
      <Link href="/" className="flex items-center" aria-label="Tugetha home">
        <Image
          alt="Tugetha"
          className="h-auto w-36"
          height={72}
          priority
          src="/brand/tugetha-logo.png"
          width={260}
        />
      </Link>

      <div className="hidden items-center gap-8 text-sm font-semibold text-muted lg:flex">
        {navLinks.map((link) => (
          <Link className="hover:text-primary" href={link.href} key={link.href}>
            {link.label}
          </Link>
        ))}
      </div>

      <Link
        href="/waitlist"
        className="rounded-lg bg-primary px-5 py-3 text-sm font-semibold text-white hover:bg-ink"
      >
        Join waitlist
      </Link>
    </nav>
  );
}
