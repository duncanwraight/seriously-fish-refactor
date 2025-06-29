import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
} from "react-router";

import type { Route } from "./+types/root";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Seriously Fish - Comprehensive Aquatic Life Database" },
    { name: "description", content: "Comprehensive database of tropical fish, marine fish, aquatic plants, and freshwater invertebrates with detailed care guides and scientific information." },
  ];
}

export default function App() {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <Outlet />
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}

export function ErrorBoundary({ error }: Route.ErrorBoundaryArgs) {
  let message = "Oops!";
  let details = "An unexpected error occurred.";
  let stack: string;

  if (error instanceof Error) {
    message = error.message;
    stack = error.stack!;
  } else {
    details = typeof error === "string" ? error : JSON.stringify(error);
  }

  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Oh no!</title>
        <Meta />
        <Links />
      </head>
      <body>
        <main className="container mx-auto p-4">
          <h1 className="text-2xl font-bold mb-4">Something went wrong</h1>
          <details className="whitespace-pre-wrap">
            {stack && (
              <summary className="mb-2">
                <strong>{message}</strong>
              </summary>
            )}
            {details && <div>{details}</div>}
            {stack && <div className="mt-2">{stack}</div>}
          </details>
        </main>
        <Scripts />
      </body>
    </html>
  );
}