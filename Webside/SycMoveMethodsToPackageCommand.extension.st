Extension { #name : #SycMoveMethodsToPackageCommand }

{ #category : #'*Webside' }
SycMoveMethodsToPackageCommand >> asWebsideJson [
  "Used on just one method from Webside"

	^ super asWebsideJson
		  at: 'className' put: methods first methodClass name;
		  at: 'selector' put: methods first selector;
          at: 'package' put: package name;
		  yourself
]

{ #category : #'*Webside' }
SycMoveMethodsToPackageCommand >> fromWebsideJson: json [
	"Used on just one method from Webside"

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
