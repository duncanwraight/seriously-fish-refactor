# Phase 1: Core Foundation (MVP)

**Goal**: Basic functional website with content browsing and user management

## Technical Architecture & Database
- [ ] PostgreSQL schema design with multilingual support following TT-Reviews patterns
- [ ] MySQL to PostgreSQL migration scripts and data validation
- [ ] DatabaseService class implementation with request correlation
- [ ] Supabase client factory (regular + admin clients)
- [ ] Request correlation middleware (`withLoaderCorrelation`)
- [ ] Structured logging service with correlation context

## Authentication & Security
- [ ] User authentication system (Supabase Auth)
- [ ] User role system (Visitor, Verified, Moderator, Admin)
- [ ] Rate limiting implementation for all endpoints
- [ ] CSRF protection for state-changing operations
- [ ] Security headers and secure response patterns

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

## Testing & Deployment
- [ ] Minimal smoke testing setup (Vitest)
- [ ] Basic deployment pipeline (GitHub Actions)
- [ ] Development environment configuration