Extension { #name : #RBReplaceMessageSendTransformation }

{ #category : #'*Webside' }
RBReplaceMessageSendTransformation >> asWebsideJson [

	| json |
	json := super asWebsideJson.
	json
		at: 'className' put: class name;
		at: 'selector' put: oldSelector;
		at: 'newSelector' put: newSelector.
	^ json	
]

{ #category : #'*Webside' }
RBReplaceMessageSendTransformation >> fromWebsideJson: json [

	super fromWebsideJson: json.
	json
		at: 'className'
		ifPresent: [ :c | class := self model classObjectFor: c ];
		at: 'selector' ifPresent: [ :s | oldSelector := s asSymbol ];
		at: 'newSelector' ifPresent: [ :s | newSelector := s asSymbol ];
		at: 'replaceInAllClasses'
		ifPresent: [ :b | replaceInAllClasses := b ].
	permutation := 1 to: oldSelector numArgs
]

{ #category : #'*Webside' }
RBReplaceMessageSendTransformation class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'method';
		  at: 'label' put: 'Replace senders';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.methodClass}';
				   at: 'selector' put: '{element.selector}';
				   at: 'newSelector' put: '{parameters.newSelector}';
				at: 'replaceInAllClasses' put: '{parameters.replaceInAllClasses}';
				   yourself);
		  at: 'parameters' put: { (NeoJSONObject new
			   at: 'name' put: 'newSelector';
			   at: 'label' put: 'New selector';
			   at: 'type' put: 'text';
			   at: 'defaultValue' put: '{element.selector}';
			   yourself). (NeoJSONObject new
			   at: 'name' put: 'replaceInAllClasses';
			   at: 'label' put: 'Replace in all classes';
			   at: 'type' put: 'boolean';
			   at: 'defaultValue' put: true;
			   yourself) };
		  at: 'section' put: 'Refactorings';
		  yourself
]
