<h1 align="center">kraken</h1>

###

<div align="center">
  <img height="206"  width="600" src="https://wallpapercave.com/wp/szHV8Ed.jpg" />
</div>

###

> [!WARNING]  
> Kraken is under development and not complete yet! Use at your own risk.
<div align="left">
  

  <h3>
    Kraken is a package manager for Kraken OS, a new Linux distribution built entirely from source. Designed for researchers and scientists, Kraken OS provides a highly customizable and optimized environment tailored for advanced computing needs. Kraken follows a source-based approach, allowing users to compile packages from source for maximum performance and flexibility. This ensures fine-grained control over dependencies, compilation options, and system configuration, making it a powerful choice for those who need a fully customizable Linux experience.
  </h3>
</div>




###

<h1 align="left">kraken tools are:</h1>

###

<h3 align="left">Kraken provides a set of tools to handle every stage of package management in Kraken OS. Each tool is designed to ensure a smooth and efficient process for building and managing software from source.<br><br><code style="color: cyan">kraken download</code> : Downloads the package tarball from the repository, along with its patches, and verifies its checksum.<br><br><br><code style="color: cyan">kraken prepare</code> : Prepares the tarball for building by extracting it and configuring necessary settings before compilation.<br><br><br><code style="color: cyan">kraken build</code> : Compiles the package using its specific build system.<br><br><br><code style="color: cyan">kraken test</code> : Runs tests to verify that the package was built correctly and functions as expected.<br><code style="color: cyan">kraken preinstall</code> : Performs necessary pre-installation steps before the package is installed.<br><code style="color: cyan">kraken install</code> : Installs the compiled package into the system.<br><code style="color: cyan">kraken postinstall</code> : Executes post-installation steps required for the package to function properly.<br><code style="color: cyan">kraken remove</code> : Uninstalls the package using its native build system removal process.<br><code style="color: cyan">kraken manual_remove</code> : In cases where a package does not have an uninstall system, this tool detects all files and directories related to the package and removes them manually.<br><code style="color: cyan">kraken entropy</code> : Automates package management by detecting dependencies and resolving them in the correct order using the previous tools.<br>These tools make Kraken a powerful and flexible package manager, ensuring complete control over software installation, removal, and dependency management in Kraken OS.</h3>

###

<h1 align="left">Building Kraken from Source:</h1>

###

<h3 align="left">Follow the steps below to build and install Kraken from source:</h3>

### 1. Clone the repository
Clone the **Kraken package manager** repository from GitHub to your system:
```sh
git clone https://github.com/n1cef/kraken_package_manager.git kraken

```
### 2. Navigate to the Kraken directory

```sh
cd kraken

```
### 3. Create include directory and Copy some headers

```sh
sudo mkdir -p /usr/kraken

sudo cp -r include /usr/kraken

```

### 4. Set up the build environment

```sh
meson setup build/


```

### 5.  Build Kraken

```sh
 ninja -C build/


```
### 6. Install Kraken

```sh
 sudo ninja -C build/ install


```



