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
