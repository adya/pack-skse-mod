# Pack SKSE Mod

A universal workflow to build SKSE mods that are based on [CommonLibSSE-NG](https://github.com/alandtse/CommonLibSSE-NG) (or a personal fork of it).

### Features

- ✅ Effortless - doesn't require specific GitHub Actions knowledge, easy to setup.
- ✅ Builds a single universal DLL covering every enabled edition (SE, AE, VR).
- ✅ Include PDB files along with the DLL for easier debugging.
- ✅ Optionally bumps `CMakeLists.txt`/`vcpkg.json` version fields to match the pushed tag.
- ✅ Publishes the packaged mod to GitHub Releases.

---

### Contents
- [Pack SKSE Mod](#pack-skse-mod)
    - [Features](#features)
    - [Contents](#contents)
    - [Setting up the workflow](#setting-up-the-workflow)
    - [SSH](#ssh)
    - [CMake Configuration](#cmake-configuration)
        - [CMake Presets](#cmake-presets)
        - [Build Configurations](#build-configurations)
        - [Binary Directory](#binary-directory)
        - [Project Root](#project-root)
        - [Binary Name and Version](#binary-name-and-version)
          - [You might also explicilty specify values for `NAME` and `VERSION` if you don't want to make CMake variables cached.](#you-might-also-explicilty-specify-values-for-name-and-version-if-you-dont-want-to-make-cmake-variables-cached)
    - [Version Bumping](#version-bumping)
    - [Packaging](#packaging)
      - [Installation Path](#installation-path)
        - [Additional Required Installation](#additional-required-installation)
      - [Including Program Debug Database (PDB) files](#including-program-debug-database-pdb-files)
    - [Publishing](#publishing)
      - [Archive Type](#archive-type)
      - [GitHub Releases](#github-releases)
    - [Extending The Workflow](#extending-the-workflow)

### Setting up the workflow

The workflow tries to be as unintrusive to the actual build process as possible and has only few requirements:

1. Add [CommonLibSSE-NG](https://github.com/alandtse/CommonLibSSE-NG) (or your own fork of it) as a git submodule:
  ```bash
  git submodule add -b ng https://github.com/alandtse/CommonLibSSE-NG extern/CommonLibSSE-NG
  ```
  > Note: Make sure to point CMake to the submodule's path in `CMakeLists.txt`.
  
2. Set `NAME` and `VERSION` variables as cache variables in `CMakeLists.txt`. (See [Binary Name and Version](https://github.com/adya/pack-skse-mod#binary-name-and-version) for other options):
  ```cmake
  set(NAME "my_skse_mod" CACHE STRING "")
  set(VERSION 1.0.0 CACHE STRING "")
  ```
3. Add a workflow file at the repository's root `.github/workflows/main.yml`:
```yaml
name: Main

on:
  push:
    tags:
      - '[0-9]+.[0-9]+.[0-9]+'

concurrency:
  group: ${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: write

jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      MOD_NAME: "My SKSE Mod"
```

> Note: `permissions: contents: write` is required - the version-bump job pushes a commit/tag, and the publish job creates a GitHub Release.

---

### SSH

If your repository or one of it's submodules uses an SSH, you may specify an SSH key that workflow will use to checkout such repositories.

> Note: You should provide your SSH key as a [Secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    secrets:
      GIT_SSH_KEY: ${{ secrets.MY_SSH_KEY }}
```

---

### CMake Configuration

##### CMake Presets

The workflow supports both [Configuration Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html#configure-preset) and [Build Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html#build-preset).

You can provide presets in `CMAKE_CONFIG_PRESET` and `CMAKE_BUILD_PRESET`. By default it is configured as the following:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      CMAKE_CONFIG_PRESET: 'vs2026-windows-vcpkg'
      CMAKE_BUILD_PRESET: ''
```

> Note: **Build Presets** are an opt-in feature, if this preset is not specified then the workflow will perform `cmake --build $BINARY_DIR --config Release`. 
> If your `CMakePresets.json` provides a build preset you can set it via this parameter and the workflow will do `cmake --build --preset $BUILD_PRESET` instead - though the two are equivalent unless your build preset does more than just select a configuration.

---

##### Build Configurations

By default workflow assumes that `Release` build configuration will be used to build the project. This configuration is also used to determine path to the build artifacts that will be packaged.
When you want to use build configurations other than `Release` you can specify it with a `CMAKE_BUILD_CONFIGURATION` variable. 
For example, if you want to create both `Release` and `Debug` variants of the mod you can do this in your `main.yaml`:
```yaml
jobs:
  release:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      CMAKE_BUILD_CONFIGURATION: 'Release'
      MOD_NAME: "My SKSE Mod"
      
  debug:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      CMAKE_BUILD_CONFIGURATION: 'Debug'
      MOD_NAME: "My SKSE Mod DEBUG"
```
This will produce two packaged releases with corresponding artifacts.

---

##### Binary Directory

A directory where CMake outputs build files. 
By default the workflow uses:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      CMAKE_BINARY_DIR: 'build'
```
> If your preset uses a different binary directory you should provide it via this parameter. 

---

##### Project Root

When plugin's project files do not reside directly in the repository's root you should specify a path to its build output using `CMAKE_PROJECT_DIR`, so that build products will be searched for in _%repository_root%/CMAKE_BINARY_DIR/CMAKE_PROJECT_DIR/Release/_:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      CMAKE_PROJECT_DIR: ""
```
> For example, [SPID](https://github.com/powerof3/Spell-Perk-Item-Distributor) plugin's project files are located at `./SPID`, so it uses `CMAKE_PROJECT_DIR: "SPID"`. `VCPKG_JSON_PATH` and `CMAKE_LISTS_PATH` (see [Version Bumping](#version-bumping)) point at the project's own files separately - they aren't derived from `CMAKE_PROJECT_DIR` automatically.

---

##### Binary Name and Version

The workflow retrives information such as built product's name and version using CMake's cache. It is used to later package and publish the mod.
By default it looks for common variables `NAME` and `VERSION`.
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      CMAKE_BINARY_NAME_VAR: "NAME"
      CMAKE_BINARY_VERSION_VAR: "VERSION"
```
You may provide any other **cached** variable to be used as NAME or VERSION respectfully.
> Note: It is important that these variables are defined as `CACHE` variables, otherwise workflow will fail to read them.

###### You might also explicilty specify values for `NAME` and `VERSION` if you don't want to make CMake variables cached.
Though, you'll need to update these values (at least `VERSION`) in your workflow every time you change the version.
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      CMAKE_BINARY_NAME: "my_skse_mod"
      CMAKE_BINARY_VERSION: "1.0.0"
```

---

### Version Bumping

On every tag push, before building, the workflow can rewrite your version files to match the tag and re-tag automatically. This is enabled by default (`AUTO_VERSION_BUMP: true`):

1. Checks out the repository's default branch and verifies the pushed tag actually points at that branch's current tip - fails loudly if not (re-tag its tip and push again).
2. Extracts the version from the tag name (`X.Y.Z`), and rewrites it into `CMAKE_LISTS_PATH`'s `set(VERSION ...)` and `VCPKG_JSON_PATH`'s `"version-string"`.
3. If that changed anything, commits, pushes, force-moves the tag onto the new commit, and force-pushes the tag - which re-triggers this same workflow. The second run finds the version files already match and proceeds to build/package/publish normally.

```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      CMAKE_LISTS_PATH: 'CMakeLists.txt'
      VCPKG_JSON_PATH: 'vcpkg.json'
```
> For example, [SPID](https://github.com/powerof3/Spell-Perk-Item-Distributor)'s project files are located at `./SPID`, so it uses `CMAKE_LISTS_PATH: "SPID/CMakeLists.txt"` and `VCPKG_JSON_PATH: "SPID/vcpkg.json"`.

> Note: `VCPKG_JSON_PATH` is only used for this version-bump rewrite. The vcpkg manifest that actually drives the build's dependency install is a separate input, `VCPKG_MANIFEST_PATH` (also defaults to `vcpkg.json`) - the two only need to differ in a multi-project repo where one root manifest aggregates dependencies for several CMake subprojects (as with SPID, which keeps `VCPKG_MANIFEST_PATH` at its default despite overriding `VCPKG_JSON_PATH` above).

You can disable this and build/publish whatever version is already committed instead:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      AUTO_VERSION_BUMP: false
```

---

### Packaging

The built DLL (and PDB, optionally) is copied into `PLUGINS_PATH` inside a package folder that mirrors the game's `Data/` layout, and that folder is what gets archived and published.

#### Installation Path

> **Note: This path is relative to game's `Data/` folder, so you should not start it with "Data/" as this might cause issues in some mod managers.

Installation path is configured with `PLUGINS_PATH` and by default is set to `SKSE/Plugins`.

---

##### Additional Required Installation

You also may have additional files you'd want to include along with the DLL. 
For this case you can specify a directory containing files that you want to be always installed using `REQUIRED_INSTALLATION_DIR` parameter. This path is relative to your repository's root. Its own internal layout must already be `Data/`-relative, since its contents are copied straight into the package root.

> By default, `REQUIRED_INSTALLATION_DIR` is set to `Required Files`. If no such directory exists in your repository, this step is skipped - so you don't need to disable it if you don't have one. Pass an empty string to disable it explicitly regardless of whether the directory exists.

```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      REQUIRED_INSTALLATION_DIR: "Required Files"
```

---

#### Including Program Debug Database (PDB) files

If you'd like to distribute your mod with a PDB file, you may specify `INCLUDE_PDB` option. This will include the PDB file into the package and install it along with the DLL.
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      INCLUDE_PDB: true
```
> Note: Defaults to `true`.

---

### Publishing

When you push a new `tag` to GitHub, the workflow will perform an additional publishing step.

---

#### Archive Type

When publishing you may specify what archiver to use. Currently supported are `zip` and `7z`:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      PUBLISH_ARCHIVE_TYPE: '7z'
```

> Note: By default workflow will use `PUBLISH_ARCHIVE_TYPE: '7z'`.

> Note: This option is only relevant for publishing, since the Artifact produced by the build job is packed into zip automatically by GitHub Actions.

---

#### GitHub Releases

One of the destinations where the package can be published is GitHub's Releases. Once workflow publishes there you'll be able to download the package's archive from the Releases page of your repository. The release is named `$MOD_NAME $PRODUCT_VERSION`, its notes are auto-generated by GitHub from commit history, and it's marked a prerelease automatically when the pushed tag contains `rc` (e.g. `1.0.0.rc1`).

---

### Extending The Workflow

The workflow exposes all useful data as outputs. This allows building your custom workflows on top of pack-skse-mod.

Here are currently available outputs:
- `PRODUCT_NAME`
- `PRODUCT_VERSION`
- `PACKAGE_NAME`

which can be used in your workflow like this:
```yaml
name: Main

on:
  push:
    tags:
      - '[0-9]+.[0-9]+.[0-9]+'

concurrency:
  group: ${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: write

jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@ng
    with:
      MOD_NAME: "My SKSE Mod"

  post-discord-notification:
    runs-on: windows-latest
    needs: run
    steps:
      - name: Print version
        run: echo "Built Version ${{needs.run.outputs.PRODUCT_VERSION}}"
```
