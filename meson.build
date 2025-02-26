project('kraken', 'c', version: '1.0.0', default_options: ['warning_level=3'])

# Checking dependencies
wget = find_program('wget', required: true)
awk = find_program('awk', required: true)
find_prog = find_program('find', required: true)
gcc = find_program('gcc', required: true)
meson_prog = find_program('meson', required: true)
ninja_prog = find_program('ninja', required: true)
sudo_prog = find_program('sudo', required: true)

if not wget.found()
    error('wget is required but not found. Please install it.')
endif

if not awk.found()
    error('awk is required but not found. Please install it.')
endif

if not find_prog.found()
    error('find is required but not found. Please install it.')
endif

if not meson_prog.found()
    error('meson is required but not found. Please install it.')
endif

if not ninja_prog.found()
    error('ninja is required but not found. Please install it.')
endif

if not sudo_prog.found()
    error('sudo is required but not found. Please install it.')
endif

# Define installation directories
headers_dir = '/usr/kraken/include'
scripts_dir = '/usr/kraken/scripts'
bin_dir = '/usr/bin'

# Header files
headers = files(
    'include/build_graph.h', 
    'include/dependency.h', 
    'include/get_pkg.h', 
    'include/graph.h'
)

# Scripts
scripts = files(
    'scripts/build.sh',
    'scripts/dir_filtring.sh',
    'scripts/extract_dep_with_awk.sh',
    'scripts/fake_install.sh',
    'scripts/get_package.sh',
    'scripts/install.sh',
    'scripts/manual_remove.sh',
    'scripts/postinstall.sh',
    'scripts/preinstall.sh',
    'scripts/prepare.sh',
    'scripts/remove.sh',
    'scripts/test.sh'
)

# Source files for the entropy executable
src = files(
    'src/build_graph.c', 
    'src/dependency.c', 
    'src/get_pkg.c', 
    'src/graph.c', 
    'src/main.c'
)

# Install headers and scripts
install_data(headers, install_dir: headers_dir)
install_data(scripts, install_dir: scripts_dir)

# Install the main script (kraken.sh -> /usr/bin/kraken)
install_data('bin/kraken.sh', install_dir: bin_dir, install_mode: 'rwxr-xr-x')

# Compile and install the entropy binary
entropy_exec = executable(
    'entropy',
    ['src/main.c', 'src/build_graph.c', 'src/graph.c', 'src/dependency.c', 'src/get_pkg.c'],
    install: true,
    install_dir: bin_dir
)

