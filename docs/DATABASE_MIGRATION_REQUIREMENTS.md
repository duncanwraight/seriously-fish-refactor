# Database Migration Requirements - WordPress to PostgreSQL

**Generated from schema analysis of Seriously Fish WordPress database**  
**Date**: 2025-06-25  
**Source Database**: 112 tables, ~306MB sanitized data  
**Target**: PostgreSQL schema for React Router v7 + Supabase supporting multi-organism content types

---

## Executive Summary

The Seriously Fish WordPress database contains **1,809 published species profiles** with rich scientific metadata, plus curated educational content. Migration to PostgreSQL will preserve scientific data while enabling modern search capabilities and **content-type expansion** to include marine fish, aquatic plants, and freshwater invertebrates, alongside **geographic filtering** for habitat and distribution-based discovery.

### Final Migration Scope
- **Species Content**: 1,809 existing fish profiles + expansion infrastructure for marine fish, plants, invertebrates
- **Content Type Support**: Single unified table supporting fish, plants, invertebrates with type-specific fields
- **Habitat Expansion**: Freshwater, marine, brackish, and terrestrial organism support
- **Educational Articles**: ~68 scientific/educational articles (filtered from 157 total)
- **Rich Media**: Species and article images (filtered from 8,973 total attachments)
- **Geographic Data**: 2,122 terms (1,890 rivers + 232 countries) for search filtering
- **Scientific Systems**: 1,731 glossary terms + 90 taxonomic classifications

### Content Excluded from Migration
- **Forum/Community**: 53K+ forum posts, Q&A content, user discussions
- **User Accounts**: 51K+ user accounts (starting fresh with new auth)
- **Site Management**: News, announcements, blogs, events (~120 posts)
- **Spam/Low-value**: Content revisions, forum attachments, outdated content

---

## 1. Content Analysis & Migration Scope

### WordPress Content Types (Final Selection)

#### ✅ **Organism Profiles** (1,845 existing + expansion infrastructure)
- **Current Content**: 1,809 published fish profiles with complete scientific metadata
- **Draft/Private**: 36 fish profiles (migrate selectively)
- **Metadata Fields**: 49 different fields per species (fish-focused, expanding to multi-organism)
- **Expansion Ready**: Database schema supports fish, plants, invertebrates in unified table
- **Core Value**: Primary scientific content expanding beyond fish to comprehensive aquatic life

#### ✅ **Educational Articles** (~68 from selected categories)
**Categories to Migrate:**
- **Articles** (26 posts) - Care guides, species analyses, breeding guides
- **Ichthyology** (28 posts) - Scientific research, taxonomy updates
- **New Species** (34 posts) - Species discovery announcements
- **Conservation** (20 posts) - Conservation efforts, habitat protection
- **Science** (7 posts) - General aquatic research
- **Beginner's Guide** (4 posts) - Basic aquarium setup and care
- **Discoveries** (26 posts) - General aquatic discoveries
- **Aquatic Plants** (1 post) - Plant care and information
- **Aquatic Invertebrates** (2 posts) - Shrimp, snails, other invertebrates

**Categories to Skip:**
- News (88 posts), Announcements (14 posts), Blogs (34 posts)
- Events (3 posts), SF Offers (2 posts), Website updates (1 post)

#### ✅ **Glossary Terms** (1,731 published)
- Scientific terminology definitions
- Enable auto-linking in species profiles and articles
- Support search functionality

#### ✅ **Geographic Data** (2,122 terms)
- **Rivers** (1,890 terms) - Specific river systems for habitat searches
- **Countries** (232 terms) - Geographic distribution for species filtering
- **Key Feature**: Enable searches like "Organisms from Amazon River" or "Species native to Brazil"

#### ✅ **Scientific Classification** (90 taxonomic terms)
- Taxonomic hierarchy: Orders, Families, Genera
- Enable browsing by scientific classification
- Examples: Cypriniformes (507 species), Cichlidae (113 species)

#### ✅ **Media Files** (Filtered subset)
- Organism photos and galleries (fish, plants, invertebrates)
- Article illustrations and diagrams
- Educational images for glossary and guides
- **Exclude**: Forum attachments, user uploads, spam images

---

## 2. Organism Profile Data Structure Analysis

### Complete Species Metadata Fields (49 total)

