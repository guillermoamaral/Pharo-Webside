Extension { #name : #RBSequenceNode }

{ #category : #'*Webside' }
RBSequenceNode >> asWebsideJson [ 
	| children |
	children := OrderedCollection new.
	temporaries do: [ :n | children add: n asWebsideJson  ].
	statements do: [ :n |  children add: n asWebsideJson].
	^super asWebsideJson at: 'children' put: children ; yourself
]
