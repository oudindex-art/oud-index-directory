import Link from "next/link";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="container">
        <Link href="/" className="logo">
          <svg className="logo-mark" viewBox="0 0 220 220" xmlns="http://www.w3.org/2000/svg" style={{ width: 36, height: 36 }}>
            <polygon points="110,18 195,63 195,157 110,202 25,157 25,63" stroke="#C4882A" strokeWidth="1.5" fill="none" />
            <text x="110" y="125" textAnchor="middle" fontFamily="Cinzel, serif" fontSize="56" fontWeight="700" fill="#C4882A" letterSpacing="2">OI</text>
          </svg>
          <div className="logo-text">
            <span className="en">OUD INDEX</span>
            <span className="ar">مؤشر العود</span>
          </div>
        </Link>
        <p>The Global Agarwood Reference · المرجع العالمي للعود</p>
        <div className="links">
          <Link href="/">الأسعار</Link>
          <Link href="/directory">دليل التجار</Link>
          <Link href="/#how">كيف يعمل؟</Link>
          <Link href="/privacy">سياسة الخصوصية</Link>
        </div>
        <p style={{ marginTop: 12, opacity: 0.7 }}>
          © {new Date().getFullYear()} Oud Index · جميع الحقوق محفوظة
        </p>
      </div>
    </footer>
  );
}
