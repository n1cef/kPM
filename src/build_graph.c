#include<stdio.h>
#include<stdlib.h>
#include <assert.h>
#include<strings.h>
#include <string.h>
#include "/usr/kraken/include/graph.h"
#include "/usr/kraken/include/build_graph.h"
#include "/usr/kraken/include/get_ver_dep_checkins.h"
void build_graph(Graph *graph , const char *pkgname){




  char *version=get_version(pkgname);
  if (!version){
    fprintf(stderr,"cant process package %s version not found please repport  this /gihbu.com/n1cef/KPM\n", pkgname);
    return;

  
  }

  else  {

      version[strcspn(version, "\n")] = '\0'; 
  printf("version is %s\n",version);
  }


  
  //we need to check if the package is installed in the system by quary form /var/lib/kraken/db/kraken.db
  if(check_installed(pkgname,version)){
    printf("package %s-%s is already installed \n" ,pkgname,version);
    free(version);
    return;


  }
  else {
 
    printf("package not installed\n ");
  }


  //if the node exist in the graph or we must create it

  Node *pkg_node=find_node_by_packages_name_and_version(graph,pkgname,version);
  if (!pkg_node){
    pkg_node=create_node(pkgname,version);
    if(!pkg_node){
      fprintf(stderr, "failed to create node for %s-%s\n",pkgname,version);
      free (version);
      return ;

    }
    add_node(graph,pkg_node);
   
  }

  //we need to get the dependecy

  int dep_count=0;
  char **deps_array=get_deps(pkgname,version,&dep_count);
  free(version);
  
  if (!deps_array){

    printf("no dependency for this package %s \n",pkgname);
    return ; // no dependecy for this package 


  }
  else {
    printf ("depndecnyfo this package  %s are detected  \n",pkgname);
   
  }
  
  printf("nbr dependency for this package is %d \n",dep_count);
  for (int i =0;i<dep_count;i++){

    char *dep_name=deps_array[i];
    printf("dep name is %d is %s\n" ,i,dep_name);
    char *dep_version=get_version(dep_name);
    if (!dep_version){

      fprintf(stderr,"missing version of the dependency %s\n" , dep_name);
      continue;//prevent this bad dependencie to break the intire process
    }

    else {
        version[strcspn(version, "\n")] = '\0'; 

      printf("version of package %d is %s",i,dep_version);
    }

      version[strcspn(version, "\n")] = '\0'; 

    if(!check_installed(dep_name,dep_version)){
      printf("package %d with name %s and version %s  is not installed so we need to build her graph\n ",i,dep_name,dep_version);
        
      build_graph(graph,dep_name);

      Node *dep_node=find_node_by_packages_name_and_version(graph,dep_name,dep_version);
      if(dep_node){
	add_dependencies(pkg_node,dep_node);
	

      }
      


    }



    free(dep_version);



    

  }

  //clean this shit
  
  for (int i=0;i<dep_count;i++){

    free(deps_array[i]);
    
  }
  free(deps_array);
  





}