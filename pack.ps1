Param(
    # Path to a directory relative to CMake's BINARY_DIR (e.g. build/CMAKE_PROJECT_DIR/Release/mod.dll)
    [String]$CMAKE_PROJECT_DIR = '',

    # Name of the of the built binary. When CMAKE_BINARY_NAME is set it takes precedence over CMAKE_BINARY_NAME_VAR.
    [String]$CMAKE_BINARY_NAME = '',

    # Name of the CMake variable that contains name of the built binary. Note that this variable must be CACHE variable.
    [String]$CMAKE_BINARY_NAME_VAR = 'NAME',

    # Version of the of the built binary. When CMAKE_BINARY_VERSION is set it takes precedence over CMAKE_BINARY_VERSION_VAR.
    [String]$CMAKE_BINARY_VERSION = '',

    # Name of the CMake variable that contains version of the built binary. Note that this variable must be CACHE variable.
    [String]$CMAKE_BINARY_VERSION_VAR = 'VERSION',

    # Configuration in which the project will be built. Note that you need to specify it even when providing build presets.
    [String]$CMAKE_BUILD_CONFIGURATION = 'Release',

    # Name of the CMakePresets.json's configuration to use to generate the project files for SE variant.
    [String]$CMAKE_SE_CONFIG_PRESET = 'vs2022-windows-vcpkg-se',

    # Name of the CMakePresets.json's configuration to build the project for SE variant.
    [String]$CMAKE_SE_BUILD_PRESET = '',

    # Default directory where SE product will be built. Defaults to 'build'.
    [String]$CMAKE_SE_BINARY_DIR = 'build',

    # Name of the CMakePresets.json's configuration to use to generate the project files for AE variant.
    [String]$CMAKE_AE_CONFIG_PRESET = 'vs2022-windows-vcpkg-ae',

    # Name of the CMakePresets.json's configuration to build the project for AE variant.
    [String]$CMAKE_AE_BUILD_PRESET = '',

    # Default directory where AE product will be built. Defaults to 'build'.
    [String]$CMAKE_AE_BINARY_DIR = 'buildae',

    # Name of the CMakePresets.json's configuration to use to generate the project files for VR variant.
    [String]$CMAKE_VR_CONFIG_PRESET = 'vs2022-windows-vcpkg-vr',

    # Name of the CMakePresets.json's configuration to build the project for VR variant.
    [String]$CMAKE_VR_BUILD_PRESET = '',

    # Default directory where VR product will be built. Defaults to 'build'.
    [String]$CMAKE_VR_BINARY_DIR = 'buildvr',
    
    # Preferred type of archive to be used. Supports either zip or 7z
    [String]$ARCHIVE_TYPE = 'zip',

    # Name of the mod that will be displayed in FOMOD Installer.
    [Parameter(Mandatory)]
    [String]$FOMOD_MOD_NAME,

    # Author of the mod that will be displayed in FOMOD Installer's metadata.
    [Parameter(Mandatory)]
    [String]$FOMOD_MOD_AUTHOR,

    # Id of the mod page on Nexus that will be displayed in FOMOD Installer's metadata.
    [String]$FOMOD_MOD_NEXUS_ID = '',

    # Path to the directory that contains game files that should always be installed. This path is relative to repository's root.
    [String]$FOMOD_REQUIRED_INSTALLATION_DIR = '',

    # Path to the folder in FOMOD installer containing files that should always be installed.
    [String]$FOMOD_REQUIRED_SRC_PATH = 'Required',

    # Path to the installation directory where FOMOD will install required files. This path is relative to FOMOD Installer's root.
    [String]$FOMOD_REQUIRED_DST_PATH = '',

    # Path to the installation directory where FOMOD will install files. This is typically SKSE/Plugins.
    [String]$FOMOD_DST_PATH = 'SKSE/Plugins',

    # Title of the installation page in FOMOD Installer (displayed under the mod's name).
    [String]$FOMOD_TITLE = 'Main',

    # Title of the group with installation options.
    [String]$FOMOD_GROUP_NAME = 'DLL',
    
    # Path to the image file to be used as a default cover for all installation options. Ignored for variants that define their own image.
    [String]$FOMOD_DEFAULT_IMAGE = '',

    # Path to SE binaries relative to FOMOD Installer's root.
    [String]$FOMOD_SE_PATH = 'SE/SKSE/Plugins',

    # Name of the SE installation option.
    [String]$FOMOD_SE_NAME = 'SSE v1.5.97 ("Special Edition")',

    # Description of the SE installation option.
    [String]$FOMOD_SE_DESCR = 'Select this if you are using Skyrim Special Edition v1.5.97.',

    # Path to the image file to be used as a cover for SE installation option.
    [String]$FOMOD_SE_IMAGE = '',

    # Minimum version of the game that is recognized as SE variant.
    [String]$FOMOD_SE_MIN_GAME_VERSION = '1.5.97.0',

    # Path to AE binaries relative to FOMOD Installer's root.
    [String]$FOMOD_AE_PATH = 'AE/SKSE/Plugins',

    # Name of the AE installation option.
    [String]$FOMOD_AE_NAME = 'SSE v1.6.629+ ("Anniversary Edition")',

    # Description of the AE installation option.
    [String]$FOMOD_AE_DESCR = 'Select this if you are using Skyrim Anniversary Edition v1.6.629 or higher (latest update).',

    # Path to the image file to be used as a cover for AE installation option.
    [String]$FOMOD_AE_IMAGE = '',

    # Minimum version of the game that is recognized as AE variant.
    [String]$FOMOD_AE_MIN_GAME_VERSION = '1.6.629.0',

    # Path to VR binaries relative to FOMOD Installer's root.
    [String]$FOMOD_VR_PATH = 'VR/SKSE/Plugins',

    # Name of the VR installation option.
    [String]$FOMOD_VR_NAME = 'VR v1.4.15 ("Skyrim VR")',

    # Description of the VR installation option.
    [String]$FOMOD_VR_DESCR = 'Select this if you are using Skyrim VR v1.4.15.',

    # Path to the image file to be used as a cover for VR installation option.
    [String]$FOMOD_VR_IMAGE = '',

    # Minimum version of the game that is recognized as VR variant.
    [String]$FOMOD_VR_MIN_GAME_VERSION = '1.4.15.0',

    # Flag indicating whether PDB files should be packed into FOMOD along with DLLs.
    [Boolean]$FOMOD_INCLUDE_PDB = $false
)

