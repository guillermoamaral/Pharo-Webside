Extension { #name : 'ClyMoveClassToGroupCommand' }

{ #category : '*Webside' }
ClyMoveClassToGroupCommand >> asWebsideJson [
	"Used on just one class from Webside"

	^ super asWebsideJson
		  at: 'className' put: classes first name;
		  at: 'package' put: classGroup name;
		  yourself
]

{ #category : '*Webside' }
ClyMoveClassToGroupCommand >> fromWebsideJson: json [
	"Used on just one class from Webside"

	| environment |
	super fromWebsideJson: json.
	environment := ClySystemEnvironment currentImage.
	json
		at: 'className'
		ifPresent: [ :c | classes := { (environment classNamed: c) } ].
	json
		at: 'package'
		ifPresent: [ :p | classGroup := environment packageNamed: p ]
]

{ #category : '*Webside' }
ClyMoveClassToGroupCommand class >> websideExtension [

	^ NeoJSONObject new
		  at: 'type' put: 'change';
		  at: 'elementType' put: 'class';
		  at: 'label' put: 'Move to package';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.name}';
				   at: 'package' put: '{parameters.package}';
				   yourself);
		  at: 'parameters' put: { (NeoJSONObject new
			   at: 'name' put: 'package';
			   at: 'label' put: 'Target package';
			   at: 'type' put: 'text';
			   at: 'options' put: '{packages}';
			   yourself) };
		  at: 'section' put: 'Refactorings';
		  yourself
]
