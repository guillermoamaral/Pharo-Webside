Extension { #name : #Exception }

{ #category : #'*Webside' }
Exception >> asWebsideJson [ 
	^super asWebsideJson at: 'description' put: self description; yourself
]