Function New-Variant {
    Param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [String]$projectDir,

        [Parameter(Mandatory)]
        [String]$preset,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [String]$buildPreset,

        [Parameter(Mandatory)]
        [String]$config,

        [Parameter(Mandatory)]
        [String]$binaryDir,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [String]$binaryName,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [String]$binaryNameVar,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [String]$binaryVersion,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [String]$binaryVersionVar,

        [Parameter(Mandatory)]
        [String]$variant
    )
    $MarketingSuffix = $variant.ToUpper()
    
    Write-Host "    Building $MarketingSuffix..." 

    cmake --preset $preset

    If (![String]::IsNullOrEmpty($buildPreset)) {
        cmake --build --preset $buildPreset
    } Else {
        cmake --build $binaryDir --config $config
    }

    $ProductName = If (![String]::IsNullOrEmpty($binaryName)) { $binaryName } Else { cmake -L -N $binaryDir | Select-String "$($binaryNameVar):STRING"  | ForEach-Object {$_.Line -replace "$($binaryNameVar):STRING=",""} }
    $Version = If (![String]::IsNullOrEmpty($binaryVersion)) { $binaryVersion } Else { cmake -L -N $binaryDir | Select-String "$($binaryVersionVar):STRING" | ForEach-Object {$_.Line -replace "$($binaryVersionVar):STRING=",""} }
    
    $ProductsDir = "$binaryDir/$projectDir/$config" 
    
    $ProductBinaryName = "$ProductName.dll"
    $ProductBinaryPath = "$ProductsDir/$ProductBinaryName"

    $PDBName = "$ProductName.pdb"
    $PDBPath = "$ProductsDir/$PDBName"

    

    $ArtifactName = "$ProductName $MarketingSuffix $config"
    $ArtifactPath = $ProductsDir

    return [PSCustomObject]@{
            Name = $ProductName
            Version = $Version
            BinaryName = $ProductBinaryName
            BinaryPath = $ProductBinaryPath
            PDBName = $PDBName
            PDBPath = $PDBPath
            ArtifactName = $ArtifactName
            ArtifactPath = $ArtifactPath
          }
}

