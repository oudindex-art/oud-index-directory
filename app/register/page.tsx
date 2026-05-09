"use client";
import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";

export default function RegisterPage() {
  const router = useRouter();
  const params = useSearchParams();
  const next = params.get("next") || "/";
  const asMerchant = params.get("merchant") === "1";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const supabase = createClient();

  async function signUp(e: React.FormEvent) {
    e.preventDefault();
    setErr(null);
    setLoading(true);

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: `${window.location.origin}/auth/callback?next=${encodeURIComponent(next)}`,
        data: { full_name: name, is_merchant: asMerchant },
      },
    });

    setLoading(false);
    if (error) {
      setErr(error.message);
      return;
    }

    if (data.user && !data.session) {
      // Email confirmation required
      setSuccess(true);
    } else if (data.session) {
      // Auto-login (if email confirmation disabled)
      router.push(asMerchant ? "/dashboard/add-merchant" : next);
      router.refresh();
    }
  }

  async function signUpWithGoogle() {
    setErr(null);
    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback?next=${encodeURIComponent(asMerchant ? "/dashboard/add-merchant" : next)}`,
      },
    });
    if (error) setErr(error.message);
  }

  if (success) {
    return (
      <section className="hero" style={{ paddingBottom: 80 }}>
        <div className="container" style={{ maxWidth: 480 }}>
          <div className="hero-eyebrow" style={{ color: "var(--up)", borderColor: "var(--up)" }}>✓ Check Your Email</div>
          <h1 style={{ fontSize: "28px", marginBottom: 12 }}>تم إرسال رابط التحقق</h1>
          <p className="lead" style={{ marginBottom: 30 }}>
            افتح إيميلك <strong style={{ color: "var(--cream)" }}>{email}</strong> واضغط رابط التفعيل لتسجيل الدخول. لو لم تجدي الرسالة، تحققي من البريد المزعج.
          </p>
          <Link href="/login" className="btn btn-ghost">العودة لتسجيل الدخول</Link>
        </div>
      </section>
    );
  }

  return (
    <section className="hero" style={{ paddingBottom: 80 }}>
      <div className="container" style={{ maxWidth: 480 }}>
        <div className="hero-eyebrow">{asMerchant ? "Merchant Registration · تسجيل تاجر" : "Create Account · إنشاء حساب"}</div>
        <h1 style={{ fontSize: "30px", marginBottom: 8 }}>{asMerchant ? "Add Your Shop" : "Join Oud Index"}</h1>
        <div className="ar-title" style={{ fontSize: "20px", marginBottom: 30 }}>
          {asMerchant ? "أضف متجرك إلى الدليل" : "انضم إلى مؤشر العود"}
        </div>

        {err && (
          <div style={{ background: "rgba(224,112,112,0.1)", border: "0.5px solid var(--down)", color: "var(--down)", padding: "12px 16px", marginBottom: 20, fontSize: 13, textAlign: "right" }}>
            {err}
          </div>
        )}

        <form onSubmit={signUp} className="form-section" style={{ textAlign: "right" }}>
          <h3>التسجيل بالإيميل</h3>
          <div className="field">
            <label>الاسم الكامل</label>
            <input type="text" required value={name} onChange={(e) => setName(e.target.value)} placeholder="مثال: مريم العتيبي" />
          </div>
          <div className="field">
            <label>الإيميل</label>
            <input type="email" required value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@example.com" dir="ltr" style={{ textAlign: "left" }} />
          </div>
          <div className="field">
            <label>كلمة سر (٦ أحرف على الأقل)</label>
            <input type="password" required minLength={6} value={password} onChange={(e) => setPassword(e.target.value)} dir="ltr" style={{ textAlign: "left" }} />
          </div>
          <button type="submit" className="submit-btn" disabled={loading}>
            {loading ? "..." : "إنشاء الحساب"}
          </button>
          <p className="form-foot">سيصلك إيميل لتفعيل الحساب.</p>
        </form>

        <div style={{ textAlign: "center", margin: "20px 0", color: "var(--dimmer)", fontSize: 11, letterSpacing: "0.2em" }}>
          ── OR ──
        </div>

        <button onClick={signUpWithGoogle} className="btn btn-ghost" style={{ width: "100%", padding: "14px", justifyContent: "center" }}>
          <svg width="18" height="18" viewBox="0 0 24 24" style={{ marginLeft: 8 }}>
            <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
            <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
            <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
            <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
          </svg>
          المتابعة بقوقل
        </button>

        <p style={{ textAlign: "center", marginTop: 30, color: "var(--dim)", fontSize: 13 }}>
          لديك حساب؟{" "}
          <Link href={`/login?next=${encodeURIComponent(next)}`} style={{ color: "var(--gold2)" }}>
            سجّل الدخول
          </Link>
        </p>

        {!asMerchant && (
          <p style={{ textAlign: "center", marginTop: 16, color: "var(--dimmer)", fontSize: 12 }}>
            تاجر؟{" "}
            <Link href="/register?merchant=1" style={{ color: "var(--gold2)" }}>
              سجّل كتاجر
            </Link>
          </p>
        )}
      </div>
    </section>
  );
}
