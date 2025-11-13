# Lobi – Event & Community Mobile App

Lobi is a modern mobile application for discovering, creating, and managing events.  
The app is built to scale like a real product: clean architecture, Supabase backend, theming system, and feature-based structure.

---

## 1. Project Summary

### What is Lobi?

Lobi is a mobile app where users can:

- Sign up / log in with a secure backend (Supabase).
- Create and manage their own events.
- Discover events around them (planned).
- Join events, save them, and follow updates (planned).

The goal is to build a **production-level event and community platform**, not just a demo app.

### Vision

- Design and UX inspired by real-world event platforms (e.g. lu.ma style).
- Sustainable architecture that can grow for years.
- Clear separation of layers (UI, state, domain, data).
- Easily extendable by human developers and AI assistants.

---

## 2. Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** Supabase (Auth, Database, Storage)
- **State / DI (current codebase):**
  - `get_it` for dependency injection
  - (Optional / planned) Riverpod or other state management on top of this structure
- **Theme & Design System:**
  - Centralized light/dark theme in `app_theme.dart`
  - Custom color and typography configuration
- **Other:**
  - `.env` configuration for Supabase and environment-specific values
  - Screen size handling with utilities (e.g. ScreenUtil or similar approach)

---

## 3. Current Features

### Implemented

- **Authentication**
  - User sign up
  - User login
  - Supabase connection configured

- **Event Creation**
  - Users can create events (form + Supabase integration)
  - Basic data model for events in the backend

- **Theming**
  - **Light / Dark theme** controlled from `app_theme.dart`
  - The rest of the UI should consume theme values instead of hard-coded colors

### Planned / Upcoming

These are features that will be added step by step:

- Event feed (Home / Discover)
- Event detail pages
- Join / Save event actions
- Search & filters for events
- Categories & tags
- User profiles (created events, joined events)
- Notifications (push / in-app)
- Multilingual support
- Offline-friendly improvements / caching

---

## 4. Architecture Overview

The project is intended to follow a **clean, scalable structure** inspired by large production apps.

High-level layers:

- **Presentation**
  - Screens / pages
  - Widgets
  - Navigation (bottom navigation, stacks, etc.)

- **Application / State**
  - Controllers / Notifiers / Providers
  - UI logic (loading, error handling, pagination, etc.)

- **Domain**
  - Entities / models
  - Repository interfaces
  - Business rules

- **Data**
  - Supabase services
  - Repository implementations
  - Mappers (from Supabase JSON → domain models)

### Folder Structure (target direction)

This is the *intended* structure for the `lib/` folder, which we will move towards step by step:

```text
lib/
  main.dart
  core/
    di/                # Service locator, dependency injection
    theme/             # app_theme.dart, colors, text styles
    utils/             # common helpers, extensions
    widgets/           # shared UI components (buttons, cards, etc.)
  features/
    auth/
      data/            # AuthRepository implementation, Supabase auth service
      domain/          # User model, auth interfaces
      presentation/    # Login, Register screens, auth-related widgets
    events/
      data/            # EventRepository, Supabase event service
      domain/          # Event model, value objects
      presentation/    # Event list, event detail, create event screens
    profile/
      ...
