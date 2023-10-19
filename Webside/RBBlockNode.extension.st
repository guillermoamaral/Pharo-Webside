Extension { #name : #RBBlockNode }

{ #category : #'*Webside' }
RBBlockNode >> asWebsideJson [

	| children |
	children := arguments collect: [ :n | n asWebsideJson ].
	children add: body asWebsideJson.
	^ super asWebsideJson
		  at: 'children' put: children;
		  yourself
]
