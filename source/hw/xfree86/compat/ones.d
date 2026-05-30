module ones;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
import dix_config;

import X11.Xfuncproto;

/*
 * this is specifically for NVidia proprietary driver: they're again lagging
 * behind a year, doing at least some minimal cleanup of their code base.
 * All attempts to get in direct contact with them have failed.
 */

/*
 * this is only needed for the 570.x nvidia drivers
 */

export 

int Ones(c_ulong mask)
{                               /* HACKMEM 169 */
    /* can't add a message here because this should be fast */
version (__has_builtin) {
static if (__has_builtin(__builtin_popcountl)) {
    return __builtin_popcountl (mask);
}
} else version (__builtin_popcountl) {
    return __builtin_popcountl (mask);
} else {
    c_ulong y = void;

    y = (mask >> 1) & octal!"033333333333";
    y = mask - y - ((y >> 1) & octal!"033333333333");
    return (((y + (y >> 3)) & octal!"030707070707") % octal!"077");
}
}
