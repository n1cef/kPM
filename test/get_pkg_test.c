#include<stdio.h>
#include<stdlib.h>
#include "../include/get_pkg.h"


int main (int argc ,char *argv[]){

    if (argc <2 ){

        printf("usage ./get_pkg_test %s",argv[1]);
        return EXIT_FAILURE;
    }

     const char * pkg_name= argv[1];
     int nbr_dep=0;

    char **dependency_array =get_pkg (pkg_name,&nbr_dep);
    if (dependency_array == NULL){
fprintf(stderr,"failde to extract the dependency for this package \n");
return EXIT_FAILURE;
    }

    

   printf("dependency for the package %s\n",pkg_name);
   for (int i=0 ; i<nbr_dep; i++){

    printf("%s\n",dependency_array[i]);
    free(dependency_array[i]);



   }

   free (dependency_array);
   return EXIT_SUCCESS;

    













}