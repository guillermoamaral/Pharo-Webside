Extension { #name : #SycGenerateAllInstVarAccessorsCommand }

{ #category : #'*Webside' }
SycGenerateAllInstVarAccessorsCommand >> asWebsideJson [
	"Used on just one class from Webside"

	^ super asWebsideJson
		  at: 'className' put: classes first name;
		  yourself
]

{ #category : #'*Webside' }
SycGenerateAllInstVarAccessorsCommand >> fromWebsideJson: json [
	"Used on just one class from Webside"

	super fromWebsideJson: json.
	json at: 'className' ifPresent: [ :c |
		classes := { (ClySystemEnvironment currentImage classNamed: c) } ]
]

{ #category : #'*Webside' }
SycGenerateAllInstVarAccessorsCommand class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'class';
		  at: 'label' put: 'Generate accessors';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.name}';
				   yourself);
		  at: 'section' put: 'Refactorings';
		  yourself
]
