Extension { #name : #RBMoveMethodToClassSideRefactoring }

{ #category : #'*Webside' }
RBMoveMethodToClassSideRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'className' put: method methodClass name;
		  at: 'selector' put: method selector;
			removeKey: 'newName' ifAbsent: [  ];
		  yourself
]

{ #category : #'*Webside' }
RBMoveMethodToClassSideRefactoring >> fromWebsideJson: json [


	super fromWebsideJson: json.
	json at: 'className' ifPresent: [ :n |
		class := self classObjectFor: n asSymbol.
		json
			at: 'selector'
			ifPresent: [ :s |
			method := class realClass compiledMethodAt: s asSymbol ] ]
]

{ #category : #'*Webside' }
RBMoveMethodToClassSideRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'method';
		  at: 'label' put: 'Move to class side';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.methodClass}';
				   at: 'selector' put: '{element.selector}';
				   yourself);
		  at: 'section' put: 'Refactorings';
		  yourself
]
