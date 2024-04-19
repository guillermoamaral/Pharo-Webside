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
	json
		at: 'selectors'
		ifPresent: [ :a | selectors := a collect: [ :s | s asSymbol ] ].
	json at: 'selector' ifPresent: [ :s | selectors := { s asSymbol } ]
]

{ #category : #'*Webside' }
RBPushDownMethodRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'method';
		  at: 'label' put: 'Push down';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.methodClass}';
				   at: 'selector' put: '{element.selector}';
				   yourself);
		  at: 'section' put: 'Refactorings';
		  yourself
]
