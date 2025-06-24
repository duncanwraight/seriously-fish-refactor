# Seriously Fish Refactor - Requirements Document

## Project Overview

**Objective**: Modernize the Seriously Fish website by migrating from WordPress to a React Router v7 + Supabase architecture, focusing on high-quality scientific content, powerful search capabilities, and Discord community integration.

**Current Site**: https://www.seriouslyfish.com  
**Primary Value**: Comprehensive, scientifically-accurate species profiles for aquarium fish  
**Key Example**: https://www.seriouslyfish.com/species/gymnochanda-verae

## Technical Architecture

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

### Deployment Pipeline
- **CI/CD**: GitHub Actions (following tt-reviews patterns)
- **Environments**: 
  - Development (auto-deploy from main branch)
  - Production (manual approval required)
- **Community integration**: Webhook notifications to Discord channels
- **Notifications**:
  - Development deployments → Discord "deployment" channel
  - Production releases → Discord "changelog" channel

### Monitoring & Logging
- **Primary logging**: Cloudflare logs and analytics
- **Application logging**: Robust logging system across frontend and API components
- **Alerting**: Discord-based alerts for errors and system issues (free solution)
- **Performance monitoring**: Cloudflare Workers analytics and metrics

### Caching Strategy
- **Cloudflare Workers caching**: API response caching with content-type specific configurations
  - Species profiles: 24 hour cache
  - Article content: 12 hour cache  
  - Search results: 1 hour cache
  - User-specific data: No cache
- **Database caching**: Native Supabase/PostgREST caching only
- **Image caching**: Cloudflare R2 + CDN automatic caching
- **Database optimization**: Read-heavy query patterns with appropriate indexing

### Form Validation & Data Integrity
- **Schema validation**: Zod for TypeScript-first validation
- **Validation layers**: 
  - Frontend: Real-time validation during user input
  - Backend: Server-side validation for security
  - Database: Schema constraints and triggers
- **Scientific data validation**: Custom validators for taxonomic names, measurements, citations
- **Rich text validation**: Content sanitization and citation format validation

### Architecture Benefits
- **Type-safe full-stack development**
- **Server-side rendering for SEO**
- **Global edge deployment via Cloudflare**
- **Unified deployment** (frontend, backend, API in single Worker)
- **Modern React patterns** with proper component composition
- **Strong local development environment** mirroring production

## Content Strategy

### Primary Content Types

#### 1. Species Profiles (Core Content)
**Current Structure Analysis**:
- Scientific name and etymology
- Classification and distribution
- Habitat requirements
- Physical characteristics (max length, etc.)
- Aquarium care instructions
- Water conditions (temperature, pH ranges)
- Diet and feeding requirements
- Behavior and compatibility
- Sexual dimorphism
- Reproduction information
- Scientific references

**Requirements**:
- Maintain all existing data fields
- Enhance with structured data for better SEO
- Support multiple high-quality images with captions
- Enable scientific reference linking and citation formatting
- Allow for community contributions (verified users only)

#### 2. Article-Based Content
**Content Categories**:
- Publications
- Blogs
- Articles
- Conservation reports

**Shared Features**:
- Rich text editor with citation support
- Image galleries with captions
- Author attribution
- Publication dates
- Category-based filtering
- Scientific reference integration

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

### Content Versioning & History
**Admin Versioning**: 
- Keep last 2-3 versions of all content for data recovery purposes
- Admin interface shows version history with restore capability
- Track editor, timestamp, and change summary for each version

**Public Change History**:
- Frontend-visible timeline for significant changes (e.g., taxonomic reclassification)
- Display when species information was updated and why
- Historical context for scientific accuracy and transparency

### Taxonomic Hierarchy & Navigation
**Hierarchical Structure**: Class → Order → Family → Genus → Species
- **Navigation**: Browse species by taxonomic classification
- **Landing Pages**: Family and genus overview pages with species lists
- **Knowledge Base**: Homepage integration serving as main navigation hub (replacing current knowledge-base page)
- **Search Integration**: Filter by taxonomic levels

### Content Moderation Workflow
**Admin Users**:
- **Draft** → **Live** (direct publishing capability)

**Non-Admin Users**:
- **Draft** → **Submitted** → **Processing** (glossary/validation) → **Discord Notification** → **Approved/Rejected**
- **Rejection Handling**: Explanations visible in user profile area
- **Re-submission**: Users can edit rejected content and re-submit
- **Review Process**: Trusted Discord reviewers approve/reject via bot interactions

### Multilingual Architecture
**Day 1 Implementation**:
- **Default Language**: English for all content
- **Database Schema**: Designed to support translations (content_translations table)
- **Future-Ready**: Architecture supports adding translated versions later
- **No Active Translation**: Feature dormant but database-supported

### Content Quality Standards
- **Scientific accuracy**: All information must be verifiable
- **Citation requirements**: References must be provided for scientific claims
- **Image standards**: High-quality photos with descriptive captions
- **Editorial review**: Content moderation via Discord integration

## User Roles & Authentication

### Application Roles
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

### Discord Integration
**Discord Roles**: Moderator and Admin roles only
- **Role Assignment**: App-controlled promotion system
- **Workflow**: Admin promotes user → App requests Discord ID → Discord bot assigns role
- **Integration**: Discord roles used for submission review and approval process
- **Simplified Architecture**: No complex role syncing, app-driven role management

