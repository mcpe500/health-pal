# Requirements Document

## Introduction

This specification outlines the requirements for cleaning up and consolidating the Health Pal Docker infrastructure. The current setup has too many duplicated Docker files, Docker Compose files, and scripts that make the project complex and hard to maintain. The goal is to remove duplicates and create a simple, clean Docker setup.

## Requirements

### Requirement 1: Remove Duplicate Docker Files

**User Story:** As a developer, I want to eliminate duplicate Docker files, so that I can maintain a single source of truth for each service.

#### Acceptance Criteria

1. WHEN examining Dockerfiles THEN each service SHALL have only one Dockerfile
2. WHEN building with Docker or Podman THEN the same Dockerfile SHALL work for both
3. IF separate Podman files exist THEN they SHALL be removed and consolidated
4. WHEN configuring builds THEN environment variables SHALL handle differences between Docker and Podman

### Requirement 2: Consolidate Docker Compose Files

**User Story:** As a developer, I want fewer Docker Compose files, so that I can easily understand and manage different deployment scenarios.

#### Acceptance Criteria

1. WHEN reviewing compose files THEN there SHALL be maximum 2 files: docker-compose.yml and docker-compose.override.yml
2. WHEN switching environments THEN Docker Compose profiles SHALL be used instead of separate files
3. IF Podman-specific compose files exist THEN they SHALL be removed
4. WHEN building different platforms THEN Docker Compose profiles SHALL handle the variations

### Requirement 3: Simplify Scripts

**User Story:** As a developer, I want minimal setup scripts, so that I can quickly get started without confusion.

#### Acceptance Criteria

1. WHEN setting up the project THEN there SHALL be one setup script that works for both Docker and Podman
2. WHEN running builds THEN the Makefile SHALL handle all build scenarios
3. IF duplicate scripts exist THEN they SHALL be removed
4. WHEN choosing container runtime THEN it SHALL be configurable via environment variable

### Requirement 4: Fix Missing Dependencies

**User Story:** As a developer, I want all builds to work without errors, so that I can successfully build and run the application.

#### Acceptance Criteria

1. WHEN building the backend THEN all Go dependencies SHALL be available
2. WHEN building the frontend THEN all Flutter dependencies SHALL be resolved
3. IF handlers or middleware are missing THEN they SHALL be implemented or references removed
4. WHEN running containers THEN all required files SHALL be present

### Requirement 5: Clean Project Structure

**User Story:** As a developer, I want a clean project structure, so that I can easily navigate and understand the codebase.

#### Acceptance Criteria

1. WHEN examining the project THEN there SHALL be no unused or orphaned Docker files
2. WHEN looking at configuration THEN there SHALL be one clear way to configure each service
3. IF multiple similar configurations exist THEN they SHALL be consolidated
4. WHEN documenting setup THEN instructions SHALL be simple and straightforward