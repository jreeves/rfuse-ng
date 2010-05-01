#include <stdlib.h>
#include <string.h>
#include <fuse.h>
#include "intern_rfuse.h"

struct intern_fuse *intern_fuse_new() {
  struct intern_fuse *inf;
  inf = (struct intern_fuse *) malloc(sizeof(struct intern_fuse));
  return inf;
};

int intern_fuse_destroy(struct intern_fuse *inf){
  //you have to take care, that fuse is unmounted yourself!
  fuse_destroy(inf->fuse);
  free(inf);
  return 0;
};

int intern_fuse_init(
  struct intern_fuse *inf,
  const char *mountpoint, 
  struct fuse_args *kernelopts,
  struct fuse_args *libopts)
{
  struct fuse_chan* fc;

  fc = fuse_mount(mountpoint, kernelopts);

  if (fc == NULL) {
    return -1;
  }

  inf->fuse=fuse_new(fc, libopts, &(inf->fuse_op), sizeof(struct fuse_operations), NULL);
  inf->fc = fc;

  if (strlen(inf->mountname) > MOUNTNAME_MAX) {
    return -1;
  }

  strncpy(inf->mountname, mountpoint, MOUNTNAME_MAX);
  return 0;
};
