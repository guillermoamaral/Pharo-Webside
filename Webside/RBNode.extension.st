Extension { #name : #RBNode }

{ #category : #'*Webside' }
RBNode >> asWebsideJson [
	| type |
	type := (self class name withoutPrefix: 'RB') withoutSuffix: 'Node'.
	^ NeoJSONObject new
		at: 'type' put: type;
		at: 'start' put: self start;
		at: 'end' put: self end;
		yourself
]
