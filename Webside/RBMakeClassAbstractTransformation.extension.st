Extension { #name : 'RBMakeClassAbstractTransformation' }

{ #category : '*Webside' }
RBMakeClassAbstractTransformation >> fromWebsideJson: json [

	super fromWebsideJson: json.
	json
		at: 'className'
		ifPresent: [ :name |
		targetClass := self classObjectFor: name asSymbol ]
]

{ #category : '*Webside' }
RBMakeClassAbstractTransformation class >> websideExtension [

	^ NeoJSONObject new
		  at: 'type' put: 'change';
		  at: 'elementType' put: 'class';
		  at: 'label' put: 'Make abstract';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.class}';
				   yourself);
		  at: 'section' put: 'Refactorings';
		  yourself
]
