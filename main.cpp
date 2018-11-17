#include "kfilter.hpp"

#ifndef NDEBUG
static clock_t meson_start, meson_end;
static double run_time;
#endif

char spaces[100];

void exit_main()
{
#ifndef NDEBUG
    meson_end = clock();
    run_time = (double)(meson_end - meson_start) / CLOCKS_PER_SEC;
    printf("Running Time = %f\n", run_time);
    fflush(stdout);
#endif
    return;
}

int main(int argc, char* argv[])
{
    int rc;
    TiXmlDocument* doc;
    TiXmlElement* root;
    TiXmlNode* opts;
    rc = atexit(exit_main);
#ifndef NDEBUG
    meson_start = clock();
#endif
    printf("%s (v.%s)\n\n", PROGRAM_NAME, VERSION);
    memset(spaces, ' ', 100);
    doc = get_file();
    root = doc->RootElement();

    if ((root == NULL) || (doc->Error() == true)) {
        printf("ERROR: - %d => %s\n", doc->ErrorId(), doc->ErrorDesc());
        exit(EXIT_FAILURE);
    }

    opts = do_diagram(root);
    puts("\nSolution");
    puts("--------");
    do_setplay(root);
    do_tryplay(root);
    do_actualplay(root);
    do_solvingtime(root);
    do_parameters(opts);
    do_footer();
    delete doc;
    return EXIT_SUCCESS;
}
