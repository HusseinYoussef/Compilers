typedef enum { typeCon, typeId, typeOpr } nodeEnum;
typedef enum { int_val, float_val, char_val, string_val } typeEnum;

/* constants */
typedef struct {
    typeEnum type;                  /* value of constant */

    union{
        int con_int;
        float con_float;
        char con_char;
        char* con_string;
    };
} conNodeType;

/* identifiers */
typedef struct {
    char* var_name;                      /* subscript to sym array */
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];	/* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    union {
        conNodeType con;         /* constants */
        idNodeType id;           /* identifiers */
        oprNodeType opr;         /* operators */
    };
} nodeType;

extern int sym[26];
