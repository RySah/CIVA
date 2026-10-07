package partial_libxml2

when ODIN_OS == .Windows do foreign import lib "../../.out/libxml2/lib/libxml2s.lib"
else                     do foreign import lib "../../.out/libxml2/lib/libxml2s.a"


import "core:c"

/*
typedef unsigned char xmlChar;

/**
 * Macro to cast a string to an xmlChar * when one know its safe.
 */
#define BAD_CAST (xmlChar *)
*/

xmlDocPtr :: distinct rawptr
xmlSchemaParserCtxtPtr :: distinct rawptr
xmlSchemaPtr :: distinct rawptr
xmlSchemaValidCtxtPtr :: distinct rawptr
xmlNodePtr :: distinct rawptr

XML_PARSE_NONET :: 1<<11

foreign lib {
    // xmlDoc * xmlReadFile(const char *filename, const char *encoding, int options)
    xmlReadFile :: proc "c" (filename: cstring, encoding: cstring, options: c.int) -> xmlDocPtr ---

    // xmlSchemaParserCtxt * xmlSchemaNewParserCtxt(const char *URL)
    xmlSchemaNewParserCtxt :: proc "c" (URL: cstring) -> xmlSchemaParserCtxtPtr ---

    // xmlSchema * xmlSchemaParse(xmlSchemaParserCtxt *ctxt)
    xmlSchemaParse :: proc "c" (ctxt: xmlSchemaParserCtxtPtr) -> xmlSchemaPtr ---

    // xmlSchemaValidCtxt * xmlSchemaNewValidCtxt(xmlSchema *schema)
    xmlSchemaNewValidCtxt :: proc "c" (schema: xmlSchemaPtr) -> xmlSchemaValidCtxtPtr ---

    // int xmlSchemaValidateDoc(xmlSchemaValidCtxt *ctxt, xmlDoc *doc)
    xmlSchemaValidateDoc :: proc "c" (ctxt: xmlSchemaValidCtxtPtr, doc: xmlDocPtr) -> c.int ---

    // void xmlSchemaFreeValidCtxt(xmlSchemaValidCtxt *ctxt)
    xmlSchemaFreeValidCtxt :: proc "c" (ctxt: xmlSchemaValidCtxtPtr) ---

    // void xmlSchemaFree(xmlSchema *schema)
    xmlSchemaFree :: proc "c" (schema: xmlSchemaPtr) ---
    
    // void xmlSchemaFreeParserCtxt(xmlSchemaParserCtxt *ctxt)
    xmlSchemaFreeParserCtxt :: proc "c" (ctxt: xmlSchemaParserCtxtPtr) ---

    // void xmlFreeDoc(xmlDoc *cur)
    xmlFreeDoc :: proc "c" (cur: xmlDocPtr) ---

    // xmlNode* xmlDocGetRootElement(const xmlDoc *doc)
    xmlDocGetRootElement :: proc "c" (doc: xmlDocPtr) -> xmlNodePtr ---

    // xmlChar* xmlGetNsProp(const xmlNode *node, const xmlChar *name, const xmlChar *nameSpace)
    xmlGetNsProp :: proc "c" (node: xmlNodePtr, name: cstring, nameSpace: cstring) -> cstring ---

    
}