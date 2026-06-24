import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";

const poppins = localFont({
  variable: "--font-sans",
  src: [
    {
      path: "./fonts/Poppins-Regular.ttf",
      weight: "400",
      style: "normal",
    },
    {
      path: "./fonts/Poppins-Medium.ttf",
      weight: "500",
      style: "normal",
    },
    {
      path: "./fonts/Poppins-SemiBold.ttf",
      weight: "600",
      style: "normal",
    },
    {
      path: "./fonts/Poppins-Bold.ttf",
      weight: "700 800",
      style: "normal",
    },
  ],
});

export const metadata: Metadata = {
  title: "Tugetha | The trusted circle for shared money goals",
  description:
    "Tugetha helps friends, families, and chama groups save together, lend with trust, and achieve shared financial goals.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${poppins.variable} antialiased`}
      data-scroll-behavior="smooth"
    >
      <body className="min-h-screen font-sans">{children}</body>
    </html>
  );
}
