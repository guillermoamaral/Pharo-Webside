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
