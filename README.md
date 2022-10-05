# Pack SKSE Mod

A universal workflow to build SKSE mods that are based on [powerof3/CommonLibSSE](https://github.com/powerof3/CommonLibSSE) and/or [alandtse/CommonLibVR](https://github.com/alandtse/CommonLibVR/tree/vr).

### Features

- ✅ Effortless - doesn't require specific GitHub Actions knowledge, easy to setup.
- ✅ Builds all supported variants: SE, AE, AE (1.6.353), VR.
- ✅ Include PDB files along with DLLs to easy debugging.
- ✅ Generates FOMOD.
- ✅ Publishes FOMOD installer to GitHub Releases.
- ⬛ _Publishes FOMOD installer directly to Nexus mod page (Coming soon-ish)._

---

### Contents
+ [Setting up the workflow](#setting-up-the-workflow)
+ [Examples](#examples)
+ [CMake Configuration](#cmake-configuration)
    * [CMake Presets](#cmake-presets)
    * [Binary Directory](#binary-directory)
    * [Project Root](#project-root)
    * [Binary Name and Version](#binary-name-and-version)
+ [Building AE **1.6.353** (pre **1.6.629** variant)](#building-ae-16353-pre-16629-variant)
+ [FOMOD Customizations](#fomod-customizations)
  - [General Information](#general-information)
  - [Nexus Mods Integration](#nexus-mods-integration)
  - [Installation Paths](#installation-paths)
    * [Additional Required Installation](#additional-required-installation)
  - [Including Program Debug Database (PDB) files](#including-program-debug-database-pdb-files)
  - [Installer Content](#installer-content)
  - [Installation Option Images](#installation-option-images)
    * [Default image for all options](#default-image-for-all-options)
+ [Publishing](#publishing)
  - [Archive Type](#archive-type)
  - [GitHub Releases](#github-releases)
  - [Nexus Mod](#nexus-mod)
+ [Extending The Workflow](#extending-the-workflow)

### Setting up the workflow

The workflow tries to be as unintrusive to the actual build process as possible and has only few requirements:

1. Add [powerof3/CommonLibSSE](https://github.com/powerof3/CommonLibSSE) and/or [alandtse/CommonLibVR](https://github.com/alandtse/CommonLibVR/tree/vr) as git submodules:
  ```bash
  git submodule add extern/CommonLibSSE https://github.com/powerof3/CommonLibSSE.git
  git submodule add extern/CommonLibVR https://github.com/alandtse/CommonLibVR.git
  ```
  > Note: Make sure to point CMake to submodules paths in `CMakeLists.txt`.
  
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
    branches: '**'
    tags: '*'

concurrency:
  group: ${{ github.ref }}
  cancel-in-progress: true

jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_MOD_NAME: "My SKSE Mod"
      FOMOD_MOD_AUTHOR: "The Author"
```

> Note: Default values for configuration of `pack.yml` workflow is based on [powerof3](https://github.com/powerof3) projects. This includes preset names, build directories, variable names, etc. If your project uses different naming you need to also specify custom values as described below.

---

### Examples

Here are some examples of configured workflows:
- [AnimObjectSwapper](https://github.com/powerof3/AnimObjectSwapper/pull/2/files): Basic configuration, builds SE, AE, VR, packs installer into 7z with PDB files.
- [EnhancedReanimation](https://github.com/powerof3/EnhancedReanimation/pull/2/files): Does everything that AnimObjectSwapper + supports AE 1.6.353 as a separate variant.
- [Spell Perk Item Distributor](https://github.com/adya/Spell-Perk-Item-Distributor/pull/2/files): Showcases custom project apth, configuration of the FOMOD, provides image and links to changelog and description files.
---

### CMake Configuration

##### CMake Presets

The workflow supports both [Configuration Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html#configure-preset) and [Build Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html#build-preset).

By default it is configured as the following:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      CMAKE_SE_CONFIG_PRESET: 'vs2022-windows-vcpkg-se'
      CMAKE_SE_BUILD_PRESET: ''
      CMAKE_AE_CONFIG_PRESET: 'vs2022-windows-vcpkg-ae'
      CMAKE_AE_BUILD_PRESET: ''
      CMAKE_VR_CONFIG_PRESET: 'vs2022-windows-vcpkg-vr'
      CMAKE_VR_BUILD_PRESET: ''
```

> Note: **Build Presets** are an opt-in feature, if these presets are not specified then the workflow will perform `cmake --build $BINARY_DIR --config Release`. 
> If your `CMakePresets.json` provide build presets you can set them via these parameters and the workflow will do `cmake --build --preset $BUILD_PRESET` instead.

> The workflow checks whether specified **Configuration Presets** are present in `CMakePresets.json` and builds only variants that have existing presets.
> You might explicitly disable building of any variant by passing blank string to corresponding **Configuration Preset**.

---

##### Binary Directory

A directory where CMake outputs build files. 
By default the workfow sets binary directories for variants as follows:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      CMAKE_SE_BINARY_DIR: 'build'
      CMAKE_AE_BINARY_DIR: 'buildae'
      CMAKE_VR_BINARY_DIR: 'buildvr'
```
> If you have different binary directories you should provide them via these parameters. 

---

##### Project Root

When plugin's project files do not reside directly in the repository's root you should specify a path to it using `CMAKE_PROJECT_DIR`.
This will point `vcpkg` to _%repository_root%/CMAKE_PROJECT_DIR/vcpkg.json_ and append CMAKE_PROJECT_DIR as a suffix to `CMAKE_XX_BINARY_DIR` variables, so that build products will be searched for in _%repository_root%/CMAKE_XX_BINARY_DIR/CMAKE_PROJECT_DIR/Release/_:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      CMAKE_PROJECT_DIR: ""
```
> For example, [SPID](https://github.com/powerof3/Spell-Perk-Item-Distributor) plugin's project files are located at `./SPID`, so it uses `CMAKE_PROJECT_DIR: "SPID"`

---

##### Binary Name and Version

The workflow retrives information such as built product's name and version using CMake's cache. It is used to later generate FOMOD and publish the mod.
By default it looks for common variables `NAME` and `VERSION`.
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
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
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      CMAKE_BINARY_NAME: "my_skse_mod"
      CMAKE_BINARY_VERSION: "1.0.0"
```

---

### Building AE **1.6.353** (pre **1.6.629** variant)

This is another opt-in feature. It is disabled by default.

Support for AE **1.6.353** is implemented through checkouting a dedicated branch that is built against [powerof3/CommonLibSSE](https://github.com/powerof3/CommonLibSSE)'s [dev-1.6.353](https://github.com/powerof3/CommonLibSSE/tree/dev-1.6.353) branch.

You can opt-in by providing such branch like this:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      AE_353_BRANCH: "ae_353_branch" # name of the branch that can be built with dev-1.6.353
```

If you don't have a separate branch for **1.6.353** and your main branch supports all AE versions, then you can specify workflow's current branch to enable this feature:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      AE_353_BRANCH: "${{ github.ref }}"
```
> Note: You can also change CommonLibSSE's branch to be used for **1.6.353** build by specifying it with `AE_353_COMMON_LIB_BRANCH` parameter.

> Note: This variant uses AE-related build parameters of the workflow.

---

### FOMOD Customizations

The ultimate artifact produced by this workflow is a FOMOD installer containing all built variants that is ready to be published to Nexus or any other platform.

> The FOMOD has built-in automated detection of appropriate game version and pre-selects correct option for user.

#### General Information

The metadata that is provided in `info.xml`:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_MOD_NAME: "My SKSE Mod"
      FOMOD_MOD_AUTHOR: "The Author"
```
> Note: Version is picked up from binary's version, so there is no dedicated `FOMOD_MOD_VERSION`.

---

#### Nexus Mods Integration

Optionally you can specify id of your mod on Nexus page. It will be used to provide a URL to your mod in FOMOD.
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_MOD_NEXUS_ID: "1111"
```

---

#### Installation Paths

##### Source Paths

Source paths are paths that specify where installable files are located within FOMOD. 
These paths are relative to the installer's root.

By default, workflow is preconfigured for a common installer template with the following structure:
```
installer
├───Required*
├───SE
│   └───SKSE
│       └───Plugins
├───AE353
│   └───SKSE
│       └───Plugins
├───AE
│   └───SKSE
│       └───Plugins
└───VR
    └───SKSE
        └───Plugins
```

This corresponds to the following configuration, that you may choose to customize:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_VR_PATH: "VR/SKSE/Plugins"
      FOMOD_SE_PATH: "SE/SKSE/Plugins"
      FOMOD_AE_PATH: "AE/SKSE/Plugins"
      FOMOD_AE353_PATH: "AE353/SKSE/Plugins"
```

> Note: * 'Required' is an optional path and configured with `FOMOD_REQUIRED_SRC_PATH`. (See [Additional required installation](https://github.com/adya/pack-skse-mod/blob/main/README.md#additional-required-installation)

---

##### Destination Paths

Destinations paths are paths that specify where files should be installed to. 
****.
> **Note: These paths are relative to game's `Data/` folder, so you should not start destination paths with "Data/" as this might cause issues in some mod managers. For instance, Vortex handles such paths correctly, but MO2 does not.**

Installation path for all options is configured with `FOMOD_DST_PATH` and by default is set to `SKSE/Plugins`.

---

##### Additional Required Installation

You also may have additional files you'd want to include along with plugin variants. 
For this case you can specify a directory containing files that you want to be always installed using `FOMOD_REQUIRED_INSTALLATION_DIR` parameter. This path is relative to your repository's root where you place the required files. The files in specified directory will be copied into FOMOD's installer to directory specified with in `FOMOD_REQUIRED_SRC_PATH`.

> By default, `FOMOD_REQUIRED_INSTALLATION_DIR` is blank, so that required installation is skipped.

Aditionally, you may customize where required files will be placed inside FOMOD and the default installation path within Game's folder. 

Here is an example of all relevant inputs:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_REQUIRED_INSTALLATION_DIR: "FOMOD/Required Files"
      FOMOD_REQUIRED_SRC_PATH: "Required"
```

> Note that contents of `FOMOD_REQUIRED_INSTALLATION_DIR` will be copied to game's Data folder (this is the default `FOMOD_REQUIRED_DST_PATH`).

---

#### Including Program Debug Database (PDB) files

If you'd like to distribute your mod with PDB files, you may specify `FOMOD_INCLUDE_PDB` option. This will include PDB files into FOMOD and install them along with DLLs.
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_INCLUDE_PDB: true
```

---

#### Installer Content

Things like installer's title, option names, descriptions, minimum required game versions are all configurable using the following parameters:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_TITLE: 'Main'
      FOMOD_GROUP_NAME: 'DLL'
      FOMOD_SE_NAME: 'SSE v1.5.97 ("Special Edition")'
      FOMOD_SE_DESCR: 'Select this if you are using Skyrim Special Edition v1.5.97.'
      FOMOD_SE_MIN_GAME_VERSION: '1.5.97.0'
      FOMOD_AE353_NAME:  'SSE v1.6.353 ("Anniversary Edition")'
      FOMOD_AE353_DESCR: 'Select this if you are using Skyrim Anniversary Edition v1.6.353 or lower.'
      FOMOD_AE353_MIN_GAME_VERSION: '1.6.317.0'
      FOMOD_AE_NAME: 'SSE v1.6.629+ ("Anniversary Edition")'
      FOMOD_AE_DESCR: 'Select this if you are using Skyrim Anniversary Edition v1.6.629 or higher (latest update).'
      FOMOD_AE_MIN_GAME_VERSION: '1.6.629.0'
      FOMOD_VR_NAME: 'VR v1.4.15 ("Skyrim VR")'
      FOMOD_VR_DESCR: 'Select this if you are using Skyrim VR v1.4.15.'
      FOMOD_VR_MIN_GAME_VERSION: '1.4.15.0'
```

---

#### Installation Option Images

In addition to textual content of the installer you might as well provide cover images for each installation option.
Put them inside your repository and specify paths to these images. Path is relative to repository's root.
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_SE_IMAGE: 'FOMOD/images/cover_se.png'
      FOMOD_AE353_IMAGE: 'FOMOD/images/cover_ae353.png'
      FOMOD_AE_IMAGE: 'FOMOD/images/cover_ae.png'
      FOMOD_VR_IMAGE: 'FOMOD/images/cover_vr.png'
```

> Note that images are copied to dedicated FOMOD's folder (fomod/images), so make sure your images have distrinct names, otherwise they'll be overwritten by one another.

##### Default image for all options

If you don't have separate images for each variant (or only for few of them) you might instead provide `FOMOD_DEFAULT_IMAGE` which will be used when variant's image is not provided.

For example here all variants except VR will use default 'cover.png', but VR will have it's own image:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_DEFAULT_IMAGE: 'FOMOD/images/cover.png'
      FOMOD_VR_IMAGE: 'FOMOD/images/cover_vr.png'
```

---

### Publishing

When you push a new `tag` to GitHub, the workflow will perform an additional publishing step.

> Even though the workflow doesn't use tag's name as a version, you should still follow Semantic Versioning for the sake of clarity :) 

---

#### Archive Type

When publishing FOMOD installer you may specify what archiver to use. Currently supported are `zip` and `7z`:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      PUBLISH_ARCHIVE_TYPE: '7z'
```

> Note: By deafult workflow will use `PUBLISH_ARCHIVE_TYPE: 'zip'`.

> Note: This option is only relevant for publishing, since Artifacts produced by separate jobs are packed into zip automatically by GitHub Actions.

---

#### GitHub Releases

One of the destinations where package can be published is GitHub's Releases. Once workflow publishes there you'll be able to download the installer's archive from Releases page of your repository.

You may also specify changelog and description of the mod file. They'll be added to that Release:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      PUBLISH_MOD_DESCRIPTION_FILE: 'FOMOD/description.txt'
      PUBLISH_MOD_CHANGELOG_FILE: 'FOMOD/changelog.txt'
```

---

#### Nexus Mod

> **This one is work in progress and is not included in @main. It's also highliy experimental :) so if you feel adventurous you might try it on @nexus-upload**

##### DISCLAIMER: As of now there is no official NexusMods API to upload files, this step uses known, yet still unofficial tool to perform upload.

This will publish produced installer's package directly to your mod's Nexus page, replacing the Main file that had the latest version. So if your mod had several published Main files the first one with largest version will be update. 

> `VERSION` variable from you `CMakeLists.txt` will be used as a new version of the uploaded file.

##### To configuration the workflow you'll need to do the following:

0. If you don't have Nexus's **Personal API Key**, then [Create one](https://www.nexusmods.com/users/myaccount?tab=api).
1. Add this key to your repositor's secrets. Refer to [GitHub Secrets docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets).
1.1.  or if you plan on using it in multiple repositories, consider creating your own organization and moving all repos there, so they'll share the same Organization's secrets.
2. Get Cookies from your active Nexus session. This can be done in various ways, for example, using **Get cookies.txt* [for Google Chrom](https://chrome.google.com/webstore/detail/get-cookiestxt/bgaddhkoddajcdgocldbbfleckgcbcid) (or [Microsoft Edge](https://microsoftedge.microsoft.com/addons/detail/get-cookiestxt/helleheikohejgehaknifdkcfcmceeip))
3. Once set you're ready to enable publishing on Nexus step:
```yaml
jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_MOD_NEXUS_ID: '11111'
      PUBLISH_GAME_NAME: 'skyrimspecialedition'
      PUBLISH_MOD_DESCRIPTION_FILE: 'FOMOD/description.txt'
      PUBLISH_MOD_CHANGELOG_FILE: 'FOMOD/changelog.txt'
    secrets:
      PUBLISH_NEXUS_API_KEY: ${{ secrets.YOUR_NEXUS_API_KEY_SECRET }}
      PUBLISH_NEXUS_COOKIE: ${{ secrets.YOUR_NEXUS_COOKIES_SECRET }}
```

> Replace `YOUR_NEXUS_API_KEY_SECRET` and `YOUR_NEXUS_COOKIES_SECRET` with corresponding secrets that you've created.

##### IMPORTANT: You must also provide `FOMOD_MOD_NEXUS_ID` as it will be used for publishing.

---

### Extending The Workflow

The workflow exposes all useful data as outputs. This allows building your custom workflows on top of pack-skse-mod.

Here are currently available outputs:
- `PRODUCT_VERSION`
- `FOMOD_INSTALLER`
- `SE_ARTIFACT_NAME`
- `AE_ARTIFACT_NAME`
- `AE353_ARTIFACT_NAME`
- `VR_ARTIFACT_NAME`

which can be used in your workflow like this:
```yaml
name: Main

on:
  push:
    branches: '**'
    tags: '*'

concurrency:
  group: ${{ github.ref }}
  cancel-in-progress: true

jobs:
  run:
    uses: adya/pack-skse-mod/.github/workflows/pack.yml@main
    with:
      FOMOD_MOD_NAME: "My SKSE Mod"
      FOMOD_MOD_AUTHOR: "The Author"

  post-discord-notification:
    runs-on: windows-latest
    needs: run
    steps:
      - name: Print version
        run: echo "Built Version ${{needs.run.outputs.PRODUCT_VERSION}}"
```
