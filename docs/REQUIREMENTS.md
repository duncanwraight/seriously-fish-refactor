# Seriously Fish Refactor - Requirements Document

## Project Overview

**Objective**: Modernize the Seriously Fish website by migrating from WordPress to a React Router v7 + Supabase architecture, expanding from tropical freshwater fish to comprehensive aquatic life coverage including marine fish, aquatic plants, and freshwater invertebrates, while maintaining scientific accuracy and powerful discovery capabilities.

**Current Site**: https://www.seriouslyfish.com  
**Primary Value**: Comprehensive, scientifically-accurate profiles for aquatic organisms  
**Current Focus**: Tropical freshwater fish (1,809 species)  
**Expansion Scope**: Marine fish, aquatic plants, freshwater invertebrates  
**Key Example**: https://www.seriouslyfish.com/species/gymnochanda-verae

---

# PART I: TECHNICAL ARCHITECTURE

## Technology Stack

### Core Stack
- **Framework**: React Router v7 (full-stack React framework)
- **Database**: Supabase (PostgreSQL) - migrated from existing MySQL
- **Hosting**: Cloudflare Workers
- **Authentication**: Supabase Auth with Discord role integration
- **Image Storage**: Cloudflare R2
- **Search**: Advanced search implementation (possibly Algolia if native search insufficient)

### Development Environment
- **Local setup**: React Router local build with Supabase Docker containers
- **Reference architecture**: Based on tt-reviews repository patterns
- **Database**: Local PostgreSQL via Docker for development/testing
- **Authentication**: Local Supabase auth simulation

### Deployment & CI/CD
- **CI/CD**: GitHub Actions (following tt-reviews patterns)
- **Environments**: 
  - Development (auto-deploy from main branch)
  - Production (manual approval required)
- **Community integration**: Webhook notifications to Discord channels
- **Notifications**:
  - Development deployments → Discord "deployment" channel
  - Production releases → Discord "changelog" channel

## Performance & Caching

### Caching Strategy
- **Cloudflare Workers caching**: API response caching with content-type specific configurations
  - Organism profiles: 24 hour cache (fish, plants, invertebrates)
  - Article content: 12 hour cache  
  - Search results: 1 hour cache (includes content-type filtering)
  - Geographic data: 6 hour cache (countries, continents, organism counts)
  - Heat map data: 1 hour cache (frequently accessed, lightweight)
  - Country/continent pages: 2 hour cache (all organism types)
  - User-specific data: No cache
- **Database caching**: Native Supabase/PostgREST caching only
- **Image caching**: Cloudflare R2 + CDN automatic caching
- **Database optimization**: Read-heavy query patterns with appropriate indexing for geographic queries

### Performance Requirements
- **Global accessibility**: Sub-3-second load times worldwide
- **Image optimization**: Progressive loading and format selection
- **Search responsiveness**: <200ms response time for real-time UX including geographic results
- **Geographic features**: Heat map renders <500ms, country pages <2s load time
- **Core Web Vitals**: <2.5s LCP, <100ms FID, <0.1 CLS targets

## Data Validation & Testing

### Form Validation & Data Integrity (Enhanced with TT-Reviews Patterns)
**Schema Validation Architecture**:
- **Zod schemas**: Mirror database structure for each submission type and content entity
- **Registry integration**: Zod schemas linked to submission registry configurations
- **Database alignment**: Zod constraints match PostgreSQL schema (NOT NULL, CHECK constraints, VARCHAR limits)

**Multi-Layer Validation**:
- **Frontend**: Real-time validation using Zod schemas as user types
- **Backend**: Server-side Zod validation for security (`safeParse()` with structured error handling)
- **Database**: PostgreSQL constraints and triggers as final validation layer

**Scientific Data Validation**:
- **Custom Zod validators** for scientific accuracy:
  - Scientific name format validation (`Genus species` pattern)
  - Temperature/pH range validation with logical constraints
  - Taxonomic hierarchy consistency (Family → Genus → Species relationships)
  - Citation format validation and URL verification
- **Cross-field validation**: Temperature ranges, compatibility rules, measurement consistency
- **Rich error messages**: Field-specific error messages with scientific context

**Field Configuration Integration**:
- **Enhanced FormField interface**: Zod schema integration with existing validation patterns
- **Dynamic validation**: Conditional validation based on field dependencies
- **Error handling**: Structured field-level error responses from Zod validation failures

