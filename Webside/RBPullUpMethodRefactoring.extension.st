Extension { #name : #RBPullUpMethodRefactoring }

{ #category : #'*Webside' }
RBPullUpMethodRefactoring >> asWebsideJson [
	^ super asWebsideJson
		at: 'selectors' put: selectors;
		yourself
]

{ #category : #'*Webside' }
RBPullUpMethodRefactoring >> fromWebsideJson: json [

	super fromWebsideJson: json.
	class ifNotNil: [ targetSuperclass := class superclass ].
	json
		at: 'selectors'
		ifPresent: [ :a | selectors := a collect: [ :s | s asSymbol ] ].
	json at: 'selector' ifPresent: [ :s | selectors := { s asSymbol } ].
	self pullUp:  selectors from: class  to: class superclass 
]
