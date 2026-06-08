#include <stdio.h>
#include <z3.h>

int main(void)
{
    unsigned major;
    unsigned minor;
    unsigned build;
    unsigned revision;
    Z3_config cfg;
    Z3_context ctx;
    Z3_sort bool_sort;
    Z3_symbol name;
    Z3_ast p;
    Z3_solver solver;
    Z3_lbool result;

    Z3_get_version(&major, &minor, &build, &revision);
    if (major != 4 || minor != 16) {
        printf("unexpected Z3 version: %u.%u.%u.%u\n",
               major,
               minor,
               build,
               revision);
        return 1;
    }

    cfg = Z3_mk_config();
    ctx = Z3_mk_context(cfg);
    Z3_del_config(cfg);

    bool_sort = Z3_mk_bool_sort(ctx);
    name = Z3_mk_string_symbol(ctx, "p");
    p = Z3_mk_const(ctx, name, bool_sort);

    solver = Z3_mk_solver(ctx);
    Z3_solver_inc_ref(ctx, solver);
    Z3_solver_assert(ctx, solver, p);
    result = Z3_solver_check(ctx, solver);
    Z3_solver_dec_ref(ctx, solver);
    Z3_del_context(ctx);

    if (result != Z3_L_TRUE) {
        printf("unexpected solver result: %d\n", (int)result);
        return 2;
    }

    return 0;
}
