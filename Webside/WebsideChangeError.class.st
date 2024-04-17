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
WebsideChangeError class >> on: anException from: change [

	^ (self classFor: anException) new on: anException from: change
]

{ #category : #accessing }
WebsideChangeError >> addSuggestion: aString changes: aCollection [
	suggestions at: aString put: aCollection
]

{ #category : #json }
WebsideChangeError >> asWebsideJson [
	 | json  todo | 
	json := error asWebsideJson.
	suggestions isEmpty ifTrue: [^json].
	todo := suggestions associations collect: [:a | 
		NeoJSONObject
			with: 'description' -> a key
			with: 'changes' -> (a value collect: #asWebsideJson)].
	json at: 'suggestions' put: todo asArray.
	^json
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
