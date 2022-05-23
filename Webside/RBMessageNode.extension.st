Extension { #name : #RBMessageNode }

{ #category : #'*Webside' }
RBMessageNode >> asWebsideJson [
	| s children |
	s := NeoJSONObject new
		at: 'type' put: 'Selector';
		at: 'start' put: self start;
		at: 'end' put: self start + selector size;
		at: 'value' put: selector;
		yourself.
	children := OrderedCollection
		with: receiver asWebsideJson
		with: s.
	arguments do: [ :n | children add: n asWebsideJson ].
	^ super asWebsideJson
		at: 'children' put: children;
		yourself
]
