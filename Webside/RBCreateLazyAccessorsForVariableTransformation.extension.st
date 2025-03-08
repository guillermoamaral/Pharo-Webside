Extension { #name : 'RBCreateLazyAccessorsForVariableTransformation' }

{ #category : '*Webside' }
RBCreateLazyAccessorsForVariableTransformation class >> websideExtension [

	^ NeoJSONObject new
		  at: 'type' put: 'change';
		  at: 'elementType' put: 'variable';
		  at: 'label' put: 'Generate lazy accessors';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.class}';
				   at: 'variable' put: '{element.name}';
				   at: 'variableType' put: '{element.type}';
				   yourself);
		  yourself
]
