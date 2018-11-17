#include "kfilter.hpp"

#define BDS_ALLOC_SIZE 1000

TiXmlDocument* get_file()
{
    char buff[BUFFSIZE];
    char* xml;
    int xmlsize = BDS_ALLOC_SIZE;
    char* ptr;
    xml = (char*) calloc(1, BDS_ALLOC_SIZE);

    if (xml == NULL) {
        puts("Initial allocation failed.");
        exit(EXIT_FAILURE);
    }

    xml[0] = '\0';

    while ((ptr = fgets(buff, BUFFSIZE, stdin)) != NULL) {
        if ((strlen(xml) + BUFFSIZE) > xmlsize) {
            xmlsize += BDS_ALLOC_SIZE;
            xml = (char*) realloc(xml, xmlsize);

            if (xml == NULL) {
                puts(" Reallocation failed.");
                exit(EXIT_FAILURE);
            }
        }

        strcat(xml, buff);
    }

    if (ferror(stdin) != 0) {
        printf("Error reading xml file\n");
        exit(EXIT_FAILURE);
    }

    TiXmlDocument* doc = new TiXmlDocument();
    doc->Parse(xml);

    if (doc->Error()) {
        printf("Error in %s: %s\n", doc->Value(), doc->ErrorDesc());
        exit(1);
    }

    return doc;
}
