import { NextResponse } from "next/server";

const requiredFields = ["name", "email", "phone", "interest"];

export async function POST(request: Request) {
  const body = await request.json();

  for (const field of requiredFields) {
    if (!body[field] || typeof body[field] !== "string") {
      return NextResponse.json({ error: `${field} is required` }, { status: 400 });
    }
  }

  if (process.env.GOOGLE_SHEETS_WEBHOOK_URL) {
    await fetch(process.env.GOOGLE_SHEETS_WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ type: "waitlist", ...body }),
    });
  } else {
    console.info("Tugetha waitlist submission", body);
  }

  return NextResponse.json({ ok: true });
}
