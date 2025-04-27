#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "/usr/kraken/include/get_ver_dep_checkins.h"
#include <stdbool.h>
#include <sys/wait.h>
#include <string.h>
char * get_version(const char *pkgname){
  char version_cmd[256];
  snprintf(version_cmd,sizeof(version_cmd), "sudo kraken getversion %s " , pkgname);

  FILE *version_file =popen(version_cmd ,"r");
  if (!version_file){
    fprintf(stderr,"failed to get version for %s\n" , pkgname);
    return NULL;
  }

  char version[128];
  if (!fgets(version,sizeof(version),version_file)){
    pclose(version_file);
    return NULL;

  }

  pclose (version_file);
 
 version[strcspn(version, "\n")] = 0;

 char *final_version= strdup(version);
 if(!final_version){

   fprintf(stderr,"failed to allocate memory for the final version you can blame gcc for this shit , nothink to do !");
   return NULL;

 }
 



 return final_version;

}


char **get_deps(const char *pkgname, const char *version,int *count){

  char deps_cmd[256];
  snprintf(deps_cmd,sizeof(deps_cmd),"sudo kraken getdeps %s %s " , pkgname ,version);

  
  FILE *deps_file=popen(deps_cmd,"r");
  if(!deps_file){
    fprintf(stderr, "failed to extract dependency for package %s with version %s",pkgname , version);
    return NULL;

  }
 
  char **deps_array=malloc(128 * sizeof(char *));
  if (!deps_array){

    pclose (deps_file);
    return NULL;
  }
  
  char dep_line[128];
  *count=0;
  while(fgets(dep_line,sizeof(dep_line),deps_file) ){
    dep_line[strcspn(dep_line,"\n")]='\0';
    deps_array[*count]=strdup(dep_line);
    
    if(!deps_array[*count]){
      //free if the allocation fail
      for(int i=0;i< *count;i++){
	free(deps_array[i]);
	
      }
      free(deps_array);
      pclose(deps_file);
      return NULL;
           

    }

    (*count)++;
    


  }

  
 
  
  return deps_array;


}

bool check_installed(const char * pkgname, const char *version ){

  char check_cmd[256];
  sprintf(check_cmd,"sudo kraken checkinstalled %s %s ", pkgname
	 , version);
  
  //TBD:IF checkinstalled return 1 mean the package installed so return 1 and if return 0  mean not installed and must bereutn 0

  int status =system(check_cmd);


  if (WIFEXITED(status)){

    int exit_code=WEXITSTATUS(status);
    return (exit_code ==1);
    
   }
  
  return false ;

}