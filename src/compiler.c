#include <stdio.h>
#include <stdlib.h>
#include "compiler.h"
#include "compiler.tab.h"
#include <string.h>
#include "linked_list.h"

int t = 0;
char* quad(nodeType *p)
{
    switch (p->type)
    {
    case typeCon:
        
        switch (p->con.type)
        {
        char *str;
        case int_val: ;
            str = malloc(sizeof(char)*8);
            sprintf(str, "%d", p->con.con_int);
            return str;
            
        case float_val: ;
            str = malloc(sizeof(char)*8);
            sprintf(str, "%f", p->con.con_float);
            return str;
            
        case char_val: ;
            str = malloc(sizeof(char)*2);
            str[1] = 0;
            str[0] = p->con.con_char;
            return str;
            
        case string_val: ;
            char *str_dup = strdup(p->con.con_string);
            return str_dup;

        default:
            printf("Quads DONT BE HERE\n");
            break;
        }
        break;
    case typeId: ;
        char* str = strdup(p->id.var_name);
        return str;
    
    case typeOpr:
        
        if(p->opr.oper == '+' || p->opr.oper == '-' || p->opr.oper == '*' || p->opr.oper == '/')
        {
            char* LHS = strdup(quad(p->opr.op[0]));
            char* RHS = strdup(quad(p->opr.op[1]));

            //op arg1 arg2 result
            printf("%c\t%-15s\t\t%s\t\tT%d\n", p->opr.oper, LHS, RHS, t);
            
            char* str;
            (str = malloc(sizeof(char)*2));
            sprintf(str, "T%d", t++);

            free(LHS);
            free(RHS);
            return str;
        }
        else if(p->opr.oper == UMINUS)
        {
            char* LHS = strdup(quad(p->opr.op[0]));
            
            //- LHS NULL Var
            printf("MINUS\t%-15s\t\tNULL\t\tT%d\n", LHS, t);
            char* str;
            (str = malloc(sizeof(char)*2));
            sprintf(str, "T%d", t++);
            
            free (LHS);
            return str;
        }
        else if(p->opr.oper == '=')
        {
            char* LHS = strdup(quad(p->opr.op[0]));
            char* RHS = strdup(quad(p->opr.op[1]));

            //= RHS NULL Var
            printf("=\t%-15s\t\tNULL\t\t%s\n", RHS, LHS);
            
            free (LHS);
            free (RHS);
            return "";
        }
    default:
        printf("Quads NODE TYPE NOT FOUND\n");
        break;
    }

    return "";
}

char* update_table(nodeType *p)
{
    switch (p->type)
    {
    case typeCon:
        
        switch (p->con.type)
        {
        char *str;
        case int_val: ;
            str = malloc(sizeof(char)*8);
            sprintf(str, "%d", p->con.con_int);
            return str;
            
        case float_val: ;
            str = malloc(sizeof(char)*8);
            sprintf(str, "%f", p->con.con_float);
            return str;
            
        case char_val: ;
            str = malloc(sizeof(char)*2);
            str[1] = 0;
            str[0] = p->con.con_char;
            return str;
            
        case string_val: ;
            char *str_dup = strdup(p->con.con_string);
            return str_dup;

        default:
            printf("Update Table DONT BE HERE\n");
            break;
        }
        break;
    case typeId: ;
        node_t * var = search(p->id.var_name);

        switch(var->type)
        {
            char *str;
            case int_val:
                str = malloc(sizeof(char)*8);
                sprintf(str, "%d", var->iValue);
                return str;
            
            case float_val:
                str = malloc(sizeof(char)*8);
                sprintf(str, "%f", var->fValue);
                return str;
            
            case char_val:
                str = malloc(sizeof(char)*2);
                str[1] = 0;
                str[0] = var->cValue;
                return str;

            case string_val: ;
                char *str_dup = strdup(var->sValue);
                return str_dup;
        }            
    
    case typeOpr:
        
        if(p->opr.oper == '+' || p->opr.oper == '-' || p->opr.oper == '*' || p->opr.oper == '/')
        {
            char* LHS = strdup(update_table(p->opr.op[0]));
            char* RHS = strdup(update_table(p->opr.op[1]));

            char* str;
            (str = malloc(sizeof(char)*8));
            // int
            if(atoi(LHS) == atof(LHS) && atoi(RHS) == atof(RHS))
            {
                int result = 0;
                if(p->opr.oper == '+')
                    result = atoi(LHS) + atoi(RHS);
                else if (p->opr.oper == '-')
                    result = atoi(LHS) - atoi(RHS);
                else if (p->opr.oper == '*')
                    result = atoi(LHS) * atoi(RHS);
                else
                    result = atoi(LHS) / atoi(RHS);

                sprintf(str, "%d", result);
            }
            else // float
            {
                float result = 0;
                if(p->opr.oper == '+')
                    result = atof(LHS) + atof(RHS);
                else if(p->opr.oper == '-')
                    result = atof(LHS) - atof(RHS);
                else if(p->opr.oper == '*')
                    result = atof(LHS) * atof(RHS);
                else
                    result = atof(LHS) / atof(RHS);

                sprintf(str, "%f", result);
            }
            free(LHS);
            free(RHS);
            return str;
        }
        else if(p->opr.oper == UMINUS)
        {
            char* LHS = strdup(update_table(p->opr.op[0]));

            char* str;
            (str = malloc(sizeof(char)*8));
            if(atoi(LHS) == atof(LHS))
            {
                int result = -1 * atoi(LHS);
                sprintf(str, "%d", result);
            }
            else
            {
                float result = -1 * atof(LHS);
                sprintf(str, "%f", result);
            }
            free(LHS);
            return str;
        }
        else if(p->opr.oper == '=')
        {
            char* RHS = strdup(update_table(p->opr.op[1]));

            node_t * var = search(p->opr.op[0]->id.var_name);
            switch (var->type)
            {
            case int_val:
                var->iValue = atoi(RHS);
                break;
            case float_val:
                var->fValue = atof(RHS);
                break;
            case char_val:
                var->cValue = RHS[0];
                break;
            case string_val:
                var->sValue = strdup(RHS);
                break;
            default:
                break;
            }
            free(RHS);
            return "";
        }
    default:
        printf("Update table NODE TYPE NOT FOUND\n");
        break;
    }

    return "";
}

int ex(nodeType *p, int s_cnt, int update) {
    
    if (!p) return 0;

    // FILE *fp;
    // fp = freopen("quads.txt", "a", stdout);

    t=0;
    printf("\nQuadruples for statement: %d\n", s_cnt);
    quad(p);
    if(update)
        update_table(p);
    // fclose(fp);
    return 0;
}
