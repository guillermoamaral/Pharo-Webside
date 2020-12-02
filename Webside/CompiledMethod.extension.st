Extension { #name : #CompiledMethod }

{ #category : #'*Webside' }
CompiledMethod >> asWebsideJson [
	^ NeoJSONObject new
		at: 'selector' put: self selector;
		at: 'class' put: self methodClass name;
		at: 'category' put: self category;
		at: 'source' put: self sourceCode;
		at: 'author' put: self author;
		at: 'timestamp' put: self timeStamp;
		yourself
]
