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
