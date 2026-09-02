import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Jan Setu — Jharkhand's Societal Innovation OS",
    template: "%s · Jan Setu",
  },
  description:
    "Jan Setu connects students, citizens, institutions and industry across Jharkhand to surface societal challenges, form teams, and ship measurable impact.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html className={`${inter.variable} h-full antialiased`} lang="en">
      <body className="min-h-full font-sans">{children}</body>
    </html>
  );
}
