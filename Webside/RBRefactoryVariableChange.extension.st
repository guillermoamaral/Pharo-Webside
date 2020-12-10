Extension { #name : #RBRefactoryVariableChange }

{ #category : #'*Webside' }
RBRefactoryVariableChange >> asWebsideJson [
	^ super asWebsideJson
		at: 'variable' put:  variable;
		yourself
]

{ #category : #'*Webside' }
RBRefactoryVariableChange >> fromWebsideJson: json [
	super fromWebsideJson: json.
	variable := json at: 'variable' ifAbsent: nil
]
