Extension { #name : #RBMessageNode }

{ #category : #'*Webside' }
RBMessageNode >> asWebsideJson [

	| children |
	children := OrderedCollection with: receiver asWebsideJson with: selector asWebsideJson .
	arguments do: [ :n | children add: n asWebsideJson ].
	^ super asWebsideJson
		  at: 'children' put: children;
		  yourself
]
