#include "font_cache.h"
#include <stdint.h>
#include <string.h>

// FindBestFontSize with a small direct-mapped cache.
int FindBestFontSize(Font font, const char *a, const char *b, int maxWidth, int maxHeight, int maxSize, int minSize, int gap) {
  enum { CACHE_SIZE = 256 };
  typedef struct { uint64_t key; int size; int used; } CacheEntry;
  static CacheEntry cache[CACHE_SIZE] = {0};

  const uint64_t FNV_OFFSET = 14695981039346656037ULL;
  const uint64_t FNV_PRIME = 1099511628211ULL;
  uint64_t h = FNV_OFFSET;

  // mix font identity and numeric params
  uintptr_t fb = (uintptr_t)font.baseSize;
  uintptr_t tid = (uintptr_t)font.texture.id;
  const void *parts[] = { &fb, &tid, &maxWidth, &maxHeight, &maxSize, &minSize, &gap };
  for (size_t i = 0; i < sizeof(parts)/sizeof(parts[0]); ++i) {
    const unsigned char *p = (const unsigned char *)parts[i];
    size_t len = sizeof(uintptr_t);
    for (size_t j = 0; j < len; ++j) {
      h ^= (uint64_t)p[j];
      h *= FNV_PRIME;
    }
  }

  // mix strings
  for (const char *s = a; s && *s; ++s) { h ^= (uint64_t)(unsigned char)(*s); h *= FNV_PRIME; }
  h ^= (uint64_t)0xff; h *= FNV_PRIME;
  for (const char *s = b; s && *s; ++s) { h ^= (uint64_t)(unsigned char)(*s); h *= FNV_PRIME; }

  size_t idx = (size_t)(h & (CACHE_SIZE - 1));
  CacheEntry *entry = &cache[idx];
  if (entry->used && entry->key == h) {
    return entry->size;
  }

  // compute best size
  int result = minSize;
  for (int sz = maxSize; sz >= minSize; --sz) {
    Vector2 A = MeasureTextEx(font, a, (float)sz, 0);
    Vector2 B = MeasureTextEx(font, b, (float)sz, 0);
    if ((int)A.x <= maxWidth && (int)B.x <= maxWidth && ((int)A.y + (int)B.y + gap) <= maxHeight) {
      result = sz;
      break;
    }
  }

  entry->key = h;
  entry->size = result;
  entry->used = 1;

  return result;
}