#### **Scientific Classification**
- `genus` (1,821 entries) - Scientific genus with HTML formatting
- `species` (1,815 entries) - Scientific species epithet
- `family` (1,810 entries) - Taxonomic family (136 unique families)
- `synonyms` (1,219 entries) - Historical scientific names
- `species_author` (1,276 entries) - Taxonomic authority
- `year_described` (1,276 entries) - Year of first description
- `etymology` (1,275 entries) - Name origin and meaning

#### **Common Names & Identification**
- `common_names` (1,813 entries) - Popular names (1,093 unique)
- `synonyms_title` (1,159 entries) - Alternative name sources

#### **Physical Characteristics**
- `max_size` (1,871 entries) - Maximum length in various units
- `max_size_M` (1,276 entries) - Male maximum size
- `max_size_F` (1,276 entries) - Female maximum size
- `dimorphism` (1,870 entries) - Sexual differences description

#### **Aquarium Requirements**
- `aquarium_size` (1,870 entries) - Tank size recommendations
- `aquarium_L` (1,276 entries) - Minimum tank length
- `aquarium_H` (1,275 entries) - Minimum tank height
- `aquarium_D` (1,275 entries) - Minimum tank depth
- `beginner_suitability` (1,276 entries) - Care difficulty (5 levels)

#### **Water Parameters**
- `temp_min` / `temp_max` (1,275 entries each) - Temperature range
- `pH_min` / `pH_max` (1,275 entries each) - pH range
- `hardness_min` / `hardness_max` (1,275 entries each) - Water hardness
- `conductivity_min` / `conductivity_max` (1,275 entries) - Conductivity
- `water_chemistry` (1,870 entries) - Detailed water requirements

#### **Biological Information**
- `habitat` (1,872 entries) - Natural habitat description
- `distribution` (1,871 entries) - Geographic distribution
- `diet` (1,870 entries) - Feeding requirements and behavior
- `behaviour` (1,870 entries) - Social behavior, temperament
- `reproduction` (1,870 entries) - Breeding information
- `maintenance` (1,870 entries) - General care requirements

#### **References & Media**
- `references` (1,299 entries) - Scientific citations
- `attached_media` (2,923 entries) - Associated images/videos
- `_thumbnail_id` (2,538 entries) - Featured image references

#### **Classification & Metadata**
- `type_of_fish` (1,274 entries) - Fish category classification
- `misc_notes` (1,870 entries) - Additional information

---

## 3. PostgreSQL Schema Design

### Core Tables Structure

