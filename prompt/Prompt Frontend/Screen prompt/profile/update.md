# Profile Skills - Coding Category Enhancement

## Objective

Enhance the **Skills** section by providing a more detailed skill selection flow for the **Coding** category while keeping the existing design and interaction consistent with the rest of the application.

---

# Scope

Update only the **Skills** section.

Do not modify the business logic outside of the Skills feature.

---

# Coding Skill Selection Flow

Currently, users can directly select **Coding** as a skill.

Update the behavior so that selecting **Coding** opens additional selections.

The flow should be:

```text
Coding
    │
    ▼
Select Category
    │
    ├── Frontend
    ├── Backend
    └── Other

Frontend / Backend
    │
    ▼
Select Specific Skill
```

---

# Step 1 - Select Category

When the user selects **Coding**, display a second selection screen or bottom sheet.

Display the following categories:

- Frontend
- Backend
- Other

The UI should follow the same design as the existing skill selection.

---

# Step 2 - Select Specific Skill

After selecting **Frontend** or **Backend**, display a list of related technologies.

Provide **at least 20 skills** for each category.

The final option in every list must always be:

- Other

Selecting **Other** allows users to create their own custom skill.

---

# Frontend Skills

Include at least the following technologies:

- Flutter
- Dart
- HTML
- CSS
- JavaScript
- TypeScript
- React
- React Native
- Next.js
- Vue.js
- Nuxt.js
- Angular
- Svelte
- Tailwind CSS
- Bootstrap
- Material UI
- jQuery
- Sass (SCSS)
- Less
- Alpine.js
- Ionic
- Electron
- Expo
- Other

You may include additional frontend technologies if appropriate.

---

# Backend Skills

Include at least the following technologies:

- Java
- Spring Boot
- Kotlin
- C#
- ASP.NET
- PHP
- Laravel
- CodeIgniter
- Node.js
- Express.js
- NestJS
- Python
- Django
- Flask
- FastAPI
- Ruby on Rails
- Go
- Rust
- C++
- MySQL
- PostgreSQL
- MongoDB
- Redis
- Firebase
- GraphQL
- Docker
- Kubernetes
- Other

You may include additional backend technologies if appropriate.

---

# Other Option

When the user selects **Other**, display a form to create a custom skill.

Fields:

- Skill Name (Required)
- Skill Icon/Image (Optional)

Requirements:

- Users may leave the image empty.
- If no image is provided, display the default skill icon.
- The custom skill should behave the same as predefined skills.

---

# Skill Icons

Each predefined coding technology should have its own official icon or logo.

Examples:

- Flutter
- Dart
- Java
- Spring Boot
- HTML
- CSS
- JavaScript
- React
- Vue
- Angular
- Node.js
- Docker
- Kubernetes
- Laravel
- Django
- MongoDB
- MySQL
- PostgreSQL
- Firebase
- etc.

## Requirements

Find and use the most recognizable official logo or icon for each technology.

Do not reuse a generic coding icon.

Each technology should display its own corresponding logo.

---

# Skill Circle Design

The existing skill circle design should remain unchanged.

Only update the content inside the circle.

Requirements:

- Keep the existing circle size.
- Place the technology logo or icon inside the circle.
- Display the logo as a background watermark with approximately **30% opacity**.
- Keep the skill text readable above the background image.
- Use consistent alignment and scaling for every technology.

Example:

```text
┌──────────────┐
│              │
│     70%      │
│              │
│  (Logo 30%)  │
│              │
└──────────────┘
```

---

# Other Skill Categories

The same enhancement should also apply to the remaining skill categories.

Requirements:

- Display an appropriate icon or image for each category.
- Keep the same UI design used by the Coding category.
- Maintain consistent sizing, spacing, and opacity.

Examples:

- Design
- UI/UX
- Networking
- Cybersecurity
- AI
- Data Science
- Cloud Computing
- Mobile Development
- DevOps
- Project Management
- Marketing
- Business
- Photography
- Video Editing
- Writing
- Language
- Music
- Sports
- Others

Use icons or images that clearly represent each category.

---

# Design Requirements

- Follow the existing Skills UI.
- Maintain the current spacing, typography, and layout.
- Keep the interaction consistent with other skill selections.
- Use the existing bottom sheet or selection UI where applicable.
- Support both Light Mode and Dark Mode.

---

# Implementation Notes

- Preserve all existing business logic.
- Update only the skill selection flow and UI.
- Reuse existing widgets where possible.
- Avoid duplicate implementations.
- Organize the skill data into reusable models or constants.
- Make it easy to add new categories or technologies in the future.
- Ensure the "Other" option is always the last item in every selection list.

```

```