Function New-FOMOD {
    Param(
    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$MOD_NAME,
    
    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$MOD_AUTHOR,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$MOD_NEXUS_ID,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$REQUIRED_INSTALLATION_DIR,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$REQUIRED_SRC_PATH,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$REQUIRED_DST_PATH,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$DST_PATH,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [Boolean]$INCLUDE_PDB,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$TITLE,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$GROUP_NAME,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$DEFAULT_IMAGE,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$SE_PATH,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$SE_NAME,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$SE_DESCR,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$SE_IMAGE,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$SE_MIN_GAME_VERSION,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$SE_VERSION,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$SE_ARTIFACT,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$AE_PATH,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$AE_NAME,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$AE_DESCR,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$AE_IMAGE,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$AE_MIN_GAME_VERSION,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$AE_VERSION,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$AE_ARTIFACT,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$VR_PATH,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$VR_NAME,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$VR_DESCR,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$VR_IMAGE,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$VR_MIN_GAME_VERSION,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$VR_VERSION,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [String]$VR_ARTIFACT
    )

    $INSTALLER_NAME="$MOD_NAME FOMOD Installer"
    $INSTALLER_DIR = "$PWD/$INSTALLER_NAME"

    Write-Host "Creating $INSTALLER_NAME..."

    $HAS_REQUIRED_INSTALL = ![String]::IsNullOrEmpty($REQUIRED_INSTALLATION_DIR) -and (Test-Path "$REQUIRED_INSTALLATION_DIR/*")
    $HAS_VALID_SRC = ![String]::IsNullOrEmpty($REQUIRED_SRC_PATH)
    If ($HAS_REQUIRED_INSTALL -and $HAS_VALID_SRC) {
        Write-Host "    Packing Required installation..."
        $REQUIRED_DIR = "$PWD/$REQUIRED_INSTALLATION_DIR"
        $REQUIRED_SRC = "$INSTALLER_DIR/$REQUIRED_SRC_PATH"

        New-Item $REQUIRED_SRC -ItemType Directory -Force
        Get-ChildItem "$REQUIRED_DIR/*" | ForEach-Object {
            Write-Host "        Copying $($_.Name) from '$($_.DirectoryName)' to '$REQUIRED_SRC'"    
            $_ | Copy-Item -Destination $REQUIRED_SRC
        }
    }

    # Get the first available version (defaults to 1.0.0 if no versions found)
    $versions = $SE_VERSION, $AE_VERSION, $VR_VERSION, "1.0.0"
    $MOD_VERSION = $versions | Where-Object {$_ -ne ""} | Select-Object -first 1

    # "Private" vars. You shouldn't change it
    
    $FOMOD_DIR = "$INSTALLER_DIR/fomod"
    $IMAGES_DIR = "$FOMOD_DIR/images"
    $IMAGES_PATH = "fomod/images"
    $MOD_CONFIG_PATH = "$FOMOD_DIR/ModuleConfig.xml"
    $MOD_INFO_PATH = "$FOMOD_DIR/info.xml"
    $MOD_NEXUS_URL = "https://www.nexusmods.com/skyrimspecialedition/mods/$MOD_NEXUS_ID"

    # Creates a usable objects that hold information about variants
    Function New-Variant-Info {
      [CmdletBinding()]
      Param (
        [string] $Name,
        [string] $Path,
        [string] $Description,
        [string] $Image,
        [string] $GameVersion,
        [string] $Artifact
      )

      $ImageSrc = If (![string]::IsNullOrEmpty($Image)) { $Image } else { $DEFAULT_IMAGE }
      # ImageDst will be empty if there is no image detected for given variant
      $ImageDst = If (![string]::IsNullOrEmpty($ImageSrc) -and (Test-Path "$ImageSrc")) { "$IMAGES_PATH/$(Split-Path $ImageSrc -Leaf)" } else { "" }
      $IsDetected = ![string]::IsNullOrEmpty($Artifact)
      return [PSCustomObject]@{
        Name = $Name
        Path = $Path
        Description = $Description
        ImageSrc = $ImageSrc
        ImageDst = $ImageDst
        GameVersion = $GameVersion
        Artifact = $Artifact
        IsDetected = $IsDetected
      }
    }

    $Variants = @(
      New-Variant-Info $AE_NAME $AE_PATH $AE_DESCR $AE_IMAGE $AE_MIN_GAME_VERSION $AE_ARTIFACT
      New-Variant-Info $SE_NAME $SE_PATH $SE_DESCR $SE_IMAGE $SE_MIN_GAME_VERSION $SE_ARTIFACT
      New-Variant-Info $VR_NAME $VR_PATH $VR_DESCR $VR_IMAGE $VR_MIN_GAME_VERSION $VR_ARTIFACT
    )

    # Writes installation option with given title, desciption and path. Providing auto-select behavior for specified versions.
    function Write-Plugin {
        [CmdletBinding()]
        param (
            [System.XML.XmlWriter] $xmlWriter,
            [string] $Title,
            [string] $Descr,
            [string] $Image,
            [string] $SrcPath,
            [string] $GameVersion
        )
        
        process {
            $xmlWriter.WriteStartElement("plugin")
            $xmlWriter.WriteAttributeString("name", $Title)
            If (![string]::IsNullOrEmpty($Descr)) {
                $xmlWriter.WriteElementString("description", $Descr)
            }
            If (![string]::IsNullOrEmpty($Image)) {
              $xmlWriter.WriteStartElement("image")
                  $xmlWriter.WriteAttributeString("path", "$Image") 
              $xmlWriter.WriteEndElement()
            }
            $xmlWriter.WriteStartElement("files")
                $xmlWriter.WriteStartElement("folder")
                    $xmlWriter.WriteAttributeString("source", $SrcPath)
                    $xmlWriter.WriteAttributeString("destination", $DST_PATH)
                    $xmlWriter.WriteAttributeString("priority", "0")
                $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
            $xmlWriter.WriteStartElement("typeDescriptor")
                $xmlWriter.WriteStartElement("dependencyType")
                    $xmlWriter.WriteStartElement("defaultType")
                        $xmlWriter.WriteAttributeString("name", "Optional")
                    $xmlWriter.WriteEndElement()
                    $xmlWriter.WriteStartElement("patterns")
                    # Write pattern for each version
                    Foreach ($Variant in $Variants) {
                        If ($Variant.IsDetected) {
                            If ($Variant.GameVersion -eq $GameVersion) {
                                $DepType = "Recommended"
                            } else {
                                $DepType = "Optional"
                            }
                            $xmlWriter.WriteStartElement("pattern")
                                $xmlWriter.WriteStartElement("dependencies")
                                    $xmlWriter.WriteStartElement("gameDependency")
                                        $xmlWriter.WriteAttributeString("version", $Variant.GameVersion)
                                    $xmlWriter.WriteEndElement()
                                $xmlWriter.WriteEndElement()
                                $xmlWriter.WriteStartElement("type")
                                    $xmlWriter.WriteAttributeString("name", $DepType)
                                $xmlWriter.WriteEndElement()
                            $xmlWriter.WriteEndElement()
                        }
                    }
                    $xmlWriter.WriteEndElement()
                $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
        $xmlWriter.WriteEndElement()
        }
    }

    function Write-Config {
      process {
        $xmlSettings = New-Object System.Xml.XmlWriterSettings
        $xmlSettings.Indent = $true
        $xmlSettings.IndentChars = "    "
        
        $xmlWriter = [System.XML.XmlWriter]::Create($MOD_CONFIG_PATH, $xmlSettings)
        $xmlWriter.WriteStartDocument()
        $xmlWriter.WriteStartElement("config")
            $xmlWriter.WriteAttributeString("xmlns", "xsi", $null, "http://www.w3.org/2001/XMLSchema-instance")
            $xmlWriter.WriteAttributeString("noNamespaceSchemaLocation", "http://www.w3.org/2001/XMLSchema-instance", "http://qconsulting.ca/fo3/ModConfig5.0.xsd")
            $xmlWriter.WriteElementString("moduleName", $MOD_NAME)
            If ($HAS_REQUIRED_INSTALL) {
                $xmlWriter.WriteStartElement("requiredInstallFiles")
                    $xmlWriter.WriteStartElement("folder")
                        $xmlWriter.WriteAttributeString("source", $REQUIRED_SRC_PATH)
                        $xmlWriter.WriteAttributeString("destination", $REQUIRED_DST_PATH)
                    $xmlWriter.WriteEndElement()
                $xmlWriter.WriteEndElement()
            }
            $xmlWriter.WriteStartElement("installSteps")
                $xmlWriter.WriteAttributeString("order", "Explicit")
                $xmlWriter.WriteStartElement("installStep")
                    $xmlWriter.WriteAttributeString("name", $TITLE)
                    $xmlWriter.WriteStartElement("optionalFileGroups")
                        $xmlWriter.WriteAttributeString("order", "Explicit")
                        $xmlWriter.WriteStartElement("group")
                            $xmlWriter.WriteAttributeString("name", $GROUP_NAME)
                            $xmlWriter.WriteAttributeString("type", "SelectExactlyOne")
                            $xmlWriter.WriteStartElement("plugins")
                                $xmlWriter.WriteAttributeString("order", "Explicit")
                                Foreach ($Variant in $Variants) {
                                    If ($Variant.IsDetected) {
                                        Write-Plugin -xmlWriter $xmlWriter -Title $Variant.Name -Descr $Variant.Description -Image $Variant.ImageDst -SrcPath $Variant.Path -GameVersion $Variant.GameVersion
                                    }
                                }
                            $xmlWriter.WriteEndElement()
                        $xmlWriter.WriteEndElement()
                    $xmlWriter.WriteEndElement()
                $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
        $xmlWriter.WriteEndElement()
        $xmlWriter.WriteEndDocument()
        $xmlWriter.Flush()
        $xmlWriter.Close()
      }
    }

    function Write-Info {
        process {
            $xmlSettings = New-Object System.Xml.XmlWriterSettings
            $xmlSettings.Indent = $true
            $xmlSettings.IndentChars = "    "
            
            $xmlWriter = [System.XML.XmlWriter]::Create($MOD_INFO_PATH, $xmlSettings)
            $xmlWriter.WriteStartDocument()
                $xmlWriter.WriteStartElement("fomod")
                    $xmlWriter.WriteElementString("Name", $MOD_NAME)
                    $xmlWriter.WriteElementString("Author", $MOD_AUTHOR)
                    $xmlWriter.WriteElementString("Version", $MOD_VERSION)
                    if (![string]::IsNullOrEmpty($MOD_NEXUS_ID)) {
                      $xmlWriter.WriteElementString("Website", $MOD_NEXUS_URL)
                    }
                    
                $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndDocument()
            $xmlWriter.Flush()
            $xmlWriter.Close()
        }
    }

    If ($($Variants | Where-Object {$_.IsDetected}).Count -eq 0) {
        Write-Host "    No available variants."
        return
    }

    # Finally we can create the installer
    New-Item $FOMOD_DIR -ItemType Directory -Force
    
    Write-Host "    Name: $MOD_NAME"
    Write-Host "    Version: $MOD_VERSION"
    Write-Host "    Author: $MOD_AUTHOR"
    if (![string]::IsNullOrEmpty($MOD_NEXUS_ID)) {
        Write-Host "    Nexus: $MOD_NEXUS_URL"
    }

    Foreach ($Variant in $Variants) {
        If ($Variant.IsDetected) {
            New-Item "$INSTALLER_DIR/$($Variant.Path)" -ItemType Directory -Force
            
            Write-Host "    Adding $($Variant.GameVersion) Variant plugin"
            Write-Host "        Name: $($Variant.Name)"
            Write-Host "        Description: $($Variant.Description)"
            Write-Host "        Path: $($Variant.Path)"
            
            If (![string]::IsNullOrEmpty($Variant.ImageDst) -and ![string]::IsNullOrEmpty($Variant.ImageSrc) -and (Test-Path "$($Variant.ImageSrc)")) {
                New-Item "$IMAGES_DIR" -ItemType Directory -Force
                Write-Host "        Image: $($Variant.ImageDst)"
                Write-Host "        Image Source: $($Variant.ImageSrc)"
                Copy-Item -Path "$($Variant.ImageSrc)" -Destination "$INSTALLER_DIR/$($Variant.ImageDst)" -Force
            }
        } else {
            Write-Host "    Skipped $($Variant.GameVersion) Variant plugin"
        }
    }
    
    Write-Info
    Write-Config

    
    $INSTALLER_SE_PATH="$INSTALLER_DIR/$SE_PATH"
    $INSTALLER_AE_PATH="$INSTALLER_DIR/$AE_PATH"
    $INSTALLER_VR_PATH="$INSTALLER_DIR/$VR_PATH"
    
    Write-Host "Created $MOD_NAME ($MOD_VERSION) FOMOD Installer at $INSTALLER_DIR"

    # Pack Required Files
    

    Function Pack-Artifacts {
        param(
            [String]$VARIANT,
            [String]$ARTIFACTS_DIR,
            [String]$DESTINATION,
            [Boolean]$INCLUDE_PDB
        )

        If (![String]::IsNullOrEmpty($ARTIFACTS_DIR) -and ![String]::IsNullOrEmpty($DESTINATION)) {
            Write-Host "Packing $VARIANT artifacts..."
            
            Get-ChildItem -Path $ARTIFACTS_DIR -Filter *.dll | ForEach-Object {
                Write-Host "    Copying $($_.Name) from '$($_.DirectoryName)' to '$DESTINATION'"    
                $_ | Copy-Item -Destination $DESTINATION
            }
            
            If ($INCLUDE_PDB) {
                Get-ChildItem -Path $ARTIFACTS_DIR -Filter *.pdb | ForEach-Object {
                    Write-Host "    Copying $($_.Name) from '$($_.DirectoryName)' to '$DESTINATION'"    
                    $_ | Copy-Item -Destination $DESTINATION
                }
            }
        }
    }

    # Pack SE dll
    Pack-Artifacts -VARIANT 'SE' -ARTIFACTS_DIR $SE_ARTIFACT -DESTINATION $INSTALLER_SE_PATH -INCLUDE_PDB $INCLUDE_PDB

    # Pack AE dll
    Pack-Artifacts -VARIANT 'AE' -ARTIFACTS_DIR $AE_ARTIFACT -DESTINATION $INSTALLER_AE_PATH -INCLUDE_PDB $INCLUDE_PDB

    # Pack VR dll
    Pack-Artifacts -VARIANT 'VR' -ARTIFACTS_DIR $VR_ARTIFACT -DESTINATION $INSTALLER_VR_PATH -INCLUDE_PDB $INCLUDE_PDB

    return [PSCustomObject]@{
        FOMODName = $INSTALLER_NAME
        FOMODPath = $INSTALLER_DIR
      } 
}