#### **Species Table** (Multi-organism content table)
```sql
CREATE TABLE species (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    content TEXT,
    status content_status DEFAULT 'draft',
    author_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP,
    
    -- Content Type & Habitat Classification
    content_type content_type_enum NOT NULL DEFAULT 'fish',
    habitat_type habitat_type_enum NOT NULL DEFAULT 'freshwater',
    
    -- Scientific Classification (universal)
    genus VARCHAR(100) NOT NULL,
    species_epithet VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(200) GENERATED ALWAYS AS (genus || ' ' || species_epithet) STORED,
    family_id INTEGER REFERENCES families(id),
    taxonomic_authority VARCHAR(200),
    year_described INTEGER,
    etymology TEXT,
    
    -- Common Names & Synonyms (JSON for flexibility)
    common_names JSONB DEFAULT '[]'::jsonb,
    synonyms JSONB DEFAULT '[]'::jsonb,
    
    -- Universal Physical Characteristics
    max_size_mm INTEGER, -- length for fish/inverts, height for plants
    max_size_male_mm INTEGER, -- NULL for plants
    max_size_female_mm INTEGER, -- NULL for plants
    dimorphism TEXT, -- sexual dimorphism for fish/inverts, growth variation for plants
    
    -- Universal Care Requirements
    min_tank_length_cm INTEGER,
    min_tank_height_cm INTEGER,
    min_tank_depth_cm INTEGER,
    min_tank_volume_liters INTEGER,
    difficulty_level difficulty_enum,
    
    -- Universal Water Parameters (fish + inverts + aquatic plants)
    temp_min_c DECIMAL(3,1),
    temp_max_c DECIMAL(3,1),
    ph_min DECIMAL(3,1),
    ph_max DECIMAL(3,1),
    hardness_min_dgh DECIMAL(4,1),
    hardness_max_dgh DECIMAL(4,1),
    conductivity_min INTEGER,
    conductivity_max INTEGER,
    
    -- Marine-Specific Parameters (when habitat_type = 'marine')
    specific_gravity_min DECIMAL(4,3), -- NULL for freshwater organisms
    specific_gravity_max DECIMAL(4,3),
    salinity_ppt_min INTEGER,
    salinity_ppt_max INTEGER,
    reef_safe BOOLEAN, -- NULL for non-marine
    
    -- Plant-Specific Parameters (when content_type = 'plant')
    light_requirements light_enum, -- NULL for fish/inverts
    co2_requirements co2_enum,
    growth_rate growth_enum,
    plant_placement placement_enum,
    fertilizer_requirements fertilizer_enum,
    
    -- Invertebrate-Specific Parameters (when content_type = 'invertebrate')
    requires_calcium BOOLEAN, -- for shell/exoskeleton formation
    molting_frequency molting_enum,
    social_behavior social_enum,
    
    -- Universal Rich Text Content (context varies by type)
    habitat TEXT, -- natural habitat/environment for all types
    distribution TEXT, -- geographic distribution
    diet TEXT, -- feeding for animals, fertilization for plants
    behaviour TEXT, -- behavior for animals, growth habits for plants
    reproduction TEXT, -- breeding for animals, propagation for plants
    maintenance TEXT, -- care requirements for all types
    notes TEXT,
    
    -- Conservation & Geographic Status
    is_endemic BOOLEAN DEFAULT FALSE,
    
    -- Full-text search (includes geographic terms and content type)
    search_vector TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', 
            coalesce(title, '') || ' ' ||
            coalesce(genus, '') || ' ' ||
            coalesce(species_epithet, '') || ' ' ||
            coalesce(common_names::text, '') || ' ' ||
            coalesce(content_type::text, '') || ' ' ||
            coalesce(habitat_type::text, '') || ' ' ||
            coalesce(habitat, '') || ' ' ||
            coalesce(distribution, '') || ' ' ||
            -- Geographic terms added via trigger function
            coalesce((SELECT string_agg(c.name, ' ') FROM species_countries sc JOIN countries c ON sc.country_id = c.id WHERE sc.species_id = id), '') || ' ' ||
            coalesce((SELECT string_agg(cont.name, ' ') FROM species_countries sc JOIN countries c ON sc.country_id = c.id JOIN continents cont ON c.continent_id = cont.id WHERE sc.species_id = id), '')
        )
    ) STORED,
    
    -- Content-Type Specific Constraints
    CONSTRAINT valid_temp_range CHECK (temp_min_c IS NULL OR temp_max_c IS NULL OR temp_min_c <= temp_max_c),
    CONSTRAINT valid_ph_range CHECK (ph_min IS NULL OR ph_max IS NULL OR ph_min <= ph_max),
    CONSTRAINT valid_size CHECK (max_size_mm IS NULL OR max_size_mm > 0),
    
    -- Marine-specific fields only for marine organisms
    CONSTRAINT marine_fields_check CHECK (
        (habitat_type != 'marine') OR 
        (specific_gravity_min IS NOT NULL AND specific_gravity_max IS NOT NULL)
    ),
    
    -- Plant-specific fields only for plants
    CONSTRAINT plant_fields_check CHECK (
        (content_type != 'plant') OR 
        (light_requirements IS NOT NULL)
    ),
    
    -- Invertebrate-specific validations
    CONSTRAINT invertebrate_fields_check CHECK (
        (content_type != 'invertebrate') OR 
        (social_behavior IS NOT NULL)
    )
);

-- Indexes
CREATE INDEX idx_species_search ON species USING GIN(search_vector);
CREATE INDEX idx_species_scientific ON species(genus, species_epithet);
CREATE INDEX idx_species_family ON species(family_id);
CREATE INDEX idx_species_status ON species(status);
CREATE INDEX idx_species_content_type ON species(content_type);
CREATE INDEX idx_species_habitat_type ON species(habitat_type);
CREATE INDEX idx_species_published ON species(published_at) WHERE status = 'published';
CREATE INDEX idx_species_difficulty ON species(difficulty_level);
CREATE INDEX idx_species_reef_safe ON species(reef_safe) WHERE habitat_type = 'marine';
```

