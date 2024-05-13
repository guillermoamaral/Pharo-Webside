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
		'result',
		'error'
	],
	#category : #'Webside-Base'
}

{ #category : #json }
WebsideEvaluation >> asWebsideJson [

	| json |
	json := super asWebsideJson.
	json
		at: 'id' put: id asString;
		at: 'expression' put: expression;
		at: 'state' put: state.
	error ifNotNil: [ json at: 'error' put: error asWebsideJson ].
	^ json
]

{ #category : #actions }
WebsideEvaluation >> cancel [

	process terminate.
	self cancelled
]

{ #category : #private }
WebsideEvaluation >> cancelled [

	state := #cancelled.
	self
		triggerEvent: #cancelled;
		triggerEvent: #finalized
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

{ #category : #accessing }
WebsideEvaluation >> error [

	^ error
]

{ #category : #actions }
WebsideEvaluation >> evaluate [

	process := [
	           state := #evaluating.
	           [ result := self compiler evaluate: expression ]
		           on: Exception
		           do: [ :exception |
			           error := exception.
			           self failed.
			           process
				           suspendedContext: exception signalerContext;
				           suspend ].
	           self finished ] newProcess.
	process
		priority: priority;
		name: 'Webside evaluation ' , id asString;
		resume
]

{ #category : #actions }
WebsideEvaluation >> evaluate: aString [
	expression := aString.
	self evaluate
]

{ #category : #accessing }
WebsideEvaluation >> expression [

	^expression
]

{ #category : #accessing }
WebsideEvaluation >> expression: aString [

	expression := aString
]

{ #category : #private }
WebsideEvaluation >> failed [

	state := #failed.
	self
		triggerEvent: #failed;
		triggerEvent: #finalized
]

{ #category : #private }
WebsideEvaluation >> finished [

	state := #finished.
	self
		triggerEvent: #finished;
		triggerEvent: #finalized
]

{ #category : #testing }
WebsideEvaluation >> hasFailed [

	^ state == #failed
]

{ #category : #testing }
WebsideEvaluation >> hasFinished [

	^ state == #finished
]

{ #category : #accessing }
WebsideEvaluation >> id [
	^id
]

{ #category : #accessing }
WebsideEvaluation >> id: uuid [

	id := uuid
]

{ #category : #initialization }
WebsideEvaluation >> initialize [

	super initialize.
	id := UUID new.
	state := #pending.
	priority := Processor userSchedulingPriority
]

{ #category : #testing }
WebsideEvaluation >> isEvaluating [

	^ state == #evaluating
]

{ #category : #testing }
WebsideEvaluation >> isFinalized [

	^ self hasFinished or: [ self hasFailed or: [ self wasCancelled ] ]
]

{ #category : #testing }
WebsideEvaluation >> isPaused [

	^ state == #paused
]

{ #category : #testing }
WebsideEvaluation >> isPending [

	^ state == #pending
]

{ #category : #actions }
WebsideEvaluation >> pause [

	process suspend.
	self paused
]

{ #category : #private }
WebsideEvaluation >> paused [

	state := #paused.
	self triggerEvent: #paused
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

	self hasFinished ifTrue: [ ^ result ]
]

{ #category : #accessing }
WebsideEvaluation >> result: anObject [

	result := anObject
]

{ #category : #actions }
WebsideEvaluation >> resume [
	self resumed.
	process resume.

]

{ #category : #private }
WebsideEvaluation >> resumed [

	state := #evaluating.
	self triggerEvent: #resumed
]

{ #category : #actions }
WebsideEvaluation >> waitForResult [

	| semaphore |
	self isFinalized ifFalse: [
		semaphore := Semaphore new.
		self when: #finalized evaluate: [ semaphore signal ].
		semaphore wait ].
	^ self result
]

{ #category : #testing }
WebsideEvaluation >> wasCancelled [

	^ state == #cancelled
]
