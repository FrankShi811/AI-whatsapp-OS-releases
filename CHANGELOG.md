# Relvyn public changelog

## 5.23.0 — private-source/public-distribution transition

- Moves future proprietary builds to the authoritative private source
  repository while keeping public Windows downloads and Velopack updates free
  to access.
- Adds SHA-256 coverage, a release manifest, exact public asset auditing,
  GitHub Artifact Attestation and repository-bound self-verification before a
  draft can become Stable.
- Keeps the historical `AISalesOS` Velopack identity and
  `AI.Sales.OS.Setup.exe` compatibility filename so installed and portable
  clients do not select the new security metadata as an update package.
- Publishes the GPL-required WhatsApp Bridge corresponding source beside the
  object-code release without publishing the proprietary desktop source.
- Uses a one-time legacy-feed transition copy for existing users; future
  updates resolve from this repository.

## 5.19.0 — prepared, not commercially published

- Unified outward product naming as **Relvyn** with the English and Chinese
  product descriptors.
- Renamed the Windows application, installer, WhatsApp companion, macOS bundle,
  PWA metadata, icons, shortcuts, and public update assets.
- Includes the v5.18.6 platform-neutral Customer Success Agent, knowledge-base
  headings, and compatibility migration without overwriting custom personas.
- Preserved legacy data, credential, single-instance, and updater identities
  internally so an approved transition release can upgrade existing users.
- Added the proprietary project license, EULA, privacy notice, third-party
  notices, exact license texts, in-app legal links, and CI distribution checks.
- Split the intended architecture into a private source repository and this
  public binary-release repository.

This older entry records the state of the gate at that point in history; it is
not a claim about the current candidate.
