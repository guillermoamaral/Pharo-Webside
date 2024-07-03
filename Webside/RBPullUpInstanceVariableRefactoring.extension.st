Extension { #name : 'RBPullUpInstanceVariableRefactoring' }

{ #category : '*Webside' }
RBPullUpInstanceVariableRefactoring >> fromWebsideJson: json [
	super fromWebsideJson: json.
	class notNil
		ifTrue: [ class := class superclass ]
]

{ #category : '*Webside' }
RBPullUpInstanceVariableRefactoring class >> websideType [

	^ 'MoveUpInstanceVariable'
]
