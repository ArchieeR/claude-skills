---
name: vercel-troubleshooting
description: A guide to debugging and fixing common Vercel deployment issues for Next.js apps, specifically resolving module resolution, type safety, and configuration pitfalls.
---

# Vercel Deployment Troubleshooting Guide

This skill covers common causes of Vercel build failures and how to prevent them in a Next.js codebase.

## 1. `firebase-admin` & `@google-cloud` Module Resolution
**Symptom:** Build fails with `Error: Cannot find module '@google-cloud/firestore/build/src/path'` or similar errors related to `grpc` or `fs`.
**Cause:** Next.js (especially Turbopack) tries to bundle Node.js-only packages for the Edge runtime or fails to resolve deeply nested dependencies in `firebase-admin`.
**Fix:**
1.  **Externalize Packages:** Add them to `serverExternalPackages` in `next.config.mjs`:
    ```javascript
    serverExternalPackages: [
        'firebase-admin',
        '@google-cloud/firestore',
        '@google-cloud/storage',
        '@google-cloud/functions',
        '@google-cloud/vertexai',
        '@grpc/grpc-js',
        '@grpc/proto-loader',
        'google-gax',
    ],
    ```
2.  **Explicit Dependency:** If the error persists, install the failing package explicitly as a direct dependency in `package.json` (e.g., `npm install @google-cloud/firestore`). This helps the package manager flatten the dependency tree for resolution.

## 2. Strict Type Checks (`scripts/` and local files)
**Symptom:** `npm run build` fails on type errors in files that aren't even used in the app (e.g., `scripts/db-watcher.ts`, `e2e/tests`).
**Cause:** TypeScript by default includes all `.ts` files in the project context. Vercel runs `next build`, which runs type checking on *everything* included in `tsconfig.json`.
**Fix:**
1.  **Exclude Non-App Code:** Add local scripts and test folders to the `exclude` array in `tsconfig.json`:
    ```json
    "exclude": [
        "node_modules",
        "functions",
        "scripts",
        "e2e"
    ]
    ```
2.  **Explicit Compilation:** If you need to run these scripts, use `tsx` or `ts-node` which handles on-the-fly compilation, or have a separate `tsconfig.scripts.json`.

## 3. Implicit `any` Errors
**Symptom:** Local `next dev` works fine, but Vercel build fails with `Parameter 'x' implicitly has an 'any' type`.
**Cause:** Vercel builds strictly use `tsconfig.json` settings (`"noImplicitAny": true`). `next dev` is more permissive during hot reloading.
**Fix:**
- Always run `npm run type-check` (which should run `tsc --noEmit`) locally before pushing.
- Explicitly type all parameters in callbacks, even if just `any` for scripts:
  ```typescript
  // BAD
  query.onSnapshot((snap) => { ... })
  
  // GOOD
  query.onSnapshot((snap: QuerySnapshot) => { ... })
  ```

## 4. Environment Variables
**Symptom:** App works locally but fails to connect to Firebase/APIs on Vercel.
**Cause:**
- `.env.local` is not uploaded to Vercel.
- Private keys (like `FIREBASE_PRIVATE_KEY`) usually need `\n` handling when pasted into Vercel's UI.
**Fix:**
- Manually add variables to Vercel Project Settings > Environment Variables.
- For private keys, use the regex replace pattern in your code:
  ```typescript
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n");
  ```

## 5. Case Sensitivity (Mac vs Linux)
**Symptom:** `Module not found: Can't resolve './Component'`
**Cause:** Mac is case-insensitive (`import './file'` finds `./File.ts`). Vercel (Linux) is case-sensitive.
**Fix:**
- Ensure import paths exactly match filenames.
- Use `git mv` if you need to rename a file only by case (e.g., `git mv file.ts File.ts`).
