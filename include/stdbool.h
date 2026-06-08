#ifndef WDKZ3_STDBOOL_H
#define WDKZ3_STDBOOL_H

#ifndef __cplusplus
#ifndef bool
typedef unsigned char bool;
#endif

#ifndef true
#define true ((bool)1)
#endif

#ifndef false
#define false ((bool)0)
#endif
#endif

#endif
