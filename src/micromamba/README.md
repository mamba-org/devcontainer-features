
# micromamba (micromamba)

Installs micromamba, the fast cross-platform package manager.

## Example Usage

```json
"features": {
    "ghcr.io/mamba-org/devcontainer-features/micromamba:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Exact version of Micromamba to install, if not latest (must be X.Y.Z) | string | latest |
| allowReinstall | Reinstall in case Micromamba already exists | boolean | false |
| autoActivate | Auto activation of base environment | boolean | true |
| channels | Space separated list of Conda channels to add | string | - |
| packages | Space separated list of packages to install. Should use with the 'channels' option. | string | - |
| envFile | Path of the an environment file (spec file) in the container. Referenced by the `micromamba create` command's `-f` option | string | - |
| envName | Should use with the 'envFile' option. Referenced by the `micromamba create` command's `-n` option | string | - |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/mamba-org/devcontainer-features/blob/main/src/micromamba/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
