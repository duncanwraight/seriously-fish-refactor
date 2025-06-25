#!/bin/bash
set -e

# Database connection info
DB_NAME="seriously_fish_local"
DB_USER="root"
DB_PASS="rootpassword"
CONTAINER_NAME="seriously-fish-mysql"

# Output directory
OUTPUT_DIR="./analysis"
mkdir -p $OUTPUT_DIR

echo "🔍 Analyzing Seriously Fish database schema..."
echo ""

# 1. Table overview
echo "📋 1. Table overview..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    TABLE_NAME as table_name,
    TABLE_ROWS as row_count,
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) as size_mb
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = '$DB_NAME'
ORDER BY TABLE_ROWS DESC;
" > $OUTPUT_DIR/01_tables.txt 2>/dev/null

# 2. Content types
echo "📝 2. Content types..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT post_type, post_status, COUNT(*) as count 
FROM wp_posts 
GROUP BY post_type, post_status 
ORDER BY count DESC;
" > $OUTPUT_DIR/02_content_types.txt 2>/dev/null

# 3. Species metadata
echo "🐟 3. Species metadata..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    pm.meta_key,
    COUNT(*) as usage_count,
    COUNT(DISTINCT pm.meta_value) as unique_values
FROM wp_postmeta pm
JOIN wp_posts p ON pm.post_id = p.ID
WHERE p.post_type = 'species' AND p.post_status = 'publish'
GROUP BY pm.meta_key
ORDER BY usage_count DESC;
" > $OUTPUT_DIR/03_species_meta.txt 2>/dev/null

# 4. Taxonomies
echo "🔗 4. Taxonomies..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT taxonomy, COUNT(*) as term_count
FROM wp_term_taxonomy
GROUP BY taxonomy
ORDER BY term_count DESC;
" > $OUTPUT_DIR/04_taxonomies.txt 2>/dev/null

# 5. Sample species data
echo "📄 5. Sample species..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    post_title,
    post_name,
    post_date,
    LENGTH(post_content) as content_length
FROM wp_posts
WHERE post_type = 'species' AND post_status = 'publish'
ORDER BY post_date DESC
LIMIT 5;
" > $OUTPUT_DIR/05_sample_species.txt 2>/dev/null

# 6. Key species metadata examples
echo "🔬 6. Species metadata examples..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    p.post_title,
    pm.meta_key,
    pm.meta_value
FROM wp_posts p
JOIN wp_postmeta pm ON p.ID = pm.post_id
WHERE p.post_type = 'species' 
    AND p.post_status = 'publish'
    AND pm.meta_key IN ('_scientific_name', '_common_name', '_max_length', '_temperature_low', '_temperature_high', '_ph_low', '_ph_high')
    AND p.post_title LIKE '%Betta%'
LIMIT 20;
" > $OUTPUT_DIR/06_species_meta_examples.txt 2>/dev/null

# 7. Forum structure
echo "💬 7. Forum structure..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 'Forums' as type, COUNT(*) as count FROM wp_sfforums
UNION ALL
SELECT 'Topics', COUNT(*) FROM wp_sftopics
UNION ALL  
SELECT 'Posts', COUNT(*) FROM wp_sfposts
UNION ALL
SELECT 'Members', COUNT(*) FROM wp_sfmembers;
" > $OUTPUT_DIR/07_forum_stats.txt 2>/dev/null

# 8. Media files
echo "🖼️ 8. Media analysis..."
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    SUBSTRING_INDEX(guid, '.', -1) as extension,
    COUNT(*) as file_count
FROM wp_posts 
WHERE post_type = 'attachment'
GROUP BY SUBSTRING_INDEX(guid, '.', -1)
ORDER BY file_count DESC;
" > $OUTPUT_DIR/08_media.txt 2>/dev/null

echo ""
echo "✅ Analysis complete! Files generated:"
ls -la $OUTPUT_DIR/

echo ""
echo "📊 Quick summary:"
echo "Tables: $(cat $OUTPUT_DIR/01_tables.txt | wc -l) tables found"
echo "Species: $(grep species $OUTPUT_DIR/02_content_types.txt | grep publish | cut -f3)"
echo "Metadata fields: $(cat $OUTPUT_DIR/03_species_meta.txt | wc -l) different metadata keys for species"

echo ""
echo "🎯 Review these key files:"
echo "• 02_content_types.txt - What content types exist"
echo "• 03_species_meta.txt - All species data fields"  
echo "• 04_taxonomies.txt - Classification system"
echo "• 06_species_meta_examples.txt - Real species data examples"