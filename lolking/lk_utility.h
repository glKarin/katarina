#ifndef LK_UTILITY_H
#define LK_UTILITY_H

#include "lk_std.h"

class QIODevice;

#define IN_READ(in, val) ((in).read((char *)(&(val)), (sizeof(val))))
#define IN_READ_ARR(in, val, size) ((in).read((char *)(&(val)), ((sizeof(val)) * (size))))

int8 * get_string(QIODevice *in, uint16 len = 0);
int8 * get_lower_string(QIODevice *in, uint16 len = 0);

#endif // LK_UTILITY_H
