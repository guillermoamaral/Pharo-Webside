Extension { #name : #CompiledMethod }

{ #category : #'*Webside' }
CompiledMethod >> asWebsideJson [
	^ NeoJSONObject new
		at: 'selector' put: self selector;
		at: 'class' put: (self methodClass ifNotNil: [:c | c name]);
		at: 'category' put: self category;
		at: 'package' put: (self package ifNotNil: [ :p | p name ] );
		at: 'source' put: self sourceCode;
		at: 'author' put: self author;
		at: 'timestamp' put: self timeStamp;
		at: 'overriding' put: self isOverriding;
		at: 'overriden' put: self isOverridden;
		yourself
]
