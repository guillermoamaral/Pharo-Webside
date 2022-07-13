Extension { #name : #CompiledBlock }

{ #category : #'*Webside' }
CompiledBlock >> asWebsideJson [

	^ NeoJSONObject new
		  at: 'selector' put: self selector;
		  at: 'class' put: (self methodClass ifNotNil: [ :c | c name ]);
		  at: 'package' put: (self package ifNotNil: [ :p | p name ]);
		  at: 'source' put: self sourceCode;
		  at: 'author' put: self author;
		  at: 'timestamp' put: self timeStamp;
		  yourself
]
