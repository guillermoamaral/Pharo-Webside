Extension { #name : #ClassDescription }

{ #category : #'*Webside' }
ClassDescription >> asWebsideJson [
	^NeoJSONObject new
		at: 'name' put: self name;
		at: 'definition' put: self oldDefinition;
		at: 'superclass' put: self superclass name;
		at: 'comment' put: self comment;
		yourself
]
