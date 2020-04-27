typedef struct node {
    char* name;
    typeEnum type;
    int initial;
    
    union{
        int iValue;
        float fValue;
        char cValue;
        char* sValue;
    };

    struct node * next;
} node_t;

node_t* search(char* var_name);
void push(node_t *new_node);
void print_list(node_t * head);