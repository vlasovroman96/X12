module tests-common.c;
@nogc nothrow:
extern(C): __gshared:
import core.sys.posix.sys.types;
import core.sys.posix.sys.wait;
import core.stdc.stdlib;
import core.stdc.stdio;
import core.sys.posix.unistd;

import tests-common;

void run_test_in_child(const(testfunc_t)* function() suite, const(char)* funcname)
{
    int cpid = void;
    int csts = void;
    int exit_code = -1;
    const(testfunc_t)* func = suite();

    printf("\n---------------------\n%s...\n", funcname);

    while (*func)
    {
        cpid = fork();
        if (cpid) {
            waitpid(cpid, &csts, 0);
            if (!WIFEXITED(csts))
                goto child_failed;
            exit_code = WEXITSTATUS(csts);
            if (exit_code != 0) {
    child_failed:
                printf(" FAIL\n");
                exit(exit_code);
            }
        } else {
            testfunc_t f = *func;
            f();
            exit(0);
        }
        func++;
    }
    printf(" Pass\n");
}