### Testing Strategy
**Minimal Smoke Testing**: Fail-fast approach focused on preventing site crashes
- **Framework**: Vitest for fast, TypeScript-friendly testing
- **Execution**: CI-based testing with manual pre-commit workflow
- **Seed Data**: Use migrated species profiles from MySQL database for test scenarios

**Core Workflow Tests**:
1. **Homepage loads** without errors
2. **Species profile page** renders (using migrated seed data)
3. **User authentication** flow works (login/logout)
4. **Search bar** returns results for basic queries
5. **Content submission form** renders and accepts input

**Implementation**:
- **Fail-fast**: Stop on first test failure for quick feedback
- **CI integration**: Block deployments on test failures
- **Personal workflow**: Run tests before pushing changes
- **Future enhancement**: Move to pre-commit hooks during alpha/beta stages

## Monitoring & Operations

### Request Correlation & Logging (TT-Reviews Pattern)
**Correlation System**:
- **Request correlation middleware**: `withLoaderCorrelation` for tracking requests across operations
- **Unique request IDs**: Generated for each request and propagated through all operations
- **Database operation tracking**: All database queries tagged with correlation context
- **User action logging**: Track popular species views, search patterns, submission behavior

**Structured Logging**:
- **Logger service**: Centralized logging with correlation context
- **Log levels**: Debug, info, warn, error with appropriate filtering
- **Performance monitoring**: Database operation timing and caching effectiveness
- **Error tracking**: Comprehensive error logging with request context

### Monitoring & Alerting
- **Primary logging**: Cloudflare logs and analytics
- **Application logging**: Robust correlation-aware logging system across frontend and API components
- **Discord-based alerting**: Free solution for errors, system issues, and performance degradation
- **Performance monitoring**: Cloudflare Workers analytics with custom metrics

### Configuration Management (TT-Reviews Patterns)
**Environment Access**:
- **Cloudflare context**: `context.cloudflare.env` for environment variable access
- **Supabase client factory**: Regular vs admin client creation patterns
- **Environment Variables**: Following tt-reviews patterns:
  - Development: `.dev.vars` file (not committed)
  - Configuration: `wrangler.toml` file (committed)
  - Production: `npx wrangler secret put` command for sensitive data

**Configuration Services**:
- **Site Settings**: Admin-configurable site-wide settings
- **Runtime configuration**: Dynamic settings loaded via database
- **Schema service**: Structured data generation for SEO

### Error Handling & User Experience
- **Consistent Messaging**: Uniform error and success notifications across site (modal or styled components)
- **Error Pages**: Custom 404 page and generic error page for all other errors
- **Image Upload UX**: Progress indicators for large image uploads (up to 6MB)
- **User Feedback**: Clear success/failure messaging for all user actions

### Support & Analytics
- **User Support**: Link to Discord server for user assistance
- **Analytics**: Google Analytics integration for site metrics
- **Database Management**: Supabase handles backups and data management

---

# PART II: CONTENT & USER MANAGEMENT

## Content Strategy

### Database Service Architecture (TT-Reviews Pattern)
**Centralized Database Service**:
- **DatabaseService class**: Organized methods by entity type (species, articles, users, submissions)
- **Supabase client management**: Regular and admin client factory functions
- **Request correlation**: All database operations tagged with correlation context
- **Performance monitoring**: Database operation timing and logging
- **Consistent error handling**: Standardized error patterns (`.catch(() => [])` vs thrown errors)

**Service Structure**:
- **Type-safe interfaces**: Strong TypeScript interfaces for all entities
- **Method organization**: Grouped by functionality (search, CRUD, aggregation, user-specific)
- **Fallback strategies**: Graceful degradation when optional features fail
- **Caching integration**: Database-level caching with performance monitoring

### Primary Content Types

#### 1. Species Profiles (Expanded Content Coverage)
**Multi-Organism Support**:
- **Fish Species**: Current focus (1,809 tropical freshwater + marine expansion)
- **Aquatic Plants**: Comprehensive plant profiles with care requirements
- **Freshwater Invertebrates**: Shrimp, snails, crabs, crayfish profiles
- **Unified URL Structure**: All organisms under `/species/[genus-species]` for SEO preservation

**Universal Profile Fields**:
- Scientific name and etymology
- Classification and distribution  
- Habitat requirements (freshwater/marine/brackish/terrestrial)
- Physical characteristics (size, appearance, growth rate)
- Care instructions (aquarium/tank setup)
- Water conditions (temperature, pH, salinity where applicable)
- Diet and feeding/fertilization requirements
- Behavior and compatibility
- Reproduction/propagation information
- Scientific references

