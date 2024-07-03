Extension { #name : 'RBAddClassChange' }

{ #category : '*Webside' }
RBAddClassChange >> fromWebsideJson: json [

	| doit |
	super fromWebsideJson: json.
	builder := ShiftClassBuilder new.
	json at: 'package' ifPresent: [ :package | builder package: package ].
	json
		at: 'superclass'
		ifPresent: [ :superclass | builder superclassName: superclass ].
	json
		at: 'instanceVariables'
		ifPresent: [ :slots | builder slots: slots ].
	json
		at: 'classVariables'
		ifPresent: [ :slots | builder sharedVariables: slots ].
	json
		at: 'poolDictionaries'
		ifPresent: [ :pools | builder sharedPools: pools ].
	json at: 'definition' ifPresent: [:definition |
		doit := OpalCompiler new
			        isScripting: true;
			        parse: definition.
		className := doit body statements first value receiver arguments first value
			             asString ].
	builder name: className
]
