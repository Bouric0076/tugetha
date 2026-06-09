"use client";

import { FormEvent, useState } from "react";

const interests = [
  "Chama",
  "Family fund",
  "Travel group",
  "School fees",
  "Welfare fund",
  "Other",
];

export function WaitlistForm() {
  const [status, setStatus] = useState<"idle" | "loading" | "sent" | "error">(
    "idle",
  );

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus("loading");
    const form = event.currentTarget;
    const body = Object.fromEntries(new FormData(form));
    const response = await fetch("/api/waitlist", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    setStatus(response.ok ? "sent" : "error");
    if (response.ok) form.reset();
  }

  return (
    <form className="min-w-0 rounded-lg border border-line bg-cream p-6" onSubmit={onSubmit}>
      <div className="grid min-w-0 gap-4 md:grid-cols-2">
        <input className="min-h-12 min-w-0 rounded-lg border border-line px-4 outline-none focus:border-primary" name="name" placeholder="Name" required />
        <input className="min-h-12 min-w-0 rounded-lg border border-line px-4 outline-none focus:border-primary" name="email" placeholder="Email" required type="email" />
        <input className="min-h-12 min-w-0 rounded-lg border border-line px-4 outline-none focus:border-primary" name="phone" placeholder="Phone" required type="tel" />
        <select className="min-h-12 min-w-0 rounded-lg border border-line px-4 outline-none focus:border-primary" defaultValue="" name="interest" required>
          <option disabled value="">Interest</option>
          {interests.map((interest) => (
            <option key={interest} value={interest}>{interest}</option>
          ))}
        </select>
      </div>
      <textarea className="mt-4 min-h-28 w-full min-w-0 rounded-lg border border-line px-4 py-3 outline-none focus:border-primary" name="notes" placeholder="Tell us about your circle" />
      <button className="mt-5 min-h-12 w-full rounded-lg bg-primary px-6 text-sm font-bold text-white hover:bg-ink" disabled={status === "loading"}>
        {status === "loading" ? "Joining..." : "Join waitlist"}
      </button>
      {status === "sent" ? <p className="mt-4 text-sm font-semibold text-emerald">You are on the list. We will reach out with early access updates.</p> : null}
      {status === "error" ? <p className="mt-4 text-sm font-semibold text-red-700">Could not submit right now. Please email hello@tugetha.co.ke.</p> : null}
    </form>
  );
}
