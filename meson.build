project('kraken', 'c', version: '1.0.0', default_options: ['warning_level=3'])

# Checking dependencies
wget = find_program('wget', required: true)
awk = find_program('awk', required: true)
find_prog = find_program('find', required: true)
gcc = find_program('gcc', required: true)
meson_prog = find_program('meson', required: true)
ninja_prog = find_program('ninja', required: true)
sudo_prog = find_program('sudo', required: true)
strace_prog = find_program('strace', required: true)
fakeroot_prog = find_program('fakeroot', required: true)
curl_prog = find_program('curl', required: true)
bash_prog = find_program('bash', required: true)
yq = find_program('yq', required: true)
sqlite3 = find_program('sqlite3', required: true)


if not wget.found()
    error('wget is required but not found. Please install it.')
endif

if not sqlite3.found()
    error('sqlite3 is required but not found. Please install it.')
endif


if not yq.found()
    error('yq is required but not found. Please install it.')
endif
if not strace_prog.found()
    error('strace is required but not found. Please install it.')
endif


if not fakeroot_prog.found()
    error('fakeroot is required but not found. Please install it.')
endif

if not curl_prog.found()
    error('curl is required but not found. Please install it.')
endif

if not bash_prog.found()
    error('bash is required but not found. Please install it.')
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
metadata_dir = '/var/lib/kraken'
db_dir='/var/lib/kraken/db'
# Header files
headers = files(
    'include/build_graph.h', 
    'include/resolve_dep.h', 
    'include/get_ver_dep_checkins.h', 
    'include/graph.h',
    'include/conflict.h'
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
    'scripts/test.sh',
    'scripts/getdeps.sh',
    'scripts/getversion.sh'
)

# Source files for the entropy executable
src = files(
    'src/build_graph.c', 
    'src/resolve_dep.c', 
    'src/get_ver_dep_checkins.c', 
    'src/graph.c', 
    'src/main.c',
    'src/conflict.c'
)

#source files for the checkinstalled executable
 querry = files(
   'querry/checkinstalled.c'
  

)



db = files (
   'db/kraken.sql',
   'db/kraken.db',
    'db/kraken_db.sh'

)


# Install headers and scripts
install_data(headers, install_dir: headers_dir)
install_data(scripts, install_dir: scripts_dir)
install_data(db,install_dir:db_dir)

# Install the main script (kraken.sh -> /usr/bin/kraken)
install_data('bin/kraken.sh', install_dir: bin_dir, install_mode: 'rwxr-xr-x' ,rename: 'kraken')

entropy_exec = executable(
    'entropy',
    ['src/main.c', 'src/build_graph.c', 'src/graph.c', 'src/resolve_dep.c', 'src/get_ver_dep_checkins.c','src/conflict.c'],
    install: true,
    install_dir: bin_dir
)

checkinstalled_exec = executable(
      'checkinstalled',
     'querry/checkinstalled.c',
     dependencies:[sqlite3],
      install:true,
      install_dir:bin_dir
)

install_data(
    'uninstall.sh',
    install_dir: bin_dir,
    install_mode: 'rwxr-xr-x',
    rename: 'kraken-uninstall'
)