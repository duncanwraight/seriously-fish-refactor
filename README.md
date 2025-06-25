# Seriously Fish Refactor Project

Welcome! This repository contains the planning and development work for refactoring the Seriously Fish website (https://www.seriouslyfish.com).

## 📋 Project Overview

If you're looking to understand what this project is about, here are the key documents to review:

### 📚 [Requirements Document](docs/REQUIREMENTS.md)
This comprehensive document outlines the complete vision for the modernized Seriously Fish website. It covers:
- Moving from WordPress to a modern React-based architecture
- Giving the capability to expand beyond tropical freshwater fish to include marine fish, aquatic plants, and freshwater invertebrates
- Creating powerful search and discovery features, including a strong focus on geographical locations
- Building a community-driven content submission system

### 🗄️ [Database Migration Requirements](docs/DATABASE_MIGRATION_REQUIREMENTS.md)
This document details how we'll migrate the existing WordPress/MySQL database to a modern PostgreSQL setup. It includes:
- Analysis of the current database structure
- Migration strategy and data preservation plans
- Technical requirements for maintaining existing content and URLs

This document also shows information about what our new application's database structure would be. You can see what type of content would be stored for all the different organisms, including content that is shared across all organisms and some content that is type-specific.

### 🎨 [Homepage Design Concept](wireframes/homepage-wireframe.png)
This is a screenshot of an example wireframe concept created by AI, based on designs like the Uber website.

Instead of a WordPress-style blog post, this approach suggests using the homepage as a signpost for the types of content available on the website, such as:
- Interactive world map for exploring species by geography
- Advanced filtering system for finding the perfect fish
- Beginner-friendly guides and resources
- Expansion into aquatic plants and invertebrates
- Community integration via Discord

## 🔧 Technical Files
All other files and directories in this repository are for technical development purposes and can be safely ignored if you're just trying to understand the project vision. These include database analysis scripts, Docker configurations, and development tooling.

---

*This project aims to preserve and enhance the scientific value of Seriously Fish while making it more accessible and comprehensive for the fishkeeping community.*
