// Mutual exclusion lock.
#include "memlayout.h"

struct spinlock
{
  uint locked; // Is the lock held?

  // For debugging:
  char *name;      // Name of lock.
  struct cpu *cpu; // The cpu holding the lock.
};
struct q
{
  struct spinlock lock;
  int memref[PHYSTOP / 4096];
};
