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
