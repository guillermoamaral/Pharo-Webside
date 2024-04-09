Extension { #name : #RBMoveMethodToClassRefactoring }

{ #category : #'*Webside' }
RBMoveMethodToClassRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'className' put: method methodClass name;
		  at: 'selector' put: method selector;
		  at: 'newName' put: class name;
		  yourself
]

{ #category : #'*Webside' }
RBMoveMethodToClassRefactoring >> fromWebsideJson: json [

	| c |
	super fromWebsideJson: json.
	json 
		at: 'newName'
		ifPresent: [ :n | class := self classObjectFor: n asSymbol ];
		at: 'className' ifPresent: [ :n |
			c := self classObjectFor: n asSymbol.
			json
				at: 'selector'
				ifPresent: [ :s |
					method := c realClass compiledMethodAt: s asSymbol ] ]
]
