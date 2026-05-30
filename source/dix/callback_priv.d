module callback_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import include.callback;

void InitCallbackManager();
void DeleteCallbackManager();

struct _CallbackRec {
    CallbackProcPtr proc;
    void* data;
    Bool deleted;
    _CallbackRec* next;
}alias CallbackRec = _CallbackRec;
alias CallbackPtr = _CallbackRec*;

struct CallbackListRec {
    int inCallback;
    Bool deleted;
    int numDeleted;
    CallbackPtr list;
}

/*
 * @brief delete a callback list
 *
 * Calling this is necessary if a CallbackListPtr is used inside a dynamically
 * allocated structure, before it is freed. If it's not done, memory corruption
 * or segfault can happen at a much later point (eg. next server incarnation)
 *
 * @param pcbl pointer to the list head (CallbackListPtr)
 */
void DeleteCallbackList(CallbackListPtr* pcbl);

 /* _XSERVER_CALLBACK_PRIV_H */
