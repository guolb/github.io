原文参见: [detect-if-usb-disk-is-mounted-in-c-application-in-linux](https://unix.stackexchange.com/questions/497351/detect-if-usb-disk-is-mounted-in-c-application-in-linux)

If you need to check the full list of mount points, use getmntent(3) or its thread-safe GNU extension getmntent_r(3).

If you just want to quickly check whether a given directory has a filesystem mounted on it or not, then use one of the functions in the stat(2) family. For example, if you want to check if /mnt has a filesystem mounted or not, you could do something like this。

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

struct stat mountpoint;
struct stat parent;

/* Get the stat structure of the directory...*/
if stat("/mnt", &mountpoint) == -1) {
    perror("failed to stat mountpoint:");
    exit(EXIT_FAILURE);
}

/* ... and its parent. */
if stat("/mnt/..", &parent) == -1) {
    perror("failed to stat parent:");
    exit(EXIT_FAILURE);
}

/* Compare the st_dev fields in the results: if they are
   equal, then both the directory and its parent belong 
   to the same filesystem, and so the directory is not 
   currently a mount point.
*/
if (mountpoint.st_dev == parent.st_dev) {
    printf("No, there is nothing mounted in that directory.\n");
} else {
    printf("Yes, there is currently a filesystem mounted.\n");
}
```

