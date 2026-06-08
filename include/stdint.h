#ifndef WDKZ3_STDINT_H
#define WDKZ3_STDINT_H

typedef signed __int64 int64_t;
typedef unsigned __int64 uint64_t;

#ifndef INT64_C
#define INT64_C(x) x##i64
#endif

#ifndef UINT64_C
#define UINT64_C(x) x##ui64
#endif

#ifndef INT64_MAX
#define INT64_MAX 9223372036854775807i64
#endif

#ifndef INT64_MIN
#define INT64_MIN (-9223372036854775807i64 - 1)
#endif

#ifndef UINT64_MAX
#define UINT64_MAX 0xffffffffffffffffui64
#endif

#endif
