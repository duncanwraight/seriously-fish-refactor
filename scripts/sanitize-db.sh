#!/bin/bash
set -e

echo "🧹 Sanitizing Seriously Fish database for safe commits..."

# Database connection info
DB_NAME="seriously_fish_local"
DB_USER="root"
DB_PASS="rootpassword"
CONTAINER_NAME="seriously-fish-mysql"

# Output file
OUTPUT_FILE="./archive/db/sf-db-sanitized.sql"

echo "📊 Current database stats:"
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 
    'Users' as table_name, COUNT(*) as count FROM wp_users
UNION ALL
SELECT 
    'Species' as table_name, COUNT(*) as count FROM wp_posts WHERE post_type = 'species'
UNION ALL
SELECT 
    'Articles' as table_name, COUNT(*) as count FROM wp_posts WHERE post_type = 'post'
UNION ALL
SELECT 
    'Glossary' as table_name, COUNT(*) as count FROM wp_posts WHERE post_type = 'glossary'
"

echo ""
echo "🔒 Sanitizing sensitive data..."

# Create sanitization SQL script
cat > /tmp/sanitize.sql << 'EOF'
-- Sanitize user data
UPDATE wp_users SET 
    user_pass = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: 'password'
    user_email = CONCAT('user', ID, '@example.com'),
    user_url = '',
    user_activation_key = '',
    display_name = CONCAT('User ', ID);

-- Sanitize user metadata (keep structure, sanitize values)
UPDATE wp_usermeta SET meta_value = 'sanitized' 
WHERE meta_key IN ('first_name', 'last_name', 'description', 'aim', 'yim', 'jabber');

-- Remove sensitive options
DELETE FROM wp_options WHERE option_name IN (
    'cp_auth_key',
    'ezoic_cdn_api_key',
    'frm_connect_token',
    'frm_form_state_key',
    'ga_google_authtoken',
    'ga_google_token',
    'gsg_indexnow-admin_api_key',
    'postman_auth_token',
    'q_wpcomAPIkey',
    'wordpress_api_key',
    'wpmudev_apikey',
    'wpsqt_docraptor_api'
);

-- Remove API keys and tokens from any remaining options
UPDATE wp_options SET option_value = 'sanitized' 
WHERE option_name LIKE '%key%' 
   OR option_name LIKE '%secret%' 
   OR option_name LIKE '%token%' 
   OR option_name LIKE '%password%'
   OR option_name LIKE '%api%';

-- Clean up logs and tracking data
DELETE FROM wp_cleantalk_ac_log;
DELETE FROM wp_cleantalk_connection_reports;
DELETE FROM wp_cleantalk_sessions;
DELETE FROM wp_cleantalk_sfw_logs;
DELETE FROM wp_cleantalk_spamscan_logs;
DELETE FROM wp_audit_trail;
DELETE FROM wp_wfAuditEvents;
DELETE FROM wp_wfBlockedIPLog;
DELETE FROM wp_wfHits;
DELETE FROM wp_wfLiveTrafficHuman;
DELETE FROM wp_wfLogins;
DELETE FROM wp_wfSecurityEvents;
DELETE FROM wp_redirection_logs;
DELETE FROM wp_relevanssi_log;

-- Remove spam content but keep structure
DELETE FROM wp_posts WHERE post_status = 'spam';
DELETE FROM wp_comments WHERE comment_approved = 'spam';

-- Sanitize comment author data
UPDATE wp_comments SET 
    comment_author_email = CONCAT('commenter', comment_ID, '@example.com'),
    comment_author_url = '',
    comment_author_IP = '127.0.0.1';

-- Keep only essential Simple Press forum data, remove personal info
UPDATE wp_sfmembers SET 
    display_name = CONCAT('Member', user_id),
    signature = 'Sanitized signature',
    feedkey = NULL,
    admin_options = NULL,
    user_options = NULL;

-- Remove private messages
DELETE FROM wp_sfpmmessages;
DELETE FROM wp_sfpmrecipients;
DELETE FROM wp_sfpmthreads;
DELETE FROM wp_sfpmattachments;

-- Clean user activity logs
DELETE FROM wp_sfuseractivity;
DELETE FROM wp_sftrack;
DELETE FROM wp_sflog;
EOF

# Apply sanitization
echo "🔄 Applying sanitization..."
docker exec -i $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME < /tmp/sanitize.sql

echo "📤 Exporting sanitized database..."
docker exec $CONTAINER_NAME mysqldump -u $DB_USER -p$DB_PASS \
    --single-transaction \
    --routines \
    --triggers \
    --add-drop-table \
    --complete-insert \
    $DB_NAME > $OUTPUT_FILE

echo "🧹 Cleaning up temporary files..."
rm /tmp/sanitize.sql

echo ""
echo "✅ Sanitization complete!"
echo "📁 Sanitized database saved to: $OUTPUT_FILE"
echo "📊 File size: $(du -h $OUTPUT_FILE | cut -f1)"
echo ""
echo "🔍 Quick verification:"
docker exec $CONTAINER_NAME mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
SELECT 'Sanitized users' as check_type, COUNT(*) as count 
FROM wp_users WHERE user_email LIKE '%@example.com';
"

echo ""
echo "⚠️  IMPORTANT: Review the sanitized file before committing!"
echo "    - Check that species and article content is preserved"
echo "    - Verify no real email addresses remain"
echo "    - Confirm API keys are removed"