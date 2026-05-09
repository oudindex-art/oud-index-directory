import Link from "next/link";
import { createClient } from "@/lib/supabase/server";

export default async function Header() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();

  let isAdmin = false;
  let isMerchant = false;
  if (user) {
    const { data } = await supabase
      .from("profiles")
      .select("is_admin, is_merchant")
      .eq("id", user.id)
      .single();
    isAdmin = data?.is_admin ?? false;
    isMerchant = data?.is_merchant ?? false;
  }

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
          {!user ? (
            <>
              <Link href="/login" className="btn btn-ghost">دخول</Link>
              <Link href="/register?merchant=1" className="btn">أضف متجرك</Link>
            </>
          ) : (
            <>
              {isAdmin && (
                <Link href="/admin" className="btn btn-ghost">الأدمن</Link>
              )}
              <Link href="/dashboard" className="btn btn-ghost">
                {isMerchant ? "متجري" : "حسابي"}
              </Link>
              <form action="/auth/signout" method="post" style={{ display: "inline" }}>
                <button type="submit" className="btn" style={{ borderColor: "var(--down)", color: "var(--down)" }}>
                  خروج
                </button>
              </form>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
