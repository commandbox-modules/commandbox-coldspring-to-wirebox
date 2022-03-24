component extends="coldbox.system.ioc.config.Binder" {

	/**
	 * Configure WireBox, that's it!
	 */
	function configure(){
		/**
		 * --------------------------------------------------------------------------
		 * WireBox Configuration (https://wirebox.ortusbooks.com)
		 * --------------------------------------------------------------------------
		 * Configure WireBox
		 */
		wireBox = {
			// Scope registration, automatically register a wirebox injector instance on any CF scope
			// By default it registeres itself on application scope
			scopeRegistration : {
				enabled : true,
				scope   : "application", // server, cluster, session, application
				key     : "wireBox"
			},
			// DSL Namespace registrations
			customDSL      : {},
			// Custom Storage Scopes
			customScopes   : {},
			// Package scan locations
			scanLocations  : [],
			// Stop Recursions
			stopRecursions : [],
			// Parent Injector to assign to the configured injector, this must be an object reference
			parentInjector : "",
			// Register all event listeners here, they are created in the specified order
			listeners      : []
		};

		// Map Bindings below
		map("UserManager").to("common.ourdomain.security.UserManager")
			.asSingleton()
			.noAutowire();
		map("anonBean:48E75E5C96").toFactoryMethod(factory="EnvironmentService",method="getProductionDSN")
			.asSingleton()
			.noAutowire();
		map("UserManager").to("common.ourdomain.security.UserManager")
			.initArg(name="productionDSN",ref="anonBean:48E75E5C96")
			.initArg(name="PaymentService",ref="PaymentService")
			.asSingleton()
			.noAutowire();

	}

}
