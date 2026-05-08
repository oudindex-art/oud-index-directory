// الصفحة الرئيسية
// ملاحظة: هذه نسخة مبسطة — ستربطين بصفحة الأسعار الموجودة
// أو يمكن تحويلها لصفحة أسعار كاملة في مرحلة لاحقة.
import Link from "next/link";

export default function HomePage() {
  return (
    <>
      <section className="hero">
        <div className="container">
          <div className="hero-eyebrow">Live Oud Price Index · مؤشر أسعار العود</div>
          <h1>The Global <span className="gold">Oud Reference</span></h1>
          <div className="ar-title">المرجع العالمي للعود</div>
          <p className="lead">
            مؤشر أسعار العود اليومي، دليل التجار العالمي، وأدوات التحقق من الجودة —
            في منصة واحدة لتجار وعشاق العود حول العالم.
          </p>

          <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
            <Link href="/directory" className="btn btn-solid">دليل التجار</Link>
            <Link href="/#prices" className="btn">أسعار اليوم</Link>
          </div>
        </div>
      </section>

      <section className="container">
        <div className="sec-head"><h2>Featured Merchants</h2></div>
        <p style={{ color: "var(--dim)", textAlign: "center", padding: "40px 20px" }}>
          استعرضي <Link href="/directory">دليل التجار الكامل</Link> لرؤية كل بيوت العود حول العالم.
        </p>
      </section>
    </>
  );
}
