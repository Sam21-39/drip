# Publishing DRIP Packages

DRIP publishes from GitHub Actions using pub.dev automated publishing with
GitHub OIDC. No long-lived pub.dev token is stored in GitHub.

## Required pub.dev setup

Enable automated publishing in the pub.dev Admin tab for each package:

| Package | Repository | Tag pattern |
|---|---|---|
| `drip_core` | `Sam21-39/drip` | `v{{version}}` |
| `drip_flutter` | `Sam21-39/drip` | `v{{version}}` |

If pub.dev is configured to require a GitHub environment, use the environment
name `pub.dev`, matching `.github/workflows/publish.yml`.

## Release tags

Create release tags only after the version in the package `pubspec.yaml`
matches the version in the tag and the release commit has been merged to
`main`. The publish workflow refuses to publish tags whose commit is not
contained in `origin/main`.

```bash
git tag v1.0.0
git push origin v1.0.0

git tag v0.7.0-alpha
git push origin v0.7.0-alpha
```

The workflow uses Dart's official reusable publishing workflow:
`dart-lang/setup-dart/.github/workflows/publish.yml@v1`.

Because pub.dev validates the tag against the package version, release tags
must use exactly `v{{version}}`. The workflow routes `v1.0.0` to
`packages/drip_core` and `v0.7.0-alpha` to `packages/drip_flutter`.

`drip_flutter` depends on `drip_core: ^1.0.0`, so publish and wait for
`drip_core 1.0.0` indexing before pushing a `drip_flutter` release tag.
