Extension { #name : 'RBRemoveMethodsInHierarchyRefactoring' }

{ #category : '*Webside' }
RBRemoveMethodsInHierarchyRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'selector' put: allSelectors anyOne;
		  yourself
]

{ #category : '*Webside' }
RBRemoveMethodsInHierarchyRefactoring >> fromWebsideJson: json [

	| class |
	super fromWebsideJson: json.
	class := json at: 'className' ifAbsent: nil.
	class ifNotNil: [ class := self classObjectFor: class asSymbol ].
	json at: 'selector' ifPresent: [ :s |
		self classSelectorMapping: { (class -> s asSymbol) }.
		allSelectors := { s asSymbol } ]
]

{ #category : '*Webside' }
RBRemoveMethodsInHierarchyRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'method';
		  at: 'label' put: 'Remove and the ones in subclasses';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.methodClass}';
				   at: 'selector' put: '{element.selector}';
				   yourself);
		  at: 'section' put: 'Refactorings';
		  yourself
]
