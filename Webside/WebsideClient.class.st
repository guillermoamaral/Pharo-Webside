"
(WebsideClient to: 'http://localhost:9001/pharo') evaluate: '3 + 4'
"
Class {
	#name : #WebsideClient,
	#superclass : #Object,
	#instVars : [
		'url',
		'client'
	],
	#category : #'Webside-Base'
}

{ #category : #'instance creation' }
WebsideClient class >> new [

	^ super new initialize 
]

{ #category : #'instance creation' }
WebsideClient class >> to: url [
	^self new url: url
]

{ #category : #evaluations }
WebsideClient >> evaluate: aString [

	| evaluation json error |
	evaluation := NeoJSONObject new.
	evaluation
		at: 'expression' put: aString;
		at: 'sync' put: true.
	client post: url , '/evaluations' contents: evaluation.
	client response hasEntity ifTrue: [ 
		json := NeoJSONReader fromString: client entity contents ].
	client isSuccess ifFalse: [ 
		error := json
			         ifNil: [ client statusLine reason ]
			         ifNotNil: [ json at: 'description' ifAbsent: [  ] ].
		self error: error ].
	^ json 
		  at: 'printString'
		  ifAbsent: [ self error: 'Result cannot be printed' ]
]

{ #category : #initialization }
WebsideClient >> initialize [

	super initialize.
	client := ZnClient new.
	client forJsonREST 
]

{ #category : #evaluations }
WebsideClient >> url: aString [
	url := aString
]
