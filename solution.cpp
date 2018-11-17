#include "kfilter.hpp"

extern char spaces[100];

void do_setplay(TiXmlElement* root)
{
    TiXmlNode* tnode;
    TiXmlNode* set;
    int i;
    puts("\nSet play");
    set = root->FirstChild("Sets");

    if (set != NULL) {
        i = 1;
        tnode = set->FirstChild("bm");

        while (tnode != NULL) {
            do_black_move(tnode, 1, i, false);
            tnode = set->IterateChildren("bm", tnode);
            i++;
        }
    }

    printf("\n");
    return;
}

void do_black_move(TiXmlNode* bm, int bmno, int lno, bool thr)
{
    TiXmlElement* telem;
    TiXmlNode* tnode;
    char* text;
    int i, tab;
    char* ptr;
    char* ptr1;
    telem = bm->ToElement();
    text = (char*) telem->GetText();
    ptr = strrchr(text, '.');

    if (ptr != NULL) {
        ptr1 = ptr + 1;

        while (*ptr1 != '\0') {
            *ptr = *ptr1;
            ptr++;
            ptr1++;
        }

        *ptr = *ptr1;
    }

    if (bmno == 1) {
        printf("\n");

        if (lno == 1) {
            printf("\n");
        }

        printf("%9s", " ");
    } else {
        if (thr == true) {
            tab = (bmno + (bmno - 1)) * MOVETAB;
            spaces[tab] = '\0';
            printf("\n%s", spaces);
            spaces[tab] = ' ';
        } else {
            if (lno > 1) {
                tab = (bmno + (bmno - 1)) * MOVETAB;
                spaces[tab] = '\0';
                printf("\n%s", spaces);
                spaces[tab] = ' ';
            }
        }
    }

    printf("%-9s", text);
    tnode = bm->FirstChild("wm");
    i = 0;

    while (tnode != NULL) {
        do_white_move(tnode, bmno + 1, i);
        tnode = bm->IterateChildren("wm", tnode);
        i++;
    }

    return;
}

void do_white_move(TiXmlNode* wm, int mno, int lno)
{
    TiXmlElement* telem = wm->ToElement();
    TiXmlNode* thr;
    TiXmlNode* tnode;
    char* text = (char*) telem->GetText();
    bool threats = false;
    int i;
    int tab;

    if (lno > 0) {
        printf("\n");
        tab = (mno - 1) * 2 * MOVETAB;
        spaces[tab] = '\0';
        printf("%s", spaces);
        spaces[tab] = ' ';
    }

    printf("%-9s", text);
    thr = wm->FirstChild("thr");

    if (thr != NULL) {
        printf("%-9s", "thr");
        i = 0;
        tnode = thr->FirstChild("wm");

        while (tnode != NULL) {
            do_white_move(tnode, mno + 1, i);
            tnode = thr->IterateChildren("wm", tnode);
            i++;
        }

        threats = true;
    }

    tnode = wm->FirstChild("bm");
    i = 1;

    while (tnode != NULL) {
        do_black_move(tnode, mno, i, threats);
        tnode = wm->IterateChildren("bm", tnode);
        i++;
    }

    return;
}

void do_tryplay(TiXmlElement* root)
{
    TiXmlNode* tnode;
    TiXmlNode* tries;
    int i;
    puts("\nTry play");
    tries = root->FirstChild("Tries");

    if (tries != NULL) {
        i = 0;
        tnode = tries->FirstChild("wm");

        while (tnode != NULL) {
            printf("\n");
            do_white_move(tnode, 1, i);
            tnode = tries->IterateChildren("wm", tnode);
            i++;
        }
    }

    printf("\n");
    return;
}

void do_actualplay(TiXmlElement* root)
{
    TiXmlNode* tnode;
    TiXmlNode* keys;
    int i;
    puts("\nActual play");
    keys = root->FirstChild("Keys");

    if (keys != NULL) {
        tnode = keys->FirstChild("wm");
        i = 0;

        while (tnode != NULL) {
            printf("\n");
            do_white_move(tnode, 1, i);
            tnode = keys->IterateChildren("wm", tnode);
            i++;
        }
    }

    printf("\n");
    return;
}
