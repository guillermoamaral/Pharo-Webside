"
Implements the API required by Webside.

WebsideServer new
	baseUri: '/pharo';
	port: 9001;
	start.
	
WebsideServer allInstances.

WebsideAPI reset.
"
Class {
	#name : #WebsideAPI,
	#superclass : #Object,
	#instVars : [
		'request'
	],
	#classVars : [
		'Debuggers',
		'Evaluations',
		'Objects',
		'Workspaces'
	],
	#category : #'Webside-Base'
}

{ #category : #initialization }
WebsideAPI class >> reset [
	"
	self reset 
	"
	Debuggers := Evaluations := Objects := Workspaces := nil
]

{ #category : #'evaluation  endpoints' }
WebsideAPI >> activeEvaluations [
	^ self evaluations associations
		collect: [ :a | NeoJSONObject new at: 'id' put: a key asString ; yourself ]
]

{ #category : #'changes endpoints' }
WebsideAPI >> addChange [
	| change author |
	change := self requestedChange.
	change ifNil: [ ^ self badRequest: 'Change not supported' ].
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

{ #category : #private }
WebsideAPI >> bodyAt: aString [
	| json |
	json := NeoJSONReader fromString: request entity.
	^json at: aString ifAbsent: nil 
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
	| json subclasses depth names |
	names := self queryAt: 'names'.
	json := names = 'true'
		ifTrue: [ NeoJSONObject new
			
				at: 'name' put: aClass name;
				at: 'superclass'
					put: (aClass superclass ifNotNil: [ :c | c name ]); yourself ]
		ifFalse: [ aClass asWebsideJson ].
	(anInteger notNil and: [ anInteger = 0 ])
		ifTrue: [ ^ json ].
	depth := anInteger notNil
		ifTrue: [ anInteger - 1 ].
	subclasses := (aClass subclasses sort: [ :a :b | a name <= b name ])
		collect: [ :c | self classTreeFrom: c depth: depth ].
	json at: 'subclasses' put: subclasses.
	^ json
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
WebsideAPI >> compiler [
	^ Smalltalk compiler
]

{ #category : #'debugging endpoints' }
WebsideAPI >> createDebugger [
	| id process exception context debugger |
	id := self bodyAt: 'evaluation'.
	id ifNil: [ ^ self notFound ].
	id := UUID fromString: id.
	process := self evaluations at: id ifAbsent: [ ^ self notFound ].
	exception := process suspendedContext exception.
	context := exception signalerContext.
	"process suspendedContext: context."
	debugger := process
		newDebugSessionNamed: exception description
		startedAt: context.
	debugger restart: context.
	self debuggers at: id put: debugger.
	^ id asString
]

{ #category : #'workspaces endpoints' }
WebsideAPI >> createWorkspace [
	| id |
	id := self newID.
	self workspaces at: id put: Dictionary new.
	^ id asString
]

{ #category : #'debugging endpoints' }
WebsideAPI >> debuggerFrame [
	| debugger index frame interval |
	debugger := self debuggers
		at: self requestedId
		ifAbsent: [ ^ self notFound ].
	index := self requestedIndex.
	frame := debugger stack at: index ifAbsent: [ ^ self notFound ].
	interval := debugger pcRangeForContext: frame.
	interval := NeoJSONObject new
		at: 'start' put: interval first;
		at: 'end' put: interval last;
		yourself.
	^ frame asWebsideJson
		at: 'index' put: index;
		at: 'interval' put: interval;
		yourself
]

{ #category : #'debugging endpoints' }
WebsideAPI >> debuggerFrames [
	| debugger |
	debugger := self debuggers
		at: self requestedId
		ifAbsent: [ ^ self notFound ].
	^ debugger stack
		withIndexCollect: [ :f :i | 
			NeoJSONObject new
				at: 'index' put: i;
				at: 'label' put: f method printString;
				yourself ]
]

{ #category : #private }
WebsideAPI >> debuggers [
	Debuggers ifNil: [ Debuggers := Dictionary new ].
	^ Debuggers
]

{ #category : #private }
WebsideAPI >> defaultRootClass [
	^Object
]

{ #category : #'debugging endpoints' }
WebsideAPI >> deleteDebugger [
	| id debugger |
	id := self requestedId .
	debugger := self debuggers at: id ifAbsent: nil.
	debugger notNil ifTrue: [ 
		debugger terminate.
		self debuggers removeKey: id ifAbsent: nil.
		self evaluations removeKey: id ifAbsent: nil ].
	^id
]

{ #category : #'workspaces endpoints' }
WebsideAPI >> deleteWorkspace [
	self workspaces removeKey: self requestedId ifAbsent: [^self notFound].
	^ nil
]

{ #category : #'code endpoints' }
WebsideAPI >> dialect [
	^'Pharo'
]

{ #category : #'evaluation  endpoints' }
WebsideAPI >> evaluateExpression [
	| expression sync pin id block json process |
	expression := self bodyAt: 'expression'.
	sync := (self bodyAt: 'sync') ifNil: true.
	pin := (self bodyAt: 'pin') ifNil: false.
	id := self newID.
	block := [ | object |
	[ object := self compiler evaluate: expression ]
		on: Exception
		do: [ :exception | 
			process
				suspendedContext: exception signalerContext;
				suspend ].
	(sync not or: [ pin ])
		ifTrue: [ self objects at: id put: object ].
	self evaluations removeKey: id ifAbsent: nil.
	object ].
	sync
		ifTrue: [ json := block value asWebsideJson.
			pin
				ifTrue: [ json at: 'id' put: id asString ].
			^ json ].
	process := self evaluations at: id put: block fork.
	^ NeoJSONObject new
		at: 'id' put: id asString;
		at: 'expression' put: expression;
		yourself
]

{ #category : #private }
WebsideAPI >> evaluationError: id [
	| process json entity |
	process := self evaluations at: id.
	json := NeoJSONObject new
		at: 'description'
			put: process suspendedContext exception description;
		at: 'evaluation' put: id asString;
		yourself.
	entity := ZnStringEntity
		with: (NeoJSONWriter toString: json)
		type:
			(ZnMimeType applicationJson
				charSet: 'utf-8';
				yourself).
	^ ZnResponse serverErrorWithEntity: entity
]

{ #category : #private }
WebsideAPI >> evaluations [
	Evaluations ifNil: [ Evaluations := Dictionary new ].
	^ Evaluations
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
	variable := self queriedReferencing.
	variable ifNil: [ ^ aCollection ].
	^ aCollection
		select: [ :m | 
			class := m methodClass.
			(class hasSlotNamed: variable)
				ifTrue: [ slot := class slotNamed: variable ].
			(class classVarNames includes: variable)
				ifTrue: [ classVar := class classVarNamed: variable ].
			(slot notNil and: [ slot isReferencedIn: m ])
				or: [ classVar notNil and: [ classVar isReferencedIn: m ] ] ]
]

{ #category : #'debugging endpoints' }
WebsideAPI >> frameBindings [
	| debugger frame |
	debugger := self debuggers
		at: self requestedId
		ifAbsent: [ ^ self notFound ].
	frame := debugger stack
		at: self requestedIndex
		ifAbsent: [ ^ self notFound ].
	^ frame gtDebuggerRetrieveVariableValuePairs
		collect: [ :b | 
			NeoJSONObject new
				at: 'name' put: b key asString;
				at: 'value' put: b value printString;
				yourself ]
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
	selector := self requestedSelector.
	selector ifNil: [ ^ self notFound ].
	method := class >> selector.
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
WebsideAPI >> newID [
	^UUID new
]

{ #category : #private }
WebsideAPI >> notFound [
	^ZnResponse notFound: 'resource not found'
]

{ #category : #private }
WebsideAPI >> objects [
	Objects ifNil: [ Objects := Dictionary new ].
	^ Objects
]

{ #category : #'objects endpoints' }
WebsideAPI >> pinnedObject [
	| id object  |
	id := self requestedId.
	self evaluations
		at: id
		ifPresent: [ :process | 
			process isSuspended
				ifTrue: [ ^ self evaluationError: id ] ].
	object := self objects at: id ifAbsent: [ ^ self notFound ].
	^ object asWebsideJson
		at: 'id' put: id asString;
		yourself
]

{ #category : #'objects endpoints' }
WebsideAPI >> pinnedObjectSlot [
	
	| id object path index |
	id := self requestedId.
	object := self objects at: id ifAbsent: [ ^ self notFound ].
	path := request url segments.
	index := path indexOf: 'objects'.
	path
		from: index + 2
		to: path size
		do:
			[ :s | object := self slot: s of: object ifAbsent: [ ^ self notFound ] ].
	^ object asWebsideJson
]

{ #category : #'objects endpoints' }
WebsideAPI >> pinnedObjects [
	^ self objects
		associations collect: [ :a | 
			a value asWebsideJson
				at: 'id' put: a key asString;
				yourself ]
]

{ #category : #'code endpoints' }
WebsideAPI >> projects [
	| organizer root packages names |
	organizer := RPackageOrganizer default .
	root := self queryAt: 'root'.
	root := root notNil
		ifTrue: [ organizer packageNamed: root ifAbsent: nil ].
	packages := root notNil
		ifTrue: [ {root} ]
		ifFalse: [ organizer packages ].
	names := self queryAt: 'names'.
	names = 'true'
		ifTrue: [ ^ (packages collect: #name) sort ].
	^ packages collect: #asWebsideJson
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
WebsideAPI >> queriedReferencing [
	^ self queriedReferencingClass isNil
		ifTrue: [ self queryAt: 'referencing' ]
]

{ #category : #private }
WebsideAPI >> queriedReferencingClass [
	| name |
	name := self queryAt: 'referencing'.
	^ name ifNotNil: [ self classNamed: name ]
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
WebsideAPI >> referencesTo: aClass [
	| binding |
	binding := Smalltalk bindingOf: aClass name asSymbol.
	^SystemNavigation default allReferencesTo: binding
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
	name := self urlAt: 'name'.
	^ name ifNotNil: [ self classNamed: name ]
]

{ #category : #private }
WebsideAPI >> requestedId [
	| id |
	id := self urlAt: 'id'.
	^ id ifNotNil: [ UUID fromString: id]
]

{ #category : #private }
WebsideAPI >> requestedIndex [
	| index |
	index := self urlAt: 'index'.
	^ index ifNotNil: [ index asInteger ]
]

{ #category : #private }
WebsideAPI >> requestedSelector [
	| selector |
	selector := self urlAt: 'selector'.
	^ selector ifNotNil: [ selector asSymbol ]
]

{ #category : #'debugging endpoints' }
WebsideAPI >> restartDebugger [
	| debugger context update method |
	debugger := self debuggers
		at: self requestedId
		ifAbsent: [ ^ self notFound ].
	context := debugger stack
		at: self requestedIndex
		ifAbsent: [ ^ self notFound ].
	update := self queryAt: 'update'.
	method := context method.
	(update = 'true' and: [ method notNil ])
		ifTrue: [ context privRefreshWith: method classBinding value >> method selector ].
	debugger restart: context.
	^ nil
]

{ #category : #'debugging endpoints' }
WebsideAPI >> resumeDebugger [
	| id debugger |
	id := self requestedId.
	debugger := self debuggers at: id ifAbsent: [ ^ self notFound ].
	self debuggers removeKey: id.
	debugger resume.
		^ nil
]

{ #category : #private }
WebsideAPI >> sendersOf: aSymbol [
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ scope sendersOf: aSymbol ]
		ifNil: [ SystemNavigation default allSendersOf: aSymbol ]
]

{ #category : #private }
WebsideAPI >> slot: aString of: anObject ifAbsent: aBlock [
	| index |
	aString asInteger asString = aString ifTrue: [ 
		index := aString asInteger.
		anObject isCollection
			ifTrue: [ 
				index > anObject size ifTrue: [ ^aBlock value ].
				^anObject at: index ] 
			ifFalse: [
				anObject class isVariable ifTrue: [^anObject at: index].
				index > anObject class instSize ifTrue: [^aBlock value].
				^anObject instVarAt: index]].
		^(anObject class allInstVarNames includes: aString)
			ifTrue:[anObject instVarNamed: aString] ifFalse: [ aBlock value ]
]

{ #category : #'debugging endpoints' }
WebsideAPI >> stepIntoDebugger [
	| debugger context |
	debugger := self debuggers
		at: self requestedId
		ifAbsent: [ ^ self notFound ].
	context := debugger stack
		at: self requestedIndex
		ifAbsent: [ ^ self notFound ].
	debugger stepInto: context.
		^ nil
]

{ #category : #'debugging endpoints' }
WebsideAPI >> stepOverDebugger [
	| debugger context |

	debugger := self debuggers
		at: self requestedId
		ifAbsent: [ ^ self notFound ].
	context := debugger stack
		at: self requestedIndex
		ifAbsent: [ ^ self notFound ].
	debugger stepOver: context.
	^ nil
]

{ #category : #'code endpoints' }
WebsideAPI >> subclasses [
| class |
class := self requestedClass .
class ifNil: [ ^ self notFound  ].
^ class subclasses collect: #asWebsideJson 
]

{ #category : #'debugging endpoints' }
WebsideAPI >> terminateDebugger [
	| id debugger |
	id := self requestedId.
	debugger := self debuggers at: id ifAbsent: [ ^ self notFound ].
	self debuggers removeKey: id.
	debugger terminate.
		^nil
]

{ #category : #'objects endpoints' }
WebsideAPI >> unpinObject [

	self objects removeKey: self requestedId ifAbsent: [ ^ self notFound ].
	^ nil
]

{ #category : #private }
WebsideAPI >> urlAt: aString [
	^request at: aString ifAbsent: nil
]

{ #category : #'code endpoints' }
WebsideAPI >> variables [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ self instanceVariables , self classVariables
]

{ #category : #private }
WebsideAPI >> workspaces [
	Workspaces ifNil: [ Workspaces := Dictionary new ].
	^ Workspaces
]
