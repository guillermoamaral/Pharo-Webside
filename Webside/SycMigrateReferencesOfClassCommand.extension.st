Extension { #name : 'SycMigrateReferencesOfClassCommand' }

{ #category : '*Webside' }
SycMigrateReferencesOfClassCommand >> asWebsideJson [

	^ super asWebsideJson
		  at: 'className' put: targetClass name;
		  at: 'newName' put: newName name;
		  yourself
]

{ #category : '*Webside' }
SycMigrateReferencesOfClassCommand >> fromWebsideJson: json [

	| environment |
	super fromWebsideJson: json.
	environment := ClySystemEnvironment currentImage.
	json
		at: 'className'
		ifPresent: [ :c | targetClass := environment classNamed: c ].
	json
		at: 'newName'
		ifPresent: [ :c | newName := environment classNamed: c ]
]

{ #category : '*Webside' }
SycMigrateReferencesOfClassCommand class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'class';
		  at: 'label' put: 'Migrate references';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.name}';
				   at: 'newName' put: '{parameters.newName}';
				   yourself);
		  at: 'parameters' put: { (NeoJSONObject new
			   at: 'name' put: 'newName';
			   at: 'label' put: 'New class name';
			   at: 'type' put: 'text';
			   at: 'options' put: '{classes}';
			   yourself) };
		  at: 'section' put: 'Refactorings';
		  yourself
]
