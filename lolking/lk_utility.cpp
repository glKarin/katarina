#include "lk_utility.h"
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <QIODevice>

int8 * get_lower_string(QIODevice *in, uint16 len)
{
	int8 *str = get_string(in, len);
	size_t l = strlen(str);
	int i;
	for(i = 0; i < l; i++)
		if(isupper(str[i]))
			str[i] = tolower(str[i]);
	return str;
}

int8 * get_string(QIODevice *in, uint16 len)
{
    if(len == 0)
        IN_READ(*in, len);
    int8 *str = (int8 *)malloc(len + 1);
		memset(str, 0, len + 1);
    /*
    for(int i = 0; i < len; i++)
        IN_READ(in, str[i]);
        */
    IN_READ_ARR(*in, str[0], len);
    str[len] = '\0';
		return str;
}

