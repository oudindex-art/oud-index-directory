// Register disabled — use /suggest-merchant.html instead
import { redirect } from "next/navigation";

export const dynamic = "force-dynamic";

export default function RegisterPage() {
  redirect("https://oudindex.com/suggest-merchant.html");
}
