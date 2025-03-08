Extension { #name : 'RBInsertNewClassRefactoring' }

{ #category : '*Webside' }
RBInsertNewClassRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'newName' put: className asString;
		  at: 'className' put: subclasses first name asString;
		  at: 'superclassName' put: superclass name asString;
		  yourself
]

{ #category : '*Webside' }
RBInsertNewClassRefactoring >> fromWebsideJson: json [

	| target |
	super fromWebsideJson: json.
	comment := ''.
	className := json at: 'newName' ifAbsent: nil.
	json at: 'className' ifPresent: [ :name |
		target := self classObjectFor: name asSymbol.
		target ifNotNil: [
			packageName := target packageName.
			tagName := target tagName.
			superclass := target superclass.
			subclasses := { target } ] ]
]

{ #category : '*Webside' }
RBInsertNewClassRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'type' put: 'change';
		  at: 'elementType' put: 'class';
		  at: 'label' put: 'Insert superclass';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.name}';
				   at: 'newName' put: '{parameters.newName}';
				   yourself);
		  at: 'parameters' put: { (NeoJSONObject new
			   at: 'name' put: 'newName';
			   at: 'label' put: 'New class name';
			   at: 'type' put: 'text';
			   yourself) };
		  at: 'section' put: 'Refactorings';
		  yourself
]
