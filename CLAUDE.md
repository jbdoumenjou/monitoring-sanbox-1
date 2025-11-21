# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository "monitoring-sanbox-1" appears to be an empty Go project initialized for monitoring-related development. The repository currently contains only basic project scaffolding:

- Standard Go `.gitignore` file
- Basic `README.md`
- License file

## Development Setup

Since this is a Go project (as indicated by the Go-specific .gitignore), you will likely need to:

1. Initialize Go modules when code is added:
   ```
   go mod init github.com/jbdoumenjou/monitoring-sanbox-1
   ```

2. Common Go development commands:
   ```
   go build          # Build the project
   go test ./...     # Run all tests
   go run main.go    # Run the main application (when created)
   go mod tidy       # Clean up dependencies
   ```

## Architecture Notes

This is currently an empty repository. Once code is added, update this file with:
- Main application structure
- Key packages and their responsibilities
- Configuration patterns used
- Any monitoring-specific architectural decisions