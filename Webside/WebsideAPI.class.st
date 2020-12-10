"
Implements the API required by Webside.

WebsideServer new start
"
Class {
	#name : #WebsideAPI,
	#superclass : #Object,
	#instVars : [
		'request'
	],
	#category : #'Webside-Base'
}

{ #category : #'changes endpoints' }
WebsideAPI >> addChange [
	| change author |
	change := self requestedChange.
	change ifNil: [ ^ self halt badRequest: 'Change not supported' ].
	author := (NeoJSONReader fromString: request entity) at: 'author'.
	Author
		useAuthor: author
		during: [ [ change execute ]
				on: Error , SyntaxErrorNotification
				do: [ :e | ^ self halt compilationError: e ] ].
	^ change asWebsideJson
]

{ #category : #private }
WebsideAPI >> badRequest: aString [
	^ZnResponse badRequest: aString
]

{ #category : #'code endpoints' }
WebsideAPI >> categories [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^class protocols
]

{ #category : #'code endpoints' }
WebsideAPI >> classDefinition [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^class asWebsideJson
]

{ #category : #private }
WebsideAPI >> classNamed: aString [
	| name metaclass class |
	name := aString.
	metaclass := name endsWith: ' class'.
	metaclass
		ifTrue: [ name := name withoutSuffix: ' class' ].
	class := Smalltalk at: name asSymbol ifAbsent: [ ^ nil 
		].
	^ metaclass
		ifTrue: [ class class ]
		ifFalse: [ class ]
]

{ #category : #private }
WebsideAPI >> classTreeFrom: aClass depth: anInteger [
	| json subclasses depth |
	json := NeoJSONObject new.
	json
		at: 'name' put: aClass name;
		at: 'superclass' put: aClass superclass name.
	(anInteger notNil and: [anInteger = 0]) ifTrue: [^json].
	depth := anInteger notNil ifTrue: [anInteger - 1].
	subclasses := (aClass subclasses sort: [:a :b | a name <= b name])
		collect: [:c | self classTreeFrom: c depth: depth].
	json at: 'subclasses' put: subclasses.
	^json
]

{ #category : #'code endpoints' }
WebsideAPI >> classVariables [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^class withAllSuperclasses
		gather: [:c | 
			c classVarNames asArray sort collect: [:v | 
				NeoJSONObject new
					at: 'name' put: v;
					at: 'class' put: c name , ' class';
					yourself]]
]

{ #category : #'code endpoints' }
WebsideAPI >> classes [
	| root tree classes names depth json |
	root := self queryAt: 'root'.
	root := root notNil
		ifTrue: [self classNamed: root]
		ifFalse: [self defaultRootClass].
	root ifNil: [^self notFound].
	tree := self queryAt: 'tree'.
	tree = 'true' ifTrue: [
		depth := self queryAt:'depth'.
		depth notNil ifTrue: [depth := depth asInteger].
		json := self classTreeFrom: root depth: depth.
		^Array with: json].
	classes := root withAllSubclasses.
	names := self queryAt: 'names'.
	names = 'true' ifTrue: [^(classes collect: #name) sort].
	^classes collect: #asWebsideJson
]

{ #category : #private }
WebsideAPI >> compilationError: aCompilationError [
	|  entity |
	entity := ZnStringEntity
		with: (NeoJSONWriter toString: aCompilationError asWebsideJson)
		type:
			(ZnMimeType applicationJson
				charSet: 'utf-8';
				yourself).
	^ (ZnResponse statusCode: 409) entity: entity
]

{ #category : #private }
WebsideAPI >> defaultRootClass [
	^Object
]

{ #category : #'code endpoints' }
WebsideAPI >> dialect [
	^'Pharo'
]

{ #category : #private }
WebsideAPI >> filterByCategory: aCollection [
	| category |
	category := self queriedCategory.
	^(category notNil and: [category notEmpty])
		ifTrue: [aCollection select: [:m | m category = category]]
		ifFalse: [aCollection]
]

{ #category : #private }
WebsideAPI >> filterByVariable: aCollection [
	| variable class slot classVar |
	variable := self queriedReferencingVariable.
	variable ifNil: [^aCollection].
	^aCollection select: [:m | 
		class := m methodClass.
		(class hasSlotNamed: variable) ifTrue: [slot := class slotNamed: variable].
		(class hasClassVarNamed: variable) ifTrue: [classVar := class classVarNamed: variable].
		(slot notNil and: [slot isReferencedIn: m])
			or: [classVar notNil and: [classVar isReferencedIn: m]]]
]

{ #category : #private }
WebsideAPI >> implementorsOf: aSymbol [
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ scope implementorsOf: aSymbol ]
		ifNil: [ SystemNavigation default allImplementorsOf: aSymbol ]
]

{ #category : #'code endpoints' }
WebsideAPI >> instanceVariables [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^class withAllSuperclasses
		gather: [:c | 
			c instVarNames collect: [:v | 
				NeoJSONObject new
					at: 'name' put: v;
					at: 'class' put: c name;
					yourself]]
]

{ #category : #'code endpoints' }
WebsideAPI >> method [
	| class selector method |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	selector := request at: 'selector' ifAbsent: nil.
	selector ifNil: [ ^ self notFound ].
	method := class >> selector asSymbol.
	method ifNil: [ ^ self notFound ].
	^ method asWebsideJson
]

{ #category : #'code endpoints' }
WebsideAPI >> methods [
	| selector methods senders global references class |
	selector := self queriedSelector.
	selector notNil
		ifTrue: [ methods := self implementorsOf: selector ].
	selector := self queriedSending.
	selector notNil
		ifTrue: [ senders := self sendersOf: selector.
			methods := methods
				ifNil: [ senders ]
				ifNotNil: [ methods intersection: senders ] ].
	global := self queriedReferencingClass.
	global notNil
		ifTrue: [ references := self referencesTo: global.
			methods := methods
				ifNil: [ references ]
				ifNotNil: [ methods intersection: references ] ].
	class := self requestedClass ifNil: [ self queriedClass ].
	(class notNil and: [ methods notNil ])
		ifTrue: [ methods := methods select: [ :m | m methodClass == class ] ].
	methods
		ifNil: [ methods := (class ifNil: [ self defaultRootClass ]) methodDictionary
				asArray ].
	methods := self filterByCategory: methods.
	methods := self filterByVariable: methods.
	^ methods collect: #asWebsideJson
]

{ #category : #private }
WebsideAPI >> notFound [
	^ZnResponse notFound: 'resource not found'
]

{ #category : #private }
WebsideAPI >> queriedCategory [
	| category |
	category := request at: 'category' ifAbsent: nil.
	^category ifNotNil: [category asSymbol]
]

{ #category : #private }
WebsideAPI >> queriedClass [
	| name |
	name := request at: 'class' ifAbsent: nil.
	^name ifNotNil: [self classNamed: name]
]

{ #category : #private }
WebsideAPI >> queriedReferencingClass [
	| name |
	name := request at: 'referencingClass' ifAbsent: nil.
	^name ifNotNil: [self classNamed: name]
]

{ #category : #private }
WebsideAPI >> queriedReferencingVariable [
	^request at: 'referencingClass' ifAbsent: nil
]

{ #category : #private }
WebsideAPI >> queriedScope [
	| scope |
	scope := request at: 'scope' ifAbsent: nil.
	^ scope ifNotNil: [ self classNamed: scope ]
]

{ #category : #private }
WebsideAPI >> queriedSelector [
	| selector |
	selector := request at: 'selector' ifAbsent: nil.
	^selector ifNotNil: [selector asSymbol]
]

{ #category : #private }
WebsideAPI >> queriedSending [
	| selector |
	selector := request at: 'sending' ifAbsent: nil.
	^selector ifNotNil: [selector asSymbol]
]

{ #category : #private }
WebsideAPI >> queryAt: aString [
	^request at: aString ifAbsent: nil.
]

{ #category : #private }
WebsideAPI >> referencesTo: anAssociation [
	| scope |
	scope := self queriedClass ifNil: [SystemNavigation default].
	^(scope allCallsOn: anAssociation)
		& (scope allCallsOn: anAssociation key)
]

{ #category : #accessing }
WebsideAPI >> request: aTeaRequest [ 
	request := aTeaRequest
]

{ #category : #private }
WebsideAPI >> requestedChange [
	| json change |
	json := NeoJSONReader fromString: request entity.
	change := RBRefactoryChange fromWebsideJson: json.
   change ifNil: [ change := RBRefactoring fromWebsideJson: json ].
	^ change
]

{ #category : #private }
WebsideAPI >> requestedClass [
	| name |
	name := request at: 'name' ifAbsent: nil.
	^name ifNotNil: [self classNamed: name]
]

{ #category : #private }
WebsideAPI >> sendersOf: aSymbol [
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ scope sendersOf: aSymbol ]
		ifNil: [ SystemNavigation default allSendersOf: aSymbol ]
]

{ #category : #'code endpoints' }
WebsideAPI >> variables [
	| class |
	class := self requestedClass.
	class isNil ifTrue: [^self notFound].
	^self instanceVariables , self classVariables
]
