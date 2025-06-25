# Phase 2: Content Management & Workflow

**Goal**: Complete content creation, editing, and moderation workflow

## Submission Registry System
- [ ] Unified submission system (`submissions.$type.submit` route)
- [ ] Submission registry with config-driven form generation
- [ ] Field factories for scientific data (temperature ranges, taxonomic selectors)
- [ ] Dynamic field dependencies (Family → Genus → Species dropdowns)
- [ ] Pre-selection support for contextual submissions
- [ ] Enhanced Zod validation with cross-field rules

## Content Management
- [ ] Admin interface for comprehensive content management
- [ ] Content submission workflow (Draft → Submitted → Processing → Review)
- [ ] Content versioning system (admin versions + public change history)
- [ ] Required field validation for species profiles with scientific constraints
- [ ] Content archiving system with frontend display
- [ ] Article-based content types with full rich text editing

## Rich Text & Processing
- [ ] Complete Tiptap integration with custom extensions
- [ ] SF Species/Article search and linking extension
- [ ] Citation formatter and scientific notation support
- [ ] Glossary integration and auto-linking
- [ ] Background job processing (Durable Objects) for glossary terms
- [ ] Image galleries for species profiles

## Moderation & Notifications
- [ ] User profile pages with submission history and preferences
- [ ] Email notification system for content status updates
- [ ] In-app notification system with unread indicators
- [ ] Community guidelines system (admin-configurable per content type)
- [ ] Content moderation workflow with rejection handling