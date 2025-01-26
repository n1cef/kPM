
#include"../include/dependency.h"
#include"../include/graph.h"
#include<stdio.h>

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
printf("installing %s\n",node->pkg_name);



}

  

