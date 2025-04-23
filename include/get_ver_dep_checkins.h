#include <stdbool.h>
#ifndef GET_VER_DEP_CHECKINST_H
#define GET_VER_DEP_CHECKINST_H

char * get_version(const char *pkgname);
char **get_deps(const char *pkgname,const char *version,int *count);
bool check_installed(const char *pkgname,const char *version);








#endif
