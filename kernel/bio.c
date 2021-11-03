// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.

#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

struct
{
  struct spinlock lock;
  struct buf buf[NBUF];

  // Linked list of all buffers, through prev/next.
  // Sorted by how recently the buffer was used.
  // head.next is most recent, head.prev is least.
} bcache;

struct
{
  struct spinlock lock;
  struct buf head;
} bbucket[NBUCKET];

void binit(void)
{
  struct buf *b;

  initlock(&bcache.lock, "bcache");

  int i = 0;

  for (i = 0; i < NBUCKET; ++i)
  {
    bbucket[i].head.prev = bbucket[i].head.next = &bbucket[i].head;
    initlock(&bbucket[i].lock, "bbucket");
  }

  i = 0;
  // Create linked list of buffers
  for (b = bcache.buf; b < bcache.buf + NBUF; ++b)
  {
    b->next = bbucket[i].head.next;
    b->prev = &bbucket[i].head;
    bbucket[i].head.next->prev = b;
    bbucket[i].head.next = b;
    initsleeplock(&b->lock, "buffer");
    ++i;
    if (i == NBUCKET)
      i = 0;
  }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf *
bget(uint dev, uint blockno)
{
  struct buf *b;

  int id = blockno % NBUCKET;

  acquire(&bbucket[id].lock);

  // Is the block already cached?
  for (b = bbucket[id].head.next; b != &bbucket[id].head; b = b->next)
  {
    if (b->dev == dev && b->blockno == blockno)
    {
      b->refcnt++;
      release(&bbucket[id].lock);
      acquiresleep(&b->lock);
      return b;
    }
  }

  for (b = bbucket[id].head.prev; b != &bbucket[id].head; b = b->prev)
  {
    if (b->refcnt == 0)
    {
      b->dev = dev;
      b->blockno = blockno;
      b->valid = 0;
      b->refcnt = 1;
      release(&bbucket[id].lock);
      acquiresleep(&b->lock);
      return b;
    }
  }

  release(&bbucket[id].lock);

  // Not cached.

  acquire(&bcache.lock);
  acquire(&bbucket[id].lock);
  for (int i = 0; i < NBUCKET; ++i)
  {
    if (i == id)
      continue;
    acquire(&bbucket[i].lock);
    for (b = bbucket[i].head.next; b != &bbucket[i].head; b = b->next)
    {
      if (b->refcnt == 0)
      {
        b->dev = dev;
        b->blockno = blockno;
        b->valid = 0;
        b->refcnt = 1;

        b->prev->next = b->next;
        b->next->prev = b->prev;

        b->prev = &bbucket[id].head;
        b->next = bbucket[id].head.next;
        bbucket[id].head.next->prev = b;
        bbucket[id].head.next = b;

        release(&bbucket[i].lock);
        release(&bbucket[id].lock);
        release(&bcache.lock);
        acquiresleep(&b->lock);
        return b;
      }
    }
    release(&bbucket[i].lock);
  }
  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid)
  {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
  if (!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b, 1);
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)
{
  if (!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);

  int id = b->blockno % NBUCKET;

  acquire(&bbucket[id].lock);
  b->refcnt--;
  if (b->refcnt == 0)
  {
    b->next->prev = b->prev;
    b->prev->next = b->next;

    b->next = bbucket[id].head.next;
    b->prev = &bbucket[id].head;
    bbucket[id].head.next->prev = b;
    bbucket[id].head.next = b;
  }
  release(&bbucket[id].lock);
}

void bpin(struct buf *b)
{
  int id = b->blockno % NBUCKET;

  acquire(&bbucket[id].lock);
  b->refcnt++;
  release(&bbucket[id].lock);
}

void bunpin(struct buf *b)
{
  int id = b->blockno % NBUCKET;

  acquire(&bbucket[id].lock);
  b->refcnt--;
  release(&bbucket[id].lock);
}
