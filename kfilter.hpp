#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include "tinystr.h"
#include "tinyxml.h"

#define VERSION "1.4"
#define PROGRAM_NAME "Kalulu"
#define BUFFSIZE 200
#define RANK_LINE    "+---+---+---+---+---+---+---+---+\n"
#define BOARDSIZE 64
#define MOVETAB	9

#define SQUARE_TO_INT(a) ((8 - ( *((a) + 1) - '0')) * 8) + (*(a) - 'a')

TiXmlDocument* get_file();
TiXmlNode* do_diagram(TiXmlElement*);
void do_solvingtime(TiXmlElement*);
void do_parameters(TiXmlNode*);
void do_footer();
void do_setplay(TiXmlElement*);
void do_tryplay(TiXmlElement*);
void do_actualplay(TiXmlElement*);
void do_black_move(TiXmlNode*, int, int, bool);
void do_white_move(TiXmlNode*, int, int);
