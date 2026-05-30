module include.optionstr.h;
@nogc nothrow:
extern(C): __gshared:
 
public import include.list;

struct _InputOption {
    GenericListRec list;
    char* opt_name;
    char* opt_val;
    int opt_used;
    char* opt_comment;
}

                          /* INPUTSTRUCT_H */
