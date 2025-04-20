#include<stdio.h>
#include<stdlib.h>
#include <string.h>
#include<sys/stat.h>
#include<unistd.h>
#include<dirent.h>

// Color definitions
#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define CYAN "\033[36m"
#define MAGENTA "\033[35m"
#define BOLD "\033[1m"
#define RESET "\033[0m"

char **get_pkg (const char *pkg_name,int *nbr_dep){
    const char *SOURCE_DIR="/sources";
    const char *REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository";
    char PKG_DIR[256];

    // Directory creation with colorized output
    if(opendir(SOURCE_DIR)== NULL){
        if(mkdir (SOURCE_DIR,0755)== -1){
            fprintf(stderr, RED BOLD "✗ ERROR: " RESET RED "Failed to create %s directory\n" RESET, SOURCE_DIR);
            return NULL;
        }
        printf(GREEN BOLD "✓ Created directory: " CYAN "%s\n" RESET, SOURCE_DIR);
    }

    snprintf(PKG_DIR,sizeof(PKG_DIR),"%s/%s",SOURCE_DIR,pkg_name);
    if(opendir(PKG_DIR)== NULL){
        if(mkdir(PKG_DIR,0755)== -1){
            fprintf(stderr, RED BOLD "✗ ERROR: " RESET RED "Failed to create package directory: %s\n" RESET, PKG_DIR);
            return NULL;
        }
        printf(GREEN BOLD "✓ Created package directory: " CYAN "%s\n" RESET, PKG_DIR);
    }

    // Ownership changes
    if(chown(SOURCE_DIR,getuid(),getgid())== -1 ){
        fprintf(stderr, YELLOW BOLD "⚠ WARNING: " RESET YELLOW "Failed to change ownership of %s\n" RESET, SOURCE_DIR);
    }
    if (chown(PKG_DIR,getuid(),getgid())== -1 ) {
        fprintf(stderr, YELLOW BOLD "⚠ WARNING: " RESET YELLOW "Failed to change ownership of %s\n" RESET, PKG_DIR);
    }

    // Package download
    char pkgbuild_url[512]; 
    snprintf(pkgbuild_url,sizeof(pkgbuild_url),"%s/refs/heads/main/pkgbuilds/%s/pkgbuild.kraken",REPO_URL,pkg_name);
    printf(CYAN BOLD "🌐 Package URL: " YELLOW "%s\n" RESET, pkgbuild_url);

    char command[1024];
    snprintf(command,sizeof(command),"sudo kraken oaddownl %s",pkg_name);
    printf(MAGENTA BOLD "⚙ Executing: " RESET MAGENTA "%s\n" RESET, command);
    
    int verify_down = system(command);
    if (verify_down!=0){
        fprintf(stderr, RED BOLD "✗ ERROR: " RESET RED "Failed to download package: %s\n" RESET, pkg_name);
        return NULL;
    }
    printf(GREEN BOLD "✓ Successfully downloaded: " YELLOW "%s\n" RESET, pkg_name);

    // Dependency extraction
    char **dependency_array=NULL;
    *nbr_dep=0;
    char bash_awk_command[1024];
    snprintf(bash_awk_command,sizeof(bash_awk_command),"sudo /usr/kraken/scripts/./extract_dep_with_awk.sh %s %s",pkg_name,SOURCE_DIR);

    printf(CYAN BOLD "\n🔍 Extracting dependencies...\n" RESET);
    FILE *file=popen(bash_awk_command,"r");
    if (file == NULL){
        fprintf(stderr, RED BOLD "✗ ERROR: " RESET RED "Failed to start dependency extraction\n" RESET);
        return NULL;
    }

    char line[256];
    while (fgets(line, sizeof(line), file) != NULL) {
        line[strcspn(line,"\n")]=0;
        if (strlen(line) == 0) continue;

        printf(CYAN "│ Found dependency: " YELLOW "%s\n" RESET, line);
        
        dependency_array = realloc(dependency_array,(*nbr_dep + 1 ) * sizeof(char*));
        if(dependency_array == NULL){
            fprintf(stderr, RED BOLD "✗ ERROR: " RESET RED "Memory allocation failed\n" RESET);
            pclose(file);
            return NULL;
        }

        dependency_array[*nbr_dep]=strdup(line);
        if (dependency_array[*nbr_dep] == NULL) {
            fprintf(stderr, RED BOLD "✗ ERROR: " RESET RED "Failed to store dependency\n" RESET);
            pclose(file);
            return NULL;
        }

        (*nbr_dep)++;
    }
    pclose(file);

    if (*nbr_dep == 0) {
        printf(YELLOW BOLD "⚠ No dependencies found for: " CYAN "%s\n" RESET, pkg_name);
        return NULL;
    }

    printf(GREEN BOLD "\n✓ Found %d dependencies for " YELLOW "%s\n" RESET, *nbr_dep, pkg_name);
    return dependency_array;
}