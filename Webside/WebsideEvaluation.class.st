Class {
	#name : #WebsideEvaluation,
	#superclass : #Object,
	#instVars : [
		'id',
		'expression',
		'context',
		'priority',
		'process',
		'state',
		'result'
	],
	#category : #'Webside-Base'
}

{ #category : #json }
WebsideEvaluation >> asWebsideJson [
	^super asWebsideJson
        at: 'id' put: id asString; 
		at: 'expression' put: expression;
		at: 'state' put: state;
		yourself
]

{ #category : #actions }
WebsideEvaluation >> cancel [
	process terminate.
	state := #cancelled.
	self triggerEvent: #finished
]

{ #category : #private }
WebsideEvaluation >> compiler [
	^ OpalCompiler new
		noPattern: true;
		receiver: self receiver;
		requestor: self requestor
]

{ #category : #accessing }
WebsideEvaluation >> context [
	^context
]

{ #category : #accessing }
WebsideEvaluation >> context: anObject [
	context := anObject
]

{ #category : #actions }
WebsideEvaluation >> evaluate: aString [
	expression := aString.
	self evaluate
]

{ #category : #accessing }
WebsideEvaluation >> expression: aString [
	expression := aString
]

{ #category : #testing }
WebsideEvaluation >> hasFinished [
	^state == #finished
]

{ #category : #accessing }
WebsideEvaluation >> id [
	^id
]

{ #category : #accessing }
WebsideEvaluation >> id: idd [
	id := idd
]

{ #category : #initialization }
WebsideEvaluation >> initialize [

	super initialize.
	id := UUID new.
	state := #pending
]

{ #category : #testing }
WebsideEvaluation >> isPending [
	^state == #pending
]

{ #category : #accessing }
WebsideEvaluation >> priority: anInteger [
	priority := anInteger
]

{ #category : #accessing }
WebsideEvaluation >> process [
	^process
]

{ #category : #private }
WebsideEvaluation >> receiver [
  ^context class == Workspace ifFalse: [context]
]

{ #category : #private }
WebsideEvaluation >> requestor [
  ^context class == Workspace ifTrue: [context]
]

{ #category : #accessing }
WebsideEvaluation >> result [
	self isPending ifTrue: [^self].
	^result
]

{ #category : #private }
WebsideEvaluation >> resumed [
	state := #pending.
	self triggerEvent: #resumed
]

{ #category : #actions }
WebsideEvaluation >> suspend [
	process suspend.
	self suspended
]

{ #category : #private }
WebsideEvaluation >> suspended [
	state := #suspended.
	self triggerEvent: #suspended
]

{ #category : #actions }
WebsideEvaluation >> waitForResult [
	| semaphore |
	self isPending ifTrue: [
		semaphore := Semaphore new.
		self when: #finished evaluate: [semaphore signal].
		semaphore wait].
	^self result
]

{ #category : #testing }
WebsideEvaluation >> wasCancelled [
	^state == #cancelled
]
