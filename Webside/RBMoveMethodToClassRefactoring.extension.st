Extension { #name : 'RBMoveMethodToClassRefactoring' }

{ #category : '*Webside' }
RBMoveMethodToClassRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'className' put: method methodClass name;
		  at: 'selector' put: method selector;
		  at: 'newName' put: class name;
		  yourself
]

{ #category : '*Webside' }
RBMoveMethodToClassRefactoring >> fromWebsideJson: json [

	| c |
	super fromWebsideJson: json.
	json 
		at: 'newName'
		ifPresent: [ :n | class := self classObjectFor: n asSymbol ];
		at: 'className' ifPresent: [ :n |
			c := self classObjectFor: n asSymbol.
			json
				at: 'selector'
				ifPresent: [ :s |
					method := c realClass compiledMethodAt: s asSymbol ] ]
]

{ #category : '*Webside' }
RBMoveMethodToClassRefactoring class >> websideExtension [

	^ NeoJSONObject new
		  at: 'type' put: 'change';
		  at: 'elementType' put: 'method';
		  at: 'label' put: 'Move to another class';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.methodClass}';
				   at: 'selector' put: '{element.selector}';
				   at: 'newName' put: '{parameters.newName}';
				   yourself);
		  at: 'parameters' put: { (NeoJSONObject new
			   at: 'name' put: 'newName';
			   at: 'label' put: 'Target class name';
			   at: 'type' put: 'text';
			   at: 'options' put: '{classes}';
			   yourself) };
		  at: 'section' put: 'Refactorings';
		  yourself
]
