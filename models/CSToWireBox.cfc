/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * CS Converter to WireBox
 */
component singleton {

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	 * Convert to WireBox
	 *
	 *
	 * @filePath The file to convert
	 * @return Struct of { errorMessages:string, data:string }
	 */
	struct function convert( required filePath ){
		var results  = { "errorMessages" : "", "data" : "" };
		var beanData = createObject( "java", "java.util.Vector" ).init();

		// Parsing
		try {
			var csXML = xmlParse( arguments.filePath );
			var beans = xmlSearch( csXML, "/beans/bean" );

			// If no beans
			if ( NOT arrayLen( beans ) ) {
				results.errorMessages = "No bean definitions found";
				return results;
			}

			// loop over beans to create definitions from XML
			for ( var i = 1; i lte arrayLen( beans ); i++ ) {
				translateBean( beans[ i ], beanData );
			}

			// process into wirebox notation.
			results.data = toWireBox( beanData );
		} catch ( any e ) {
			results.errorMessages = "Error parsing bean definitions: #e.message# #e.detail# #e.stacktrace#";
		}

		return results;
	}

	/**
	 * Convert bean data to wirebox data
	 */
	function toWireBox( required beanData ){
		var buf   = createObject( "java", "java.lang.StringBuilder" ).init( "" );
		var cr    = chr( 13 ) & chr( 10 );
		var tab   = repeatString( chr( 9 ), 3 );
		var beans = arguments.beanData;
		var x     = 1;
		var j     = 1;

		for ( x = 1; x lte arrayLen( beans ); x++ ) {
			buf.append( "#repeatString( chr( 9 ), 2 )#map(""#beans[ x ].beanName#"")" );
			// class?
			if ( len( beans[ x ].fullClassPath ) ) {
				buf.append( ".to(""#beans[ x ].fullClassPath#"")" );
				// constructor dependencies
				for ( j = 1; j lte arrayLen( beans[ x ].constructorProperties ); j++ ) {
					buf.append( "#cr##tab#.initArg(name=""#beans[ x ].constructorProperties[ j ].name#""" );
					if ( len( beans[ x ].constructorProperties[ j ].ref ) ) {
						buf.append( ",ref=""#beans[ x ].constructorProperties[ j ].ref#""" );
					} else {
						buf.append( ",value=""#beans[ x ].constructorProperties[ j ].value#""" );
					}
					buf.append( ")" );
				}
				// setter dependencies
				for ( j = 1; j lte arrayLen( beans[ x ].setterProperties ); j++ ) {
					buf.append( "#cr##tab#.setter(name=""#beans[ x ].setterProperties[ j ].name#""" );
					if ( len( beans[ x ].setterProperties[ j ].ref ) ) {
						buf.append( ",ref=""#beans[ x ].setterProperties[ j ].ref#""" );
					} else {
						buf.append( ",value=""#beans[ x ].setterProperties[ j ].value#""" );
					}
					buf.append( ")" );
				}
			}
			// factory methods?
			if ( len( beans[ x ].factoryBean ) ) {
				buf.append( ".toFactoryMethod(factory=""#beans[ x ].factoryBean#"",method=""#beans[ x ].factoryMethod#"")" );
				// dependencies
				for ( j = 1; j lte arrayLen( beans[ x ].constructorProperties ); j++ ) {
					buf.append( "#cr##tab#.methodArg(name=""#beans[ x ].constructorProperties[ j ].name#""" );
					if ( len( beans[ x ].constructorProperties[ j ].ref ) ) {
						buf.append( ",ref=""#beans[ x ].constructorProperties[ j ].ref#""" );
					} else {
						buf.append( ",value=""#beans[ x ].constructorProperties[ j ].value#""" );
					}
					buf.append( ")" );
				}
			}
			// singleton?
			if ( beans[ x ].singleton ) {
				buf.append( "#cr##tab#.asSingleton()" );
			}
			// Autowire?
			if ( NOT beans[ x ].autowire ) {
				buf.append( "#cr##tab#.noAutowire()" );
			}
			// Constructor?
			if ( len( beans[ x ].initMethod ) ) {
				buf.append( "#cr##tab#.constructor(""#beans[ x ].initMethod#"")" );
			}
			// Lazy?
			if ( NOT beans[ x ].lazy ) {
				buf.append( "#cr##tab#.asEagerInit()" );
			}

			// end declaration;
			buf.append( ";#cr#" );
		}

		return buf.toString();
	}

	/**
	 * I translate ColdSpring XML bean definitiions to WireBox config
	 *
	 * @bean The xml bean defintion
	 * @beanData The bean data array
	 *
	 * @throws InvalidBeanIdNameException - When the bean has no id or name
	 */
	function translateBean( required bean, required beanData ){
		var beanStruct         = structNew();
		var key                = "";
		var beanAttributeValue = 0;
		var errormsg           = "";

		// default bean
		beanStruct = {
			factoryBean           : "",
			factoryMethod         : "",
			singleton             : true,
			fullClassPath         : "",
			beanName              : "",
			initMethod            : "",
			lazy                  : true,
			constructorProperties : [],
			setterProperties      : [],
			autowire              : false
		};

		// loop over bean tag attributes and create beanStruct keys
		for ( key in bean.XmlAttributes ) {
			// Get Attribute Value
			beanAttributeValue = trim( bean.XMLAttributes[ key ] );
			// Set Values
			if ( key eq "factory-bean" ) {
				beanStruct.FactoryBean = beanAttributeValue;
			}
			if ( key eq "autowire" ) {
				beanStruct.autowire = beanAttributeValue;
			}
			if ( key eq "factory-method" ) {
				beanStruct.FactoryMethod = beanAttributeValue;
			}
			if ( key eq "singleton" ) {
				beanStruct.Singleton = beanAttributeValue;
			}
			if ( key eq "class" ) {
				beanStruct.FullClassPath = beanAttributeValue;
			}
			if ( key eq "id" ) {
				beanStruct.BeanName = beanAttributeValue;
			}
			if ( key eq "init-method" ) {
				beanStruct.InitMethod = beanAttributeValue;
			}
			if ( key eq "lazy-init" ) {
				beanStruct.Lazy = beanAttributeValue;
			}
		}
		// end loop over xml attributes

		// Check for a the presence of bean name
		if ( not structKeyExists( beanStruct, "BeanName" ) ) {
			errormsg = "Missing bean name or id in xml declaration";
			if ( structKeyExists( beanStruct, "FullClassPath" ) ) {
				errormsg = errormsg & " for object of class #beanStruct.FullClassPath#";
			} else if ( structKeyExists( beanStruct, "FactoryBean" ) and structKeyExists( beanStruct, "FactoryMethod" ) ) {
				errormsg = errormsg & " for object referencing factory bean #beanStruct.FactoryBean# and method #beanStruct.FactoryMethod#";
			}
			throw(
				message: "Check config file for id or beanname key on object definition.",
				detail : errormsg,
				type   : "InvalidBeanIdNameException"
			);
		}

		// add constructor dependecies and properties
		beanStruct.constructorProperties = translateBeanChildren(
			arguments.bean,
			"constructor-arg",
			arguments.beanData
		);
		// add setter dependecies and properties
		beanStruct.setterProperties = translateBeanChildren(
			arguments.bean,
			"property",
			arguments.beanData
		);

		arrayAppend( arguments.beanData, beanStruct );
	}

	/**
	 * Translate the bean children in the xml definition
	 */
	function translateBeanChildren(
		required bean,
		required childTagName,
		required beanData
	){
		var children = "";
		var entries  = "";
		var hashMap  = "";
		var i        = 1;
		var j        = 1;
		var data     = [];

		// find all constructor properties and dependencies
		children = xmlSearch(
			arguments.bean,
			arguments.childTagName
		);
		// Loop Over Children
		for ( i = 1; i lte arrayLen( children ); i++ ) {
			data[ i ] = {
				name  : trim( children[ i ].XmlAttributes[ "name" ] ),
				value : "",
				ref   : ""
			};

			// child element "value"
			if ( structKeyExists( children[ i ], "value" ) ) {
				data[ i ].value = trim( children[ i ].value.XmlText );
			};

			// Map
			if ( structKeyExists( children[ i ], "map" ) ) {
				entries = xmlSearch(
					xmlParse( toString( children[ i ] ) ),
					"//map/entry"
				);
				hashMap = structNew();
				for ( j = 1; j lte arrayLen( entries ); j++ ) {
					if ( structKeyExists( entries[ j ], "value" ) ) {
						hashMap[ entries[ j ].XmlAttributes[ "key" ] ] = entries[ j ].value.XmlText;
					}
				}
				data[ i ].value = hashMap;
			};

			// child element "ref"
			if ( structKeyExists( children[ i ], "ref" ) ) {
				data[ i ].ref = children[ i ].ref.XmlAttributes[ "bean" ];
			};

			// child element "bean"
			if ( structKeyExists( children[ i ], "bean" ) ) {
				// Verify ID exists, else create a unique ID for this nested bean definition
				if (
					not structKeyExists(
						children[ i ].bean.xmlAttributes,
						"id"
					)
				) {
					if (
						structKeyExists(
							children[ i ].bean.xmlAttributes,
							"class"
						)
					) {
						children[ i ].bean.xmlAttributes.id = listLast(
							children[ i ].bean.xmlAttributes.class,
							"."
						) & ":" & left( hash( createUUID() ), 10 );
					} else {
						children[ i ].bean.xmlAttributes.id = "anonBean:" & left( hash( createUUID() ), 10 );
					}
				}
				// setup the reference.
				data[ i ].ref = children[ i ].bean.xmlAttributes.id;

				// Translate it and add it to array definition
				translateBean(
					children[ i ].bean,
					arguments.beanData
				);
			};
		};

		return data;
	}

}