$LIST = cmake --list-presets
$HAS_SE = ![String]::IsNullOrEmpty($CMAKE_SE_CONFIG_PRESET) -and ($LIST | Select-String -Pattern $CMAKE_SE_CONFIG_PRESET -Quiet)
$HAS_AE = ![String]::IsNullOrEmpty($CMAKE_AE_CONFIG_PRESET) -and ($LIST | Select-String -Pattern $CMAKE_AE_CONFIG_PRESET -Quiet)
$HAS_VR = ![String]::IsNullOrEmpty($CMAKE_VR_CONFIG_PRESET) -and ($LIST | Select-String -Pattern $CMAKE_VR_CONFIG_PRESET -Quiet)

If ($HAS_SE -or $HAS_AE -or $HAS_VR) {
    Write-Host "Building Variants: " -NoNewline
    
    If ($HAS_SE) {
        Write-Host "SE " -NoNewline
    }
    If ($HAS_AE) {
        Write-Host "AE " -NoNewline
    }
    If ($HAS_VR) {
        Write-Host "VR" -NoNewline
    }
    Write-Host ""
} Else {
    Exit 0
}

$SEVariant = @()
$AEVariant = @()
$VRVariant = @()

if ($HAS_SE) {
    
    $SEVariant = New-Variant -variant "SE" `
                             -projectDir $CMAKE_PROJECT_DIR `
                             -preset $CMAKE_SE_CONFIG_PRESET `
                             -buildPreset $CMAKE_SE_BUILD_PRESET `
                             -config $CMAKE_BUILD_CONFIGURATION `
                             -binaryDir $CMAKE_SE_BINARY_DIR `
                             -binaryName $CMAKE_BINARY_NAME `
                             -binaryNameVar $CMAKE_BINARY_NAME_VAR `
                             -binaryVersion $CMAKE_BINARY_VERSION `
                             -binaryVersionVar $CMAKE_BINARY_VERSION_VAR
}

if ($HAS_AE) {
    $AEVariant = New-Variant -variant "AE" `
                             -projectDir $CMAKE_PROJECT_DIR `
                             -preset $CMAKE_AE_CONFIG_PRESET `
                             -buildPreset $CMAKE_AE_BUILD_PRESET `
                             -config $CMAKE_BUILD_CONFIGURATION `
                             -binaryDir $CMAKE_AE_BINARY_DIR `
                             -binaryName $CMAKE_BINARY_NAME `
                             -binaryNameVar $CMAKE_BINARY_NAME_VAR `
                             -binaryVersion $CMAKE_BINARY_VERSION `
                             -binaryVersionVar $CMAKE_BINARY_VERSION_VAR
}

