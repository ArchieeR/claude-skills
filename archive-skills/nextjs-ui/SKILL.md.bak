---
name: nextjs-ui
description: Universal UI patterns for Next.js 16 + React 19 + Tailwind v4 + shadcn/ui projects. Layout architecture, responsive design, component patterns, color system.
trigger: When building pages, components, layouts, or fixing responsive/styling issues in any project.
---

# Next.js UI Standards

Universal UI patterns for projects using Next.js 16 + React 19 + Tailwind CSS v4 + shadcn/ui.

## Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Framework | Next.js 16 (App Router) | React 19, Server Components by default |
| Styling | Tailwind CSS v4 | CSS-first config, no tailwind.config |
| Components | shadcn/ui (new-york) | Radix UI primitives underneath |
| Icons | Lucide React only | No other icon libraries |
| Class merging | `cn()` from `@/lib/utils` | Always use for conditional classes |
| Animations | Framer Motion (optional) | For page transitions, micro-interactions |

## Layout Patterns

### App Shell (SaaS apps)
```tsx
<SidebarProvider>
  <AppSidebar />
  <SidebarInset>
    {children}
  </SidebarInset>
</SidebarProvider>
<MobileBottomNav />  {/* md:hidden */}
```

### Marketing Site
```tsx
<Navbar />
<main className="min-h-screen">
  {children}
</main>
<Footer />
```

### Page Content Structure
```tsx
export default function Page() {
  return (
    <div className="flex flex-col h-full">
      <header className="shrink-0 h-14 border-b px-4 flex items-center">
        <h1>Page Title</h1>
      </header>
      <main className="flex-1 overflow-auto p-4 md:p-6">
        {/* Content */}
      </main>
    </div>
  )
}
```

## Responsive Design

### Mobile-first — ALWAYS
```tsx
// Start mobile, add desktop
className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
className="p-4 md:p-6 lg:p-8"
className="text-sm md:text-base"
```

### Breakpoints (Tailwind defaults only)
- `sm:` 640px
- `md:` 768px (mobile/desktop breakpoint)
- `lg:` 1024px
- `xl:` 1280px

### Responsive visibility
```tsx
className="hidden md:flex"    // Desktop only
className="flex md:hidden"    // Mobile only
```

### Touch targets
Minimum 44x44px for interactive elements on mobile.

## Color System

Use CSS variables, never hardcode colors:
```tsx
className="bg-background text-foreground"
className="bg-card text-card-foreground"
className="bg-muted text-muted-foreground"
className="bg-primary text-primary-foreground"
className="bg-destructive text-destructive-foreground"
```

## Component Patterns

### Import
```tsx
import { Button } from "@/components/ui/button"
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
```

### Class merging
```tsx
import { cn } from "@/lib/utils"

className={cn("base-styles", isActive && "active-styles", className)}
```

### Common layouts

**Responsive card grid:**
```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-4 md:p-6">
```

**Centered content:**
```tsx
<div className="w-full max-w-4xl mx-auto px-4">
```

**Full-height with scrollable area:**
```tsx
<div className="flex flex-col h-full">
  <header className="shrink-0" />
  <main className="flex-1 overflow-auto" />
</div>
```

**Sticky header:**
```tsx
<div className="sticky top-0 z-10 bg-background">
```

## File Organisation

```
components/
├── ui/           # shadcn/ui base (don't modify)
├── layout/       # App shell, sidebar, nav, footer
├── features/     # Domain-specific (by feature area)
├── shared/       # Cross-feature reusable
├── providers/    # Context providers
└── dialogs/      # Modal components
```

## Rules

### DO
- Use `cn()` for all conditional classes
- Test at 375px width AND desktop
- Use `h-full` not `h-screen` in nested containers
- Use `flex-1 min-w-0` for flexible containers
- Use CSS variables for all colors

### DON'T
- Don't use `style={{}}` — always Tailwind
- Don't hardcode colors or breakpoints
- Don't use fixed pixel widths for content
- Don't rely on `:hover` for critical actions
- Don't add custom breakpoints

## Visual QA

After building UI, always verify visually:
1. Use `/ss` to screenshot Chrome
2. Check mobile (375px) and desktop (1280px+)
3. Check dark mode if supported
4. Verify touch targets on mobile
