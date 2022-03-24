# ColdSpring XML to WireBox DSL Converter

This module can convert any ColdSpring XML file to the equivalent programmatic DSL for usage by WireBox Dependency Injection Framework (https://wirebox.ortusbooks.com/configuration/configuring-wirebox).

## Usage

Run the `coldspring-to-wirebox` command and pass in the location of the XML file to convert with an optional destination for the `WireBox.cfc`

```bash
# Produces a WireBox.cfc where you run the command
coldspring-to-wirebox tests/coldspring.xml.cfm

# Stores the WireBox.cfc in the same location as the file above
coldspring-to-wirebox tests/coldspring.xml.cfm tests/WireBox.cfc
```