if ($HAS_VR) {
    $VRVariant = New-Variant -variant "VR" `
                             -projectDir $CMAKE_PROJECT_DIR `
                             -preset $CMAKE_VR_CONFIG_PRESET `
                             -buildPreset $CMAKE_VR_BUILD_PRESET `
                             -config $CMAKE_BUILD_CONFIGURATION `
                             -binaryDir $CMAKE_VR_BINARY_DIR `
                             -binaryName $CMAKE_BINARY_NAME `
                             -binaryNameVar $CMAKE_BINARY_NAME_VAR `
                             -binaryVersion $CMAKE_BINARY_VERSION `
                             -binaryVersionVar $CMAKE_BINARY_VERSION_VAR
}


$FOMOD = New-FOMOD -MOD_NAME $FOMOD_MOD_NAME `
                   -MOD_AUTHOR $FOMOD_MOD_AUTHOR `
                   -MOD_NEXUS_ID $FOMOD_MOD_NEXUS_ID `
                   -REQUIRED_INSTALLATION_DIR $FOMOD_REQUIRED_INSTALLATION_DIR `
                   -REQUIRED_SRC_PATH $FOMOD_REQUIRED_SRC_PATH `
                   -REQUIRED_DST_PATH $FOMOD_REQUIRED_DST_PATH `
                   -DST_PATH $FOMOD_DST_PATH `
                   -INCLUDE_PDB $FOMOD_INCLUDE_PDB `
                   -TITLE $FOMOD_TITLE `
                   -GROUP_NAME $FOMOD_GROUP_NAME `
                   -DEFAULT_IMAGE $FOMOD_DEFAULT_IMAGE `
                   -SE_PATH $FOMOD_SE_PATH `
                   -SE_NAME $FOMOD_SE_NAME `
                   -SE_DESCR $FOMOD_SE_DESCR `
                   -SE_IMAGE $FOMOD_SE_IMAGE `
                   -SE_MIN_GAME_VERSION $FOMOD_SE_MIN_GAME_VERSION `
                   -SE_VERSION $SEVariant.Version `
                   -SE_ARTIFACT $SEVariant.ArtifactPath `
                   -AE_PATH $FOMOD_AE_PATH `
                   -AE_NAME $FOMOD_AE_NAME `
                   -AE_DESCR $FOMOD_AE_DESCR `
                   -AE_IMAGE $FOMOD_AE_IMAGE `
                   -AE_MIN_GAME_VERSION $FOMOD_AE_MIN_GAME_VERSION `
                   -AE_VERSION $AEVariant.Version `
                   -AE_ARTIFACT $AEVariant.ArtifactPath `
                   -VR_PATH $FOMOD_VR_PATH `
                   -VR_NAME $FOMOD_VR_NAME `
                   -VR_DESCR $FOMOD_VR_DESCR `
                   -VR_IMAGE $FOMOD_VR_IMAGE `
                   -VR_MIN_GAME_VERSION $FOMOD_VR_MIN_GAME_VERSION `
                   -VR_VERSION $VRVariant.Version `
                   -VR_ARTIFACT $VRVariant.ArtifactPath


If (($ARCHIVE_TYPE -ne 'zip') -and ($ARCHIVE_TYPE -ne '7z')) {
    Write-Host "ARCHIVE_TYPE must be either 'zip' or '7z', but not '$ARCHIVE_TYPE'"
    Exit 1
}

If ($ARCHIVE_TYPE -eq 'zip') {
    Write-Host "Archiving '$($FOMOD.FOMODName)' to zip..."
    Compress-Archive -Path $FOMOD.FOMODPath -DestinationPath "$($FOMOD.FOMODName).zip" -Force
}

If ($ARCHIVE_TYPE -eq '7z') {
    Write-Host "Archiving '$($FOMOD.FOMODName)' to 7z..."
    7z a -t7z -mx=9 "$($FOMOD.FOMODName).7z" $FOMOD.FOMODPath -r
}
Write-Host "Done!"
