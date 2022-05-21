Extension { #name : #RBMethodNode }

{ #category : #'*Webside' }
RBMethodNode >> asWebsideJson [
	| children |
	children := OrderedCollection with: selector asWebsideJson.
	arguments do: [ :n | children add: n asWebsideJson  ].
	children add: body asWebsideJson .
	^super asWebsideJson at: 'children' put: children; yourself 
]
