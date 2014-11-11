#include <errno.h>
#include <stdlib.h>

struct list_head {
    struct list_head *prev;
    struct list_head *next;
    void *payload;
};

struct list_head *list_add(struct list_head *root, void *payload)
{
    struct list_head *l, *n;

    n = calloc(1, sizeof(struct list_head));
    if (!n)
        exit(ENOMEM);

    n->payload = payload;

    if (!root)
        return n;

    for (l = root; l->next; l = l->next);
    n->prev = l;
    l->next = n;

    return root;
}

struct list_head *list_remove(struct list_head *root, struct list_head *rm)
{
    if (!root || !rm)
        return NULL;

    if (root == rm) {
        struct list_head *nr = root->next;

        if (nr)
            nr->prev = NULL;

        free(root);
        return nr;
    } else {
        struct list_head *l;

        for (l = root; l; l = l->next)
            if (l == rm)
                break;

        l->prev->next = l->next;
        if (l->next)
            l->next->prev = l->prev;

        free(l);
    }

    return root;
}

unsigned int list_length(struct list_head *root)
{
    struct list_head *l;
    unsigned int count = 0;

    if (!root)
        return 0;

    for (l = root; l; l = l->next)
        count++;

    return count;
}

