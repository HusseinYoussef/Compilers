#include <stdio.h>
#include <string.h>

void push(node_t *new_node)
{
    node_t * current = head;
    if (current == NULL)
    {
        head = new_node;
        return;
    }

    while (current->next != NULL)
    {
        current = current->next;
    }

    current->next = new_node;
    current->next->next = NULL;
}

node_t* search(char* var_name)
{
    node_t * current = head;

    if (current == NULL)
    {
        return NULL;
    }

    while (current != NULL)
    {
        int result = strcmp(var_name, current->name);
        // same variable name
        if (result == 0)
        {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void print_list(node_t * head) 
{
    node_t * current = head;

    while (current != NULL)
    {
        printf("==================================================\n");
        printf("Variable\t\tType\t\tValue\n");
        switch (current->type)
        {
        case int_val:
            if(current->initial)
                printf("%-15s\t\tint\t\t%d\n", current->name, current->iValue);
            else
                printf("%-15s\t\tint\t\tNULL\n", current->name);
            break;
        case float_val:
            if(current->initial)
                printf("%-15s\t\tfloat\t\t%f\n", current->name, current->fValue);
            else
                printf("%-15s\t\tint\t\tNULL\n", current->name);
            break;
        case char_val:
            if(current->initial)
                printf("%-15s\t\tchar\t\t%c\n", current->name, current->cValue);
            else
                printf("%-15s\t\tint\t\tNULL\n", current->name);
            break;
        case string_val:
            if(current->initial)
                printf("%-15s\t\tstring\t\t%s\n", current->name, current->sValue);
            else
                printf("%-15s\t\tint\t\tNULL\n", current->name);
            break;
        default:
            break;
        }
        printf("==================================================\n");

        current = current->next;
    }
}