Extension { #name : #Object }

{ #category : #'*Webside' }
Object >> asWebsideJson [ 
	^NeoJSONObject new
		at: 'selector' put: self selector;
		at: 'class' put: self methodClass name;
		at: 'category' put: self category;
		at: 'source' put: self sourceCode;
		yourself
]
