Class {
	#name : #WebsideWorkspace,
	#superclass : #Object,
	#instVars : [
		'id',
		'contents',
		'bindings'
	],
	#category : #'Webside-Base'
}

{ #category : #bindings }
WebsideWorkspace >> asWebsideJson [

	| json |
	json := super asWebsideJson.
	json at: 'id' put: id asString;   at: 'source' put: contents.
	^ json
]

{ #category : #binding }
WebsideWorkspace >> bindingOf: aString [

	(bindings includesKey: aString) ifFalse: [
		bindings add: (WorkspaceVariable key: aString asSymbol) ].
	^ bindings associationAt: aString
]

{ #category : #bindings }
WebsideWorkspace >> bindings [

	^ bindings
]

{ #category : #bindings }
WebsideWorkspace >> contents [

	^contents
]

{ #category : #bindings }
WebsideWorkspace >> contents: aString [

	 contents := aString
]

{ #category : #bindings }
WebsideWorkspace >> doItContext [

	^ nil
]

{ #category : #bindings }
WebsideWorkspace >> doItReceiver [

	^ nil
]

{ #category : #binding }
WebsideWorkspace >> hasBindingOf: aString [

	^ bindings includesKey: aString asSymbol
]

{ #category : #accessing }
WebsideWorkspace >> id [

	^ id
]

{ #category : #accessing }
WebsideWorkspace >> id: uuid [

	id := uuid
]

{ #category : #initialization }
WebsideWorkspace >> initialize [

	super initialize.
	id := UUID new.
	contents := ''.
	bindings := Dictionary new
]

{ #category : #'interactive error protocol' }
WebsideWorkspace >> notify: message at: location in: code [
SyntaxErrorNotification
		             inClass: nil
		             withCode: code
		             doitFlag: false
		             errorMessage: message
		             location: location.
	
]
