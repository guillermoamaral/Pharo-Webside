Class {
	#name : #WebsideCompilationError,
	#superclass : #WebsideChangeError,
	#category : #Webside
}

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
		addSuggestion:
			'Declare ' , identifier printString , ' as temporary variable'
		changes: { variation };
		addSuggestion:
			'Declare ' , identifier printString , ' as instance variable'
		changes: {
				(RBAddInstanceVariableChange
					 add: identifier
					 to: change changeClass).
				change }
]

{ #category : #json }
WebsideCompilationError >> asWebsideJson [

	| interval |
	interval := NeoJSONObject new
		            at: 'start' put: error node start;
		            at: 'end' put: error node stop;
		            yourself.
	^ super asWebsideJson
		  at: 'description' put: self messageText;
		  at: 'interval' put: interval;
		  yourself
]

{ #category : #accessing }
WebsideCompilationError >> on: anException from: originalChange [
  super on: anException from: originalChange.
  (anException isKindOf: OCUndeclaredVariableWarning)
    ifTrue: [self addSuggestionsForUndeclaredVariable: anException node name]
]
