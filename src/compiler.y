%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdarg.h>
#include "compiler.h"
#include "linked_list.h"
/* prototypes */
nodeType *opr(int rule, int oper, int nops, ...);
nodeType *id(char* var_name);
nodeType *con(conNodeType *con_node);
bool chech_type(char* var_name, nodeType* p, typeEnum var_type);
bool declaration(char* name, typeEnum type, int init);
void assignment(char* lhs, nodeType* rhs);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

int err = 0;
void yyerror(char *s);
int sym[26];                    /* symbol table */
node_t *head = NULL;            /* symbol table */
#include "linked_list.c"
extern FILE *yyin;

%}


%union {
    int iValue;                     /* integer value */
    float fValue;                   /* float value */
    char cValue;                    /* char value "c" */ 
    char *sValue;                   /* string value "wdwd" */
    
    char *var_name;                 /* variable name */
    nodeType *nPtr;                 /* node pointer */
};

%token <iValue> INTEGER
%token <fValue> FLOAT
%token <cValue> CHAR
%token <sValue> STRING
%token <var_name> VARIABLE
// type reserved words
%token type_int type_float type_char type_string
%token WHILE IF PRINT
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> stmt expr stmt_list

%%

program:
        function                { printf("TERMINATE"); }
        ;

function:
          function stmt         { freeNode($2); err=0;}                                         
        | /* NULL */
        ;

stmt:
          ';'                               { $$ = opr(';', 2, NULL, NULL); }
        | expr ';'                          { 
                                               $$ = $1;
                                            }
        | PRINT expr ';'                    { $$ = opr(PRINT, 1, $2); }
        
        | type_int VARIABLE ';'             { 
                                               declaration($2, int_val, 0); 
                                               $$ = id($2);
                                            }
        
        | type_float VARIABLE ';'           { 
                                               declaration($2, float_val, 0);
                                               $$ = id($2);
                                            }
        
        | type_char VARIABLE ';'            { 
                                               declaration($2, char_val, 0);
                                               $$ = id($2);
                                            }
        
        | type_string VARIABLE ';'          { 
                                               declaration($2, string_val, 0);
                                               $$ = id($2);
                                            }
        
        | type_int VARIABLE '=' expr ';'    { $$ = opr(int_val, '=', 2, id($2), $4);}
        
        
        | type_float VARIABLE '=' expr ';'  { $$ = opr(float_val, '=', 2, id($2), $4);}
        
        
        | type_char VARIABLE '=' expr ';'   { $$ = opr(char_val, '=', 2, id($2), $4);}
        
        
        | type_string VARIABLE '=' expr ';' { $$ = opr(string_val, '=', 2, id($2), $4);}

        | VARIABLE '=' expr ';'             { $$ = opr(-1, '=', 2, id($1), $3);}
    
        | '{' stmt_list '}'                 { $$ = $2; }
        ;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = opr(-1, ';', 2, $1, $2); }
        ;

