#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include "/usr/kraken/include/graph.h"


Graph *create_graph(){
Graph *graph= malloc(sizeof(Graph));
graph->node_array=NULL;
graph->nbr_node=0;
return graph;


}


Node *create_node(const char *pkg_name, const char *version){

Node *node=malloc(sizeof(Node));
node->pkg_name=strdup(pkg_name);
node->version=strdup(version);
node->dep_array = NULL;
node->nbr_dep=0;
node->visited=0;

return node;
}



void add_node(Graph *graph , Node *node){
graph->nbr_node++;
graph->node_array=realloc(graph->node_array,graph->nbr_node*sizeof(Node *));
graph->node_array [graph->nbr_node -1]= node;


}


void add_dependencies(Node * node_parent , Node *node_child ){

node_parent->nbr_dep++;
node_parent->dep_array=realloc(node_parent->dep_array,node_parent->nbr_dep*sizeof(Node *));
node_parent->dep_array[node_parent->nbr_dep -1]=node_child;




}


void free_graph(Graph *graph){

int i;
for (i=0;i<graph->nbr_node;i++){
free(graph->node_array[i]->pkg_name);
free(graph->node_array[i]->version);
free(graph->node_array[i]->dep_array);
free(graph->node_array[i]);



}

free(graph->node_array);
free (graph);



}

bool has_cycle(Graph * graph){
int i;
for (i=0;i<graph->nbr_node;i++){
   graph->node_array[i]->visited=0;


}

int j;
for (j=0;j<graph->nbr_node;j++){

    if (check_dfs_cycle(graph->node_array[j])){
        return true;
    }

}
return false;




}


bool check_dfs_cycle(Node * node){
    if (node==NULL){
     printf("node is null");
     return false ;
    }
    if (node->visited == 1){
        return true ;

    }

    if(node->visited == 2){

        return false;
    }
     node->visited=1;
    int i;
    for (i=0;i<node->nbr_dep;i++){

        if (check_dfs_cycle(node->dep_array[i])){
            return true;
        }
    }


    node->visited=2;
    return false;
}


Node *find_node_by_packages_name_and_version(Graph *graph, const char *pkg_name, const char *version){
int i;

for(i=0;i<graph->nbr_node;i++){

Node *current=graph->node_array[i];
if(
    (strcmp(current->pkg_name,pkg_name)==0)
    &&
    (strcmp(current->version,version)==0)
)
       {
          return current;
       }
}
return NULL;








}


void print_graph(Graph *graph){

  printf("\n=== Graph Structure ===\n");
   printf("Total nodes: %d\n", graph->nbr_node);
 
   for (int i=0;i<graph->nbr_node;i++){

     Node *current=graph->node_array[i];
     printf("\n node  %d : %s %s ",i+1,current->pkg_name,current->version);
     printf("dependency (%d) \n" , current->nbr_dep);


     for (int j =0 ; j<current->nbr_dep;j++){
  
       printf("%s %s \n" ,current->dep_array[j]->pkg_name,current->dep_array[j]->version);         

     }
     
    


   }
   printf("\n");





}