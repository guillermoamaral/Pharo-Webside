Class {
	#name : 'WebsideWorkspace',
	#superclass : 'Object',
	#instVars : [
		'id',
		'contents',
		'bindings'
	],
	#category : 'Webside-Base',
	#package : 'Webside',
	#tag : 'Base'
}

{ #category : 'bindings' }
WebsideWorkspace >> asWebsideJson [

	| json |
	json := super asWebsideJson.
	json at: 'id' put: id asString;   at: 'source' put: contents.
	^ json
]

{ #category : 'bindings' }
WebsideWorkspace >> bindingOf: aString [
	(bindings includesKey: aString) ifFalse: [
		bindings add: (WorkspaceVariable key: aString asSymbol) ].
	^ bindings associationAt: aString
]

{ #category : 'bindings' }
WebsideWorkspace >> bindings [

	^ bindings
]

{ #category : 'testing' }
WebsideWorkspace >> canAddBindingOf: name [

	^ true
]

{ #category : 'bindings' }
WebsideWorkspace >> contents [

	^contents
]

{ #category : 'bindings' }
WebsideWorkspace >> contents: aString [

	 contents := aString
]

{ #category : 'bindings' }
WebsideWorkspace >> doItContext [

	^ nil
]

{ #category : 'bindings' }
WebsideWorkspace >> doItReceiver [

	^ nil
]

{ #category : 'testing' }
WebsideWorkspace >> hasBindingOf: aString [

	^ bindings includesKey: aString asSymbol
]

{ #category : 'accessing' }
WebsideWorkspace >> id [

	^ id
]

{ #category : 'accessing' }
WebsideWorkspace >> id: uuid [

	id := uuid
]

{ #category : 'initialization' }
WebsideWorkspace >> initialize [

	super initialize.
	id := UUID new.
	contents := ''.
	bindings := Dictionary new
]

{ #category : 'testing' }
WebsideWorkspace >> interactive [

	^false
]

{ #category : 'testing' }
WebsideWorkspace >> needRequestorScope [

	^ true
]

{ #category : 'interactive error protocol' }
WebsideWorkspace >> notify: message at: location in: code [

	
	| node notice |
	node := RBParseErrorNode new
		errorMessage: message; errorPosition: location.
	notice := RBSyntaxErrorNotice new
		messageText: message;
		node: node.
			CodeError new
		notice: notice;
		signal
]
