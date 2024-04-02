Extension { #name : #RBPushDownMethodRefactoring }

{ #category : #'*Webside' }
RBPushDownMethodRefactoring >> asWebsideJson [
	^ super asWebsideJson
		at: 'selectors' put: selectors;
		yourself
]

{ #category : #'*Webside' }
RBPushDownMethodRefactoring >> fromWebsideJson: json [

	super fromWebsideJson: json.
	json halt
		at: 'selectors'
		ifPresent: [ :a | selectors := a collect: [ :s | s asSymbol ] ].
	json at: 'selector' ifPresent: [ :s | selectors := { s asSymbol } ]
]
