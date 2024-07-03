Extension { #name : 'CompiledBlock' }

{ #category : '*Webside' }
CompiledBlock >> asWebsideJson [

	^ super asWebsideJson
		  at: 'selector' put: self selector;
		  at: 'methodClass'
		  put: (self methodClass ifNotNil: [ :c | c name ]);
		  at: 'package' put: (self package ifNotNil: [ :p | p name ]);
		  at: 'source' put: self sourceCode;
		  at: 'author' put: self author;
		  at: 'timestamp' put: self timeStamp;
		  yourself
]
