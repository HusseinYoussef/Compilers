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
        printf("**************\n");
        switch (current->type)
        {
        case int_val:
            printf("%s\tint\n", current->name);
            break;
        case float_val:
            printf("%s\tfloat\n", current->name);
            break;
        case char_val:
            printf("%s\tchar\n", current->name);
            break;
        case string_val:
            printf("%s\tstring\n", current->name);
            break;
        default:
            break;
        }
        printf("**************\n");

        current = current->next;
    }
}