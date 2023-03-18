## Version number specification

Soft version matching is *not* supported, meaning that `"1"` and `"1.0"` are not
valid values of the `version` parameter. The full version number must be specified
like `"1.0.0"`.

## Channels

By default, `micromamba` configures no channels. If you would like to set `conda-forge`
as a default channel, then use

```json
"features": {
  "ghcr.io/mamba-org/devcontainer-features/micromamba:1": {
    "channels": "conda-forge"
  }
}
```

More generally, `channels` can be a space-separated list such as "conda-forge defaults".

## Install packages with the `packages` option

This Feature supports package installation during image build.

Specify package names separated by **spaces** in the `packages` option.

For example, specify like the following installs `python>=3.11,<3.12` and `r-base`.

```json
"features": {
  "ghcr.io/mamba-org/devcontainer-features/micromamba:1": {
    "channels": "conda-forge",
    "packages": "python>=3.11,<3.12 r-base"
  }
}
```

This option has only been tested with sufficiently new versions of micromamba
and may not work if an older version is specified.

## Create a new environment with the `envFile` option

If a specfile (envfile) exists in the base image,
we can create an environment and install packages at image build time
by specifying the path to the specfile with the `envFile` option.

For example, with the following Dockerfile...

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:debian
COPY specfile.yml /tmp/specfile.yml
```

...copies the following `specfile.yml` to the container.

```yml
name: testenv
channels:
  - conda-forge
dependencies:
  - python >=3.6,<3.7
```

Specify the path to the spec file in the container with the `envFile` option in `devcontainer.json`.

```json
"features": {
  "micromamba": {
    "envFile": "/tmp/specfile.yml"
  }
}
```

Please check [the mamba user guide](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html#specification-files)
for more information about spec files.