#### **Taxonomic Hierarchy**
```sql
CREATE TABLE families (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    order_name VARCHAR(100),
    class_name VARCHAR(100),
    description TEXT,
    species_count INTEGER DEFAULT 0
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    class_name VARCHAR(100),
    description TEXT
);

CREATE TABLE classes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);
```

#### **Geographic Data** (Key feature for search and heat map)
```sql
CREATE TABLE continents (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    continent_id INTEGER REFERENCES continents(id),
    iso_code VARCHAR(3),
    description TEXT
);

CREATE TABLE rivers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    country_id INTEGER REFERENCES countries(id),
    region TEXT,
    description TEXT
);

-- Many-to-many relationships for species
CREATE TABLE species_countries (
    species_id INTEGER REFERENCES species(id) ON DELETE CASCADE,
    country_id INTEGER REFERENCES countries(id) ON DELETE CASCADE,
    PRIMARY KEY (species_id, country_id)
);

CREATE TABLE species_rivers (
    species_id INTEGER REFERENCES species(id) ON DELETE CASCADE,
    river_id INTEGER REFERENCES rivers(id) ON DELETE CASCADE,
    PRIMARY KEY (species_id, river_id)
);
```

#### **Articles & Content**
```sql
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    content TEXT,
    excerpt TEXT,
    status content_status DEFAULT 'draft',
    category article_category,
    author_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP,
    
    -- Search
    search_vector TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))
    ) STORED
);

CREATE INDEX idx_articles_search ON articles USING GIN(search_vector);
CREATE INDEX idx_articles_category ON articles(category);
CREATE INDEX idx_articles_published ON articles(published_at) WHERE status = 'published';
```

#### **Glossary System** (Auto-linking support)
```sql
CREATE TABLE glossary_terms (
    id SERIAL PRIMARY KEY,
    term VARCHAR(200) UNIQUE NOT NULL,
    definition TEXT NOT NULL,
    aliases JSONB DEFAULT '[]'::jsonb,
    category VARCHAR(100),
    author_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    search_vector TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', term || ' ' || coalesce(definition, ''))
    ) STORED
);

CREATE INDEX idx_glossary_search ON glossary_terms USING GIN(search_vector);
CREATE INDEX idx_glossary_term ON glossary_terms(term);
```

#### **Media Management**
```sql
CREATE TABLE media (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    url VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100),
    file_size INTEGER,
    width INTEGER,
    height INTEGER,
    alt_text VARCHAR(500),
    caption TEXT,
    credit VARCHAR(200),
    uploaded_at TIMESTAMP DEFAULT NOW(),
    uploaded_by INTEGER REFERENCES users(id)
);

CREATE TABLE species_media (
    id SERIAL PRIMARY KEY,
    species_id INTEGER REFERENCES species(id) ON DELETE CASCADE,
    media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    UNIQUE(species_id, media_id)
);

CREATE TABLE article_media (
    article_id INTEGER REFERENCES articles(id) ON DELETE CASCADE,
    media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
    PRIMARY KEY (article_id, media_id)
);
```

#### **Citations & References**
```sql
CREATE TABLE citations (
    id SERIAL PRIMARY KEY,
    citation_text TEXT NOT NULL,
    url VARCHAR(500),
    doi VARCHAR(100),
    publication_year INTEGER,
    authors JSONB DEFAULT '[]'::jsonb
);

CREATE TABLE content_citations (
    content_type VARCHAR(50) NOT NULL, -- 'species', 'article', 'glossary'
    content_id INTEGER NOT NULL,
    citation_id INTEGER REFERENCES citations(id) ON DELETE CASCADE,
    PRIMARY KEY (content_type, content_id, citation_id)
);
```

