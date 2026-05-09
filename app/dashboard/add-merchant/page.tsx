// نموذج إضافة تاجر جديد
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import AddMerchantForm from "@/components/AddMerchantForm";

export const dynamic = "force-dynamic";

export default async function AddMerchantPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login?next=/dashboard/add-merchant");

  return (
    <>
      <section className="merchant-hero">
        <div className="container">
          <div style={{ marginBottom: 12 }}>
            <Link href="/dashboard" style={{ color: "var(--dim)", fontSize: 12, letterSpacing: "0.1em" }}>
              ← لوحة التحكم
            </Link>
          </div>
          <h1>أضف متجرك</h1>
          <div className="en-name">Add Your Shop</div>
          <p style={{ color: "var(--dim)", fontSize: 14, lineHeight: 1.85, maxWidth: 640, marginTop: 16 }}>
            مجاني تماماً. سيظهر متجرك بشارة "غير موثّق" حتى تستكملي خطوات التحقق (السجل التجاري + مكالمة فيديو قصيرة).
          </p>
        </div>
      </section>

      <section className="container" style={{ paddingTop: 40, maxWidth: 640 }}>
        <AddMerchantForm userId={user.id} />
      </section>
    </>
  );
}
