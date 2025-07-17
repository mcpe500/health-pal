-- Health Pal Database Initialization
-- This file contains the basic database setup for Health Pal

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS health_pal;
USE health_pal;

-- Basic health check table
CREATE TABLE IF NOT EXISTS health_check (
    id INT AUTO_INCREMENT PRIMARY KEY,
    status VARCHAR(50) NOT NULL DEFAULT 'healthy',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert initial health check record
INSERT INTO health_check (status) VALUES ('initialized');

-- Note: The actual table creation is handled by GORM Auto-Migration in the Go application
-- This file is just for basic database setup and health checks