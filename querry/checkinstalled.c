#include <stdio.h>
#include <sqlite3.h>
#include <stdlib.h>
#include <string.h>

//return types of the checkinstalled 
//0: Not installed

//1: Installed

//2: Usage error

//3: Database connection error

//4: SQL preparation error




#define DB_PATH "/var/lib/kraken/db/kraken.db"

//ok , we learn some shit here 
void usage (const char * ptr){

      fprintf(stderr, "Usage: %s <package-name> <version>\n", ptr);

}



int main(int argc , char *argv[]){

 
  if (argc != 3){

    usage(argv[0]);
    return 2;
  }
 
  const char *pkgname = argv[1];
 const char *version = argv[2];
 sqlite3 *db;
 int rc;
   int exists = 0;
 
 //open the connection to the  f*** db

 rc = sqlite3_open(DB_PATH,&db);
 if (rc!=SQLITE_OK){

   fprintf(stderr, "Database error: %s\n", sqlite3_errmsg(db));
   sqlite3_close(db);
   return 3;


 }


 //prepare the sql statement with the package and version parameters

 const char *sql = "SELECT 1 FROM packages "
                     " WHERE name = ? "
                     " AND  version = ? "
                     " AND installed = 1; ";
               
 sqlite3_stmt *stmt;
 rc= sqlite3_prepare_v2(db,sql,-1,&stmt,NULL);
 if(rc != SQLITE_OK){
       fprintf(stderr, "SQL error: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return 4;
 }

 //BIND THE PARAMATER OF THE SQL QUERRY

   sqlite3_bind_text(stmt, 1, pkgname, -1, SQLITE_STATIC);
   sqlite3_bind_text(stmt, 2, version, -1, SQLITE_STATIC);
 
   //exexute the querry btw  i hate sql in c

   rc = sqlite3_step(stmt);
   if (rc == SQLITE_ROW) {
        exists = 1;
    } else if (rc != SQLITE_DONE) {
        fprintf(stderr, "Query failed: %s\n", sqlite3_errmsg(db));
    }
// Cleanup
    sqlite3_finalize(stmt);
    sqlite3_close(db);

   if (exists == 1) {
    return 1;
}

   else if(exists == 0) {
    return 0;
}

   //TBD: handle the other return 2 , 3 , 4     

   
}
