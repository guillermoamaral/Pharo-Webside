Extension { #name : #RBReturnNode }

{ #category : #'*Webside' }
RBReturnNode >> asWebsideJson [ 
	^super asWebsideJson at: 'children' put: { value asWebsideJson  }; yourself
]
