# Implementation Plan

- [ ] 1. Fix Backend Build Issues
  - Fix missing handler imports in routes.go
  - Ensure all referenced handlers exist and are properly implemented
  - Test Go build compiles successfully
  - _Requirements: 4.1, 4.3_

- [ ] 2. Consolidate Backend Dockerfiles
  - Remove health_pal_backend/Dockerfile.podman
  - Update health_pal_backend/Dockerfile to work with both Docker and Podman
  - Add runtime-agnostic user management and permissions
  - Test backend builds successfully with both runtimes
  - _Requirements: 1.1, 1.2, 1.4_

- [ ] 3. Consolidate Frontend Dockerfiles
  - Remove health_pal_frontend/Dockerfile.web.podman
  - Update health_pal_frontend/Dockerfile.web to work with both runtimes
  - Remove health_pal_frontend/nginx.podman.conf (use single nginx.conf)
  - Test frontend web builds successfully with both runtimes
  - _Requirements: 1.1, 1.2, 1.4_

- [ ] 4. Create Unified Docker Compose Configuration
  - Replace multiple compose files with single docker-compose.yml using profiles
  - Remove docker-compose.podman.yml and docker-compose.build.podman.yml
  - Create docker-compose.override.yml for development-specific settings
  - Add profiles for: dev, prod, build, apk-build, ios-build, web-build
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [ ] 5. Remove Duplicate Nginx Configurations
  - Remove nginx/nginx.podman.conf
  - Update nginx/nginx.conf to work with both runtimes
  - Consolidate nginx configuration into single file
  - _Requirements: 5.2, 5.3_

- [ ] 6. Simplify Setup Scripts
  - Remove setup-podman.sh (consolidate into setup.sh)
  - Update setup.sh to detect and work with both Docker and Podman
  - Remove test-build-podman-all.bat
  - Add runtime detection to setup.bat
  - _Requirements: 3.1, 3.3, 3.4_

- [ ] 7. Update Makefile for Runtime Detection
  - Add CONTAINER_RUNTIME variable with auto-detection
  - Update all commands to use detected runtime
  - Remove separate Podman commands (use unified commands)
  - Test all Makefile targets work with both Docker and Podman
  - _Requirements: 3.2, 3.4_

- [ ] 8. Update Environment Configuration
  - Consolidate environment variables in .env.example
  - Remove runtime-specific environment files
  - Add CONTAINER_RUNTIME configuration option
  - Document all environment variables clearly
  - _Requirements: 5.2, 5.4_

- [ ] 9. Test Consolidated Setup
  - Test development environment starts correctly with Docker
  - Test development environment starts correctly with Podman
  - Test all build profiles work correctly
  - Test production configuration works correctly
  - _Requirements: 4.1, 4.2, 4.4_

- [ ] 10. Update Documentation
  - Update README.md with simplified setup instructions
  - Remove references to duplicate files and scripts
  - Add troubleshooting section for common issues
  - Document Docker Compose profiles usage
  - _Requirements: 5.4_

- [ ] 11. Clean Up Project Structure
  - Remove all duplicate and unused Docker files
  - Remove unused configuration files
  - Remove orphaned scripts and utilities
  - Verify no broken references remain
  - _Requirements: 5.1, 5.3_