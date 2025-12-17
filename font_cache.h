/* font_cache.h - helper for measuring and caching best-fit font sizes */
#ifndef FONT_CACHE_H
#define FONT_CACHE_H

#include <raylib.h>

int FindBestFontSize(Font font, const char *a, const char *b, int maxWidth, int maxHeight, int maxSize, int minSize, int gap);

#endif // FONT_CACHE_H
