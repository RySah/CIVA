package civa

import qxml "util/quick_xml"
import qcurl "util/quick_curl"

import "core:fmt"
import "core:log"

main :: proc() {
    context.logger = log.create_console_logger()
    defer log.destroy_console_logger(context.logger)

    assert(qcurl.init() == nil)
    defer qcurl.cleanup()

    {
        res, err := qxml.schema_validate_xml(
            "xmlschemas/v0/examples/dashboard.civa.xml", 
            "xmlschemas/v0/civa.xsd"
        )
        log.infof("%v %v", res, err)
    }

    {
        schema_loc := qxml.get_schema_location("xmlschemas/v0/examples/dashboard.civa.xml")
        defer if schema_loc_v, schema_loc_ok := schema_loc.?; schema_loc_ok do delete(schema_loc_v)
        log.infof("%v", schema_loc)
    }

    {
        res, err := qcurl.aprint_url_content("https://raw.githubusercontent.com/RySah/CIVA/refs/heads/main/xmlschemas/v0/civa.xsd")
        defer delete(res)
        log.infof("%v\n%v", err, res)
    }
}