**Content-Type Specific Fields**:
- **Fish**: Water parameters, behavior, breeding, tank mates
- **Marine Fish**: Salinity/specific gravity, reef compatibility, marine-specific care
- **Plants**: Light requirements, CO2 needs, fertilization, placement, propagation
- **Invertebrates**: Molting, calcium requirements, social behavior, breeding difficulty

**Requirements**:
- Maintain all existing fish data fields
- Add content-type discrimination with appropriate field sets
- Support habitat-type expansion (marine, brackish additions)
- Enhance with structured data for better SEO across all organism types
- Support multiple high-quality images with captions for all content types
- Enable scientific reference linking and citation formatting
- Allow for community contributions across all content types (verified users only)

### Rich Text Editing System
**Editor**: Tiptap (React-based, extensible rich text editor)

**Input Types**:
1. **Plain Text**: Simple text fields for structured data (genus, species names, measurements)
   - No formatting options
   - Automatic formatting applied (e.g., scientific names in italics)

2. **Limited Rich Text**: Basic formatting for short content (captions, summaries)
   - Bold, italic formatting only
   - No links or complex structures

3. **Full Rich Text**: Complete editing capabilities for articles and detailed content
   - All basic formatting (bold, italic, headings, lists)
   - External link insertion
   - Internal SF linking (search and link to species/articles)
   - Citation formatting and management
   - Scientific notation support
   - Image insertion with captions

**Custom Extensions**:
- **SF Species/Article Search**: Search and link to internal content
- **Citation Formatter**: Scientific citation formatting and management
- **Scientific Notation**: Automatic italicization of scientific names

### Content Submission System (TT-Reviews Registry Pattern)

#### Submission Registry Architecture
**Config-Driven Form Generation**:
- **Content-Type Specific Routes**: Separate optimized forms for each content type
  - `/submissions/fish/submit` - Tropical freshwater fish submissions
  - `/submissions/marine-fish/submit` - Marine fish with salinity parameters
  - `/submissions/plant/submit` - Aquatic plant submissions with lighting/CO2 fields
  - `/submissions/invertebrate/submit` - Invertebrate submissions with molting/calcium needs
  - `/submissions/article/submit` - Article submissions
  - `/submissions/image/submit` - Image submissions for existing content
- **Submission registry**: Centralized configuration for all content types with type-specific field sets
- **Field factories**: DRY form field creation with scientific field patterns
- **Dynamic dependencies**: Taxonomic hierarchy dropdowns (Family → Genus → Species)
- **Pre-selection support**: URL-based context for submissions (e.g., "add image to Betta splendens")
- **Content-Type Validation**: Form fields and validation rules adapt based on content type and habitat type

**Security Integration**:
- **Rate limiting**: Form submission rate limits per user/IP
- **CSRF protection**: Token-based protection for all state-changing operations
- **Authentication gates**: Verified user requirement for submissions
- **Input sanitization**: XSS prevention and content validation

**Processing Workflow**:
- **Zod validation**: Schema validation before database insertion
- **Admin client usage**: Privileged database operations for submissions
- **Discord notifications**: Non-blocking, type-specific Discord alerts
- **Background processing**: Glossary linking and content processing

#### Content States & Workflow
**Admin Users**:
- **Draft** → **Live** (direct publishing capability)

**Non-Admin Users**:
- **Draft** → **Submitted** → **Processing** (glossary/validation) → **Discord Notification** → **Approved/Rejected**
- **Rejection Handling**: Explanations visible in user profile area
- **Re-submission**: Users can edit rejected content and re-submit
- **Review Process**: Trusted Discord reviewers approve/reject via bot interactions

#### Content Versioning & History
**Admin Versioning**: 
- Keep last 2-3 versions of all content for data recovery purposes
- Admin interface shows version history with restore capability
- Track editor, timestamp, and change summary for each version

**Public Change History**:
- Frontend-visible timeline for significant changes (e.g., taxonomic reclassification)
- Display when species information was updated and why
- Historical context for scientific accuracy and transparency

#### Content Archiving
- **Archive State**: Admin-controlled archiving for outdated or deprecated content
- **Archived Content Display**: Archived routes remain accessible with message: "This content has been archived. If you think this is a mistake, contact us on Discord"
- **Version Access**: Historical versions only available to admins for recovery purposes, not public frontend

