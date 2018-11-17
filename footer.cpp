#include "kfilter.hpp"

void do_solvingtime(TiXmlElement* root)
{
    char* st;
    TiXmlNode* tnode;
    TiXmlElement* diag;
    tnode = root->FirstChild("SolvingTime");
    diag = tnode->ToElement();
    st = (char*) diag->GetText();
    printf("\nSolving time: %s seconds\n", st);
    return;
}

void do_parameters(TiXmlNode* options)
{
    TiXmlNode* tnode;
    TiXmlElement* telem;
    char* text;
    char onoffst[4];
    puts("\nSolving Parameters");
    puts("------------------");
    // sols
    tnode = options->FirstChild("sols");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();
    printf("\nIntended solutions: %s,", text);
    // set
    tnode = options->FirstChild("set");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();

    if (strcmp(text, "true") == 0) {
        strcpy(onoffst, "on");
    } else {
        strcpy(onoffst, "off");
    }

    printf(" Set play: %s,", onoffst);
    // tries
    tnode = options->FirstChild("tries");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();

    if (strcmp(text, "true") == 0) {
        strcpy(onoffst, "on");
    } else {
        strcpy(onoffst, "off");
    }

    printf(" Try play: %s\n", onoffst);
    // refuts
    tnode = options->FirstChild("refuts");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();
    printf("Refutations: %s,", text);
    // trivialtries
    tnode = options->FirstChild("trivialtries");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();

    if (strcmp(text, "true") == 0) {
        strcpy(onoffst, "on");
    } else {
        strcpy(onoffst, "off");
    }

    printf(" Trivialtries: %s,", onoffst);
    // actual
    tnode = options->FirstChild("actual");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();

    if (strcmp(text, "true") == 0) {
        strcpy(onoffst, "on");
    } else {
        strcpy(onoffst, "off");
    }

    printf(" Actual play: %s\n", onoffst);
    // threats
    tnode = options->FirstChild("threats");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();
    printf("Threats: %s,", text);
    // fleck
    tnode = options->FirstChild("fleck");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();

    if (strcmp(text, "true") == 0) {
        strcpy(onoffst, "on");
    } else {
        strcpy(onoffst, "off");
    }

    printf(" Fleck: %s,", onoffst);
    // shortvars
    tnode = options->FirstChild("shortvars");
    telem = tnode->ToElement();
    text = (char*) telem->GetText();

    if (strcmp(text, "true") == 0) {
        strcpy(onoffst, "on");
    } else {
        strcpy(onoffst, "off");
    }

    printf(" Shortvars: %s\n", onoffst);
    return;
}

void do_footer()
{
    char formtime[100];
    time_t caltime;
    struct tm* ltimeptr;
    struct tm ltime;
    caltime = time(NULL);
    ltimeptr = localtime(&caltime);
    ltime = *ltimeptr;
    strftime(formtime, 100, "on %a %d %B at %T", &ltime);
    printf("\nSolved by %s version %s %s\n", PROGRAM_NAME, VERSION, formtime);
    return;
}
