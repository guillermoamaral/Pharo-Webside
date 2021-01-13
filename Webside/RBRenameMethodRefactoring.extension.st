Extension { #name : #RBRenameMethodRefactoring }

{ #category : #'*Webside' }
RBRenameMethodRefactoring >> asWebsideJson [
	^super asWebsideJson
	at: 'selector' put: oldSelector;
	at: 'newSelector' put: newSelector; yourself
]

{ #category : #'*Webside' }
RBRenameMethodRefactoring >> fromWebsideJson: json [
	super fromWebsideJson: json.
	oldSelector := json at: 'selector' ifAbsent: nil.
	oldSelector ifNotNil: [ oldSelector := oldSelector asSymbol.
			permutation := 1 to: oldSelector numArgs ].
	newSelector := json at: 'newSelector' ifAbsent: nil.
	newSelector ifNotNil: [ newSelector := newSelector asSymbol ].

]

{ #category : #'*Webside' }
RBRenameMethodRefactoring class >> websideType [
	^ 'SelectorRename'
]