### Enums and Types
```sql
-- Content and status types
CREATE TYPE content_status AS ENUM ('draft', 'submitted', 'processing', 'published', 'archived');
CREATE TYPE content_type_enum AS ENUM ('fish', 'plant', 'invertebrate');
CREATE TYPE habitat_type_enum AS ENUM ('freshwater', 'marine', 'brackish', 'terrestrial');
CREATE TYPE difficulty_enum AS ENUM ('beginner', 'easy', 'moderate', 'difficult', 'expert');
CREATE TYPE article_category AS ENUM (
    'articles', 'ichthyology', 'new_species', 'conservation', 
    'science', 'beginners_guide', 'discoveries', 'aquatic_plants', 
    'aquatic_invertebrates'
);

-- Plant-specific enums
CREATE TYPE light_enum AS ENUM ('low', 'medium', 'high', 'very_high');
CREATE TYPE co2_enum AS ENUM ('none', 'optional', 'required');
CREATE TYPE growth_enum AS ENUM ('slow', 'medium', 'fast', 'very_fast');
CREATE TYPE placement_enum AS ENUM ('foreground', 'midground', 'background', 'floating', 'epiphyte');
CREATE TYPE fertilizer_enum AS ENUM ('low', 'medium', 'high');

-- Invertebrate-specific enums  
CREATE TYPE molting_enum AS ENUM ('rare', 'monthly', 'weekly', 'frequent');
CREATE TYPE social_enum AS ENUM ('solitary', 'pairs', 'small_groups', 'large_groups', 'schooling');
```

---

## 4. Content Type Expansion Strategy

### Multi-Organism Database Design

The new schema supports multiple organism types within a single `species` table using content-type discrimination. This approach provides:

**✅ Benefits:**
- **SEO Preservation**: All URLs follow `/species/[genus-species]` pattern
- **Unified Search**: Single search index covers all organism types
- **Shared Features**: Geographic relationships, media, citations work across all types
- **Simple Queries**: No complex joins between organism type tables
- **Flexible Expansion**: Easy to add new content types

### Content-Type Specific Field Usage

| Field Category | Fish | Marine Fish | Plants | Invertebrates |
|---------------|------|-------------|---------|---------------|
| **Core Scientific** | ✅ | ✅ | ✅ | ✅ |
| **Size/Physical** | ✅ | ✅ | ✅ (height) | ✅ |
| **Basic Water Params** | ✅ | ✅ | ✅ | ✅ |
| **Marine Parameters** | ❌ | ✅ | ❌ | ✅ (brackish) |
| **Plant-Specific** | ❌ | ❌ | ✅ | ❌ |
| **Invertebrate-Specific** | ❌ | ❌ | ❌ | ✅ |

### URL Structure & SEO Preservation

```
All organism types use consistent URL pattern:
✅ /species/betta-splendens (existing fish - unchanged)
✅ /species/amphiprion-ocellatus (marine fish)  
✅ /species/cryptocoryne-wendtii (aquatic plant)
✅ /species/neocaridina-davidi (freshwater shrimp)

Differentiation via:
- Page titles: "Betta splendens - Siamese Fighting Fish"
- Page titles: "Cryptocoryne wendtii - Wendtii Crypt (Aquatic Plant)"
- Breadcrumbs: Home > Freshwater Fish > Anabantidae > Betta splendens
- Breadcrumbs: Home > Aquatic Plants > Araceae > Cryptocoryne wendtii
- Content type indicators: Icons, badges, search result categories
```

### Submission Form Strategy

```
Content-type specific submission routes:
/submissions/fish/submit          → Freshwater fish form
/submissions/marine-fish/submit   → Marine fish form (adds salinity fields)
/submissions/plant/submit         → Plant form (light, CO2, placement)
/submissions/invertebrate/submit  → Invertebrate form (molting, calcium)

Form field logic:
- Base fields: genus, species, common names, difficulty
- Fish/Inverts: + temperature, pH, diet, behavior  
- Marine: + specific gravity, reef safe, salinity
- Plants: + light requirements, CO2, placement, fertilizer
- Invertebrates: + calcium needs, molting, social behavior
```

---

## 5. WordPress to PostgreSQL Field Mapping

### Species Profile Field Mapping

