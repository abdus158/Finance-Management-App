# Performance Guidelines

## Goals
- Fast startup
- Smooth scrolling
- Minimal battery usage

## Rules

### UI
- Avoid rebuilding entire widgets
- Use const constructors
- Lazy load large lists

### Database
- Use indexes
- Avoid blocking queries

### State Management
- Minimize unnecessary provider refreshes

### Animations
- Keep under 300ms
- Avoid heavy shadows everywhere

### Memory
- Dispose controllers properly
- Avoid memory leaks
