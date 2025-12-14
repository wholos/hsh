#include <stdio.h>
#include <stdlib.h>
// Config library
#include "../cfg.h"
int main() {
    while(1) {
    char tty[1024];
    printf("hsh# ");
    fflush(stdout);
    fgets(tty,sizeof(tty),stdin);
    system(tty);
    }
}