## Search Requirements

### Critical Success Factors
- **Accuracy**: Return legitimately relevant results
- **Performance**: Fast response times for global users
- **Comprehensiveness**: Search across all content types
- **Advanced filtering**: By habitat, care requirements, geographic region, etc.

### Search Capabilities
1. **Species Search**
   - Scientific names (exact and fuzzy matching)
   - Common names
   - Habitat characteristics
   - Care requirements (temperature, pH, tank size)
   - Geographic distribution

2. **Content Search**
   - Full-text search across articles
   - Author-based filtering
   - Date range filtering
   - Category-specific searches

### Technical Implementation
- **Primary**: PostgreSQL full-text search with custom ranking
- **Fallback**: Algolia integration if native search proves insufficient
- **Performance**: Indexed search with caching strategies

## Image Management

### Critical Requirements
- **Flawless functionality**: Images must load reliably worldwide
- **Caption support**: All images require descriptive captions
- **Multiple formats**: Support for JPEG, PNG, WebP
- **Responsive delivery**: Optimized for various screen sizes

### Image Types
1. **Species Photos**
   - Multiple angles and life stages
   - Habitat photos
   - Behavioral documentation

2. **Article Images**
   - Scientific illustrations
   - Conservation photography
   - Research documentation

### Technical Implementation
- **Storage**: Cloudflare R2 for global CDN performance
- **Processing**: On-demand resizing and format optimization
- **Organization**: Structured folder hierarchy by content type

## SEO & Migration Strategy

### SEO Priorities
1. **Preserve high-ranking content**: Maintain Google rankings for top-performing pages
2. **URL strategy**: Selective reuse of existing routes vs. new structure
3. **Redirect management**: Permanent redirects for changed URLs
4. **Structured data**: Enhanced schema markup for species profiles

### Migration Approach
1. **Content audit**: Export Google Search Console data to identify critical routes
2. **Database migration**: MySQL to PostgreSQL with data integrity validation
3. **URL mapping**: Strategic redirect plan for SEO preservation
4. **Performance optimization**: Leverage Cloudflare edge caching

## Discord Community Integration

### Architecture
- **Unified worker integration**: Discord webhooks within existing Cloudflare Worker
- **Role-based permissions**: Discord server roles determine moderation capabilities
- **Content moderation**: Submission review system via Discord channels

### Key Features
1. **Content Submission Notifications**
   - New submissions posted to moderation channel
   - Quick approve/reject actions via Discord interactions

2. **Search Commands**
   - `/species query:name` - Search species profiles
   - `/content query:term` - Search articles and publications
   - Role-restricted access for quality control

3. **Moderation Workflow**
   - Two-moderator approval system
   - Submission tracking and accountability
   - Automated database updates from Discord actions

## Data Migration Strategy

### MySQL Database Analysis
- **Current database**: Available for containerized analysis
- **Schema interpretation**: User guidance for complex relationships
- **Data integrity**: Validation scripts for migration accuracy

### Migration Phases
1. **Schema mapping**: MySQL to PostgreSQL conversion
2. **Content migration**: Species profiles, articles, media
3. **User data**: Account information and roles
4. **URL mapping**: Route preservation and redirect setup

## Development Phases

### Phase 1: Foundation (MVP)
- [ ] Database schema design and migration scripts
- [ ] Basic species profile display
- [ ] User authentication and roles
- [ ] Image storage and display
- [ ] Basic search functionality

### Phase 2: Content Management
- [ ] Admin interface for content management
- [ ] Article-based content types
- [ ] Enhanced species profile editing
- [ ] Citation and reference system
- [ ] SEO optimization and redirects

### Phase 3: Community Integration
- [ ] Discord bot integration
- [ ] Content submission workflow
- [ ] Moderation system
- [ ] Advanced search with filtering
- [ ] Performance optimization

### Phase 4: Advanced Features
- [ ] Algolia search integration (if needed)
- [ ] Advanced image management
- [ ] Analytics and monitoring
- [ ] Mobile optimization
- [ ] API for external integrations

## Technical Considerations

### Performance Requirements
- **Global accessibility**: Sub-3-second load times worldwide
- **Image optimization**: Progressive loading and format selection
- **Search responsiveness**: <500ms search result delivery
- **Caching strategy**: Aggressive caching for read-heavy usage patterns

### Security Requirements
- **Content integrity**: Protection against malicious submissions
- **User data protection**: GDPR-compliant user management
- **Role-based access**: Secure permission boundaries
- **Input validation**: XSS and injection prevention

### Scalability Planning
- **Database optimization**: Indexed queries for large datasets
- **CDN utilization**: Global content delivery
- **Worker scaling**: Automatic scaling for traffic spikes
- **Monitoring**: Performance and error tracking

## Success Metrics

### Content Quality
- Scientific accuracy validation
- Citation completeness
- Image quality and coverage
- User contribution engagement

### Technical Performance
- Page load speeds
- Search result relevance
- Image delivery performance
- Uptime and reliability

### Community Engagement
- Discord server activity
- Content submission rates
- User registration and verification
- SEO ranking maintenance

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-24  
**Next Review**: Upon Phase 1 completion