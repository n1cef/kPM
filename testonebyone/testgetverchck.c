#include <stdio.h>

#include <stdlib.h>
#include "/usr/kraken/include/graph.h"
#include "/usr/kraken/include/get_ver_dep_checkins.h"

int main ()

{

char *version = get_version ("giflib");

if(!version){

 printf("cannot found version ");

}

else {
  printf("version is %s", version );

}


if (check_installed("giflib","5.2.0")){

                printf("giflib already instaqlled ");
}

else {
  printf("giflib not installed ");
}


int dep_count=0;
char **deps_array=get_deps("jdk","22.0.2",&dep_count);
if(!deps_array){
 printf("no dependencie for this package ");


}
else {

   printf("dependency jdk found and are ");


  for (int i=0;i<dep_count;i++){
  
     char *dep_name=deps_array[i];
     printf("dep name is %s ",dep_name);
  }

}



	return 0;



}

