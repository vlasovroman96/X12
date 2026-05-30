module os.mathx_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
version (MIN) {} else {
enum string MIN(string a,string b) = `(((` ~ a ~ `)<(` ~ b ~ `))?(` ~ a ~ `):(` ~ b ~ `))`;
}

version (MAX) {} else {
enum string MAX(string a,string b) = `(((` ~ a ~ `)>(` ~ b ~ `))?(` ~ a ~ `):(` ~ b ~ `))`;
}

 /* _XSERVER_OS_MATHX_PRIV_H_ */
