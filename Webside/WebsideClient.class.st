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

{ #category : #services }
WebsideClient >> dialect [

	^ client get: url , '/dialect'
]

{ #category : #evaluations }
WebsideClient >> evaluate: aString [
	^self evaluate: aString sync: true
]

{ #category : #evaluations }
WebsideClient >> evaluate: aString sync: aBoolean [

	| evaluation json error |
	evaluation := NeoJSONObject new.
	evaluation
		at: 'expression' put: aString;
		at: 'sync' put: aBoolean.
	client post: url , '/evaluations' contents: evaluation.
	client response hasEntity ifTrue: [ 
		json := NeoJSONReader fromString: client entity contents ].
	client isSuccess ifFalse: [ 
		error := json
			         ifNil: [ client statusLine reason ]
			         ifNotNil: [ json at: 'description' ifAbsent: [  ] ].
		self error: error ].
	^ json
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
