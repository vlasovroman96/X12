module atom_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
/*
 * @brief initialize atom table
 */
void InitAtoms();

/*
 * @brief free all atoms and atom table
 */
void FreeAllAtoms();

 /* _XSERVER_DIX_ATOM_PRIV_H */
