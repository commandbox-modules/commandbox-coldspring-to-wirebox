/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Command to convert a ColdSpring XML file to WireBox DSL
 */
component {

	property name="converter"    inject="CSToWireBox@commandbox-coldspring-to-wirebox";
	property name="moduleConfig" inject="commandbox:moduleConfig:commandbox-coldspring-to-wirebox";

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	 * @coldspringFile The ColdSpring XML file to convert
	 * @binderFile The name of the file to convert to. By default it will be called `WireBox.cfc`
	 */
	function run(
		required string coldspringFile,
		string binderFile = "WireBox.cfc"
	){
		// Resolve Paths
		arguments.coldspringFile = resolvePath( arguments.coldspringFile );
		arguments.binderFile     = resolvePath( arguments.binderFile );

		print.boldBlueLine( "Starting to convert your ColdSpring XML File, please wait.." ).toConsole();

		var results = variables.converter.convert( arguments.coldspringFile );

		print.blueLine( "-> Conversion completed, verifying results..." ).toConsole();

		if ( len( results.errorMessages ) ) {
			return error( results.errorMessages );
		}

		var template = fileRead( moduleConfig.modelsPhysicalPath & "/templates/WireBox.txt" ).replaceNoCase(
			"|mapBindings|",
			results.data
		);

		fileWrite(
			arguments.binderFile,
			template,
			"UTF-8"
		);

		variables.print
			.greenBoldLine( "√ Conversion Finalized." )
			.greenLine( "√ WireBox Binder Created: #arguments.binderFile#" )
			.toConsole();
	}

}
