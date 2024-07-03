Extension { #name : 'RBDeprecateClassRefactoring' }

{ #category : '*Webside' }
RBDeprecateClassRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'newName' put: newName ;
		  yourself
]

{ #category : '*Webside' }
RBDeprecateClassRefactoring >> fromWebsideJson: json [

	super fromWebsideJson: json.
	self className: (json at: 'className' ifAbsent: nil) newName: (json at: 'newName' ifAbsent: nil) 
]

{ #category : '*Webside' }
RBDeprecateClassRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'class';
		  at: 'label' put: 'Deprecate';
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
