# Instructions for Claude

## Commands & Scripts

### Development Commands (Planned - following tt-reviews patterns)
- `npm run dev` - Start development server
- `npm run build` - Build for production
- NOT YET IMPLEMENTED `npm run lint` - Run linting
- NOT YET IMPLEMENTED `npm run typecheck` - Run TypeScript checks
- NOT YET IMPLEMENTED `npm test` - Run tests

### Database Commands
- `supabase start` - Start local Supabase
- `supabase stop` - Stop local Supabase
- `supabase migrations up` - Apply database migrations
- **NEVER run `supabase db reset` without asking first**

## Code Style & Conventions

### React Router v7 Patterns

**Reference**: See `../tt-reviews/app/routes.ts` for file-based routing setup
- **File-based routing**: Use dot notation for nested routes (`parent.child.tsx`)
- **Layout components**: Shared layouts with `<Outlet />` for child routes
- **Route naming**: `_index.tsx` for index routes, `$param.tsx` for dynamic routes

### Component Conventions
- **Component files**: PascalCase (`UserProfile.tsx`)
- **Component names**: PascalCase matching file names
- **Component structure**: Break large JSX into focused, reusable components
- **Composition**: Prefer composition over large monolithic components
- **Directory structure**:
  - `/app/components/ui/` - Reusable UI components
  - `/app/components/[feature]/` - Feature-specific components

### TypeScript Standards
- **Props interfaces**: Strong TypeScript interfaces for all component props
- **Naming**: PascalCase for interfaces/types, camelCase for variables/functions
- **Boolean variables**: Use `is`, `has`, `should` prefixes (`isModalOpen`, `hasError`)

### Supabase Authentication

**CRITICAL**: Always use **client-side only authentication** for all auth operations. Do NOT mix server-side and client-side auth in the same component.

**Implementation References**:
- **Server client setup**: `../tt-reviews/app/lib/supabase.server.ts`
- **Auth utilities**: `../tt-reviews/app/lib/auth.server.ts`
- **Login form example**: `../tt-reviews/app/routes/login.tsx`
- **Protected route example**: `../tt-reviews/app/routes/profile.tsx`

**Key Patterns**:
- Use `createBrowserClient` for all client-side auth operations
- Use regular HTML `<form>` elements (NOT React Router `<Form>`)
- Handle form submission with `onSubmit` handlers and `FormData`
- Use `getServerClient` only in route loaders for auth checks

### Project Structure
- **Migrations**: Store in `supabase/migrations/` with timestamp prefixes
- **App structure**: Reference `../tt-reviews/app/` directory structure:
  - `/components/ui/` - Reusable UI components
  - `/components/[feature]/` - Feature-specific components  
  - `/lib/` - Server utilities (auth, database, etc.)
  - `/routes/` - File-based routes

## Environment & Setup

### Environment Variables

**Reference**: See `../tt-reviews/wrangler.toml` for Cloudflare Workers configuration
- **Development**: `.dev.vars` file (not committed)
- **Configuration**: `wrangler.toml` file (committed, non-sensitive config)
- **Production**: `npx wrangler secret put` command for sensitive data
- **Access**: `context.cloudflare.env` for environment variable access in routes

### Database Development
- **Local Database**: Supabase uses Docker containers
- **Database Queries**: Use `docker exec` for direct database access when needed
- **Container Access**: `docker-compose exec` for database operations

### Deployment
- **Platform**: Cloudflare Workers with React Router v7
- **Configuration**: Reference `../tt-reviews/wrangler.toml` for setup
- **Build**: `npm run build` creates `/build` directory
- **Deploy**: `npx wrangler deploy` or GitHub Actions
- **CI/CD**: GitHub Actions pipeline
- **Environments**: Development (auto-deploy) and Production (manual approval)

## Development Workflow & Permissions

### Tasks That Don't Require Permission
- **File operations**: Reading, searching, analyzing existing files
- **Documentation**: Updating markdown files in `docs/`, `analysis/`, `todo/`
- **Database analysis**: Reading analysis files, examining schema
- **Git operations**: `git add`, `git push`, `git status`, `git diff`, `git log`
- **Package operations**: `npm install`, `npm run` commands
- **Database reads**: SELECT queries via docker exec
- **Supabase migrations**: `supabase migrations up` (but not `supabase db reset`)

### Tasks That Require Permission
- **Code modifications**: Creating, editing, or deleting application code
- **Database writes**: INSERT, UPDATE, DELETE operations
- **Git commits**: Creating commits
- **System configuration**: Environment setup changes
- **Destructive database operations**: Especially `supabase db reset`

### Workflow Rules
- **Phase-based development**: Follow the 4-phase approach in `todo/` directory
- **TODO management**: Keep TODO markdown files constantly updated and always update before git commit

### Script Management
- **Temporary scripts**: Store in `/scripts/` directory
- **Cleanup**: Remove one-time scripts after use
- **Analysis scripts**: Keep schema analysis scripts for reference

## Key Project Documents

- **[Requirements Document](docs/REQUIREMENTS.md)** - Comprehensive project vision and technical specifications
- **[Database Migration Requirements](docs/DATABASE_MIGRATION_REQUIREMENTS.md)** - Migration strategy from WordPress/MySQL to PostgreSQL
- **[Development Phases](todo/)** - Detailed phase-by-phase implementation plan