expr:
          INTEGER               {
                                    conNodeType *con_ptr;
                                    if ((con_ptr = malloc(sizeof(conNodeType))) == NULL)
                                        printf("out of memory\n");
                                    con_ptr->type = int_val;
                                    con_ptr->con_int = $1;
                                    $$ = con(con_ptr);
                                }
        | FLOAT                 { 
                                    conNodeType *con_ptr;
                                    if ((con_ptr = malloc(sizeof(conNodeType))) == NULL)
                                        printf("out of memory\n");
                                    con_ptr->type = float_val;
                                    con_ptr->con_float = $1;
                                    $$ = con(con_ptr); 
                                }
        | CHAR                  {
                                    conNodeType *con_ptr;
                                    if ((con_ptr = malloc(sizeof(conNodeType))) == NULL)
                                        printf("out of memory\n");
                                    con_ptr->type = char_val;
                                    con_ptr->con_char = $1;
                                    $$ = con(con_ptr);
                                }
        | STRING                {
                                    conNodeType *con_ptr;
                                    if ((con_ptr = malloc(sizeof(conNodeType))) == NULL)
                                        printf("out of memory\n");
                                    con_ptr->type = string_val;
                                    con_ptr->con_string = strdup($1);
                                    $$ = con(con_ptr);
                                }
        | VARIABLE              { $$ = id($1); }

        | '-' expr %prec UMINUS {
                                    $$ = opr(-1, UMINUS, 1, $2);
                                }

        | expr '+' expr         { $$ = opr(-1, '+', 2, $1, $3); }
        | expr '-' expr         { $$ = opr(-1, '-', 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%

// REVISED
nodeType *con(conNodeType *con_node) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        printf("out of memory\n");

    /* copy information */
    p->type = typeCon;
    p->con.type = con_node->type;

    switch (con_node->type)
    {
        case int_val:
            p->con.con_int = con_node->con_int;
            break;
        case float_val:
            p->con.con_float = con_node->con_float;
            break;
        case char_val:
            p->con.con_char = con_node->con_char;
            break;
        case string_val:
            p->con.con_string = con_node->con_string;
            break;
        default:
            break;
    }

    return p;
}

// REVISED
nodeType *id(char* var_name)
{
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        printf("out of memory\n");

    /* copy information */
    p->type = typeId;
    p->id.var_name = strdup(var_name);
    return p;
}

typeEnum get_operand_type(nodeType* op, int oper)
{
    typeEnum operand_type;
    node_t * var = NULL;
    switch(op->type)
    {
        case typeCon:
            operand_type = op->con.type;
            break;
        case typeId:
        
            var = search(op->id.var_name);
            if(var == NULL )
            {   
                yyerror("Variable undeclared");
                err = 1;
                // return anything
                return -1;
            }
            else if (var->initial == 0)
            {
                yyerror("Variable uninitialized");
                err = 1;
                // return anything
                return -1;
            }
            else
            {
                operand_type = var->type;
            }
            break;
        case typeOpr:
            operand_type = get_operand_type(op->opr.op[0], oper);
            break;
        default:
            printf("SHOULD NOT BE HERE\n");
            break;
    }
    return operand_type;
}

nodeType *opr(int rule, int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        printf("out of memory\n");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;

    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);

    if(nops == 2)
    {
        if (oper == '+' || oper == '-')
        {
            typeEnum operand1_type = get_operand_type(p->opr.op[0], oper);
            typeEnum operand2_type = get_operand_type(p->opr.op[1], oper);

            // error in getting type so don't continue
            if (operand1_type == -1 || operand2_type == -1)
            {
                return p;
            }

            if(operand1_type != operand2_type)
            {
                yyerror("+ or - Two operands type mismatch");
                err = 1;
            }
            if(operand1_type == char_val || operand1_type == string_val ||
                 operand2_type == char_val || operand2_type == string_val)
            {
                yyerror("Can't perform this operation on char or string");
                err = 1;
            }
        }
        else if(oper == '=')
        {
            node_t* var = search(p->opr.op[0]->id.var_name);
            typeEnum LHS_type;
            typeEnum RHS_type;
            // LHS
            if(rule >= 0)
            {
                if (var != NULL)
                {
                    yyerror("Redeclaration error with assignment =\n");
                    err=1;
                    return p;
                }
                else
                {
                    LHS_type = rule;
                }
            }
            else
            {
                if (var == NULL)
                {
                    yyerror("Undeclared variable with assignment =\n");
                    err=1;
                    return p;
                }
                else
                {
                    LHS_type = var->type;
                }
            }
            // RHS
            nodeType* RHS = p->opr.op[1];
            if(RHS->type == typeOpr)
            {
                if(RHS->opr.op[0]->type != typeOpr)
                    RHS_type = get_operand_type(RHS->opr.op[0], oper);
                else
                    RHS_type = get_operand_type(RHS->opr.op[1], oper);
            }
            else
                RHS_type = get_operand_type(RHS, oper);

            // printf("LHS %d RHS %d var \n", LHS_type, RHS_type, var);
            if(RHS_type != -1 && (LHS_type != RHS_type))
            {
                yyerror("Type mismatch with assignment =\n");
                err=1;
            }
            else if(RHS_type != -1 && (LHS_type == RHS_type))
            {
                if (rule >= 0)
                    declaration(p->opr.op[0]->id.var_name, rule, 1);
                else
                    var->initial = 1;
            }
        }
    }
    else if(nops == 1)
    {
        typeEnum operand1_type = get_operand_type(p->opr.op[0], oper);

        if(operand1_type == char_val || operand1_type == string_val)
        {
            yyerror("Operand type char or string");
            err = 1;
        }
    }

    return p;
}

