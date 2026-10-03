package civa

import mxml "util/more_xml"

main :: proc() {
    mxml.schema_validate_xml("xmlschemas/v0/examples/dashboard.civa.xml", "")
}