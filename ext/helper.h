#include <sys/stat.h>
#include <ruby.h>
#include <fuse.h>

#ifndef _RHUSE_HELPER_H
#define _RHUSE_HELPER_H

void rstat2stat(VALUE rstat,struct stat *statbuf);
struct fuse_args * rarray2fuseargs(VALUE rarray);

#endif