bool chech_type(char* var_name, nodeType* p, typeEnum var_type)
{
    if(p->type == typeCon)
    {
        if(var_type != p->con.type)
            return false;
    }
    else if(p->type == typeId)
    {
        node_t * var = search(p->id.var_name);
        if(var_type != var->type)
            return false;
    }
    return true;
}

bool declaration(char* name, typeEnum type, int init)
{
    node_t * var = search(name);
    if (var == NULL)
    {
        node_t * node;
        if ((node = malloc(sizeof(node))) == NULL)
            printf("out of memory\n");

        node->name = strdup(name);
        node->type = type;
        node->initial = init;
        node->next = NULL;     

        // ?????????????????????????????????????????????????????
        if (err == 0)
        {
            push(node);
            printf("\nvariable %s added to the table\n", node->name);
        }

        return true;
    }
    else
    {
        yyerror("Redeclaration error");
        err = 1;
        return false;
    }
}

void assignment(char* lhs, nodeType* rhs)
{
    node_t * var = search(lhs);
    if(var == NULL)
    {
        printf("%s ", lhs);
        yyerror("wasn't declared in this scope");
    }
    else if(rhs->type == typeCon)
    {
        if(var->type == rhs->con.type)
        {
            var->initial = 1;
            switch (var->type)
            {
                case int_val:
                    var->iValue = rhs->con.con_int;
                    break;
                case float_val:
                    var->fValue = rhs->con.con_float;
                    break;
                case char_val:
                    var->cValue = rhs->con.con_char;
                    break;
                case string_val:
                    var->sValue = strdup(rhs->con.con_string);
                    break;
                default:
                    break;
            }
        } 
        else
        {
            yyerror("constant Type mismatch");
            // printf("\n");
        }
    }
    else if(rhs->type == typeId)
    {
        node_t * rhs_var = search(rhs->id.var_name);
        if(rhs_var == NULL)
        {
            printf("%s ", rhs->id.var_name);
            yyerror("wasn't declared in this scope\n");
        }
        else
        {
            // printf("HERE ELSE\n");
            if(var->type == rhs_var->type)
            {
                if(rhs_var->initial == 1)
                {    
                    var->initial = 1;
                    switch (var->type)
                    {
                        case int_val:
                            var->iValue = rhs_var->iValue;
                            break;
                        case float_val:
                            var->fValue = rhs_var->fValue;
                            break;
                        case char_val:
                            var->cValue = rhs_var->cValue;
                            break;
                        case string_val:
                            var->sValue = strdup(rhs_var->sValue);
                            break;
                        default:
                            break;
                    }
                }
                else
                {
                    printf("%s ", rhs_var->name);
                    yyerror("wasn't initialized");
                }
            }
            else
            {
                yyerror("Variable type mismatch");
            }
        }
    }

    print_list(head);
}

void freeNode(nodeType *p) {
    int i;
    // printf("START OF FREENODE\n");
    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    // printf("END OF FREENODE\n");
    free (p);
}

int main(int argc, char* argv[]) {

    yydebug = 0;

    char filename[100];
    strcpy(filename, argv[1]);
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
        printf("\nfilename is %s\n", filename);
    }
    else {
        printf("No files - Exit\n");
        exit(1);
    }

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));
    fclose(yyin);

    printf("\n\nSymbol Table %d\n", err);
    print_list(head);

    return 0;
}