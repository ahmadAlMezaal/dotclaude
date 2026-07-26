---
description: CI workflows, containers, infrastructure, and deploy configuration
paths:
  - ".github/workflows/**"
  - "**/Dockerfile*"
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/vercel.json"
  - "**/vercel.ts"
  - "**/fly.toml"
  - "**/eas.json"
  - "supabase/**"
---

# Deployment

Link this only in a repository that actually deploys something. The `paths`
frontmatter narrows it further to the files that configure a deploy.

## Secrets

- No secrets in any of these files. Not a token, not a connection string, not an
  API key, not a private URL.
- CI reads secrets from the platform's secret store and passes them as
  environment variables. Reference them, never inline them.
- Do not echo, print, or log an environment variable that might hold a secret.
  Masking in CI output is not a guarantee.
- Never commit a `.env`. Commit `.env.example` with empty values and the keys
  documented.

## CI workflows

- Pin actions to a version tag at minimum. Never `@master`, never an unpinned
  branch.
- Grant the minimum `permissions` block a job needs rather than relying on the
  default token scope.
- Every pull request runs typecheck, lint, and the test suite. A deploy job
  depends on those passing, never runs in parallel with them.
- Cache the package manager store by lockfile hash. Do not cache `node_modules`
  directly.
- Install with the frozen lockfile flag so CI fails on a stale lockfile rather
  than silently resolving new versions.
- Do not add a workflow that pushes commits, opens PRs, or comments on issues
  unless that is the point of the task.
- Keep workflow changes in their own commit. A CI change buried in a feature
  commit is invisible in review.

## Containers

- Multi-stage builds. The runtime stage carries the built output and production
  dependencies, not the toolchain.
- Pin the base image to a specific version, never `latest`.
- Run as a non-root user in the final stage.
- Order layers so dependency installation is cached separately from the source
  copy: manifests first, install, then the rest of the source.
- Keep a `.dockerignore` that excludes `node_modules`, `.git`, `.env`, and build
  artefacts.
- Do not install debugging tools into a production image.

## Infrastructure as code

- Terraform changes are proposed as a plan first. Never apply without being
  asked, and never apply against production without an explicit instruction.
- Never edit or delete state files, and never run `terraform import`, `taint`,
  or `state rm` unless asked.
- Do not put credentials in `.tfvars`. Use the provider's own secret handling.
- Name resources from variables rather than hardcoding environment names in
  string literals.

## Deploy configuration

- Environment-specific values come from environment variables, not from
  committed configuration.
- Keep the same build command in local scripts and in the deploy config. If they
  drift, the deploy is testing something you never ran.
- A rollback path exists before a risky deploy goes out. Say what it is.
- Database migrations run as their own step, are forward-compatible with the
  currently deployed code, and are never bundled into the application start
  command.
- Do not trigger a production deploy, promote a preview, or run a migration
  against a live database unless explicitly asked in that message.
