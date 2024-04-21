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