| WordPress Meta Key | PostgreSQL Column | Data Type | Notes |
|---------------------|-------------------|-----------|-------|
| `genus` | `genus` | VARCHAR(100) | Remove HTML formatting |
| `species` | `species_epithet` | VARCHAR(100) | Remove HTML formatting |
| `family` | `family_id` | INTEGER | Lookup in families table |
| `common_names` | `common_names` | JSONB | Convert to JSON array |
| `synonyms` | `synonyms` | JSONB | Convert to JSON array |
| `species_author` | `taxonomic_authority` | VARCHAR(200) | Direct mapping |
| `year_described` | `year_described` | INTEGER | Direct mapping |
| `etymology` | `etymology` | TEXT | Direct mapping |
| `max_size` | `max_size_mm` | INTEGER | Convert to millimeters |
| `max_size_M` | `max_size_male_mm` | INTEGER | Convert to millimeters |
| `max_size_F` | `max_size_female_mm` | INTEGER | Convert to millimeters |
| `dimorphism` | `dimorphism` | TEXT | Direct mapping |
| `aquarium_L` | `min_tank_length_cm` | INTEGER | Convert to centimeters |
| `aquarium_H` | `min_tank_height_cm` | INTEGER | Convert to centimeters |
| `aquarium_D` | `min_tank_depth_cm` | INTEGER | Convert to centimeters |
| `aquarium_size` | `min_tank_volume_liters` | INTEGER | Parse and convert |
| `beginner_suitability` | `difficulty_level` | difficulty_enum | Map to enum values |
| `temp_min` | `temp_min_c` | DECIMAL(3,1) | Direct mapping (Celsius) |
| `temp_max` | `temp_max_c` | DECIMAL(3,1) | Direct mapping (Celsius) |
| `pH_min` | `ph_min` | DECIMAL(3,1) | Direct mapping |
| `pH_max` | `ph_max` | DECIMAL(3,1) | Direct mapping |
| `hardness_min` | `hardness_min_dgh` | DECIMAL(4,1) | Direct mapping |
| `hardness_max` | `hardness_max_dgh` | DECIMAL(4,1) | Direct mapping |
| `conductivity_min` | `conductivity_min` | INTEGER | Direct mapping |
| `conductivity_max` | `conductivity_max` | INTEGER | Direct mapping |
| `habitat` | `habitat` | TEXT | Clean HTML formatting |
| `distribution` | `distribution` | TEXT | Clean HTML formatting |
| `diet` | `diet` | TEXT | Clean HTML formatting |
| `behaviour` | `behaviour` | TEXT | Clean HTML formatting |
| `reproduction` | `reproduction` | TEXT | Clean HTML formatting |
| `maintenance` | `maintenance` | TEXT | Clean HTML formatting |
| `misc_notes` | `notes` | TEXT | Clean HTML formatting |
| `water_chemistry` | *merged into water params* | - | Parse into specific fields |
| `attached_media` | *species_media table* | - | Parse media relationships |
| `references` | *content_citations* | - | Parse citations |

### Geographic Data Mapping

| WordPress Taxonomy | PostgreSQL Table | Processing Notes |
|--------------------|------------------|------------------|
| `rivers` (1,890 terms) | `rivers` table | Map term names to river records |
| `countries` (232 terms) | `countries` table | Map term names to country records |
| Species → River relationships | `species_rivers` | Extract from species distribution text |
| Species → Country relationships | `species_countries` | Extract from species distribution text |

### Article Category Mapping

| WordPress Category | PostgreSQL Enum | Migration Decision |
|-------------------|-----------------|-------------------|
| Articles | `articles` | ✅ Migrate |
| Ichthyology | `ichthyology` | ✅ Migrate |
| New Species | `new_species` | ✅ Migrate |
| Conservation | `conservation` | ✅ Migrate |
| Science | `science` | ✅ Migrate |
| Beginner's Guide | `beginners_guide` | ✅ Migrate |
| Discoveries | `discoveries` | ✅ Migrate |
| Aquatic Plants | `aquatic_plants` | ✅ Migrate |
| Aquatic Invertebrates | `aquatic_invertebrates` | ✅ Migrate |
| News, Announcements, Blogs | - | ❌ Skip |

---

## 5. Migration Strategy & Implementation

### Phase 1: Schema Setup
1. **Create PostgreSQL schema** with all tables, indexes, and constraints
2. **Seed reference data**: families, orders, classes, countries, rivers
3. **Set up full-text search** configuration and indexes
4. **Create validation functions** for data integrity

### Phase 2: Core Content Migration
1. **Organism Profiles** (Priority 1)
   - Migrate 1,809 published fish profiles with metadata transformation to multi-organism schema
   - Set content_type='fish' and habitat_type='freshwater' for existing content
   - Parse and normalize measurement units
   - Extract geographic relationships from distribution text
   - Clean HTML formatting from text fields
   - Create organism-media relationships
   - Prepare schema for future plant and invertebrate content

