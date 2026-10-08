package quick_xml

import plibxml "../libxml2"

import "core:log"
import "core:strings"
import "core:mem"
import "core:c"
import "core:c/libc"

import "base:runtime"

// Exampl error:
//
// xmlschemas/v0/examples/dashboard.civa.xml:23: Schemas validity error : Element '{urn:civa:1}component', attribute 'export': 'truee' is not a valid value of the atomic type 'xs:boolean'.
// 

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

DEFAULT_XSI_NS :: "http://www.w3.org/2001/XMLSchema-instance"

get_schema_location_cstr :: proc(
    xml_path: cstring, xsi_ns: cstring = DEFAULT_XSI_NS, 
    allocator := context.allocator
) -> (res: Maybe(cstring), err: mem.Allocator_Error) #optional_allocator_error {
    doc := plibxml.xmlReadFile(xml_path, nil, 0)
    defer if doc != nil do plibxml.xmlFreeDoc(doc)
    if doc == nil {
        log.errorf("Failed to parse XML: %s", xml_path)
        return
    }

    root := plibxml.xmlDocGetRootElement(doc)
    if root == nil {
        log.errorf("XML has no root element: %s", xml_path)
        return
    }

    schema_loc := plibxml.xmlGetNsProp(root, "schemaLocation", xsi_ns)
    defer if schema_loc != nil do libc.free(transmute([^]u8)schema_loc)

    if schema_loc == nil {
        res = nil
    }
    else {
        res = strings.clone_to_cstring(string(schema_loc), allocator=allocator) or_return
    }
    return
}

get_schema_location :: proc(
    xml_path: string, xsi_ns: cstring = DEFAULT_XSI_NS, 
    allocator := context.allocator
) -> (res: Maybe(cstring), err: mem.Allocator_Error) #optional_allocator_error {
    xml_path_cstr := strings.clone_to_cstring(xml_path) or_return
    defer delete(xml_path_cstr)
    return get_schema_location_cstr(xml_path_cstr, xsi_ns=xsi_ns, allocator=allocator)
}