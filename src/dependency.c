
#include"/usr/kraken/include/dependency.h"
#include"/usr/kraken/include/graph.h"
#include<stdio.h>
#include<stdlib.h>


//void wait_for_user() {

   // printf("Press any key to continue...\n");

   // getchar(); 

//}

void resolve_dep(Graph *graph ){


for(int i=0; i<graph->nbr_node;i++){


graph->node_array[i]->visited=0;

}

for(int i=0;i< graph->nbr_node;i++){

    if(!graph->node_array[i]->visited){

       install_pkg_dfs(graph->node_array[i]);

    }


}



}


void install_pkg_dfs(Node *node){

if(node->visited){return;}
node->visited=1;
for (int i=0;i<node->nbr_dep;i++){


   install_pkg_dfs(node->dep_array[i]);

}

printf("\033[0;31mInstalling %s\033[0m\n", node->pkg_name);
//wait_for_user()

char command[512];


   
    // Prepare for the build

    snprintf(command, sizeof(command), "sudo kraken prepare %s", node->pkg_name);

    system(command);


    // Build the package

    snprintf(command, sizeof(command), "sudo kraken build %s", node->pkg_name);

    system(command);


    // Test the package

    snprintf(command, sizeof(command), "sudo kraken test %s", node->pkg_name);

    system(command);
      
    // preinstall
    snprintf(command, sizeof(command), "sudo kraken preinstall  %s", node->pkg_name);

    system(command);
  
    //fake isntall the package 

    snprintf(command, sizeof(command), "sudo kraken fakeinstall  %s", node->pkg_name);

    system(command);
    // Install the package

    snprintf(command, sizeof(command), "sudo kraken install %s", node->pkg_name);

    system(command);

    // postinstall
    snprintf(command, sizeof(command), "sudo kraken postinstall  %s", node->pkg_name);

    system(command);





}

  

