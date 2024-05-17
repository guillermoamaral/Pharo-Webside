Extension { #name : #RBRemoveHierarchyMethodRefactoring }

{ #category : #'*Webside' }
RBRemoveHierarchyMethodRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'selector' put: selectors anyOne;
		  yourself
]

{ #category : #'*Webside' }
RBRemoveHierarchyMethodRefactoring >> fromWebsideJson: json [

	super fromWebsideJson: json.
	json at: 'selector' ifPresent: [ :s | selectors := { s asSymbol } ]
]

{ #category : #'*Webside' }
RBRemoveHierarchyMethodRefactoring class >> websideExtension [

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
