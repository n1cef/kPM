<h1 align="center">kraken</h1>

###

<div align="center">
  <img height="206"  width="600" src="https://imgs.search.brave.com/hZJY8nXgx1plSBgvPnhx3qQ8F4Odp5bMX2cKbJ2fBL8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMtd2l4bXAtZWQz/MGE4NmI4YzRjYTg4/Nzc3MzU5NGMyLndp/eG1wLmNvbS9pLzY1/MjEyMzU5LTU1ZDct/NDAxNS1hNTk1LWVh/ODkzZWM1YmQ5Ny9k/Z2ZmZDdnLTJkODJk/NDY5LWQzZmMtNGU0/My05MjJhLTU2OWI0/ODc3ZTQ5Yi5qcGc" />
</div>

###
<div align="left">
  > **Warning**  
  > Kraken is under development and not complete yet! Use at your own risk.

  <h3>
    Kraken is a package manager for Kraken OS, a new Linux distribution built entirely from source. Designed for researchers and scientists, Kraken OS provides a highly customizable and optimized environment tailored for advanced computing needs. Kraken follows a source-based approach, allowing users to compile packages from source for maximum performance and flexibility. This ensures fine-grained control over dependencies, compilation options, and system configuration, making it a powerful choice for those who need a fully customizable Linux experience.
  </h3>
</div>




###

<h1 align="left">kraken tools are:</h1>

###

<h3 align="left">Kraken provides a set of tools to handle every stage of package management in Kraken OS. Each tool is designed to ensure a smooth and efficient process for building and managing software from source.<br><br>kraken download : Downloads the package tarball from the repository, along with its patches, and verifies its checksum.<br>kraken prepare : Prepares the tarball for building by extracting it and configuring necessary settings before compilation.<br>kraken build : Compiles the package using its specific build system.<br>kraken test : Runs tests to verify that the package was built correctly and functions as expected.<br>kraken preinstall : Performs necessary pre-installation steps before the package is installed.<br>kraken install : Installs the compiled package into the system.<br>kraken postinstall : Executes post-installation steps required for the package to function properly.<br>kraken remove : Uninstalls the package using its native build system removal process.<br>kraken manual_remove : In cases where a package does not have an uninstall system, this tool detects all files and directories related to the package and removes them manually.<br>kraken entropy : Automates package management by detecting dependencies and resolving them in the correct order using the previous tools.<br>These tools make Kraken a powerful and flexible package manager, ensuring complete control over software installation, removal, and dependency management in Kraken OS.</h3>

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



