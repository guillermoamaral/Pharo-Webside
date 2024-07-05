Extension { #name : 'ClassDescription' }

{ #category : '*Webside' }
ClassDescription >> asWebsideJson [

	^ super asWebsideJson
		  at: 'name' put: self name;
		  at: 'definition' put: self definitionString;
		  at: 'superclass' put: (self superclass ifNotNil: [ :c | c name ]);
		  at: 'comment' put: self comment;
		  at: 'category' put: self packageTag name;
		  at: 'variable' put: self isVariable;
		  at: 'package' put: self package name;
		  yourself
]

{ #category : '*Webside' }
ClassDescription >> websidePresentations [

	| comment definition |
	comment := NeoJSONObject new
		           at: 'type' put: 'markdown';
		           at: 'title' put: 'Comment';
		           at: 'code' put: self comment;
		           yourself.
	definition := NeoJSONObject new
		              at: 'type' put: 'source';
		              at: 'title' put: 'Definition';
		              at: 'code' put: self definitionString;
		              yourself.
	^ {
		  comment.
		  definition } , super websidePresentations
]