#### Content Standards & Validation
- **Required Fields**: Species profiles cannot be submitted without essential data (e.g., max length)
- **Fixed Format**: Species profiles follow consistent structure and required sections
- **Single Editor**: One person per submission, no collaborative editing
- **No Bulk Operations**: Individual content management initially
- **No Content Scheduling**: Manual publishing workflow only
- **No Templates**: Standard required fields enforce consistency without pre-filled forms

### Glossary Integration & Background Processing
**Auto-Glossary Linking**: Automatic linking of glossary terms within content
- **Database**: Glossary terms stored with aliases and case-sensitivity flags
- **Processing**: Background job processes content to identify and link glossary terms
- **Smart linking**: First occurrence only, context-aware, avoids over-linking
- **Performance**: Server-side processing during content save with client-side tooltip enhancements

**Background Job Processing**:
- **Architecture**: Single Cloudflare Worker with Durable Objects for job queuing
- **Workflow**: 
  1. Content submitted → Saved with "processing" status
  2. Background job queued using Durable Object alarms
  3. Glossary terms processed and linked
  4. Status updated to "ready for review"
- **Notifications**: Discord alerts for processing completion and failures
- **Throughput**: Sufficient for content submission volumes (~400 jobs/second capacity)

### Taxonomic Hierarchy & Navigation
**Hierarchical Structure**: Class → Order → Family → Genus → Species
- **Navigation**: Browse species by taxonomic classification
- **Landing Pages**: Family and genus overview pages with species lists
- **Knowledge Base**: Homepage integration serving as main navigation hub (replacing current knowledge-base page)
- **Search Integration**: Filter by taxonomic levels

### Content Quality Standards
- **Scientific accuracy**: All information must be verifiable
- **Citation requirements**: References must be provided for scientific claims
- **Image standards**: High-quality photos with descriptive captions
- **Editorial review**: Content moderation via Discord integration

### Multilingual Architecture
**Day 1 Implementation**:
- **Default Language**: English for all content
- **Database Schema**: Designed to support translations (content_translations table)
- **Future-Ready**: Architecture supports adding translated versions later
- **No Active Translation**: Feature dormant but database-supported

## User Management & Authentication

### User Roles & Permissions
1. **Visitors** (Not logged in)
   - Read-only access to published content
   - Basic search functionality
   - No account required

2. **Verified Users** (Email verified)
   - Submit content for review (Draft → Submitted workflow)
   - Edit their own submissions before/after submission
   - Re-submit rejected content with modifications
   - View submission status and rejection explanations in profile

3. **Moderators**
   - All Verified User permissions
   - Review and approve/reject user submissions
   - Content quality control via Discord integration

4. **Administrators**
   - All Moderator permissions
   - Direct content publishing (Draft → Live)
   - User role management and promotion
   - Site configuration and database management
   - Manage all content regardless of author

### User Experience & Profile Management
**User Profile Page** (Verified Users):
- **Submission History**: All submissions with current status (Draft, Submitted, Processing, Approved, Rejected)
- **User Preferences**: Configurable display options (cm vs inches, Celsius vs Fahrenheit)
- **Account Management**: Password reset and change functionality

**Notification System**:
- **Email Notifications**: Content approval/rejection status (using designated Gmail account)
- **In-App Notifications**: Unread notification icon on profile button
- **Notification Clearing**: Icon disappears when user visits profile page

**Community Guidelines**:
- **Admin-Configurable**: Guidelines configurable per content type (species profiles, articles, blogs)
- **Submission Context**: Guidelines displayed during content creation process
- **Moderation Reference**: Available to moderators during review process

### Security & Access Control
**File Upload Security**:
- **Supported Formats**: JPEG, PNG, WebP only
- **File Size Limit**: 6MB maximum per upload
- **Basic Validation**: File header checking and content-type validation to prevent malicious files
- **Malware Scanning**: VirusTotal API integration during background processing

**Session & Access Control**:
- **Session Management**: Supabase production environment defaults
- **Authentication**: Standard password requirements and secure session handling
- **Rate Limiting**: Cloudflare protection initially, expandable for future needs

**Additional Security**:
- **Content integrity**: Protection against malicious submissions
- **User data protection**: GDPR-compliant user management
- **Role-based access**: Secure permission boundaries
- **Input validation**: XSS and injection prevention

---

# PART III: FEATURES & FUNCTIONALITY

## Search & Discovery

### 1. Search Bar (Primary Search)
**Purpose**: Real-time search with integrated geographic discovery

