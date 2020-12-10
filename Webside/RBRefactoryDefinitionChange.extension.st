Extension { #name : #RBRefactoryDefinitionChange }

{ #category : #'*Webside' }
RBRefactoryDefinitionChange >> asWebsideJson [
	^super asWebsideJson
		at: 'sourceCode' put: self definition;
		yourself
]
