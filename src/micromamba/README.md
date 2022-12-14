
# micromamba (micromamba)

Installs micromamba, the fast cross-platform package manager.

## Example Usage

```json
"features": {
    "ghcr.io/eitsupi/mamba-devcontainer-features/micromamba:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Exact version of Micromamba to install, if not latest (must be X.Y.Z) | string | latest |
| allowReinstall | Reinstall in case Micromamba already exists | boolean | false |
| channels | Comma separated list of Conda channels to add | string | - |

## Version number specification

Soft version matching is *not* supported, meaning that `"1"` and `"1.0"` are not
valid values of the `version` parameter. The full version number must be specified
like `"1.0.0"`.

## Channels

By default, `micromamba` configures no channels. If you would like to set `conda-forge`
as a default channel, then use

```json
"features": {
  "ghcr.io/eitsupi/mamba-devcontainer-features/micromamba:0.1": {
    "channels": "conda-forge"
  }
}
```

More generally, `channels` can be a comma-separated list such as "conda-forge,defaults".


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/mamba-devcontainer-features/blob/main/src/micromamba/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