**Functionality**:
- **Target**: Organism names (fish, plants, invertebrates), scientific names, common names, geographic locations
- **Real-time**: Results appear after ~0.5 second delay as user types
- **Dropdown Results**: Categorized display with headings:
  - "Fish Species" - Fish profiles with habitat indicators (🌊 marine, 🏞️ freshwater)
  - "Plants" - Aquatic plant profiles with care level indicators
  - "Invertebrates" - Shrimp, snail, and other invertebrate profiles
  - "Geographic" - Countries and continents with species counts
  - "Articles" - Content mentioning search terms
  - "Glossary" - Relevant glossary definitions
- **Shareable Results**: Enter key navigates to `/search/[query]` for linkable results

**Geographic Search Integration**:
- **Countries**: Search "brazil" shows "🌍 Brazil (1,247 species)"
- **Continents**: Search "south america" shows "🌎 South America (2,847 species)"
- **Species by Location**: Automatically include geographic origin in species search vectors
- **Navigation**: Geographic results link to dedicated geographic pages

**Technical Implementation**:
- **Enhanced Search Vector**: Include country and continent names in species search index
- **Primary**: PostgreSQL full-text search with trigram matching + geographic terms
- **Caching**: Aggressive caching of popular search terms and geographic data
- **Performance**: <200ms response time for real-time UX including geographic results

### 2. Geographic Discovery & Heat Map
**Purpose**: Visual exploration of fish biodiversity by geographic region

**Interactive Heat Map**:
- **Technology**: D3.js with SVG world map visualization
- **Color Scheme**: Scientific blue gradient (low to high species density)
- **Granularity**: Country-level visualization (rivers too complex for map display)
- **Interactions**:
  - Hover: Country name + species count tooltip
  - Click: Navigate to country page (`/country/brazil`)
  - Zoom: Continental focus with enhanced detail

**Filter Controls**:
- **Fish Families**: Filter by Cichlidae, Cyprinidae, etc.
- **Care Level**: Beginner, Intermediate, Advanced species
- **Size Categories**: Small (<5cm), Medium (5-15cm), Large (>15cm)
- **Endemic Species**: Show countries with endemic species highlighted

**Geographic Navigation Structure**:
```
Global Heat Map
├── Continent Pages (/continent/south-america)
│   ├── Continental overview and major countries
│   ├── Regional biodiversity highlights
│   └── Conservation status summary
├── Country Pages (/country/brazil)
│   ├── Species count and family breakdown
│   ├── Major river systems (text-based, not mapped)
│   ├── Endemic species list
│   └── Filterable species browser
└── Species Lists with Geographic Context
    ├── Sort by endemic status, family, size
    ├── Filter by care requirements
    └── Geographic origin clearly displayed
```

**Mobile Heat Map**:
- **Touch-friendly**: Larger country hit areas for mobile interaction
- **Simplified**: Same country-level data, optimized for small screens
- **Progressive Enhancement**: Works on all devices with consistent UX

### 3. Advanced Filtering System
**Purpose**: Find organisms by characteristics, care requirements, and habitat preferences

**Multi-Content Type Filtering**:
- **Content Type Selection**: Fish, Plants, Invertebrates with type-specific filter sets
- **Habitat Type Filtering**: Freshwater, Marine, Brackish, Terrestrial
- **Geographic Filtering**: Filter by continent, country, or endemic status
- **Environment Filtering**: River systems, reef environments, lake species, planted tanks

**Content-Specific Filter Categories**:
- **Fish & Invertebrates**: Temperature, pH, hardness, salinity ranges, social behavior
- **Aquatic Plants**: Light requirements, CO2 needs, fertilization level, placement zones
- **Marine Organisms**: Reef compatibility, specific gravity requirements, coral-safe ratings
- **Universal**: Tank size, difficulty level, geographic origin, care requirements

**User Experience Modes**:
- **Beginner Mode**: Simplified filters with care level guidance and recommended parameters
- **Expert Mode**: Complete scientific parameters with precise ranges and advanced options
- **Progressive Enhancement**: Filters expand based on selected content types and user experience

**Implementation**:
- **Database**: Multi-dimensional indexing on content type, habitat, and care characteristics
- **UI**: Progressive disclosure with contextual filter groups
- **Results**: Unified species list with content type indicators and key care highlights

### 4. Endemic Species Discovery
**Purpose**: Highlight unique species found only in specific regions

**Features**:
- **Species Profile Badge**: Endemic species clearly marked with special icon
- **Endemic Status Field**: Simple boolean field on species (`is_endemic`)
- **User Submission**: Content creators can mark species as endemic during submission
- **Geographic Pages**: Endemic species prominently featured on country/continent pages
- **Conservation Context**: Endemic species often have higher conservation importance

