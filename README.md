# CIVA

CIVA is a declarative application schema intended to describe UI structure,
graphics, and links to application logic in a way that can be compiled for
multiple runtimes. XHTML remains available as an interoperability escape hatch;
the CIVA model itself is intended to describe more than a document tree.

## Design direction

- **Structure and rendering:** Components compose layouts, other components,
  conditions, inline vectors, and reusable vector graphics.
- **Graphics as declarations:** Shaders and named vector graphics are declared
  at module scope, then referenced where they are used. Shader source can be
  inline or loaded from a source path.
- **Logic through hooks:** A module declares the library and exported symbol
  that provide each hook. Expressions refer to a hook by its module-level name
  using `hook:name`. The hook can be passed as a value, for example as a
  component argument.
- **Full-stack boundary:** A hook's `scope` is `client`, `server`, or `shared`.
  This gives a compiler/runtime enough information to scaffold the boundary and
  route a call to the appropriate environment. Server hooks must not be linked
  into client code.
- **Library-owned contracts:** CIVA does not duplicate function signatures or
  invent a second type declaration for a library function. A library (or its
  compiler-readable metadata) owns parameter, result, and ABI types. The
  compiler/linker should resolve each hook name, verify the referenced library
  symbol and scope, and type-check every use of `hook:name`. XML Schema only
  validates the document's shape; it cannot verify those external contracts.

## Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<civa xmlns="urn:civa:1" version="1">
  <module name="Dashboard">
    <hook
      name="loadDashboard"
      library="civa:dashboard"
      symbol="load_dashboard"
      scope="server" />

    <shader name="softFill">
      <vertex language="wgsl" entry="vs_main">
        <!-- Vertex-stage WGSL source -->
      </vertex>
      <fragment language="wgsl" entry="fs_main">
        <!-- Fragment-stage WGSL source -->
      </fragment>
    </shader>

    <graphic name="BrandMark" viewBox="0 0 48 48" shader="softFill">
      <path
        d="M24 2 L46 24 L24 46 L2 24 Z"
        fill="#5b6cff" />
    </graphic>

    <component name="DashboardView" export="true">
      <param name="model" type="DashboardModel" />
      <layout type="column" gap="16">
        <draw graphic="BrandMark" width="48" height="48" />
        <use component="DashboardContent">
          <arg name="model" value="model" />
          <arg name="reload" value="hook:loadDashboard" />
        </use>
      </layout>
    </component>
  </module>
</civa>
```

In this example, CIVA declares where `loadDashboard` comes from but not its
signature. The `civa:dashboard` library must provide the `load_dashboard`
symbol and publish enough type/ABI metadata for the compiler to validate the
argument and result contract. The compiler can then generate the appropriate
client/server bridge for the `server`-scoped hook.

The `graphic` declaration is reusable module-level vector artwork. `draw`
instantiates it in a component, while `vector` remains available for artwork
that is local to a particular component.

## Using the schema during development

The XML Schema Definition (XSD) is [xmlschemas/v0/civa.xsd](xmlschemas/v0/civa.xsd). CIVA documents
must use the `urn:civa:1` namespace and have one `<module>` under the root
`<civa>` element. Start from [xmlschemas/v0/examples/dashboard.civa.xml](xmlschemas/v0/examples/dashboard.civa.xml)
when creating a document.

To enable schema-aware validation and editor completion, associate the schema
with your document. For example, in a document under `xmlschemas/v0/examples/`, declare
the schema location on the root element:

```xml
<civa
  xmlns="urn:civa:1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="urn:civa:1 ../civa.xsd"
  version="1">
  <module name="Dashboard">
    <!-- CIVA declarations go here -->
  </module>
</civa>
```

The schema path is relative to the XML document. Adjust it for documents in
other directories. An XML editor with XSD support can use this association for
validation, element/attribute completion, and navigation; alternatively,
configure the editor to map the `urn:civa:1` namespace directly to
`xml/civa.xsd`.

You can validate a document from the repository root with `xmllint` (libxml2):

```powershell
xmllint --noout --schema xml\civa.xsd xml\examples\dashboard.xml
```

Schema validation checks the XML structure, required attributes, and declared
value constraints. It does not resolve component or graphic references, verify
hook library symbols or their type contracts, compile shader code, or generate
the client/server scaffold; those are compiler and toolchain responsibilities.
