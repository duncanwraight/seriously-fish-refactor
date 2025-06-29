# Instructions for Claude

## Project Commands

### Development
- `npm run dev` - Start React Router development server (local)
- `npm run dev:wrangler` - Start Wrangler development server (Cloudflare Workers local)
- `npm run build` - Build application for production
- `npm run typecheck` - Generate types and run TypeScript checks
- `npm run typegen` - Generate React Router type definitions
- `npm run cf-typegen` - Generate Cloudflare Worker type definitions

### Deployment
- `npm run deploy` - Build and deploy to Cloudflare Workers
- `wrangler deploy --env development` - Deploy to dev environment
- `wrangler deploy --env production` - Deploy to production environment

### Database (Supabase)
- `supabase start` - Start local Supabase Docker containers
- `supabase stop` - Stop local Supabase containers
- `supabase migrations up` - Apply database migrations
- **NEVER run `supabase db reset` without asking first**

### Database (Legacy MySQL Analysis)
- `docker-compose up` - Start legacy MySQL database for migration analysis
- `docker exec -it seriously-fish-mysql mysql -u dev -p` - Access MySQL directly

## Project Naming Convention

- **Project name**: Always use "seriously-fish" (not "seriously-fish-refactor")
- **Repository context**: This repo uses "-refactor" suffix only because original repo exists
- **All code/configs**: Use "seriously-fish" as project name

## Environment Setup

### Three-Environment Architecture
- **Local**: Supabase Docker + `react-router dev` + `.dev.vars` file
- **Dev**: Cloudflare Workers + hosted Supabase + `dev.seriouslyfish.com`
- **Production**: Cloudflare Workers + hosted Supabase + `seriouslyfish.com`

### Environment Variables
- **Local**: Copy `.dev.vars.example` to `.dev.vars`
- **Dev/Prod**: Use `wrangler secret put` for sensitive values
- **Config**: Non-sensitive values in `wrangler.toml`

## React Router v7 Patterns

### File-Based Routing
- Use `@react-router/fs-routes` with `flatRoutes()` for automatic route discovery
- `_index.tsx` for index routes, `$param.tsx` for dynamic routes
- Dot notation for nested routes (`parent.child.tsx`)
- Layout components with `<Outlet />` for child routes

### Dependencies
- Use latest React Router v7.5+ with `react-router` main package
- Include `@react-router/fs-routes` for file-based routing
- Use `@react-router/cloudflare` for Workers integration

## TypeScript Standards

- **Interfaces**: PascalCase for interfaces/types, camelCase for variables/functions
- **Props**: Strong TypeScript interfaces for all component props
- **Booleans**: Use `is`, `has`, `should` prefixes (`isModalOpen`, `hasError`)
- **Path mapping**: Use `~/*` imports for app directory

## Component Conventions

- **Files**: PascalCase (`UserProfile.tsx`)
- **Names**: PascalCase matching file names
- **Structure**: Break large JSX into focused, reusable components
- **Composition**: Prefer composition over monolithic components

### Directory Structure
- `/app/components/ui/` - Reusable UI components
- `/app/components/[feature]/` - Feature-specific components
- `/app/lib/` - Server utilities (auth, database, etc.)
- `/app/routes/` - File-based routes

## Supabase Authentication

### Server-Side Rendering
- Use `@supabase/ssr` package for SSR compatibility
- Use `getServerClient` only in route loaders for auth checks
- Use `createBrowserClient` for all client-side auth operations

### Auth Patterns
- Regular HTML `<form>` elements (NOT React Router `<Form>`)
- Handle form submission with `onSubmit` handlers and `FormData`
- **NEVER mix server-side and client-side auth in same component**

### Reference Files
- Server setup: `../tt-reviews/app/lib/supabase.server.ts`
- Auth utilities: `../tt-reviews/app/lib/auth.server.ts`
- Login example: `../tt-reviews/app/routes/login.tsx`
- Protected route: `../tt-reviews/app/routes/profile.tsx`

## Build & Development Tooling

### Vite Configuration
- Use `@cloudflare/vite-plugin` for Workers integration
- Use `vite-tsconfig-paths` for TypeScript path mapping
- Use `reactRouter()` plugin for React Router v7

### Type Generation
- Run `npm run cf-typegen` to generate Cloudflare Worker types
- Use `isbot` package for server rendering optimization
- Auto-generate types with `postinstall` script

## Development Workflow

### Permissions Not Required
- Reading/searching/analyzing existing files
- Updating markdown files in `discovery/`, `docs/`, `todo/`
- Examining schema via docker-compose MySQL container
- Git operations: `add`, `push`, `status`, `diff`, `log`
- Package operations: `npm install`, `npm run` commands
- Database reads: SELECT queries via docker exec
- Supabase migrations: `supabase migrations up` only

### Permissions Required
- Creating/editing/deleting application code
- Database writes: INSERT, UPDATE, DELETE operations
- Git commits
- System configuration changes
- Destructive database operations (especially `supabase db reset`)

### Workflow Rules
- Follow 4-phase development approach in `todo/` directory
- Keep TODO markdown files updated before git commits
- Store temporary scripts in `/scripts/` directory
- Clean up one-time scripts after use

## Key Project Documents

- **Requirements**: `discovery/REQUIREMENTS.md` - Project vision and specifications
- **Database Migration**: `discovery/DATABASE_MIGRATION_REQUIREMENTS.md` - MySQL to PostgreSQL strategy
- **Development Phases**: `todo/` - Phase-by-phase implementation plan
- **Design Concepts**: `discovery/design/` - Visual design ideas
- **Wireframes**: `discovery/wireframes/` - Homepage concepts

## Legacy Database Analysis

### Purpose
- `docker-compose.yml` spins up sanitized MySQL from existing seriouslyfish.com
- Analyze existing data structure for PostgreSQL migration strategy
- Explore schema with `docker exec` commands

### Usage
- `docker-compose up` to start MySQL container
- Archive: `archive/db/sf-db-sanitized.sql.gz` contains sanitized dump
- Use for migration planning only, not development database