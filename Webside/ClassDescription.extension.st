Extension { #name : #ClassDescription }

{ #category : #'*Webside' }
ClassDescription >> asWebsideJson [
	| tags |
	tags := self tags.
	^ super asWebsideJson
		  at: 'name' put: self name;
		  at: 'definition' put: self oldDefinition;
		  at: 'superclass' put: (self superclass ifNotNil: [ :c | c name ]);
		  at: 'comment' put: self comment;
		  at: 'category' put: (tags notEmpty ifTrue: [tags first]);
		  at: 'variable' put: self isVariable;
		  at: 'package' put: self package name;
		  yourself
]

{ #category : #'*Webside' }
ClassDescription >> websidePresentations [

	| definition comment |
	definition := NeoJSONObject new
		              at: 'type' put: 'source';
		              at: 'title' put: 'Definition';
		              at: 'code' put: self definitionString;
		              yourself.
	comment := NeoJSONObject new
		           at: 'type' put: 'markdown';
		           at: 'title' put: 'Comment';
		           at: 'code' put: self comment;
		           yourself.
	^ {
		  definition.
		  comment }
]
