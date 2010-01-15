#include <sys/types.h>
#include <grp.h>
#include <stdio.h>
#include <errno.h>

int main(int argc, const char* argv[])
{ short int lp;
  struct group * grpptr=NULL;

  printf("lookup %s\n", argv[1]);

  if ((grpptr=getgrnam(argv[1])) == NULL) {
    perror("getgrnam_r() error");
    switch (errno) {
      case EINTR: 
        printf("A signal was caught.\n"); 
        break; 
      case EIO: 
        printf("I/O error.\n"); 
        break; 
      case EMFILE: 
        printf("The maximum number (OPEN_MAX) of files was open already in the calling process.\n"); 
        break; 
      case ENFILE: 
        printf("The maximum number of files was open already in the system.\n"); 
        break; 
      case ENOMEM:
        printf("Insufficient memory to allocate group structure.\n"); 
        break; 
      case ERANGE: 
        printf("Insufficient buffer space supplied.\n"); 
        break; 
      default: 
        printf("Other error... %d\n", errno); 
        break; 
    }
  }
  else
  {
     printf("\nThe group name is: %s\n", grpptr->gr_name);
     printf("The gid         is: %u\n", grpptr->gr_gid);
     for (lp = 1; NULL != *(grpptr->gr_mem); lp++, (grpptr->gr_mem)++)
        printf("Group Member %d is: %s\n", lp, *(grpptr->gr_mem));
  }
}