### Technical Architecture
- **Enhanced Search**: Geographic terms integrated into real-time search vectors
- **Heat Map Data**: Pre-computed country-level species counts with family breakdowns
- **Geographic API**: Optimized endpoints for map data and country/continent pages
- **Caching Strategy**:
  - Geographic data: 6 hours (updated when new species added)
  - Heat map data: 1 hour (lightweight, frequently accessed)
  - Country pages: 2 hours (moderate update frequency)
- **Performance**: Heat map renders <500ms, geographic search <200ms
- **Fallback**: Algolia integration if native search proves insufficient for complex geographic queries

## Image Management

### Upload & Processing
- **User Interface**: Standard drag & drop, copy & paste, file selection
- **Required Metadata**: Caption, alt text, and singular attribution for each upload
- **Immediate Display**: Images used "as is" provisionally upon upload
- **Background Processing**: Background worker resizes images for various site requirements (thumbnails, galleries, etc.)

### Image Types & Integration
1. **Species Photos**
   - Multiple angles and life stages
   - Habitat photos
   - Behavioral documentation
   - **Gallery Integration**: Image galleries for species profiles
   - **Separate from text**: Images managed independently of rich text content

2. **Article Images**
   - Scientific illustrations
   - Conservation photography
   - Research documentation
   - **Rich Text Integration**: Embedded directly in Tiptap editor for articles

### Content Moderation
- **Non-admin uploads**: Follow same moderation workflow as other content
- **Admin uploads**: Direct publication capability
- **Review process**: Images reviewed alongside content submissions via Discord

### Technical Implementation
- **Storage**: Cloudflare R2 for global CDN performance with built-in backup
- **Processing**: Background worker handles resizing for thumbnails, gallery views, responsive sizes
- **Security Validation**: VirusTotal API scanning during background processing to avoid upload latency
- **Formats**: JPEG, PNG, WebP support with automatic format optimization
- **Organization**: Structured folder hierarchy by content type
- **Accessibility**: Required alt text for screen reader compatibility

## Mobile-First Design Strategy
**Design Philosophy**: Frontend mobile-first, backend desktop-first approach
- **70% mobile traffic**: Prioritize mobile browsing experience for visitors
- **Desktop content creation**: Complex submissions and admin tasks optimized for desktop

**Frontend - Mobile-First** (Visitors & Browsing):
- **Species Profile Browsing**: Large hero images, swipeable galleries, quick facts cards
- **Collapsible Sections**: Expandable care details, habitat information, breeding notes
- **Navigation**: Hamburger menu design for main site navigation
- **Search & Discovery**: Prominent search bar, simplified organism filtering with content type selection
- **Taxonomic Browsing**: Touch-friendly family/genus navigation
- **User Profiles**: Mobile-optimized submission status and preference management

**Backend - Desktop-First** (Content Creation & Administration):
- **Rich Content Creation**: Full Tiptap editor with scientific citations and complex formatting
- **Complex Forms**: Detailed species profiles with multiple data fields and validation
- **Admin Interfaces**: User management, content moderation, and site configuration
- **Advanced Image Management**: Multiple uploads, gallery organization, detailed metadata entry

**Mobile Upload Support**:
- **Basic Image Upload**: Simple camera/gallery access for mobile users
- **Essential Metadata**: Caption and alt text entry optimized for mobile
- **Progress Indicators**: Clear feedback for larger image uploads (up to 6MB)

---

# PART IV: INTEGRATIONS & MIGRATION

## Discord Community Integration

### Architecture
- **Discord Bot Integration**: Custom bot integrated with Cloudflare Worker
- **Unified worker integration**: Discord webhooks and bot interactions within existing Worker
- **App-controlled role management**: Application manages Discord role assignments
- **Multi-channel notifications**: Separate channels for different notification types

### Key Features
1. **Content Submission Notifications**
   - New submissions posted to moderation channel after glossary processing
   - Quick approve/reject actions via Discord bot interactions
   - Single moderator approval system
   - Automated database updates from Discord actions

2. **Deployment Notifications**
   - Development deployments → "deployment" channel for testing
   - Production releases → "changelog" channel for community updates
   - Webhook integration with GitHub Actions pipeline

3. **System Monitoring & Alerts**
   - Error alerts and system issues posted to designated channel
   - Background job notifications (glossary processing completion/failures)
   - Free Discord-based alerting solution for application monitoring

4. **Role Management**
   - App-driven role assignment: Admin promotes user → App requests Discord ID → Bot assigns role
   - Simplified role structure: Moderator and Admin roles only
   - No complex role syncing, application controls Discord permissions

