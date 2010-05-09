#include "helper.h"

void rstat2stat(VALUE rstat, struct stat *statbuf)
{
  statbuf->st_dev     = FIX2ULONG(rb_funcall(rstat,rb_intern("dev"),0));
  statbuf->st_ino     = FIX2ULONG(rb_funcall(rstat,rb_intern("ino"),0));
  statbuf->st_mode    = FIX2UINT(rb_funcall(rstat,rb_intern("mode"),0));
  statbuf->st_nlink   = FIX2UINT(rb_funcall(rstat,rb_intern("nlink"),0));
  statbuf->st_uid     = FIX2UINT(rb_funcall(rstat,rb_intern("uid"),0));
  statbuf->st_gid     = FIX2UINT(rb_funcall(rstat,rb_intern("gid"),0));
  statbuf->st_rdev    = FIX2ULONG(rb_funcall(rstat,rb_intern("rdev"),0));
  statbuf->st_size    = FIX2ULONG(rb_funcall(rstat,rb_intern("size"),0));
  statbuf->st_blksize = NUM2ULONG(rb_funcall(rstat,rb_intern("blksize"),0));
  statbuf->st_blocks  = NUM2ULONG(rb_funcall(rstat,rb_intern("blocks"),0));
  statbuf->st_atime   =
    NUM2ULONG(rb_funcall(rb_funcall(rstat,rb_intern("atime"),0),rb_intern("to_i"),0));
  statbuf->st_mtime   =
    NUM2ULONG(rb_funcall(rb_funcall(rstat,rb_intern("mtime"),0),rb_intern("to_i"),0));
  statbuf->st_ctime   =
    NUM2ULONG(rb_funcall(rb_funcall(rstat,rb_intern("ctime"),0),rb_intern("to_i"),0));
}

void rstatvfs2statvfs(VALUE rstatvfs,struct statvfs *statvfsbuf) {
  statvfsbuf->f_bsize   = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_bsize"),0));
  statvfsbuf->f_frsize  = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_frsize"),0));
  statvfsbuf->f_blocks  = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_blocks"),0));
  statvfsbuf->f_bfree   = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_bfree"),0));
  statvfsbuf->f_bavail  = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_bavail"),0));
  statvfsbuf->f_files   = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_files"),0));
  statvfsbuf->f_ffree   = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_ffree"),0));
  statvfsbuf->f_favail  = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_favail"),0));
  statvfsbuf->f_fsid    = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_fsid"),0));
  statvfsbuf->f_flag    = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_flag"),0));
  statvfsbuf->f_namemax = FIX2ULONG(rb_funcall(rstatvfs,rb_intern("f_namemax"),0));
}

struct fuse_args * rarray2fuseargs(VALUE rarray){

  Check_Type(rarray, T_ARRAY);

  struct fuse_args *args = malloc(sizeof(struct fuse_args));

  args->argc      = RARRAY(rarray)->len;
  args->argv      = malloc(args->argc * sizeof(char *) + 1);
  /* Nope, this isn't really 'allocated'. The elements
   * of this array shouldn't be freed */
  args->allocated = 0;

  int i;
  VALUE v;
  for(i = 0; i < args->argc; i++) {
    v = RARRAY(rarray)->ptr[i];
    Check_Type(v, T_STRING);
    args->argv[i] = STR2CSTR(RSTRING(v));
  }
  args->argv[args->argc] = NULL;
  
  return args;
}

