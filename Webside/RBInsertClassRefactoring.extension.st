Extension { #name : #RBInsertClassRefactoring }

{ #category : #'*Webside' }
RBInsertClassRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'newName' put: className asString;
		  at: 'className' put: subclasses first name asString;
		  at: 'superclassName' put: superclass name asString;
		  yourself
]

{ #category : #'*Webside' }
RBInsertClassRefactoring >> fromWebsideJson: json [

	| target |
	super fromWebsideJson: json.
	comment := ''.
	className := json at: 'newName' ifAbsent: nil.
	json at: 'className' ifPresent: [ :name |
		target := self classObjectFor: name asSymbol.
		target ifNotNil: [
			category := target category.
			superclass := target superclass.
			subclasses := { target } ] ]
]

{ #category : #'*Webside' }
RBInsertClassRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
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
