# Architecture

## Layers
- app: composition root, routing, app-level setup
- core: shared utilities and cross-cutting concerns
- features: isolated feature modules (data, domain, presentation)
- shared: reusable widgets and design system pieces

## Conventions
- Feature-first organization under `lib/features`
- Domain layer uses abstract contracts
- Data layer provides implementations
- Presentation layer contains UI and state management

