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

{ #category : #api }
WebsideAPI >> addChange [
	| changes change json result |
	self halt.
	json := NeoJSONReader fromString: request entity.
	Author
		useAuthor: (json at: 'author')
		during: [ change := RBRefactoryChange fromWebsideJson: json.
			change ifNil: [ change := RBRefactoring fromWebsideJson: json ].
			change ifNil: [ ^ self halt badRequest: 'Change not supported' ].
			"change
				owner: changes;
				changes: changes."
			result := change execute ].
	^ result asWebsideJson
]

{ #category : #private }
WebsideAPI >> badRequest: aString [
	^ZnResponse badRequest: aString
]

{ #category : #api }
WebsideAPI >> categories [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^class protocols
]

{ #category : #api }
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

{ #category : #api }
WebsideAPI >> classVariables [
	| class |
	class := self requestedClass.
	class isNil ifTrue: [^self notFound].
	^class withAllSuperclasses
		gather: [:c | 
			c classVarNames asArray sort collect: [:v | 
				NeoJSONObject new
					at: 'name' put: v;
					at: 'class' put: c name , ' class';
					yourself]]
]

{ #category : #api }
WebsideAPI >> classes [
	| root tree classes names depth json |
	root := request at: 'root' ifAbsent: nil.
	root := root notNil
		ifTrue: [self classNamed: root]
		ifFalse: [self rootClass].
	root ifNil: [^self notFound].
	tree := request at: 'tree' ifAbsent: nil.
	tree = 'true' ifTrue: [
		depth := request at: 'depth' ifAbsent: nil.
		depth notNil ifTrue: [depth := depth asInteger].
		json := self classTreeFrom: root depth: depth.
		^Array with: json].
	classes := root withAllSubclasses.
	names := request at: 'names' ifAbsent: nil.
	names = 'true' ifTrue: [^(classes collect: #name) sort].
	^classes collect: #asWebsideJson
]

{ #category : #api }
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
	^scope
		ifNotNil: [scope implementorsOf: aSymbol]
		ifNil: [SystemNavigation default allImplementorsOf: aSymbol]		
	
]

{ #category : #api }
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

{ #category : #api }
WebsideAPI >> method [
	| class selector method |
	class := self requestedClass.
	class ifNil: [^self notFound].
	selector := request at: 'selector' ifAbsent: nil.
	selector ifNil: [^self notFound].
	method := class >> selector asSymbol.
	method ifNil: [^self notFound].
	^method asWebsideJson
]

{ #category : #api }
WebsideAPI >> methods [
	| selector methods senders global references class |
	selector := self queriedSelector.
	selector notNil ifTrue: [methods := self implementorsOf: selector].
	selector := self queriedSending.
	selector notNil ifTrue: [
		senders := self sendersOf: selector.
		methods := methods ifNil: [senders] ifNotNil: [methods intersection: senders]].
	global := self queriedReferencingClass.
	global notNil ifTrue: [
		references := self referencesTo: global.
		methods := methods ifNil: [references] ifNotNil: [methods intersection: references]].
	class := self requestedClass ifNil: [self queriedClass].
	(class notNil and: [methods notNil])
		ifTrue: [methods := methods select: [:m | m methodClass == class]].
	methods ifNil: [methods := (class ifNil: [self rootClass]) methodDictionary asArray].
	methods := self filterByCategory: methods.
	methods := self filterByVariable: methods.
	^methods collect: #asWebsideJson
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
WebsideAPI >> requestedClass [
	| name |
	name := request at: 'name' ifAbsent: nil.
	^name ifNotNil: [self classNamed: name]
]

{ #category : #private }
WebsideAPI >> rootClass [
	^Object
]

{ #category : #private }
WebsideAPI >> sendersOf: aSymbol [
	| scope |
	scope := self queriedScope ifNil: [Smalltalk].
	^scope sendersOf: aSymbol
]

{ #category : #api }
WebsideAPI >> variables [
	| class |
	class := self requestedClass.
	class isNil ifTrue: [^self notFound].
	^self instanceVariables , self classVariables
]
