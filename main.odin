package civa

import mxml "util/more_xml"

import "core:fmt"
import "core:log"

main :: proc() {
    context.logger = log.create_console_logger()
    defer log.destroy_console_logger(context.logger)

    res, err := mxml.schema_validate_xml(
        "xmlschemas/v0/examples/dashboard.civa.xml", 
        "xmlschemas/v0/civa.xsd"
    )

    log.infof("%v %v", res, err)
}