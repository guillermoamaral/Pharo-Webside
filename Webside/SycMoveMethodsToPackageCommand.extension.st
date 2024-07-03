Extension { #name : 'SycMoveMethodsToPackageCommand' }

{ #category : '*Webside' }
SycMoveMethodsToPackageCommand >> asWebsideJson [
  "Used on just one method from Webside"

	^ super asWebsideJson
		  at: 'className' put: methods first methodClass name;
		  at: 'selector' put: methods first selector;
          at: 'package' put: package name;
		  yourself
]

{ #category : '*Webside' }
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

{ #category : '*Webside' }
SycMoveMethodsToPackageCommand class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'method';
		  at: 'label' put: 'Move to package';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.methodClass}';
				   at: 'selector' put: '{element.selector}';
				   at: 'package' put: '{parameters.package}';
				   yourself);
		  at: 'parameters' put: { (NeoJSONObject new
			   at: 'name' put: 'package';
			   at: 'label' put: 'Target pacakge';
			   at: 'type' put: 'text';
			   at: 'options' put: '{packages}';
			   yourself) };
		  at: 'section' put: 'Refactorings';
		  yourself
]
