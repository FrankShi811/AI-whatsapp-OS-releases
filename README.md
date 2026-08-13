# Relvyn

**Local AI Workspace for Global Sales**

**Relvyn｜本地 AI 客户经营工作台**

This is the official public distribution repository for Relvyn. It contains
release notes, legal documents, update manifests, and approved binary
installers. It does not contain the proprietary source code or internal build
documentation.

## Download latest

Download Relvyn only from this repository's **Releases** page. Windows uses a
simplified-Chinese installer and keeps its existing Velopack automatic-update
experience. The release feed, installer and packages are published together;
ordinary users do not need GitHub CLI or a checksum tool before installing.

The proprietary application is built and tested in the authoritative private
source repository. This public repository only receives an immutable draft
candidate, validates the approved asset list and SHA-256 manifest, scans for
source/secret leakage, creates GitHub Artifact Attestations, verifies them, and
then publishes the Stable release. It never compiles the proprietary source.
Immutable releases are enabled for this repository, so future Stable tags and
assets cannot be modified after publication.

## Repository layout

- `installers/` — approved Windows/macOS installers or release placeholders.
- `updates/` — Velopack update manifests and package guidance.
- `CHANGELOG.md` — public version history.
- `EULA.md` — end-user license agreement draft.
- `PRIVACY.md` — factual privacy and data-flow notice.
- `THIRD_PARTY_NOTICES.md` and `licenses/third-party/` — dependency notices and
  exact license-text snapshots.
- `LICENSE` — proprietary project copyright and source-license notice.

## Security / verify download

Every Stable release includes `SHA256SUMS.txt` and
`relvyn-release-manifest.json`. To verify a downloaded installer in Windows
PowerShell:

```powershell
Get-FileHash ".\AI.Sales.OS.Setup.exe" -Algorithm SHA256
```

Compare the result with the matching line in `SHA256SUMS.txt`. Technical users
can also verify the public publication provenance with GitHub CLI:

```powershell
gh attestation verify ".\AI.Sales.OS.Setup.exe" `
  -R FrankShi811/AI-whatsapp-OS-releases
```

GitHub Artifact Attestation confirms the repository/workflow identity and
integrity of the exact public release artifact. It does **not** prove the
private build workflow, replace a Windows Authenticode certificate, guarantee
that software is malware-free, or resolve license compliance. Relvyn currently
has no Windows publisher certificate, so Microsoft Defender SmartScreen may
still show an Unknown Publisher warning.

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
