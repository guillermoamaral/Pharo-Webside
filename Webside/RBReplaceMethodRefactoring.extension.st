Extension { #name : #RBReplaceMethodRefactoring }

{ #category : #'*Webside' }
RBReplaceMethodRefactoring class >> acceptsWebsideJson: json [
	| classname class method selector |
	(super acceptsWebsideJson: json)
		ifFalse: [ ^ false ].
	classname := json at: 'class' ifAbsent: [ ^ false ].
	class := Smalltalk classNamed: classname.
	class ifNil: [ ^ false ].
	method := RBParser parseMethod: (json at: 'sourceCode') onError: nil.
	method ifNil: [ ^ false ].
	selector := method selector.
	selector ifNil: [ ^ false ].
	^ class includesSelector: selector
]
