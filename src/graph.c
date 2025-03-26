#include <stdio.h>
#include<stdlib.h>
#include<stdbool.h>
#include<string.h>

#include"/usr/kraken/include/graph.h"

Graph *create_graph(){

Graph *graph = malloc(sizeof(Graph));
graph->node_array= NULL;
graph->nbr_node=0;
return graph;
}

Node *create_node(const char *pkg_name){
Node *node = malloc (sizeof(Node));
node->pkg_name=strdup(pkg_name);
node->dep_array=NULL;
node->nbr_dep=0;
node->visited=0;
return node;







}

void add_node(Graph *graph , Node *node ){

graph->nbr_node++;
graph->node_array=realloc(graph->node_array,graph->nbr_node*sizeof(Node *));

graph->node_array[graph->nbr_node -1] =node;
}


void add_dependency(Node*parent , Node*child){

parent->nbr_dep++;
parent->dep_array=realloc(parent->dep_array,parent->nbr_dep * sizeof(Node *));
parent->dep_array[parent->nbr_dep -1]=child;

}




void free_graph(Graph *graph ){
for (int i=0 ;i<graph->nbr_node;i++){

free(graph->node_array[i]->pkg_name);
free(graph->node_array[i]->dep_array);
free(graph->node_array[i]);


}

free(graph->node_array);
free(graph);



}
bool has_cycle(Graph *graph ){

for(int i=0;i<graph->nbr_node;i++){
graph->node_array[i]->visited=0;

}

for(int i=0;i<graph->nbr_node;i++){


    if (check_dfs_cycle(graph->node_array[i])){    return true;}
}
return false;


}




bool check_dfs_cycle(Node *node){
if(node==NULL){
    printf("error node is null");
    return false;
}
if (node->visited==1){ return true;}
if(node->visited==2){return false;}
node->visited=1;
for(int i=0;i< node->nbr_dep;i++){
   if(check_dfs_cycle(node->dep_array[i])){
      return true;
   }


}

node->visited=2;
return false;




}


Node *find_node_by_name(Graph *graph ,const char *pkg_name){

for (int i =0 ; i<graph->nbr_node;i++){

     if(strcmp(graph->node_array[i]->pkg_name,pkg_name)==0){

        return graph->node_array[i];


     }



}
return NULL;



}


