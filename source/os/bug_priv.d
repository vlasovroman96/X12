module bug_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
/* Don't use this directly, use BUG_WARN or BUG_WARN_MSG instead */
enum string __BUG_WARN_MSG(string cond, string with_msg) = `\
    do { if (cond) {                                                  \
        ErrorF("BUG: 'if (" #cond ")'\n");                            \
        ErrorF("BUG: %s:%u in %s()\n", __FILE__, __LINE__, __func__); \
        if (with_msg) ErrorF(__VA_ARGS__);                            \
        xorg_backtrace();                                             \
    } } while(0)`;

enum string BUG_WARN_MSG(string cond) = `` ~ __BUG_WARN_MSG!(cond, `1`, `__VA_ARGS__`) ~ ``;

enum string BUG_WARN(string cond) = `` ~ __BUG_WARN_MSG!(cond, `0`, `null`) ~ ``;

enum string BUG_RETURN(string cond) = `
    do { if (` ~ cond ~ `) { ` ~ __BUG_WARN_MSG!(cond, `0`, `null`) ~ `; return; } } while(0)`;

enum string BUG_RETURN_MSG(string cond) = `
    do { if (` ~ cond ~ `) { ` ~ __BUG_WARN_MSG!(cond, `1`, `__VA_ARGS__`) ~ `; return; } } while(0)`;

enum string BUG_RETURN_VAL(string cond, string val) = `
    do { if (` ~ cond ~ `) { ` ~ __BUG_WARN_MSG!(cond, `0`, `null`) ~ `; return (` ~ val ~ `); } } while(0)`;

enum string BUG_RETURN_VAL_MSG(string cond, string val) = `
    do { if (` ~ cond ~ `) { ` ~ __BUG_WARN_MSG!(cond, `1`, `__VA_ARGS__`) ~ `; return (` ~ val ~ `); } } while(0)`;

 /* _XSERVER_OS_BUG_H_ */