### Discord Integration (User Roles)
**Discord Roles**: Moderator and Admin roles only
- **Role Assignment**: App-controlled promotion system
- **Workflow**: Admin promotes user → App requests Discord ID → Discord bot assigns role
- **Integration**: Discord roles used for submission review and approval process
- **Simplified Architecture**: No complex role syncing, app-driven role management

## SEO & Migration Strategy

### SEO Implementation (TT-Reviews Patterns)
**Schema Service Architecture**:
- **Centralized schema service**: Generate structured data for different entity types
- **Performance optimization**: Schema generation in route loaders for SSR
- **Multiple schemas per page**: Breadcrumb + entity-specific schemas

**Enhanced Meta Generation**:
- **Scientific SEO patterns**: Species names, care requirements, habitats in meta descriptions
- **Performance-based titles**: Include review counts, usage statistics, care difficulty
- **Keyword optimization**: Scientific names, common names, care terms, equipment compatibility

**Structured Data/Schema Markup**:
- **Species profiles**: Animal schema with scientific names, habitat, conservation status, care requirements
- **Articles**: Article schema with author, publication date, citations, scientific accuracy
- **Taxonomic navigation**: Breadcrumb schema for Family → Genus → Species hierarchy
- **Rich snippets**: Enhanced Google search result display with species care info

**URL Structure & Redirects**:
- **Current structure maintained**: `/species/[scientific-name]`, `/articles/[slug]`
- **Historical name redirects**: 301 redirects from old scientific names to current classifications
- **SEO value preservation**: 90-95% ranking transfer via proper redirects
- **Taxonomic navigation**: `/family/[name]`, `/genus/[name]` for browsing

**Technical SEO**:
- **Core Web Vitals optimization**: <2.5s LCP, <100ms FID, <0.1 CLS targets
- **Mobile-first indexing**: Responsive design priority
- **XML sitemaps**: Auto-generated for all content types
- **Breadcrumb navigation**: Taxonomic hierarchy (Home > Family > Genus > Species)

**Content Optimization**:
- **Title tags**: "Scientific Name (Common Name) - Care Guide | Seriously Fish"
- **Meta descriptions**: Auto-generated from species data and care requirements
- **Internal linking**: Taxonomic relationships, glossary integration, related species
- **Historical context**: Display previous scientific names and reclassification dates

### Data Migration Strategy

#### MySQL Database Analysis
- **Current database**: Available for containerized analysis
- **Schema interpretation**: User guidance for complex relationships
- **Data integrity**: Validation scripts for migration accuracy

#### Migration Approach
1. **High-traffic route identification**: Focus on preserving top-performing species and articles
2. **Database migration**: MySQL to PostgreSQL with data integrity validation
3. **Redirect mapping**: Comprehensive 301 redirect plan for URL changes and taxonomic updates
4. **Performance optimization**: Cloudflare edge caching and CDN implementation
5. **SEO monitoring**: Track ranking changes and traffic patterns during migration

#### Migration Phases
1. **Schema mapping**: MySQL to PostgreSQL conversion
2. **Content migration**: Species profiles, articles, media
3. **User data**: Account information and roles
4. **URL mapping**: Route preservation and redirect setup

---

# PART V: DEVELOPMENT PLANNING

## Development Phases

### Phase 1: Core Foundation (MVP)
**Goal**: Basic functional website with content browsing and user management

**Technical Architecture & Database**:
- [ ] PostgreSQL schema design with multilingual support following TT-Reviews patterns
- [ ] MySQL to PostgreSQL migration scripts and data validation
- [ ] DatabaseService class implementation with request correlation
- [ ] Supabase client factory (regular + admin clients)
- [ ] Request correlation middleware (`withLoaderCorrelation`)
- [ ] Structured logging service with correlation context

**Authentication & Security**:
- [ ] User authentication system (Supabase Auth)
- [ ] User role system (Visitor, Verified, Moderator, Admin)
- [ ] Rate limiting implementation for all endpoints
- [ ] CSRF protection for state-changing operations
- [ ] Security headers and secure response patterns

**Content Display & Navigation**:
- [ ] Species profile display with taxonomic hierarchy
- [ ] Basic taxonomic navigation (family/genus browsing)
- [ ] Homepage with knowledge base integration
- [ ] Mobile-first responsive design implementation
- [ ] Custom 404 and error pages

