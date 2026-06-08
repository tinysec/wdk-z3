#include <z3.h>

int main()
{
    unsigned major = 0;
    unsigned minor = 0;
    unsigned build = 0;
    unsigned revision = 0;

    Z3_get_version(&major, &minor, &build, &revision);
    return major == 4 && minor == 16 ? 0 : 1;
}
