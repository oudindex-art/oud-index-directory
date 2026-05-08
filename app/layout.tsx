import type { Metadata } from "next";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || "https://oudindex.com"),
  title: {
    default: "Oud Index | مؤشر العود — الدليل العالمي لتجار العود",
    template: "%s | Oud Index",
  },
  description: "الدليل العالمي الأول لتجار العود. تقييمات حقيقية، أسعار يومية، ومرجع موثوق لجودة العود حول العالم.",
  keywords: ["عود","دهن العود","تاجر عود","عود كمبودي","عود هندي","عود فيتنامي","Oud","Agarwood","oud merchants"],
  openGraph: {
    type: "website",
    locale: "ar_SA",
    siteName: "Oud Index | مؤشر العود",
    title: "Oud Index — الدليل العالمي لتجار العود",
    description: "تقييمات حقيقية من عملاء حقيقيين. ابحث، قارن، واختر بثقة من بين أبرز بيوت العود في العالم.",
  },
  twitter: { card: "summary_large_image" },
  robots: { index: true, follow: true },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ar" dir="rtl">
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
