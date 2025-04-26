#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "/usr/kraken/include/graph.h"
#include <assert.h>


int main(){
Graph *g = create_graph();
Node *n1 = create_node("nano","8.3");
Node *n2 = create_node("fireofx","20.5.3");
Node *n3 = create_node("vim","22.1");
Node *n4 = create_node("fmeg","88.3");
add_node(g,n1);
add_node(g,n2);
add_node(g,n3);
add_node(g,n4);
add_dependencies(n1,n2);
add_dependencies(n1,n3);
add_dependencies(n2,n4);
print_graph(g);



 return 0;
}



