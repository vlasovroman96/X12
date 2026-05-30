module action_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
enum ActionEvent {
    ACTION_TERMINATE          = 0,    /* Terminate Server */
    ACTION_NEXT_MODE          = 10,   /* Switch to next video mode */
    ACTION_PREV_MODE,
    ACTION_SWITCHSCREEN       = 100,  /* VT switch */
    ACTION_SWITCHSCREEN_NEXT,
    ACTION_SWITCHSCREEN_PREV,
}
alias ACTION_TERMINATE = ActionEvent.ACTION_TERMINATE;
alias ACTION_NEXT_MODE = ActionEvent.ACTION_NEXT_MODE;
alias ACTION_PREV_MODE = ActionEvent.ACTION_PREV_MODE;
alias ACTION_SWITCHSCREEN = ActionEvent.ACTION_SWITCHSCREEN;
alias ACTION_SWITCHSCREEN_NEXT = ActionEvent.ACTION_SWITCHSCREEN_NEXT;
alias ACTION_SWITCHSCREEN_PREV = ActionEvent.ACTION_SWITCHSCREEN_PREV;


void xf86ProcessActionEvent(ActionEvent action, void* arg);

 /* __XSERVER_XFREE86_ACTION_PRIV_H */
