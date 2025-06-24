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

### Architecture Benefits
- **Type-safe full-stack development**
- **Server-side rendering for SEO**
- **Global edge deployment via Cloudflare**
- **Unified deployment** (frontend, backend, API in single Worker)
- **Modern React patterns** with proper component composition

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

### Content Quality Standards
- **Scientific accuracy**: All information must be verifiable
- **Citation requirements**: References must be provided for scientific claims
- **Image standards**: High-quality photos with descriptive captions
- **Editorial review**: Content moderation via Discord integration

## User Roles & Authentication

### Application Roles
1. **Administrators**
   - Full content management access
   - User role management
   - Site configuration
   - Database content organization

2. **Verified Users**
   - Submit content for review
   - Requires email verification
   - Can contribute species data and articles

3. **Visitors**
   - Read-only access to published content
   - Basic search functionality

### Discord Integration Roles
1. **Moderators**
   - Review and approve user submissions
   - Content quality control
   - Community management

2. **Trusted Contributors**
   - Fast-track content approval
   - Advanced search access via Discord
   - Direct content submission privileges

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