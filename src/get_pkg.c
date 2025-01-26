#include<stdio.h>
#include<stdlib.h>
#include <string.h>
#include<sys/stat.h>
#include<unistd.h>
#include<dirent.h>

char **get_pkg (const char *pkg_name,int *nbr_dep){
const char *SOURCE_DIR="/sources";
const char *REPO_URL="https://raw.githubusercontent.com/n1cef/kraken";
char PKG_DIR[256];
if(opendir(SOURCE_DIR)== NULL){

    if(mkdir (SOURCE_DIR,0755)== -1){
      perror("error creating /sources directory");
      return NULL ;
    }




}
snprintf(PKG_DIR,sizeof(PKG_DIR),"%s/%s",SOURCE_DIR,pkg_name);
if(opendir(PKG_DIR)== NULL){
  if(mkdir(PKG_DIR,0755)== -1){

    perror("ERROR : creatig package directory");
    return NULL;
  }


}

if(chown(SOURCE_DIR,getuid(),getgid())== -1 ){ perror("error changng ownership of /sources");}
if (chown(PKG_DIR,getuid(),getgid())== -1 ) {perror("erro changing ownership of /sources/packagename");}





char pkgbuild_url[512]; 

snprintf(pkgbuild_url,sizeof(pkgbuild_url),"%s/refs/heads/master/pkgbuilds/%s/pkgbuild.kraken",REPO_URL,pkg_name);
 printf("pkgfile usr is %s\n",pkgbuild_url);


char command[1024];
snprintf(command,sizeof(command)," wget -q -P %s/%s  %s",SOURCE_DIR,pkg_name,pkgbuild_url);
printf("command is %s\n",command);
int verify_down = system(command);
printf("verify down is %d",verify_down);
if (verify_down!=0){

    fprintf(stderr, "Error downloading pkgbuild for package: %s\n", pkg_name);
        return NULL;
}
/*
char filename[256];
snprintf(filename, sizeof(filename),"%s/%s/pkgbuild.kraken",SOURCE_DIR,pkg_name);
FILE *file = fopen(filename,"r");
if(!file){
fprintf(stderr,"ERROR file not exist for packagge %s ",pkg_name);
return NULL;
}
*/

char line[256];
char **dependency_array=NULL;
*nbr_dep=0;
char bash_awk_command[1024];
snprintf(bash_awk_command,sizeof(bash_awk_command),"bash ../scripts/./extract_dep_with_awk.sh %s %s",pkg_name,SOURCE_DIR);

FILE *file=popen(bash_awk_command,"r");
if (file == NULL){

  fprintf(stderr,"failed to run bash_awk_command");
  return NULL;
}
while (fgets(line, sizeof(line), file) != NULL) {
  printf("after remplire dependecy array %s\t" , line);

line[strcspn(line,"\n")]=0;//remove the newline caracter of the line  i mean \n
dependency_array = realloc(dependency_array,(*nbr_dep + 1 ) * sizeof(char*));
        if(dependency_array == NULL){
          fprintf(stderr,"memory allocationerror \n");
          pclose(file);
          return NULL;
        }

        dependency_array[*nbr_dep]=strdup(line);
        if (dependency_array[*nbr_dep] == NULL) {

            fprintf(stderr, "Memory allocation error\n");

            pclose(file);

            return NULL;

        }

        (*nbr_dep)++;

        








}

pclose(file);
return dependency_array;











}


