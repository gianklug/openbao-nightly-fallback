---
name: Build Failure
about: Report a failed nightly build
title: '[BUILD FAILURE] YYYY-MM-DD - Brief description'
labels: build-failure
assignees: ''
---

## Build Information

**Date**: YYYY-MM-DD
**Workflow Run**: [Link to failed workflow run]
**OpenBao Commit**: [commit hash or link]

## Failure Details

### Step that Failed
<!-- e.g., "Build OpenBao binary", "Run GoReleaser", "Build UI assets" -->

### Error Message
```
Paste error message here
```

### Full Log
<!-- Attach or paste relevant section of the build log -->

## Context

- [ ] This is the first build failure in a row
- [ ] This has failed multiple times consecutively
- [ ] This worked previously on [date]
- [ ] This is a manual trigger (not scheduled)

## Possible Causes

<!-- Check any that might apply -->
- [ ] OpenBao repository changes (dependency updates, build process changes)
- [ ] GitHub Actions runner issues
- [ ] Network/connectivity issues
- [ ] Configuration changes in this repository
- [ ] Rate limiting or quota issues
- [ ] Other (describe below)

## Additional Notes

<!-- Any other relevant information -->

## Attempted Fixes

<!-- List any troubleshooting steps already tried -->

---

## For Maintainers

### Quick Checks
- [ ] Check OpenBao repo for recent breaking changes
- [ ] Verify workflow permissions
- [ ] Check Go/Node.js version compatibility
- [ ] Review goreleaser configuration
- [ ] Test local build with `./scripts/local-build.sh`

### Resolution Steps
<!-- To be filled in when investigating -->
