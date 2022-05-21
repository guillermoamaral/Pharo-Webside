Extension { #name : #RBLiteralArrayNode }

{ #category : #'*Webside' }
RBLiteralArrayNode >> asWebsideJson [ 
	| children |
	children := contents collect: [ :n | n asWebsideJson  ].
	^super asWebsideJson at: 'children' put: children; yourself 
]