2. **Taxonomic Data** (Priority 1)
   - Build family/order/class hierarchy from WordPress taxonomies
   - Normalize scientific classification
   - Link organisms to taxonomic records

3. **Geographic System** (Priority 1)
   - Import rivers and countries from WordPress taxonomies
   - Parse organism distribution text to create geographic relationships
   - Enable geographic search functionality across all content types

### Phase 3: Supporting Content
1. **Glossary Terms** (Priority 2)
   - Migrate 1,731 glossary definitions
   - Set up auto-linking system
   - Create search functionality

2. **Articles** (Priority 2)
   - Migrate ~68 selected articles from approved categories
   - Clean content formatting
   - Preserve media relationships

3. **Media Files** (Priority 2)
   - Filter media files (exclude forum attachments)
   - Upload to Cloudflare R2
   - Create responsive variants
   - Maintain organism/article relationships across all content types

### Phase 4: Search & Discovery
1. **Full-text Search**
   - Optimize search across organisms, articles, glossary
   - Implement geographic filtering
   - Add taxonomic and content-type filtering

2. **Advanced Features**
   - Multi-organism filtering system with content-type specific parameters
   - Related organism suggestions across types
   - Geographic habitat mapping and distribution visualization

---

## 6. Technical Requirements

### Data Validation & Integrity
- **Scientific names**: Binomial nomenclature validation
- **Measurement ranges**: Logical min/max constraints  
- **Geographic consistency**: Valid country/river relationships
- **Required fields**: Genus, species_epithet, content_type, habitat_type for all organisms
- **URL uniqueness**: Slug collision prevention

### Performance Optimization
- **Indexes**: Full-text search, geographic lookups, taxonomic browsing, content-type filtering
- **Caching**: Organism profiles (24h), geographic data (12h), search results (1h)
- **Pagination**: All list views with reasonable limits across content types
- **Image optimization**: Multiple sizes, WebP conversion, lazy loading for all organism types

### SEO & URL Structure
- **Preserve URLs**: `/species/genus-species` format maintained for all organism types
- **301 redirects**: Handle scientific name changes and synonyms
- **Structured data**: Organism-appropriate schema (Animal, Plant schemas), geographic breadcrumbs
- **Meta generation**: Scientific names, care requirements, distribution across all content types

---

## 7. Migration Tools & Scripts Required

### Data Migration Scripts
1. **Organism Migration Script**
   - WordPress `wp_posts` + `wp_postmeta` → PostgreSQL `species` (multi-organism table)
   - Content-type and habitat-type assignment for existing fish data
   - Metadata field transformation and validation
   - Geographic relationship extraction

2. **Media Migration Script** 
   - Filter relevant media files from WordPress uploads
   - Upload to Cloudflare R2 with proper naming
   - Create database records with relationships

3. **Taxonomic Data Script**
   - WordPress taxonomies → PostgreSQL reference tables
   - Build hierarchical relationships

4. **Geographic Data Script**
   - WordPress geographic taxonomies → PostgreSQL geo tables
   - Parse species distribution for geographic relationships

### Development Tools
1. **Schema Migration Tool** (SQL scripts)
2. **Data Validation Scripts** (check data integrity)
3. **URL Redirect Generator** (handle synonym redirects)
4. **Search Index Builder** (optimize full-text search)

---

## 8. Success Metrics

### Data Integrity
- **100% organism migration** with complete metadata (1,809 fish profiles)
- **Multi-organism schema** ready for plants and invertebrates
- **Geographic relationships** extracted and validated
- **Media files** properly linked and accessible across all content types
- **Search functionality** working across all organism types with content-type filtering

### Performance Targets
- **Page load**: <3s globally for organism profiles (all types)
- **Search response**: <200ms for real-time search including content-type filtering
- **Geographic filtering**: <500ms for complex queries across organism types
- **Image delivery**: <1s for high-resolution organism photos

### SEO Preservation
- **URL structure**: Maintain existing `/species/` patterns for all organism types
- **Search rankings**: Preserve 90%+ of current rankings
- **Structured data**: Enhance with organism-appropriate schema (Animal, Plant) and geographic schema
- **Internal linking**: Maintain glossary auto-linking across all content types

---

**This document provides the complete foundation for migrating Seriously Fish from WordPress to PostgreSQL, supporting multi-organism content expansion while preserving existing scientific content and enabling powerful geographic search capabilities.**