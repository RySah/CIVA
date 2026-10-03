package more_xml

import plibxml "../partial_libxml2"

import "core:log"
import "core:strings"
import "core:mem"

schema_validate_xml_cstr :: proc(xml_path, xsd_path: cstring) -> bool {
    document: plibxml.xmlDocPtr = ---
    schema_parser: plibxml.xmlSchemaParserCtxtPtr = ---
    schema: plibxml.xmlSchemaPtr = ---
    validator: plibxml.xmlSchemaValidCtxtPtr = ---

    defer if document != nil do plibxml.xmlFreeDoc(document)
    defer if schema_parser != nil do plibxml.xmlSchemaFreeParserCtxt(schema_parser)
    defer if schema != nil do plibxml.xmlSchemaFree(schema)
    defer if validator != nil do plibxml.xmlSchemaFreeValidCtxt(validator)

    document = plibxml.xmlReadFile(xml_path, nil, plibxml.XML_PARSE_NONET)
    if document == nil {
        log.errorf("Failed to parse XML: %s", xml_path)
        return false
    }

    schema_parser = plibxml.xmlSchemaNewParserCtxt(xsd_path)
    if schema_parser == nil {
        log.errorf("Failed to create XSD parse.")
        return false
    }

    schema = plibxml.xmlSchemaParse(schema_parser)
    if schema == nil {
        log.errorf("Failed to parse XSD: %s", xsd_path)
        return false
    }

    validator = plibxml.xmlSchemaNewValidCtxt(schema)
    if validator == nil {
        log.errorf("Failed to create schema validator.")
        return false
    }

    return plibxml.xmlSchemaValidateDoc(validator, document) == 0
}

schema_validate_xml :: proc(xml_path, xsd_path: string) -> (res: bool, err: mem.Allocator_Error) #optional_allocator_error {
    xml_path_cstr := strings.clone_to_cstring(xml_path) or_return
    defer delete(xml_path_cstr)
    xsd_path_cstr := strings.clone_to_cstring(xsd_path) or_return
    defer delete(xsd_path_cstr)
    res = schema_validate_xml_cstr(xml_path_cstr, xsd_path_cstr)
    return
}