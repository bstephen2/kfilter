#include "kfilter.hpp"

static char cells[BOARDSIZE];

static char* get_fen(char* fors, char* stip, char* castling, char* ep)
{
    char* fen = (char*) calloc(1, 100);
    fen[0] = '(';
    fen[1] = '\0';
    strcat(fen, fors);

    if (stip[0] == 'H') {
        strcat(fen, " b ");
    } else {
        strcat(fen, " w ");
    }

    if ((castling != NULL) && (strlen(castling) > 0)) {
        strcat(fen, castling);
    } else {
        strcat(fen, "-");
    }

    if ((ep != NULL) && (strlen(ep) > 0)) {
        strcat(fen, ep);
    } else {
        strcat(fen, " -");
    }

    strcat(fen, " 0 1)");
    return fen;
}

TiXmlNode* do_diagram(TiXmlElement* root)
{
    TiXmlElement* diag;
    TiXmlElement* stip;
    TiXmlElement* cast;
    TiXmlElement* enpassant;
    TiXmlElement* mv;
    TiXmlNode* tnode;
    TiXmlNode* options;
    div_t result;
    char forsythe[100];
    char fullstip[10];
    char pc[10];
    char udiag[50];
    int i, b, c, gap, j, w;
    int white = 0;
    int black = 0;
    char* kings;
    char* gbr;
    char* pos;
    char* text;
    char* l;
    char* stiptext;
    char* moves;
    char* fen;
    char* castling = NULL;
    char* ep = NULL;
    memset(cells, ' ', BOARDSIZE);
    tnode = root->FirstChild("Diagram");
    diag = tnode->ToElement();
    text = (char*) diag->GetText();
    kings = strtok(text, ":");
    gbr = strtok(NULL, ":");
    pos = strtok(NULL, ":");
    //White king.
    i = SQUARE_TO_INT(kings);
    cells[i] = 'K';
    white++;
    //Black king.
    i = SQUARE_TO_INT(kings + 2);
    cells[i] = 'k';
    black++;
    l = pos;
    c = *gbr - '0';
    result = div(c, 3);
    b = result.quot;
    w = result.rem;
    white += result.rem;
    black += result.quot;

    // White queens

    while (w > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'Q';
        w--;
        l += 2;
    }

    // Black queens

    while (b > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'q';
        b--;
        l += 2;
    }

    c = *(gbr + 1) - '0';
    result = div(c, 3);
    b = result.quot;
    w = result.rem;
    white += result.rem;
    black += result.quot;

    // White rooks

    while (w > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'R';
        w--;
        l += 2;
    }

    // Black rooks

    while (b > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'r';
        b--;
        l += 2;
    }

    c = *(gbr + 2) - '0';
    result = div(c, 3);
    b = result.quot;
    w = result.rem;
    white += result.rem;
    black += result.quot;

    // White bishops

    while (w > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'B';
        w--;
        l += 2;
    }

    // Black bishops

    while (b > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'b';
        b--;
        l += 2;
    }

    c = *(gbr + 3) - '0';
    result = div(c, 3);
    b = result.quot;
    w = result.rem;
    white += result.rem;
    black += result.quot;

    // White knights

    while (w > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'S';
        w--;
        l += 2;
    }

    // Black knights

    while (b > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 's';
        b--;
        l += 2;
    }

    // White pawns
    c = *(gbr + 5) - '0';
    white += c;

    while (c > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'P';
        c--;
        l += 2;
    }

    // Black pawns
    c = *(gbr + 6) - '0';
    black += c;

    while (c > 0) {
        i = SQUARE_TO_INT(l);
        cells[i] = 'p';
        c--;
        l += 2;
    }

    options = root->FirstChild("options");
    tnode = options->FirstChild("stip");
    stip = tnode->ToElement();
    stiptext = (char*) stip->GetText();
    tnode = options->FirstChild("castling");
    cast = tnode->ToElement();
    castling = (char*) cast->GetText();
    tnode = options->FirstChild("ep");
    enpassant = tnode->ToElement();
    ep = (char*) enpassant->GetText();
    tnode = options->FirstChild("moves");
    mv = tnode->ToElement();
    moves = (char*) mv->GetText();
    strcpy(fullstip, stiptext);
    strcat(fullstip, moves);
    forsythe[0] = '\0';

    for (i = 0; i < 63; i += 8) {
        int number = 0;
        int ct = 0;
        char temp[2];
        temp[1] = '\0';

        if (i != 0) {
            strcat(forsythe, "/");
        }

        for (j = 0; j < 8; j++) {
            char a = cells[i + j];

            if (a == ' ') {
                if (number == 0) {
                    number = 1;
                    ct = 1;
                } else {
                    ct++;
                }

                if (j == 7) {
                    temp[0] = '0' + ct;
                    strcat(forsythe, temp);
                }
            } else {
                if (number == 1) {
                    temp[0] = '0' + ct;
                    strcat(forsythe, temp);
                    temp[0] = a;
                    strcat(forsythe, temp);
                    number = 0;
                } else {
                    temp[0] = a;
                    strcat(forsythe, temp);
                    number = 0;
                }
            }
        }
    }

    fen = get_fen(forsythe, fullstip, castling, ep);
    puts(fen);
    printf("%s", RANK_LINE);

    for (i = 0; i < 63; i += 8) {
        for (j = 0; j < 8; j++) {
            printf("| %c ", cells[i + j]);
        }

        printf("|\n%s", RANK_LINE);
    }

    sprintf(pc, "(%d + %d)", white, black);
    gap = 33 - strlen(fullstip) - strlen(pc);
    sprintf(udiag, "%%s%%%ds%%s\n", gap);
    printf(udiag, fullstip, " ", pc);
    return options;
}
