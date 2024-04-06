Extension { #name : #RBVariableRefactoring }

{ #category : #'*Webside' }
RBVariableRefactoring >> asWebsideJson [
	^ super asWebsideJson
		at: 'className' put: class name;
		at: 'variable' put: variableName;
		yourself
]

{ #category : #'*Webside' }
RBVariableRefactoring >> fromWebsideJson: json [
	super fromWebsideJson: json.
	class := json at: 'className' ifAbsent: nil.
	class ifNotNil: [ class := self classObjectFor: class asSymbol ].
	variableName := json at: 'variable' ifAbsent: nil
]
