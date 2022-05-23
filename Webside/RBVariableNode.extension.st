Extension { #name : #RBVariableNode }

{ #category : #'*Webside' }
RBVariableNode >> asWebsideJson [
	^ super asWebsideJson
		at: 'value' put: name;
		yourself
]

{ #category : #'*Webside' }
RBVariableNode class >> websideType [ 
^'Identifier'
]