**Essential Features**:
- [ ] Real-time search bar with categorized dropdown results
- [ ] Zod schema validation system matching database structure
- [ ] Image upload, storage (R2), and display with required metadata
- [ ] Basic rich text editing (Tiptap) with three input types
- [ ] Schema service for structured data generation (Animal schema, breadcrumbs)
- [ ] Enhanced SEO meta generation with scientific content

**Testing & Deployment**:
- [ ] Minimal smoke testing setup (Vitest)
- [ ] Basic deployment pipeline (GitHub Actions)
- [ ] Development environment configuration

### Phase 2: Content Management & Workflow
**Goal**: Complete content creation, editing, and moderation workflow

**Submission Registry System**:
- [ ] Unified submission system (`submissions.$type.submit` route)
- [ ] Submission registry with config-driven form generation
- [ ] Field factories for scientific data (temperature ranges, taxonomic selectors)
- [ ] Dynamic field dependencies (Family → Genus → Species dropdowns)
- [ ] Pre-selection support for contextual submissions
- [ ] Enhanced Zod validation with cross-field rules

**Content Management**:
- [ ] Admin interface for comprehensive content management
- [ ] Content submission workflow (Draft → Submitted → Processing → Review)
- [ ] Content versioning system (admin versions + public change history)
- [ ] Required field validation for species profiles with scientific constraints
- [ ] Content archiving system with frontend display
- [ ] Article-based content types with full rich text editing

**Rich Text & Processing**:
- [ ] Complete Tiptap integration with custom extensions
- [ ] SF Species/Article search and linking extension
- [ ] Citation formatter and scientific notation support
- [ ] Glossary integration and auto-linking
- [ ] Background job processing (Durable Objects) for glossary terms
- [ ] Image galleries for species profiles

**Moderation & Notifications**:
- [ ] User profile pages with submission history and preferences
- [ ] Email notification system for content status updates
- [ ] In-app notification system with unread indicators
- [ ] Community guidelines system (admin-configurable per content type)
- [ ] Content moderation workflow with rejection handling

### Phase 3: Advanced Features & Discord Integration
**Goal**: Community integration, advanced search, and production polish

**Discord Integration**:
- [ ] Discord bot development and integration
- [ ] Content submission notifications to Discord
- [ ] Single moderator approval system via Discord
- [ ] Role management system (app-controlled Discord role assignment)
- [ ] Deployment notifications (dev/prod channels)
- [ ] System monitoring and alerting via Discord

**Advanced Search & Discovery**:
- [ ] Advanced organism filtering system (multi-content type, Beginner/Expert modes)
- [ ] Enhanced search performance and caching
- [ ] Taxonomic landing pages (Family/Genus overview pages)
- [ ] Search result optimization and relevance tuning

**Production Features**:
- [ ] Historical name redirects and taxonomic reclassification support
- [ ] Complete SEO optimization and redirect management
- [ ] Performance optimization and advanced caching strategies
- [ ] Background job processing for image resizing and VirusTotal scanning
- [ ] Google Analytics integration
- [ ] Production monitoring and error handling

### Phase 4: Enhancement & Scaling
**Goal**: Advanced features, optimizations, and future-proofing

**Advanced Features**:
- [ ] Algolia search integration (if PostgreSQL search insufficient)
- [ ] Advanced image management and processing features
- [ ] PWA features for mobile optimization
- [ ] Advanced Discord features (search commands, etc.)

**Analytics & Optimization**:
- [ ] Analytics and monitoring dashboard
- [ ] Performance optimization and Core Web Vitals compliance
- [ ] Advanced caching strategies and edge optimization
- [ ] API for external integrations

**Future Enhancements**:
- [ ] Multilingual content support activation
- [ ] Advanced taxonomic features
- [ ] Community contribution enhancements
- [ ] Mobile app considerations

## Success Metrics

### Content Quality
- Scientific accuracy validation
- Citation completeness
- Image quality and coverage
- User contribution engagement

### Technical Performance
- Page load speeds (<3s globally)
- Search result relevance and speed (<200ms)
- Image delivery performance
- Uptime and reliability (99.9%+)

### Community Engagement
- Discord server activity
- Content submission rates
- User registration and verification
- SEO ranking maintenance

### Scalability Planning
- **Database optimization**: Indexed queries for large datasets
- **CDN utilization**: Global content delivery
- **Worker scaling**: Automatic scaling for traffic spikes
- **Monitoring**: Performance and error tracking

---

**Document Version**: 2.0  
**Last Updated**: 2025-01-24  
**Next Review**: Upon Phase 1 completion