Extension { #name : #SycMoveMethodsToPackageCommand }

{ #category : #'*Webside' }
SycMoveMethodsToPackageCommand >> fromWebsideJson: json [

	| environment class |
	super fromWebsideJson: json.
	environment := ClySystemEnvironment currentImage.
	json at: 'className' ifPresent: [ :c |
		class := environment classNamed: c.
		json
			at: 'selector'
			ifPresent: [ :s |
			methods := { (class compiledMethodAt: s asSymbol) } ] ].
	json
		at: 'package'
		ifPresent: [ :p | package := environment packageNamed: p ]
]
