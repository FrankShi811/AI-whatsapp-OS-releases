# Update manifests

Approved Windows releases will publish the Velopack feed and every referenced
package together. Expected public names include:

- `releases.win.json`
- `assets.win.json`
- `RELEASES`
- `Relvyn-<version>-full.nupkg`
- `Relvyn-<version>-delta.nupkg`

The historical internal package identifier remains available only for installed
client compatibility; public download filenames use Relvyn. No manifest is
published while the compliance release gate is blocked.
