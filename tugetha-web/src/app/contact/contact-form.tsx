"use client";

import { FormEvent, useState } from "react";

export function ContactForm() {
  const [status, setStatus] = useState<"idle" | "loading" | "sent" | "error">(
    "idle",
  );

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus("loading");
    const form = event.currentTarget;
    const body = Object.fromEntries(new FormData(form));
    const response = await fetch("/api/contact", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    setStatus(response.ok ? "sent" : "error");
    if (response.ok) form.reset();
  }

  return (
    <form
      className="min-w-0 rounded-lg border border-line bg-cream p-6"
      onSubmit={onSubmit}
    >
      <div className="grid min-w-0 gap-4">
        <label className="grid gap-2 text-sm font-medium text-ink">
          Name
          <input
            className="min-h-12 min-w-0 rounded-lg border border-line bg-white px-4 text-base font-normal outline-none focus:border-primary"
            name="name"
            required
          />
        </label>
        <label className="grid gap-2 text-sm font-medium text-ink">
          Email
          <input
            className="min-h-12 min-w-0 rounded-lg border border-line bg-white px-4 text-base font-normal outline-none focus:border-primary"
            name="email"
            required
            type="email"
          />
        </label>
        <label className="grid gap-2 text-sm font-medium text-ink">
          Message
          <textarea
            className="min-h-36 min-w-0 rounded-lg border border-line bg-white px-4 py-3 text-base font-normal outline-none focus:border-primary"
            name="message"
            required
          />
        </label>
        <button className="min-h-12 rounded-lg bg-primary px-6 text-sm font-semibold text-white hover:bg-ink" disabled={status === "loading"}>
          {status === "loading" ? "Sending..." : "Send message"}
        </button>
        {status === "sent" ? <p className="text-sm font-semibold text-emerald">Message received. We will get back to you.</p> : null}
        {status === "error" ? <p className="text-sm font-semibold text-red-700">Something went wrong. Please email hello@tugetha.co.ke.</p> : null}
      </div>
    </form>
  );
}
