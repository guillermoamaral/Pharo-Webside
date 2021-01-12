Extension { #name : #RBVariableRefactoring }

{ #category : #'*Webside' }
RBVariableRefactoring >> asWebsideJson [
	^ super asWebsideJson
		at: 'class' put: class name;
		at: 'variable' put: variableName;
		yourself
]

{ #category : #'*Webside' }
RBVariableRefactoring >> fromWebsideJson: json [
	super fromWebsideJson: json.
	class := json at: 'class' ifAbsent: nil.
	class ifNotNil: [ class := self classObjectFor: class asSymbol ].
	variableName := json at: 'variable' ifAbsent: nil
]
