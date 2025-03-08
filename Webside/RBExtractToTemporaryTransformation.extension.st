Extension { #name : 'RBExtractToTemporaryTransformation' }

{ #category : '*Webside' }
RBExtractToTemporaryTransformation >> asWebsideJson [

	| json |
	json := super asWebsideJson.
	json
		at: 'className' put: class name;
		at: 'selector' put: selector;
		at: 'interval' put: (NeoJSONObject new
				 at: 'from' put: sourceInterval first;
				 at: 'to' put: sourceInterval last;
				 yourself);
		at: 'temporaryName' put: newVariableName.
	^ json
]

{ #category : '*Webside' }
RBExtractToTemporaryTransformation >> fromWebsideJson: json [

	super fromWebsideJson: json.
	json
		at: 'className'
		ifPresent: [ :c | class := self model classObjectFor: c ];
		at: 'selector' ifPresent: [ :s | selector := s asSymbol ];
		at: 'sourceInterval' ifPresent: [ :i |
			sourceInterval := Interval from: (i at: 'from') to: (i at: 'to') ];
		at: 'temporaryName' ifPresent: [ :n | newVariableName := n ]
]

{ #category : '*Webside' }
RBExtractToTemporaryTransformation class >> websideExtension [

	^ NeoJSONObject new
		  at: 'type' put: 'change';
		  at: 'elementType' put: 'code';
		  at: 'label' put: 'Extract temp';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.className}';
				   at: 'selector' put: '{element.selector}';
				   at: 'sourceInterval' put: '{element.sourceInterval}';
				   at: 'temporaryName' put: '{parameters.temporaryName}';
				   yourself);
		  at: 'parameters' put: { (NeoJSONObject new
			   at: 'name' put: 'temporaryName';
			   at: 'label' put: 'Temporary name';
			   at: 'type' put: 'text';
			   at: 'defaultValue' put: 'temp';
			   yourself) };
		  at: 'section' put: 'Refactorings';
		  yourself
]

{ #category : '*Webside' }
RBExtractToTemporaryTransformation class >> websideType [

	^ 'ExtractTemporaryVariable'
]
