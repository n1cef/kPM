#include<stdio.h>
#include"/usr/kraken/include/graph.h"
#include"/usr/kraken/include/dependency.h"
#include "/usr/kraken/include/build_graph.h"
#include<stdlib.h>
int main(int argc, char *argv[]){

    if(argc <2){
        fprintf(stderr,"error ");
        return 1;
    }

    const char *pkg_name=argv[1];
    printf("pkg name is %s\n",pkg_name);
/*
    Graph *graph=create_graph();
    Node *pkga=create_node("a");
    Node *pkgb=create_node("b");
    Node *pkgc=create_node("c");
    Node *pkgd=create_node("d");
    Node *pkge=create_node("e");

    add_node(graph,pkga);
    add_node(graph,pkgb);
    add_node(graph,pkgc);
    add_node(graph,pkgd);
    add_node(graph,pkge);


    add_dependency(pkga,pkgb);
    add_dependency(pkga,pkgc);
    add_dependency(pkgb,pkgd);
    add_dependency(pkgc,pkge);
*/

/*
Graph *graph = create_graph();

Node *pkgX = create_node("X");
Node *pkgY = create_node("Y");
Node *pkgZ = create_node("Z");

add_node(graph, pkgX);
add_node(graph, pkgY);
add_node(graph, pkgZ);

add_dependency(pkgX, pkgY);
add_dependency(pkgY, pkgZ);
add_dependency(pkgZ, pkgX);
*/

/*
Graph *graph = create_graph();
Node *pkgA = create_node("A");
Node *pkgB = create_node("B");
Node *pkgC = create_node("C");
Node *pkgD = create_node("D");
Node *pkgE = create_node("E");
Node *pkgF = create_node("F");
Node *pkgG = create_node("G");

add_node(graph, pkgA);
add_node(graph, pkgB);
add_node(graph, pkgC);
add_node(graph, pkgD);
add_node(graph, pkgE);
add_node(graph, pkgF);
add_node(graph, pkgG);

// Add dependencies
add_dependency(pkgA, pkgB);
add_dependency(pkgA, pkgC);
add_dependency(pkgB, pkgD);
add_dependency(pkgC, pkgD);
add_dependency(pkgD, pkgE);
add_dependency(pkgF, pkgC);
add_dependency(pkgG, pkgF);
*/


Graph *graph = create_graph();

if (graph == NULL) {

    fprintf(stderr, "Error: Failed to create graph.\n");

    return EXIT_FAILURE;

    }
    
build_graph(graph,pkg_name);

 if(has_cycle(graph)){

printf("error : dependency there is a cycle");
free_graph(graph); 

return EXIT_FAILURE;

 }
 else {
 resolve_dep(graph);

}

free_graph(graph);
return EXIT_FAILURE;
 







}
