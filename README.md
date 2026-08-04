# Relvyn

**Local AI Workspace for Global Sales**

**Relvyn｜本地 AI 客户经营工作台**

This is the official public distribution repository for Relvyn. It contains
release notes, legal documents, update manifests, and approved binary
installers. It does not contain the proprietary source code or internal build
documentation.

## Distribution status

Commercial binary publication is currently **paused by the compliance release
gate**. No installer or update manifest is published until the open copyleft
dependency and brand-asset provenance issues are resolved and documented.
Passing engineering tests does not override that gate.

When an approved release is available, users should download it only from this
repository's **Releases** page. The automated update feed and its referenced
packages will be published together so installed clients can verify and fetch
the same release chain.

## Repository layout

- `installers/` — approved Windows/macOS installers or release placeholders.
- `updates/` — Velopack update manifests and package guidance.
- `CHANGELOG.md` — public version history.
- `EULA.md` — end-user license agreement draft.
- `PRIVACY.md` — factual privacy and data-flow notice.
- `THIRD_PARTY_NOTICES.md` and `licenses/third-party/` — dependency notices and
  exact license-text snapshots.
- `LICENSE` — proprietary project copyright and source-license notice.

## Legacy update compatibility

Existing installed versions still obtain updates from the legacy public
repository. That compatibility repository must remain reachable until an
approved transition release has moved those clients to this feed. It must not
be made private prematurely.

## Legal

Relvyn is proprietary software. Public availability of this release repository
does not grant permission to copy, modify, redistribute, resell, host, or
commercially exploit the source code. Installed software is governed by the
[EULA](EULA.md); data flows are described in the [privacy notice](PRIVACY.md);
third-party components remain subject to their [own licenses](THIRD_PARTY_NOTICES.md).

Commercial licensing contact: **[TO BE CONFIRMED]**.
