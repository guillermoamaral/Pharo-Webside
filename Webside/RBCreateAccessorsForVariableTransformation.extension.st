Extension { #name : #RBCreateAccessorsForVariableTransformation }

{ #category : #'*Webside' }
RBCreateAccessorsForVariableTransformation >> asWebsideJson [

	^ super asWebsideJson
		  at: 'variableType' put: (classVariable
				   ifTrue: [ 'class' ]
				   ifFalse: [ 'instance' ]);
		  yourself
]

{ #category : #'*Webside' }
RBCreateAccessorsForVariableTransformation >> fromWebsideJson: json [

	super fromWebsideJson: json.
	classVariable := (json at: 'variableType' ifAbsent: [ 'instance' ])
	                 = 'class'
]

{ #category : #'*Webside' }
RBCreateAccessorsForVariableTransformation class >> websideExtension [

	^ NeoJSONObject new
		  at: 'extensionType' put: 'change';
		  at: 'elementType' put: 'variable';
		  at: 'label' put: 'Generate accessors';
		  at: 'properties' put: (NeoJSONObject new
				   at: 'type' put: self websideType;
				   at: 'className' put: '{element.class}';
				   at: 'variable' put: '{element.name}';
				   at: 'variableType' put: '{element.type}';
				   yourself);
		  yourself
]
