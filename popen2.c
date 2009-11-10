#include <stdio.h>
#include <unistd.h>
#include <pthread.h>

void* read_from_stdout(void* param) {
  int stdout = *((int*)param); 
  char buffer[1024]; 
  
  printf("read_from_stdout running...\n");
  
  int len; 
  while ((len=read(stdout, buffer, 1024)) > 0) {
    printf("got %d bytes of data (w)...\n", len);
    write(STDOUT_FILENO, buffer, len); 
  }
  
  return NULL; 
}
void* write_to_stdin(void* param) {
  int stdin = *((int*) param);

  char buffer[1024]; 
  
  printf("write_to_stdin running...\n");
  
  int len; 
  while ((len=read(STDIN_FILENO, buffer, 1024)) > 0) {
    printf("got data (r)...\n");
    write(stdin, buffer, len); 
  }
  
  return NULL; 
}

int main( int argc, const char* argv[] ) {
  const char* program_name = "svnserve -t";

  int stdout[2], stdin[2];
  
  if (pipe(stdout)<0) perror("stdout pipe cannot be created");
  if (pipe(stdin)<0) perror("stdout pipe cannot be created");
    
  pid_t child; 

  child = fork(); 
  if (0 == child) {
    /* Inside child process */
    printf("Running %s in child...\n", program_name);
    
    // close parts of the pipe childout and childin
    close(stdout[0]); close(stdin[1]);
    
    dup2(stdout[1], STDOUT_FILENO);     
    dup2(stdout[1], STDERR_FILENO);
    dup2(stdin[0], STDIN_FILENO); 
    
    // we don't use these anymore.
    close(stdout[1]); close(stdin[0]);    
    
    // execute the child program
    // execlp("ls", "ls", NULL);
    execlp("svnserve", "svnserve", "-t", NULL);
    
    perror("execlp failed");
  }
  
  /* Inside parent process */
  
  // close write end of childout and read end of childin
  close(stdout[1]); close(stdin[0]);
  sleep(1);
  
  // spawn threads that copy info
  pthread_t threads[2];
  pthread_attr_t pthread_custom_attr;
  
  pthread_attr_init(&pthread_custom_attr);
  pthread_create(&threads[0], &pthread_custom_attr, read_from_stdout, &stdout[0]);
  pthread_create(&threads[0], &pthread_custom_attr, write_to_stdin, &stdin[1]);

  // wait for end of child
  printf("Waiting for child to return...\n");
  int child_stat; 
  if (waitpid(0, &child_stat, 0) < 0) {
    perror("waitpid");
  }
  
  // wait a little longer, until the buffers are cleared.
  sleep(2);
}
