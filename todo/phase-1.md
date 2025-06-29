# Phase 1: Core Foundation (MVP)

**Goal**: Basic functional website with content browsing and user management

## ✅ Completed
- [x] React Router v7 application structure with file-based routing
- [x] Package.json with latest dependencies (@react-router/fs-routes, @supabase/ssr, etc.)
- [x] Wrangler.toml configuration for three environments (local/dev/prod)
- [x] TypeScript configuration with path mapping
- [x] Vite configuration with Cloudflare and React Router plugins
- [x] Environment variables template (.dev.vars.example)
- [x] Basic app directory structure (/components/ui/, /lib/, /routes/)
- [x] Root layout component with error boundary
- [x] Simple homepage and favicon handling
- [x] Comprehensive .gitignore following tt-reviews patterns

## 🚀 Priority: Deployment Pipeline
- [ ] GitHub Actions workflow for automatic dev deployment
- [ ] GitHub Actions workflow for manual production deployment  
- [ ] Environment secrets configuration in GitHub
- [ ] Test deployment to dev environment
- [ ] Verify custom domain routing (dev.seriouslyfish.com)

## Database & Authentication Foundation
- [ ] Supabase local setup with Docker containers
- [ ] PostgreSQL schema design with multilingual support following TT-Reviews patterns
- [ ] Supabase client factory (regular + admin clients) in /app/lib/supabase.server.ts
- [ ] User authentication system (Supabase Auth)
- [ ] User role system (Visitor, Verified, Moderator, Admin)
- [ ] Request correlation middleware (`withLoaderCorrelation`)
- [ ] Structured logging service with correlation context

## Content Display & Navigation
- [ ] Species profile display with taxonomic hierarchy
- [ ] Basic taxonomic navigation (family/genus browsing)
- [ ] Homepage with knowledge base integration
- [ ] Mobile-first responsive design implementation
- [ ] Custom 404 and error pages

## Essential Features
- [ ] Real-time search bar with categorized dropdown results
- [ ] Zod schema validation system matching database structure
- [ ] Image upload, storage (R2), and display with required metadata
- [ ] Basic rich text editing (Tiptap) with three input types
- [ ] Schema service for structured data generation (Animal schema, breadcrumbs)
- [ ] Enhanced SEO meta generation with scientific content

## Security & Performance
- [ ] Rate limiting implementation for all endpoints
- [ ] CSRF protection for state-changing operations
- [ ] Security headers and secure response patterns
- [ ] Minimal smoke testing setup (Vitest)

## Data Migration Preparation
- [ ] MySQL to PostgreSQL migration scripts and data validation
- [ ] DatabaseService class implementation with request correlation