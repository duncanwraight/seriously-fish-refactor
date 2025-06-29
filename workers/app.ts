import { createRequestHandler } from "@react-router/cloudflare";
import * as build from "../build/server";

const requestHandler = createRequestHandler(build, "production");

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    try {
      return await requestHandler(request, { cloudflare: { env, ctx } });
    } catch (error) {
      console.error("Worker error:", error);
      return new Response("Internal Server Error", { status: 500 });
    }
  },
} satisfies ExportedHandler<Env>;

interface Env {
  IMAGES: R2Bucket;
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
  SESSION_SECRET: string;
  ADMIN_EMAILS: string;
  DISCORD_WEBHOOK_URL?: string;
  ENVIRONMENT: string;
  SITE_URL: string;
}