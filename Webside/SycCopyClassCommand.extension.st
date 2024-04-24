Extension { #name : #SycCopyClassCommand }

{ #category : #'*Webside' }
SycCopyClassCommand >> asWebsideJson [

	^ super asWebsideJson
		  at: 'className' put: originalClass name;
		  at: 'newName' put: newClassName;
		  yourself
]

{ #category : #'*Webside' }
SycCopyClassCommand >> fromWebsideJson: json [

	super fromWebsideJson: json.
	newClassName := json at: 'newName'.
	json at: 'className' ifPresent: [ :c |
		originalClass := ClySystemEnvironment currentImage classNamed: c ]
]

{ #category : #'*Webside' }
SycCopyClassCommand class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'class';
		  at: 'label' put: 'Copy';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.name}';
				   at: 'newName' put: '{parameters.newName}';
				   yourself);
		  at: 'parameters' put: { (NeoJSONObject new
			   at: 'name' put: 'newName';
			   at: 'label' put: 'New class name';
			   at: 'type' put: 'text';
			   at: 'defaultValue' put: '{element.name}Copy';
			   yourself) };
		  at: 'section' put: 'Refactorings';
		  yourself
]

{ #category : #'*Webside' }
SycCopyClassCommand class >> websideType [

	^ 'CloneClass'
]
