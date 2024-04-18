Class {
	#name : #WebsideChangeError,
	#superclass : #Error,
	#instVars : [
		'change',
		'error',
		'suggestions'
	],
	#category : #'Webside-Base'
}

{ #category : #testing }
WebsideChangeError class >> canWrap: anException [
    ^false
]

{ #category : #private }
WebsideChangeError class >> classFor: anException [

	^ self allSubclasses detect: [:c | c canWrap: anException] ifNone: [ WebsideChangeError ]
]

{ #category : #'instance creation' }
WebsideChangeError class >> from: change [

	^ self new from: change
]

{ #category : #'instance creation' }
WebsideChangeError class >> on: anException from: change [

	^ (self classFor: anException) new on: anException from: change
]

{ #category : #json }
WebsideChangeError >> asWebsideJson [

	| json todo |
	json := error
		        ifNil: [ super asWebsideJson ]
		        ifNotNil: [ error asWebsideJson ].
	suggestions isEmpty ifTrue: [ ^ json ].
	todo := suggestions associations collect: [ :a |
		        NeoJSONObject
			        with: 'description' -> a key
			        with: 'changes' -> (a value collect: #asWebsideJson) ].
	json at: 'suggestions' put: todo asArray.
	^ json
]

{ #category : #accessing }
WebsideChangeError >> from: originalChange [

	change := originalChange.

]

{ #category : #initialization }
WebsideChangeError >> initialize [
	super initialize.
	suggestions := OrderedDictionary new
]

{ #category : #accessing }
WebsideChangeError >> on: anException from: originalChange [
  change := originalChange.
  error := anException
]

{ #category : #accessing }
WebsideChangeError >> suggest: aString withChanges: aCollection [

	suggestions at: aString put: aCollection
]
