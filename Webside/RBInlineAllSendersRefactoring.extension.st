Extension { #name : 'RBInlineAllSendersRefactoring' }

{ #category : '*Webside' }
RBInlineAllSendersRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'className' put: class name;
		  at: 'selector' put: selector;
		  yourself
]

{ #category : '*Webside' }
RBInlineAllSendersRefactoring >> fromWebsideJson: json [

	super fromWebsideJson: json.
	json at: 'className' ifPresent: [ :n |
		class := self classObjectFor: n asSymbol.
		json at: 'selector' ifPresent: [ :s | selector := s asSymbol ] ].
	numberReplaced := numberNotReplaced := 0
]

{ #category : '*Webside' }
RBInlineAllSendersRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'method';
		  at: 'label' put: 'Inline senders';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.methodClass}';
				   at: 'selector' put: '{element.selector}';
				   yourself);
		  at: 'section' put: 'Refactorings';
		  yourself
]
