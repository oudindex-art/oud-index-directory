// Login page disabled — directory-only model (no merchant accounts)
import { redirect } from "next/navigation";

export const dynamic = "force-dynamic";

export default function LoginPage() {
  redirect("/");
}
