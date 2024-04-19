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

{ #category : #'*Webside' }
RBPullUpMethodRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'method';
		  at: 'label' put: 'Push up';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.methodClass}';
				   at: 'selector' put: '{element.selector}';
				   yourself);
		  at: 'section' put: 'Refactorings';
		  yourself
]
