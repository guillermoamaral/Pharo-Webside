Class {
	#name : #WebsideCompilationError,
	#superclass : #WebsideChangeError,
	#category : #Webside
}

{ #category : #testing }
WebsideCompilationError class >> canWrap: anException [

	^ {
		  OCSemanticWarning.
		  SyntaxErrorNotification } anySatisfy: [:c | anException isKindOf: c]
]

{ #category : #private }
WebsideCompilationError >> addSuggestionsForUndeclaredVariable: identifier [

	| ast temps position source head tail variation |
	ast := RBParser parseMethod: change source.
	temps := ast temporaries isEmpty
		         ifTrue: [
			         ' | ' , identifier , ' | 
	' ]
		         ifFalse: [ ' ' , identifier , ' ' ].
	position := ast body rightBar ifNil: [ ast body start ].
	source := ast sourceCode.
	head := source copyFrom: 1 to: position - 1.
	tail := source copyFrom: position to: source size.
	variation := change copy.
	variation instVarNamed: 'source' put: head , temps , tail.
	self
		suggest:
			'Declare ' , identifier printString , ' as temporary variable'
		withChanges: { variation };
		suggest:
			'Declare ' , identifier printString , ' as instance variable'
		withChanges: {
				(RBAddInstanceVariableChange
					 add: identifier
					 to: change changeClass).
				change }
]

{ #category : #accessing }
WebsideCompilationError >> on: anException from: originalChange [
  super on: anException from: originalChange.
  (anException isKindOf: OCUndeclaredVariableWarning)
    ifTrue: [self addSuggestionsForUndeclaredVariable: anException node name]
]
