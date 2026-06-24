import Image from "next/image";
import Link from "next/link";

type FooterColumn = {
  title: string;
  links: Array<{ label: string; href: string }>;
};

const columns: FooterColumn[] = [
  {
    title: "Product",
    links: [
      { label: "Features", href: "/#features" },
      { label: "How it works", href: "/#how-it-works" },
      { label: "Use cases", href: "/#scenarios" },
      { label: "Waitlist", href: "/waitlist" },
    ],
  },
  {
    title: "Company",
    links: [
      { label: "About", href: "/about" },
      { label: "Contact", href: "/contact" },
      { label: "Trust Center", href: "/trust" },
    ],
  },
  {
    title: "Legal",
    links: [
      { label: "Privacy Policy", href: "/privacy" },
      { label: "Terms of Service", href: "/terms" },
      { label: "Security", href: "/security" },
    ],
  },
  {
    title: "Social",
    links: [
      { label: "Instagram", href: "#" },
      { label: "X", href: "#" },
      { label: "LinkedIn", href: "#" },
    ],
  },
];

export function SiteFooter() {
  return (
    <footer className="border-t border-line bg-white px-6 py-14 lg:px-10">
      <div className="mx-auto grid max-w-7xl gap-12 md:grid-cols-[1.2fr_2fr]">
        <div>
          <div className="inline-flex rounded-lg border border-line bg-white px-3 py-2">
            <Image
              alt="Tugetha"
              className="h-auto w-[128px]"
              height={72}
              src="/brand/tugetha-logo.png"
              width={260}
            />
          </div>
          <p className="mt-5 max-w-xs text-sm leading-6 text-muted">
            The trusted circle for shared money goals.
          </p>
        </div>

        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {columns.map((column) => (
            <div key={column.title}>
              <p className="text-sm font-semibold text-ink">{column.title}</p>
              <div className="mt-4 space-y-3">
                {column.links.map((link) => (
                  <Link
                    className="block text-sm font-medium text-muted hover:text-ink"
                    href={link.href}
                    key={link.label}
                  >
                    {link.label}
                  </Link>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="mx-auto mt-14 max-w-7xl border-t border-line pt-6 text-sm text-muted">
        © {new Date().getFullYear()} Tugetha. Built by Sinaps Technology.
      </div>
    </footer>
  );
}
