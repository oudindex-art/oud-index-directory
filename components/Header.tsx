import Link from "next/link";

// Simplified header — no merchant accounts, no merchant login.
// Single CTA: anyone (visitor OR merchant) can suggest/add a merchant via
// /suggest-merchant.html (form goes to admin queue).
export default function Header() {
  return (
    <header className="header">
      <div className="container nav">
        <Link href="/" className="logo">
          <svg className="logo-mark" viewBox="0 0 220 220" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <radialGradient id="hdr-glw" cx="50%" cy="50%" r="50%">
                <stop offset="0%" stopColor="#C4882A" stopOpacity="0.15" />
                <stop offset="100%" stopColor="#C4882A" stopOpacity="0" />
              </radialGradient>
            </defs>
            <circle cx="110" cy="110" r="105" fill="url(#hdr-glw)" />
            <polygon points="110,18 195,63 195,157 110,202 25,157 25,63" stroke="#C4882A" strokeWidth="1.5" fill="none" />
            <polygon points="110,40 173,75 173,145 110,180 47,145 47,75" stroke="#C4882A" strokeWidth="0.8" fill="none" opacity="0.4" />
            <text x="110" y="125" textAnchor="middle" fontFamily="Cinzel, serif" fontSize="56" fontWeight="700" fill="#C4882A" letterSpacing="2">OI</text>
          </svg>
          <div className="logo-text">
            <span className="en">OUD INDEX</span>
            <span className="ar">مؤشر العود</span>
          </div>
        </Link>

        <nav className="nav-links">
          <Link href="https://oudindex.com">الأسعار</Link>
          <Link href="/" className="on">دليل التجار</Link>
          <Link href="/#how">كيف يعمل؟</Link>
        </nav>

        <div className="nav-actions">
          <a href="/suggest-merchant" className="btn">أضف متجرك</a>
        </div>
      </div>
    </header>
  );
}
