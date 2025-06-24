#!/bin/bash
set -e

echo "🐟 Setting up Seriously Fish database..."

# Create archive directory if it doesn't exist
mkdir -p ./archive/db

# Check if there are any SQL files to load
SQL_FILES=(./archive/db/*.sql)
if [ ! -e "${SQL_FILES[0]}" ]; then
    echo "❌ No SQL files found in ./archive/db/"
    echo "Please place your database dump (seriously_fish_export.sql) in ./archive/db/"
    exit 1
fi

echo "📁 Found SQL files:"
ls -la ./archive/db/*.sql

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Start MySQL container
echo "🚀 Starting MySQL container..."
docker-compose up -d mysql

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
while ! docker exec seriously-fish-mysql mysqladmin ping -h localhost -u root -p'rootpassword' --silent; do
    echo "   Still waiting for MySQL..."
    sleep 2
done

echo "✅ MySQL is ready!"

# Load each SQL file found
for sql_file in ./archive/db/*.sql; do
    echo "📥 Loading database from $(basename "$sql_file")..."
    docker exec -i seriously-fish-mysql mysql -u root -p'rootpassword' seriously_fish_local < "$sql_file"
    echo "✅ Loaded $(basename "$sql_file")"
done

# Test the database has data
echo "🔍 Testing database content..."
echo "Tables in database:"
docker exec seriously-fish-mysql mysql -u root -p'rootpassword' seriously_fish_local -e "SHOW TABLES;"

echo ""
echo "Post types and counts:"
docker exec seriously-fish-mysql mysql -u root -p'rootpassword' seriously_fish_local -e "SELECT post_type, COUNT(*) as count FROM wp_posts GROUP BY post_type ORDER BY count DESC;" 2>/dev/null || echo "No wp_posts table found"

echo ""
echo "🎉 Database setup complete!"
echo ""
echo "To connect to MySQL:"
echo "  docker exec -it seriously-fish-mysql mysql -u root -p'rootpassword' seriously_fish_local"
echo ""
echo "To stop the database:"
echo "  docker-compose down"