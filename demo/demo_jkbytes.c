/*
 *
 */

#include "jkbytes.h"
#include "cm_logprint.h"

CMLogPrint logPrint;

int main(int argc, char **args) 
{
    char *src = args[1];
    char dst[32] = {0};
    string_reerect(src, dst);
    printf("[%s] => [%s]\n", src, dst);

    return 0;
}
