# Update manifests

Approved Windows releases will publish the Velopack feed and every referenced
package together. Expected public names include:

- `releases.win.json`
- `RELEASES`
- `AISalesOS-<version>-full.nupkg`
- optional `AISalesOS-<version>-delta.nupkg`
- `SHA256SUMS.txt`
- `relvyn-release-manifest.json`

The historical `AISalesOS` package identifier and channel `win` remain fixed for
installed-client compatibility. SHA, release manifest and attestation metadata
are not Velopack feed package records and cannot be selected by the updater.
