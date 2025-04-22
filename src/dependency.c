
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




char check_cmd[256];
   snprintf(check_cmd, sizeof(check_cmd),
       "sudo kraken checkinstalled %s %s >/dev/null 2>&1",
       node->pkg_name,
       node->version
   );



   int installed = system(check_cmd);
   if (WIFEXITED(installed) && WEXITSTATUS(installed) == 1) {
       printf("[SKIP] %s-%s already installed\n", 
             node->pkg_name, node->version);
       node->visited = 1;
       return;
   }


  
for (int i=0;i<node->nbr_dep;i++){


   install_pkg_dfs(node->dep_array[i]);

}

printf("[INSTALL] %s-%s\n", node->pkg_name, node->version);
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


    node->visited = 1;


}





