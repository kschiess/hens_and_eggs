#include <stdio.h>

#define PATH_MAX 1024

int main( int argc, const char* argv[] ) {
  FILE *fp;
  int status;
  char path[PATH_MAX];

  fp = popen("svnserve -t", "r+");
  if (fp == NULL)
    printf("fp == NULL");
    
  fwrite("()\n", sizeof(char), 3, fp);
  
  while (fread(path, sizeof(char), PATH_MAX, fp) > 0)
    printf("%s", path);

  status = pclose(fp);
  if (status == -1) {
    printf("pclose error");
  } else {
    /* Use macros described under wait() to inspect `status' in order
       to determine success/failure of command executed by popen() */
  }  
}

