# Auth Screen Background Update

> **Status: applied (v1 UI complete).**  
> This brief drove the Auth wave-background redesign. Do **not** re-implement from scratch — code lives under `vithey_app/lib/modules/auth/` (and shared wave widgets with Splash / Select Language / Onboarding).  
> Canonical prompts: [`README.md`](README.md) → `v1/04`–`v1/07`.

## Objective

Update all **Auth** screens so they follow the same visual design language as the other startup screens.

### Reference

Use the existing implementations as the design reference:

- Splash Screen
- Language Screen
- Onboarding Screens

These screens already have the correct background implementation.

---

# Overall Goal

The Auth screens should feel like they belong to the same design system as the Splash, Language, and Onboarding screens.

Reuse the same background concept, colors, and design language while allowing each Auth screen to have its own unique wave shape.

---

# Background Design

Update every Auth screen to use the shared background design.

## Background Colors

Use the same three background layers:

- Teal
- White
- White (50% opacity)

Do not introduce new colors.

---

## Wave Shapes

The White and White 50% layers should be implemented as wave shapes.

### Requirements

- Each Auth screen should have its own unique wave shape.
- The curve, bend, and angle should vary between screens.
- The design language should remain consistent across all screens.
- Reuse the same drawing/material implementation whenever possible.
- Avoid creating separate implementations for each screen.

Examples:

- Different curve height
- Different curve angle
- Different bending position
- Different wave depth

Although every screen looks different, they should clearly belong to the same visual family.

---

# Existing Screens

The following screens already have the correct implementation:

- Splash Screen
- Language Screen
- Onboarding Screens

Use these as the reference implementation.

Only update the **Auth** screens.

---

# Auth Background

Replace the current Auth background.

### Requirements

- Match the background style used by the other startup screens.
- Implement the layered Teal + White + White 50% design.
- Ensure the White layers use wave shapes instead of simple containers.
- Maintain responsive behavior across different screen sizes.

---

# Auth Content Layout

Update the placement of the Auth content.

## Current Issue

Some content is currently placed inside the White background layer.

This makes the background behave like a container instead of a decorative background.

## New Behavior

The wave shapes should remain purely decorative.

The Auth content should be positioned independently of the background.

Requirements:

- Do not place content inside the White or White 50% layers.
- Treat the wave layers as background elements only.
- Position the Auth content above the background using the normal screen layout.

---

# Content Alignment

Update the layout of every Auth screen.

### Requirements

- Place the content inside a `Column`.
- Use `MainAxisAlignment.end`.
- The content should start from the bottom portion of the screen.
- Apply **30px padding** around the content.
- Keep spacing consistent across every Auth screen.

---

# Consistency

All Auth-related screens should follow the same visual language.

Examples include:

- Sign In
- Sign Up
- Forgot Password
- Reset Password
- Verify Code
- Google Auth screens
- Any other Auth screens

Each screen may have:

- Different wave angles
- Different wave curves
- Different wave positions

However, they must all use the same:

- Background colors
- Wave material
- Design language
- Overall visual identity

---

# Design Requirements

- Match the Splash, Language, and Onboarding screens as closely as possible.
- Keep the UI modern, clean, and consistent.
- Support responsive layouts.
- Support both Light Mode and Dark Mode where applicable.

---

# Implementation Notes

- Preserve all existing business logic.
- Do not modify navigation or authentication functionality.
- Reuse the existing background implementation whenever possible.
- Avoid duplicate implementations.
- Keep the code modular, reusable, and maintainable.
