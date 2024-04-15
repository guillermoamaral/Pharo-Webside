"
self startServer

self stopServer

"
Class {
	#name : #WebsideAPI,
	#superclass : #Object,
	#instVars : [
		'request',
		'server'
	],
	#category : #'Webside-Base'
}

{ #category : #services }
WebsideAPI class >> startServer [
	"
	self startServer
	"

^WebsideServer new
	baseUri: '/pharo';
	port: 9001;
	start.
]

{ #category : #services }
WebsideAPI class >> stopServer [
	"
	self stopServer
	"

	WebsideServer allInstances do: #stop
]

{ #category : #'debugging endpoints' }
WebsideAPI >> activeDebuggers [
	^ self debuggers associations
		collect: [ :a | 
			a value asWebsideJson
				at: 'id' put: a key asString;
				at: 'description' put: a value name;
				yourself ]
]

{ #category : #'evaluation  endpoints' }
WebsideAPI >> activeEvaluation [
	| id evaluation |
	id := self requestedId .
	evaluation := self evaluations at: id ifAbsent: [^self notFound].
	^self newJsonObject
				at: 'id' put: id asString;
				yourself 
]

{ #category : #'evaluation  endpoints' }
WebsideAPI >> activeEvaluations [
	^ self evaluations associations
		collect: [ :a | self newJsonObject at: 'id' put: a key asString ; yourself ]
]

{ #category : #'testing endpoints' }
WebsideAPI >> activeTestRuns [
	^ self testRuns associations
		collect: [ :a | 
			a value key asWebsideJson
				at: 'id' put: a key asString;
				yourself ]
]

{ #category : #'workspaces endpoints' }
WebsideAPI >> activeWorkspaces [
	^ self workspaces associations
		collect: [ :a | 
			a value asWebsideJson
				at: 'id' put: a key asString;
				yourself ]
]

{ #category : #'changes endpoints' }
WebsideAPI >> addChange [

	| change author |
	change := self requestedChange.
	change ifNil: [ ^ self badRequest: 'Change not supported' ].
	author := self bodyAt: 'author' ifAbsent: [ 'Unknown' ].
	Author useAuthor: author during: [
		[ change execute ]
			on: Exception - Halt
			do: [ :e | ^ self changeError: e from: change] ].
	"Temporary workaround until a better way of gathering system changes is implemented"
	server changes add: change.
	^ change asWebsideJson
]

{ #category : #'code endpoints' }
WebsideAPI >> allCategories [
	^  Smalltalk globals organization categories
]

{ #category : #private }
WebsideAPI >> annotationsForMethod: aCompiledMethod [
    aCompiledMethod isCompiledMethod ifFalse: [^#()].
	^ aCompiledMethod critiques
		  select: [ :c | c sourceAnchor providesInterval ]
		  thenCollect: [ :c | 
			  | interval type |
			  interval := c sourceAnchor interval.
			  type := c rule severity == #error ifTrue: ['error'] ifFalse: ['warning'].
				"The severity could be #information, #warning or #error, but for the moment, the frontend only handles warnings.
				On the other hand, error"
			  self newJsonObject
				  at: 'from' put: interval first;
				  at: 'to' put: interval last;
				  at: 'type' put: 'warning';
				  at: 'description' put: c title;
				  yourself ]
]

{ #category : #'code endpoints' }
WebsideAPI >> autocompletions [

	| class source position completion entries n |
	class := (self bodyAt: 'class') ifNotNil: [ :name | 
		         self classNamed: name ].
	source := self
		          bodyAt: 'source'
		          ifAbsent: [ ^ self badRequest: 'missing source' ].
	position := self
		            bodyAt: 'position'
		            ifAbsent: [ ^ self badRequest: 'missing position' ].
	completion := CompletionContext
		              engine: CompletionEngine new
		              class: class
		              source: source
		              position: position.
	entries := completion entries.
	n := 20 min: entries size.
	^ (entries copyFrom: 1 to: n) collect: #asWebsideJson
]

{ #category : #private }
WebsideAPI >> badRequest: aString [
	^ZnResponse 
	badRequest: request 
		entity: (ZnEntity textCRLF: aString)
]

{ #category : #private }
WebsideAPI >> bodyAt: aString [
	^ self bodyAt: aString ifAbsent: nil
]

{ #category : #private }
WebsideAPI >> bodyAt: aString ifAbsent: aBlock [
	| json |
	json := NeoJSONReader fromString: request entity.
	^ json at: aString ifAbsent: aBlock
]

{ #category : #private }
WebsideAPI >> buildTestSuiteForPackage: package [
	| suite |
	suite := TestSuite named: package name.
	package definedClasses
		select: [ :c | c isTestCase ]
		thenDo: [ :c | suite addTest: c buildSuiteFromSelectors ].
	package extensionMethods
		select: [ :m | m isTestMethod ]
		thenDo: [ :m | suite addTest: m ].
	^ suite
]

{ #category : #'evaluation  endpoints' }
WebsideAPI >> cancelEvaluation [
	| id evaluation |
	id := self requestedId.
	evaluation := self evaluations at: id ifAbsent: [ ^ self notFound ].
	evaluation terminate.
	self evaluations removeKey: id.
	^ nil
]

{ #category : #'code endpoints' }
WebsideAPI >> categories [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^class protocols
]

{ #category : #private }
WebsideAPI >> changeError: error from: change [

	| json suggestions data type entity |
	json := error asWebsideJson.
	((error isKindOf: OCUndeclaredVariableWarning) and: [ change isKindOf: RBAddMethodChange ]) ifTrue: [
		suggestions := self declareVariableSuggestionsFrom: error.
		suggestions ifNotNil: [ json at: 'suggestions' put: suggestions ] ].
	data := NeoJSONWriter toString: json.
	type := ZnMimeType applicationJson
		        charSet: 'utf-8';
		        yourself.
	entity := ZnStringEntity with: data type: type.
	^ (ZnResponse statusCode: 409) entity: entity
]

{ #category : #'changes endpoints' }
WebsideAPI >> changes [

	| author changes |
	author := self queryAt: 'author'.
	changes := EpMonitor current log entries select: [ :e | 
		           e content isCodeChange ].
	"Temporary workaround until a better way of gathering changes is implemented"
	changes := server changes.
	author ifNotNil: [ 
		changes := changes select: [ :ch | ch author = author ] ].
	^ changes collect: #asWebsideJson
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

{ #category : #'code endpoints' }
WebsideAPI >> classTemplate [
	| package |
	package := self queryAt: 'package'.
	package ifNil: [ ^self badRequest: 'no package specified'].
	^self newJsonObject
		at: 'template' put: true;
		at: 'name' put: 'MyClass';
		at: 'definition'
		put: 'Object
	subclass: #MyClass
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''', package , '''';
		yourself
]

{ #category : #private }
WebsideAPI >> classTreeFrom: aClass depth: anInteger [
	| json subclasses depth names |
	names := self queryAt: 'names'.
	json := names = 'true'
		ifTrue: [ self newJsonObject
			
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

{ #category : #private }
WebsideAPI >> classTreeFromClasses: aCollection [

	| roots json subclasses removable |
	roots := Dictionary new.
	removable := Set new.
	aCollection
		do: [ :c |
			json := self newJsonObject
				        at: 'name' put: c name;
				        yourself.
			roots at: c name put: json ];
		select: [ :c | c superclass notNil ] thenDo: [ :c |
		roots at: c superclass name ifPresent: [ :sc |
			subclasses := sc
				              at: 'subclasses'
				              ifAbsentPut: [
				              SortedCollection new sortBlock: [ :a :b |
					              a name <= b name ] ].
			subclasses add: (roots at: c name).
			removable add: c name ] ].
		removable do: [ :n |
		
			roots removeKey: n ] .
	^ roots asArray sort: [ :a :b | a name <= b name ]
]

{ #category : #'code endpoints' }
WebsideAPI >> classVariables [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class withAllSuperclasses
		gather: [ :c | 
			c classVarNames asArray sort
				collect: [ :v | 
					self newJsonObject
						at: 'name' put: v;
						at: 'class' put: c name , ' class';
						at: 'type' put: 'class';
						yourself ] ]
]

{ #category : #'code endpoints' }
WebsideAPI >> classes [

	| root tree classes names depth json |
	root := self queryAt: 'root'.
	root := root ifNil: [self defaultRootClass] ifNotNil: [ self classNamed: root ].
	root ifNil: [ ^ self notFound ].
	tree := self queryAt: 'tree'.
	tree = 'true' ifTrue: [ 
		depth := self queryAt: 'depth' ifPresent: [ :d | d asInteger ].
		json := self classTreeFrom: root depth: depth.
		^ Array with: json ].
	classes := root withAllSubclasses reject: [:c | c isMeta ].
	names := self queryAt: 'names'.
    names = 'true' ifTrue: [ ^ (classes collect: [:c | c name ]) sort].
    ^ classes collect: [:c | c asWebsideJson]
]

{ #category : #'general endpoints' }
WebsideAPI >> colors [
	^self newJsonObject
		at: 'primary' put: '#3297d4';
		at: 'secondary' put: '#1565c0';
		yourself
]

{ #category : #private }
WebsideAPI >> compiler [
	^ OpalCompiler new
		noPattern: true;
		receiver: self compilerReceiver;
		requestor: self compilerRequestor
]

{ #category : #private }
WebsideAPI >> compilerReceiver [
	| context index debugger frame |
	context := self bodyAt: 'context' ifAbsent: [ ^ nil ].
	context at: 'class' ifPresent: [ :name | ^ self classNamed: name ].
	context
		at: 'object'
		ifPresent: [ :path | ^ self objectFromPath: path ].
	context
		at: 'debugger'
		ifPresent: [ :id | 
			index := context at: 'frame' ifAbsent: [ ^ nil ].
			debugger := self debuggers
				at: (UUID fromString: id)
				ifAbsent: [ ^ nil ].
			frame := debugger stack at: index asInteger ifAbsent: nil.
			^ frame ifNotNil: [ frame receiver ] ].
	^ nil
]

{ #category : #private }
WebsideAPI >> compilerRequestor [
	| context |
	context := self bodyAt: 'context' ifAbsent: [ ^ nil ].
	^ context
		at: 'workspace'
		ifPresent: [ :id | self workspaces at: (UUID fromString: id) ifAbsent: [ nil ] ]
		ifAbsent: [ nil ]
]

{ #category : #'debugging endpoints' }
WebsideAPI >> createDebugger [

	| id process exception context debugger |
	id := self bodyAt: 'evaluation' ifAbsent: [ ^ self notFound ].
	id := UUID fromString: id.
	process := self evaluations at: id ifAbsent: [ ^ self notFound ].
	exception := process suspendedContext exception.
	context := exception signalerContext.
	"process suspendedContext: context."
	context selector == #doesNotUnderstand: ifTrue: [ 
		context := context sender ].
	debugger := process
		            newDebugSessionNamed: exception description
		            startedAt: context.
	context selector == #halt ifTrue: [ 
		debugger restart: context.
		debugger
			stepOver;
			stepOver ].
	self debuggers at: id put: debugger.
	^ debugger asWebsideJson
		  at: 'id' put: id asString;
		  at: 'description' put: debugger name;
		  yourself
]

{ #category : #'workspaces endpoints' }
WebsideAPI >> createWorkspace [

	| id workspace |
	id := self newID.
	workspace := Workspace new.
	self workspaces at: id put: workspace.
	^ workspace asWebsideJson
		  at: 'id' put: id asString;
		  yourself
]

{ #category : #private }
WebsideAPI >> customPresentationsOf: anObject [
	^anObject websidePresentations
]

{ #category : #private }
WebsideAPI >> debugExpression [
	| expression method receiver process context debugger id |
	expression := self bodyAt: 'expression' ifAbsent: [''].
	method := self compiler compile: expression.
	receiver := self compilerReceiver.
	process := [ method valueWithReceiver: receiver arguments: #() ]
		newProcess.
	context := process suspendedContext.
	debugger := process
		newDebugSessionNamed: 'debug it'
		startedAt: context.
	debugger stepIntoUntil: [ :c | c method == method ].
	id := self newID.
	self evaluations at: id put: process.
	self debuggers at: id put: debugger.
	^ id asString
]

{ #category : #'testing endpoints' }
WebsideAPI >> debugTest [

	| id run class selector semaphore exception process block context debugger |
	id := self requestedId.
	run := self testRuns at: id ifAbsent: [ ^ self notFound ].
	class := self classNamed: (self bodyAt: 'class').
	class ifNil: [ ^ self notFound ].
	selector := (self bodyAt: 'selector') asSymbol.
	"test := run suite allCases
		detect: [:t | t class == class and: [t selector == selector]]
		ifNone: [^self notFound]."
	semaphore := Semaphore new.
	block := [ 
	         [ class debug: selector ]
		         on: Exception
		         do: [ :e | 
			         semaphore signal.
			         exception := e.
			         process
				         suspendedContext: e signalerContext;
				         suspend ] ].
	process := block newProcess.
	process resume.
	semaphore wait.
	context := exception signalerContext.
	debugger := process
		            newDebugSessionNamed: exception description
		            startedAt: context.
	context selector == #doesNotUnderstand: ifTrue: [ 
		context := context sender ].
	debugger restart: context.
	context selector == #halt ifTrue: [ 
		debugger
			stepOver;
			stepOver ].
	self debuggers at: id put: debugger.
	^ debugger asWebsideJson
		  at: 'id' put: id asString;
		  at: 'description' put: exception description;
		  yourself
]

{ #category : #'debugging endpoints' }
WebsideAPI >> debuggerFrame [

	| debugger index frame interval  json  method |
	debugger := self debuggers
		            at: self requestedId
		            ifAbsent: [ ^ self notFound ].
	index := self requestedIndex.
	frame := debugger stack at: index ifAbsent: [ ^ self notFound ].
	interval := debugger pcRangeForContext: frame.
	interval := self newJsonObject
		            at: 'start' put: interval first;
		            at: 'end' put: interval last;
		            yourself.
	json := frame asWebsideJson.
	json 
          at: 'index' put: index;
		  at: 'interval' put: interval.
	method := json
		at: 'method'
		ifAbsent: [].
    method ifNotNil: [:m |
          m
            at: 'ast' put: frame method ast asWebsideJson;
			at: 'annotations'
			put: (self annotationsForMethod: frame method)].
	^json
]

{ #category : #'debugging endpoints' }
WebsideAPI >> debuggerFrames [
	| debugger |
	debugger := self debuggers
		at: self requestedId
		ifAbsent: [ ^ self notFound ].
	^ debugger stack
		withIndexCollect: [ :f :i | 
			self newJsonObject
				at: 'index' put: i;
				at: 'label' put: f method printString;
				yourself ]
]

{ #category : #private }
WebsideAPI >> debuggers [
	^ server debuggers
]

{ #category : #private }
WebsideAPI >> declareVariableSuggestionsFrom: anOCUndeclaredVariableWarning [

	| original identifier temporary instance |
	original := self requestedChange.
	identifier := anOCUndeclaredVariableWarning node name.
	identifier first isLowercase ifFalse: [ ^ nil ].
	temporary := self newJsonObject.
	temporary
		at: 'description'
		put: 'Declare ' , identifier printString , ' as temporary variable';
		at: 'changes'
		put:
			{ (self methodChangeFrom: original withTemp: identifier)
				asWebsideJson }.
	instance := self newJsonObject.
	instance
		at: 'description'
		put: 'Declare ' , identifier printString , ' as instance variable';
		at: 'changes' put: { 
				(RBAddInstanceVariableChange
					 add: identifier
					 to: original changeClass) asWebsideJson.
				original asWebsideJson }.
	^ { 
		  temporary.
		  instance }
]

{ #category : #private }
WebsideAPI >> defaultRootClass [
	^Object
]

{ #category : #'debugging endpoints' }
WebsideAPI >> deleteDebugger [
	| id debugger |
	id := self requestedId.
	debugger := self debuggers at: id ifAbsent: nil.
	debugger notNil
		ifTrue: [ debugger terminate.
			self debuggers removeKey: id ifAbsent: nil.
			self evaluations removeKey: id ifAbsent: nil ].
	^ id
]

{ #category : #'testing endpoints' }
WebsideAPI >> deleteTestRun [
	self testRuns
		removeKey: self requestedId
		ifAbsent: [ ^ self notFound ].
	^ nil
]

{ #category : #'workspaces endpoints' }
WebsideAPI >> deleteWorkspace [
	self workspaces
		removeKey: self requestedId
		ifAbsent: [ ^ self notFound ].
	^ nil
]

{ #category : #'general endpoints' }
WebsideAPI >> dialect [
	^'Pharo'
]

{ #category : #private }
WebsideAPI >> doesMethod: aCompiledMethod accessVariable: variable for: aSymbol [
	aSymbol == #referencing
		ifTrue: [ ^ (variable isReadIn: aCompiledMethod) or: [  (variable isWrittenIn: aCompiledMethod)] ].
	aSymbol == #using
		ifTrue: [ ^ variable isReadIn: aCompiledMethod ].
	aSymbol == #assigning
		ifTrue: [ ^ variable isWrittenIn: aCompiledMethod ].
	self error: 'not valid access type: ' , aSymbol
]

{ #category : #'evaluation  endpoints' }
WebsideAPI >> evaluateExpression [

	| debug expression sync pin id semaphore object process block json |
	debug := self bodyAt: 'debug'.
	debug == true ifTrue: [ ^ self debugExpression ].
	expression := self bodyAt: 'expression'.
	sync := (self bodyAt: 'sync') ifNil: [ true ].
	pin := (self bodyAt: 'pin') ifNil: [ false ].
	id := self newID.
	semaphore := Semaphore new.
	block := [
	         [ object :=  self compiler evaluate: expression ]
		         on: Exception
		         do: [ :exception |
			         semaphore signal.
			         process
				         suspendedContext: exception signalerContext;
				         suspend ].
	         self evaluations removeKey: id ifAbsent: nil.
	         (sync not or: [ pin ]) ifTrue: [
		         self objects at: id put: object ].
	         semaphore signal.
	         object ].
	process := block newProcess.
	self evaluations at: id put: process.
	process resume.
	sync ifTrue: [
		semaphore wait.
		object ifNil: [ ^ self evaluationError: id ].
		json := object asWebsideJson.
		pin ifTrue: [ json at: 'id' put: id asString ].
		^ json ].
	^ self newJsonObject
		  at: 'id' put: id asString;
		  at: 'expression' put: expression;
		  yourself
]

{ #category : #private }
WebsideAPI >> evaluationError: id [

	| process json entity |
	process := self evaluations at: id.
	json := self newJsonObject
		        at: 'description'
		        put: process suspendedContext exception description;
		        at: 'evaluation' put: id asString;
		        yourself.
	entity := ZnStringEntity
		          with: (NeoJSONWriter toString: json)
		          type: (ZnMimeType applicationJson
				           charSet: 'utf-8';
				           yourself).
	^ ZnResponse serverErrorWithEntity: entity
]

{ #category : #private }
WebsideAPI >> evaluations [
	^server evaluations
]

{ #category : #'extensions endpoints' }
WebsideAPI >> extensions [
	"The following are examples (yet valid/valuable) of how to extend the set of changes predefined by the API.
  For more information, check API documentation at https://github.com/guillermoamaral/Webside."

	^ OrderedCollection new
		  add: (self newJsonObject
				   at: 'extensionType' put: 'change';
				   at: 'elementType' put: 'class';
				   at: 'label' put: 'Insert superclass';
				   at: 'properties' put: (self newJsonObject
						    at: 'type' put: 'InsertClass';
						    at: 'className' put: '{element.name}';
						    at: 'newName' put: '{parameters.newName}';
						    yourself);
				   at: 'parameters' put: { (self newJsonObject
					    at: 'name' put: 'newName';
					    at: 'label' put: 'New class name';
					    at: 'type' put: 'text';
					    yourself) };
				   at: 'section' put: 'Refactorings';
				   yourself);
		  add: (self newJsonObject
				   at: 'extensionType' put: 'change';
				   at: 'elementType' put: 'class';
				   at: 'label' put: 'Move to package';
				   at: 'properties' put: (self newJsonObject
						    at: 'type' put: 'MoveClassToGroup';
						    at: 'className' put: '{element.name}';
						    at: 'package' put: '{parameters.package}';
						    yourself);
				   at: 'parameters' put: { (self newJsonObject
					    at: 'name' put: 'package';
					    at: 'label' put: 'Target package';
					    at: 'type' put: 'text';
                        at: 'options' put: '{packages}';
					    yourself) };
				   at: 'section' put: 'Refactorings';
				   yourself);
		  add: (self newJsonObject
				   at: 'extensionType' put: 'change';
				   at: 'elementType' put: 'method';
				   at: 'label' put: 'Push up';
				   at: 'properties' put: (self newJsonObject
						    at: 'type' put: 'PullUpMethod';
						    at: 'className' put: '{element.methodClass}';
						    at: 'selector' put: '{element.selector}';
						    yourself);
				   at: 'section' put: 'Refactorings';
				   yourself);
		  add: (self newJsonObject
				   at: 'extensionType' put: 'change';
				   at: 'elementType' put: 'method';
				   at: 'label' put: 'Push down';
				   at: 'properties' put: (self newJsonObject
						    at: 'type' put: 'PushDownMethod';
						    at: 'className' put: '{element.methodClass}';
						    at: 'selector' put: '{element.selector}';
						    yourself);
				   at: 'section' put: 'Refactorings';
				   yourself);
		  add: (self newJsonObject
				   at: 'extensionType' put: 'change';
				   at: 'elementType' put: 'method';
				   at: 'label' put: 'Move to another class';
				   at: 'properties' put: (self newJsonObject
						    at: 'type' put: 'MoveMethodToClass';
						    at: 'className' put: '{element.methodClass}';
                            at: 'selector' put: '{element.selector}';
						    at: 'newName' put: '{parameters.newName}';
						    yourself);
				   at: 'parameters' put: { (self newJsonObject
					    at: 'name' put: 'newName';
					    at: 'label' put: 'Target class name';
					    at: 'type' put: 'text';
                        at: 'options' put: '{classes}';
					    yourself) };
				   at: 'section' put: 'Refactorings';
				   yourself);
		  add: (self newJsonObject
				   at: 'extensionType' put: 'change';
				   at: 'elementType' put: 'method';
				   at: 'label' put: 'Move to class side';
				   at: 'properties' put: (self newJsonObject
						    at: 'type' put: 'MoveMethodToClassSide';
						    at: 'className' put: '{element.methodClass}';
                            at: 'selector' put: '{element.selector}';
						    yourself);
				   at: 'section' put: 'Refactorings';
				   yourself);
		  add: (self newJsonObject
				   at: 'extensionType' put: 'change';
				   at: 'elementType' put: 'method';
				   at: 'label' put: 'Move to package';
				   at: 'properties' put: (self newJsonObject
						    at: 'type' put: 'MoveMethodsToPackage';
						    at: 'className' put: '{element.methodClass}';
                            at: 'selector' put: '{element.selector}';
						    at: 'package' put: '{parameters.package}';
						    yourself);
				   at: 'parameters' put: { (self newJsonObject
					    at: 'name' put: 'package';
					    at: 'label' put: 'Target pacakge';
					    at: 'type' put: 'text';
                        at: 'options' put: '{packages}';
					    yourself) };
				   at: 'section' put: 'Refactorings';
				   yourself);
		  yourself
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
	| accessing using assigning filtered |
	accessing := self queriedAccessing .
	using := self queriedUsing.
	assigning := self queriedAssigning.
	(accessing isNil and: [ using isNil and: [ assigning isNil ] ])
		ifTrue: [ ^ aCollection ].
	filtered := Set new.
	accessing notNil
		ifTrue: [ filtered
				addAll:
					(self
						filterMethods: aCollection
						byAccessTo: accessing
						type: #referencing) ].
	using notNil
		ifTrue: [ filtered
				addAll: (self filterMethods: aCollection byAccessTo: using type: #using) ].
	assigning notNil
		ifTrue: [ filtered
				addAll:
					(self
						filterMethods: aCollection
						byAccessTo: assigning
						type: #assigning) ].
	^ filtered
]

{ #category : #private }
WebsideAPI >> filterMethods: aCollection byAccessTo: aString type: aSymbol [
	| groupped filtered slot variable |
	groupped := Dictionary new.
	aCollection
		do: [ :m | 
			(groupped at: m methodClass ifAbsentPut: [ OrderedCollection new ])
				add: m ].
	filtered := OrderedCollection new.
	groupped
		keysAndValuesDo: [ :class :methods | 
			(class hasSlotNamed: aString)
				ifTrue: [ slot := class slotNamed: aString.
					filtered
						addAll:
							(methods
								select: [ :m | self doesMethod: m accessVariable: slot for: aSymbol ]) ].
			(class classVarNames includes: aString)
				ifTrue: [ variable := class classVariableNamed: aString.
					filtered addAll: (methods
						select: [ :m | self doesMethod: m accessVariable: variable for: aSymbol ]
						 )] ].
	^ filtered
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

	^ (StDebuggerContext context: frame) buildInspectorNodes collect: [ 
		  :b | 
		  self newJsonObject
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

{ #category : #private }
WebsideAPI >> indexedSlotsOf: anObject [

	| from to slot |
	anObject class isVariable ifFalse: [ ^ self notFound ].
	from := self
		        queryAt: 'from'
		        ifPresent: [ :f | f asInteger ]
		        ifAbsent: [ 1 ].
	to := self
		      queryAt: 'to'
		      ifPresent: [ :t | t asInteger ]
		      ifAbsent: [ anObject size ].
	^ (from to: to) collect: [ :i | 
		  slot := anObject basicAt: i.
		  slot asWebsideJson
			  at: 'slot' put: i;
			  yourself ]
]

{ #category : #'code endpoints' }
WebsideAPI >> instanceVariables [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ class withAllSuperclasses
		gather: [ :c | 
			c instVarNames
				collect: [ :v | 
					self newJsonObject
						at: 'name' put: v;
						at: 'class' put: c name;
						at: 'type' put: 'instance';
						yourself ] ]
]

{ #category : #private }
WebsideAPI >> instanceVariablesOf: anObject [
^anObject class allInstVarNames
		collect: [ :n | 
			self newJsonObject
				at: 'name' put: n;
				yourself ]
]

{ #category : #private }
WebsideAPI >> jsonFromMethods: aCollection [
     | ast  annotations  json | 
	ast := (self queryAt: 'ast') = 'true'.
	annotations := (self queryAt: 'annotations') = 'true'.
	^ aCollection collect: [ :m | 
		  json := m asWebsideJson.
		  ast ifTrue: [ json at: 'ast' put: m ast asWebsideJson ].
		  annotations
			ifTrue: [json at: 'annotations' put: (self annotationsForMethod: m)].
			 json ]
]

{ #category : #'general endpoints' }
WebsideAPI >> logo [

	^ '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'
]

{ #category : #'code endpoints' }
WebsideAPI >> method [
	| class selector json |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	selector := self requestedSelector.
	selector ifNil: [ ^ self notFound ].
	(class includesSelector: selector)
		ifFalse: [ ^ self notFound ].
	json := self jsonFromMethods: {class >> selector}.
	^ json first
]

{ #category : #private }
WebsideAPI >> methodChangeFrom: anRBAddMethodChange withTemp: aString [

	| original ast declaration position source head tail newSource |
	original := self requestedChange.
	ast := RBParser parseMethod: anRBAddMethodChange source.
	declaration := ast temporaries isEmpty
		               ifTrue: [ 
			               ' | ' , aString , ' | 
	' ]
		               ifFalse: [ ' ' , aString , ' ' ].
	position := ast body rightBar ifNil: [ ast body start ].
	source := ast sourceCode.
	head := source copyFrom: 1 to: position - 1.
	tail := source copyFrom: position to: source size.
	newSource := head , declaration , tail.
	^ original copy
		  instVarNamed: 'source' put: newSource;
		  yourself
]

{ #category : #'code endpoints' }
WebsideAPI >> methodTemplate [
	^self newJsonObject
		at: 'template' put: true;
		at: 'selector' put: 'methodSelectorAndArgumentNames';
		at: 'source'
		put: 'methodSelectorAndArgumentNames
	"comment stating purpose of instance-side method"
	"scope: class-variables  &  instance-variables"

	| temporary variable names |
	statements';
		yourself
]

{ #category : #'code endpoints' }
WebsideAPI >> methods [

	| methods class |
	self queriedSelectorMatching ifNotNil: [ :pattern |
		methods := self methodsWithSelectorMatching: pattern ].
	self queriedReferencingString ifNotNil: [ :string |
		methods := methods
			           ifNil: [ self referencesToString: string ]
			           ifNotNil: [
			           self referencesToString: string among: methods ] ].
	self queriedSelector ifNotNil: [ :selector |
		methods := methods
			           ifNil: [ self implementorsOf: selector ]
			           ifNotNil: [
			           methods select: [ :m | m selector = selector ] ] ].
	self queriedSending ifNotNil: [ :selector |
		methods := methods
			           ifNil: [ self sendersOf: selector ]
			           ifNotNil: [ self sendersOf: selector among: methods ] ].
	self queriedReferencingClass ifNotNil: [ :global |
		methods := methods
			           ifNil: [ self referencesToClass: global ]
			           ifNotNil: [
			           self referencesToClass: global among: methods ] ].
	class := self requestedClass ifNil: [ self queriedClass ].
	(class notNil and: [ methods notNil ]) ifTrue: [
		methods := methods select: [ :m | m methodClass == class ] ].
	methods ifNil: [
		methods := (class ifNil: [ self defaultRootClass ]) methodDictionary
			           asArray ].
	methods := self filterByCategory: methods.
	methods := self filterByVariable: methods.
	(self queryAt: 'count') = 'true' ifTrue: [ ^methods size ].
	^ self jsonFromMethods: methods
]

{ #category : #private }
WebsideAPI >> methodsWithSelectorMatching: aString [
^(RBBrowserEnvironment new implementorsMatching: '*',aString, '*') methods
]

{ #category : #private }
WebsideAPI >> nameForTestSuite [
	| packages classes methods m |
	packages := self bodyAt: 'packages' ifAbsent: [#()].
	classes := self bodyAt: 'classes' ifAbsent: [#()].
	methods := self bodyAt: 'methods' ifAbsent: [#()].
	(packages size = 1 and: [classes isEmpty and: [methods isEmpty]])
		ifTrue: [^packages first].
	(packages isEmpty and: [classes size = 1 and: [methods isEmpty]])
		ifTrue: [^classes first].
	(packages isEmpty and: [classes isEmpty and: [methods size = 1]]) ifTrue: [
		m := methods first.
		^(m at: 'class' ifAbsent: '') , ' >> #' , (m at: 'selector' ifAbsent: '')].
	^'Custom Suite'
]

{ #category : #private }
WebsideAPI >> namedSlotsOf: anObject [
	| slot |
	^anObject class allInstVarNames collect: [ :n |
		slot := self slot: n of: anObject ifAbsent: nil.
		slot asWebsideJson at: 'slot' put: n; yourself  ]
]

{ #category : #private }
WebsideAPI >> newID [
	^UUID new
]

{ #category : #private }
WebsideAPI >> newJsonObject [
	^NeoJSONObject new
]

{ #category : #private }
WebsideAPI >> notFound [
	^ZnResponse notFound: 'resource not found'
]

{ #category : #private }
WebsideAPI >> objectFromPath: uri [
	| path id slot |
 	path := uri substrings: '/'.
	id := UUID fromString: path first.
    slot := self objects at: id ifAbsent: [^nil].
	slot isNil ifTrue: [^nil].
	path
		from: 2
		to: path size
		do: [:s | slot := self slot: s of: slot ifAbsent: [^nil]].
	^slot
]

{ #category : #private }
WebsideAPI >> objects [
	^server objects
]

{ #category : #'code endpoints' }
WebsideAPI >> package [
	| package |
	package := self requestedPackage.
	package ifNil: [ ^ self notFound ].
	^ package asWebsideJson
]

{ #category : #'code endpoints' }
WebsideAPI >> packageClasses [

	| package defined extended extensions tree names instance |
	package := self requestedPackage.
	package ifNil: [ ^ self notFound ].
	defined := OrderedCollection withAll: package definedClasses.
	extended := self queryAt: 'extended'.
	extensions := extended = 'true'
		              ifTrue: [ 
						instance := package extendedClasses collect:  [ :c | c instanceSide  ].
		              (OrderedCollection withAll: instance) removeDuplicates  ]
		              ifFalse: [ #(  ) ].
	tree := self queryAt: 'tree'.
	tree = 'true' ifTrue: [ 
		^ (self classTreeFromClasses: defined)
		  , (self classTreeFromClasses: extensions) ].
	names := self queryAt: 'names'.
	names = 'true' ifTrue: [ 
    ^ (defined , extensions collect: [:c | c name]) sort ].
    ^ defined , extensions collect: [:c | c asWebsideJson]
]

{ #category : #'code endpoints' }
WebsideAPI >> packageMethods [
	| package |
	package := self requestedPackage.
	package ifNil: [ ^ self notFound ].
    ^ package extensionMethods collect: [:m | m asWebsideJson]
]

{ #category : #private }
WebsideAPI >> packageNamed: aString [
^
RPackageOrganizer default packageNamed: aString ifAbsent: nil

]

{ #category : #'code endpoints' }
WebsideAPI >> packages [
	|  packages names |
	packages := RPackageOrganizer default packages.
	names := self queryAt: 'names'.
	names = 'true'
    ifTrue: [ ^ (packages collect: [:p | p name]) sort ].
    ^ packages collect: [:p | p asWebsideJson]
]

{ #category : #'objects endpoints' }
WebsideAPI >> pinObjectSlot [
	| slot id |
	slot := self requestedSlot.
	slot ifNil: [ ^ self badRequest: 'Bad object slot URI' ].
	id := self newID.
	self objects at: id put: slot.
	^ slot asWebsideJson
		at: 'id' put: id asString;
		yourself
]

{ #category : #'objects endpoints' }
WebsideAPI >> pinnedObject [

	| id object |

	id := self requestedId.
	self evaluations at: id ifPresent: [ :process |
		process isSuspended ifTrue: [ ^ self evaluationError: id ] ].
	object := self objects at: id ifAbsent: [ ^ self notFound ].
	^ object asWebsideJson
		  at: 'id' put: id asString;
		  yourself
]

{ #category : #'objects endpoints' }
WebsideAPI >> pinnedObjectSlots [

	| id object path index last |

	id := self requestedId.
	object := self objects at: id ifAbsent: [ ^ self notFound ].
	path := request url segments.
	index := path indexOf: 'objects'.
	path from: index + 2 to: path size - 1 do: [ :s | 
		object := self slot: s of: object ifAbsent: [ ^ self notFound ] ].
	last := path last.
	last = 'instance-variables' ifTrue: [ 
		^ self instanceVariablesOf: object ].
	last = 'named-slots' ifTrue: [ ^ self namedSlotsOf: object ].
	last = 'indexed-slots' ifTrue: [ ^ self indexedSlotsOf: object ].
    last = 'custom-presentations' ifTrue: [^self customPresentationsOf: object].
	object := self slot: last of: object ifAbsent: [ ^ self notFound ].
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

{ #category : #private }
WebsideAPI >> queriedAccessing [
	^ self queryAt: 'accessing'
]

{ #category : #private }
WebsideAPI >> queriedAssigning [
	^ self queryAt: 'assigning'
]

{ #category : #private }
WebsideAPI >> queriedCategory [
	^self queryAt: 'category' ifPresent: [:c | c asSymbol]
]

{ #category : #private }
WebsideAPI >> queriedClass [
	^self queryAt: 'class' ifPresent: [:n | self classNamed: n]
]

{ #category : #private }
WebsideAPI >> queriedReferencingClass [
	^self queryAt: 'referencingClass' ifPresent: [:n | self classNamed: n ]
]

{ #category : #private }
WebsideAPI >> queriedReferencingString [
	^ self queryAt: 'referencingString'
]

{ #category : #private }
WebsideAPI >> queriedScope [
	^self queryAt: 'scope' ifPresent: [:s | self classNamed: s ]
]

{ #category : #private }
WebsideAPI >> queriedSelector [
	^self queryAt: 'selector' ifPresent: [:s | s asSymbol]
]

{ #category : #private }
WebsideAPI >> queriedSelectorMatching [
	^self queryAt: 'selectorMatching'
]

{ #category : #private }
WebsideAPI >> queriedSending [
	^self queryAt: 'sending' ifPresent: [:s | s asSymbol]
]

{ #category : #private }
WebsideAPI >> queriedUsing [
	^ self queryAt: 'using'
]

{ #category : #private }
WebsideAPI >> queryAt: aString [
	^ self queryAt: aString ifAbsent: nil
]

{ #category : #private }
WebsideAPI >> queryAt: aString ifAbsent: aBlock [
	^ self queryAt: aString ifPresent: nil ifAbsent: aBlock
]

{ #category : #private }
WebsideAPI >> queryAt: aString ifPresent: aBlock [
	^ self queryAt: aString ifPresent: aBlock ifAbsent: nil
]

{ #category : #private }
WebsideAPI >> queryAt: aString ifPresent: aBlock ifAbsent: anotherBlock [
	| value |
	value := request at: aString ifAbsent: nil.
	value ifNil: [ ^ anotherBlock value ].
	^ aBlock notNil
		ifTrue: [ aBlock value: value ]
		ifFalse: [ value ]
]

{ #category : #private }
WebsideAPI >> referencesToClass: aClass [
	| binding |
	binding := Smalltalk bindingOf: aClass name asSymbol.
	^ SystemNavigation default allReferencesTo: binding
]

{ #category : #private }
WebsideAPI >> referencesToClass: aClass among: aCollection [

	| binding index |
	binding := Smalltalk bindingOf: aClass name asSymbol.
	index := Smalltalk specialSelectorIndexOrNil: binding.
	^ aCollection
		select:
			[ :m  | m  hasSelector: binding specialSelectorIndex: index ]
]

{ #category : #private }
WebsideAPI >> referencesToString: aString [
	| scope |
	scope := self queriedScope ifNil: [ self queriedClass ].
	^ SystemNavigation default
		allMethodsSelect: [ :m |
			m
				hasLiteralSuchThat: [ :l | 
					l isString
						and: [ l isSymbol not
								and: [ l includesSubstring: aString caseSensitive: false ] ] ] ]
]

{ #category : #private }
WebsideAPI >> referencesToString: aString among: aCollection [
	^ aCollection select: [ :m |
			m
				hasLiteralSuchThat: [ :l | 
					l isString
						and: [ l isSymbol not
								and: [ l includesSubstring: aString caseSensitive: false ] ] ] ]
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
	change ifNil: [ change := CmdCommand fromWebsideJson: json ].
	^ change
]

{ #category : #private }
WebsideAPI >> requestedClass [
	| name |
	name := self urlAt: 'name'.
	^ name ifNotNil: [ self classNamed: name ]
]

{ #category : #private }
WebsideAPI >> requestedContext [
	| context name path id debugger index |
	context := self bodyAt: 'context' ifAbsent: [ ^nil ].
	name := context at: 'class' ifAbsent: nil.
	name ifNotNil: [ ^ self classNamed: name ].
	path := context at: 'object' ifAbsent: nil.
	path
		ifNotNil: [ ^ self objectFromPath: path ].
	id := context at: 'workspace' ifAbsent: nil.
	id
		ifNotNil: [ id := UUID fromString: id.
			^ self workspaces at: id ifAbsent: nil ].
	id := context at: 'debugger' ifAbsent: nil.
	id
		ifNotNil: [ id := UUID fromString: id.
			debugger := self debuggers at: id ifAbsent: [ ^ nil ].
			index := context at: 'frame' ifAbsent: [ ^ nil ].
			^ debugger stack at: index asInteger ifAbsent: [ ^ nil ] ].
	^ nil
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
WebsideAPI >> requestedPackage [
	| name |
	name := self urlAt: 'name'.
	^ name
		ifNotNil: [ self packageNamed: name ]
]

{ #category : #private }
WebsideAPI >> requestedSelector [
	| selector |
	selector := self urlAt: 'selector'.
	^ selector ifNotNil: [ selector asSymbol ]
]

{ #category : #private }
WebsideAPI >> requestedSlot [

	| uri |
	uri := self bodyAt: 'uri' ifAbsent: [ ^ nil ].
	uri := uri
		       copyFrom: (uri indexOfSubCollection: '/objects/') + 9
		       to: uri size.
	^ self  objectFromPath: uri
]

{ #category : #private }
WebsideAPI >> requestedTestSuite [

	| packages classes methods suite |

	packages := self bodyAt: 'packages' ifAbsent: [ #(  ) ].
	classes := self bodyAt: 'classes' ifAbsent: [ #(  ) ].
	methods := self bodyAt: 'methods' ifAbsent: [ #(  ) ].
	suite := TestSuite named: self nameForTestSuite.
	packages do: [ :n | 
		| p s |
		p := self packageNamed: n.
		p notNil ifTrue: [ 
			s := self buildTestSuiteForPackage: p.
			suite addTest: s ] ].
	classes do: [ :n | 
		| c |
		c := self classNamed: n.
		(c notNil and: [ c isTestCase ]) ifTrue: [ 
			suite addTest: c buildSuiteFromSelectors ] ].
	methods do: [ :s | 
		| c m |
		c := self classNamed: (s at: 'class' ifAbsent: '').
		m := c compiledMethodAt: (s at: 'selector') asSymbol.
		(m notNil and: [ m isTestMethod ]) ifTrue: [ 
			suite addTest: (c selector: m selector) ] ].
	^ suite
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
		ifTrue: [ context
				privRefreshWith: method classBinding value >> method selector ].
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

{ #category : #'testing endpoints' }
WebsideAPI >> runTestRun [
	| id run suite result |
	id := self requestedId.
	run := self testRuns at: id ifAbsent: [ ^ self notFound ].
	suite := run key.
	result := suite resultClass new.
	[ suite run: result ]
		forkAt: Processor userBackgroundPriority
		named: 'Test Run ' , id asString.
	self testRuns at: id put: suite -> result.
	^ suite asWebsideJson
		at: 'id' put: id asString;
		yourself
]

{ #category : #'testing endpoints' }
WebsideAPI >> runTests [
	| suite id result |
	suite := self requestedTestSuite.
	suite ifNil: [ ^ self badRequest: 'Invalid test suite' ].
	id := self newID.
	result := suite resultClass new.
	[ suite run: result ]
		forkAt: Processor userBackgroundPriority
		named: 'Test Run ' , id asString.
	self testRuns at: id put: suite -> result.
	^ suite asWebsideJson
		at: 'id' put: id asString;
		yourself
]

{ #category : #'general endpoints' }
WebsideAPI >> saveImage [

	SessionManager default snapshot: true andQuit: false.
	^ true
]

{ #category : #'code endpoints' }
WebsideAPI >> search [

	| text ignoreCase position type model results grouped  matches |
	text := self
		        queryAt: 'text'
		        ifAbsent: [ ^ self badRequest: 'missing text' ].
	ignoreCase := (self queryAt: 'ignoreCase') = 'true'.
	position := (self queryAt: 'position' ifAbsent: [ #beginning ])
		            asSymbol.
	type := self queryAt: 'type' ifAbsent: 'all'.
	type = 'class' ifTrue: [
		matches := Smalltalk allClasses
			  select: [ :class |
				  class name
					  includesSubstring: text
					  caseSensitive: ignoreCase = 'false' ].
        matches sort: [:a :b | (a alike: text) >= (b alike: text)].
        ^matches collect: [:c | self newJsonObject at: 'type' put: 'class'; at: 'text' put: c name asString; yourself ]].
	model := StSpotterModel new.
	model processSearch: text on: StSpotter new.
	[ 550 milliSeconds wait ] doWhileTrue: [
		model scheduler workers anySatisfy: [ :w | w isBusy ] ].
	results := model activeStep activeQuery candidatesList candidates
		           asArray collect: [ :l | l value ].
	grouped := Dictionary new.
	results
		select: [ :r |
			r websideType notNil and: [
				type = 'all' or: [ r websideType = type ] ] ]
		thenDo: [ :r | grouped at: r asString ifAbsentPut: [ r ] ].
	^ grouped values asArray collect: #asWebsideJson
]

{ #category : #'code endpoints' }
WebsideAPI >> selectorInSource [

	| source position extractor |
	source := self bodyAt: 'source'.
	position := self bodyAt: 'position'.
	extractor := CNSelectorExtractor new.
	^ position
		  ifNil: [ extractor extractSelectorFromSelection: source ]
		  ifNotNil: [
		  extractor extractSelectorFromSource: source atPosition: position ]
]

{ #category : #private }
WebsideAPI >> sendersOf: aSymbol [
	| scope |
	scope := self queriedScope.
	^ scope
		ifNotNil: [ self sendersOf: aSymbol among: scope methods ]
		ifNil: [ SystemNavigation default allSendersOf: aSymbol ]
]

{ #category : #private }
WebsideAPI >> sendersOf: aSymbol among: aCollection [
		
	
	| index |
	index := Smalltalk specialSelectorIndexOrNil: aSymbol.
	^ aCollection
		select:
			[ :m | m hasSelector: aSymbol specialSelectorIndex: index ]
]

{ #category : #accessing }
WebsideAPI >> server: aWebsideServer [
	server := aWebsideServer
]

{ #category : #private }
WebsideAPI >> slot: aString of: anObject ifAbsent: aBlock [
	| index |
	aString asInteger asString = aString ifTrue: [ 
		index := aString asInteger.
		anObject isCollection
			ifTrue: [ 
				index > anObject size ifTrue: [ ^aBlock value ].
				^[anObject at: index] on: Error do: [ anObject basicAt: index ] ] 
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

{ #category : #'debugging endpoints' }
WebsideAPI >> stepThroughDebugger [

	| debugger context |
	debugger := self debuggers
		            at: self requestedId
		            ifAbsent: [ ^ self notFound ].
	context := debugger stack
		           at: self requestedIndex
		           ifAbsent: [ ^ self notFound ].
	debugger stepThrough:  context.
	^ nil
]

{ #category : #'testing endpoints' }
WebsideAPI >> stopTestRun [
	| id run |
	id := self requestedId.
	run := self testRuns
		at: id
		ifAbsent: [ ^ self notFound ].
	^ nil
]

{ #category : #'code endpoints' }
WebsideAPI >> subclasses [
	| class |
    class := self requestedClass.
    class ifNil: [ ^ self notFound  ].
    ^ class subclasses collect: [:c | c asWebsideJson] 
]

{ #category : #'debugging endpoints' }
WebsideAPI >> terminateDebugger [
	| id debugger |
	id := self requestedId.
	debugger := self debuggers at: id ifAbsent: [ ^ self notFound ].
	self debuggers removeKey: id.
	debugger terminate.
	^ nil
]

{ #category : #private }
WebsideAPI >> testCountOf: test [
	^(test isKindOf: TestSuite) ifTrue: [ test tests sum: [ :t | self testCountOf: t ] ] ifFalse: [ 1 ]
]

{ #category : #'testing endpoints' }
WebsideAPI >> testRunResults [
	| run  |
	run := self testRuns
		at: self requestedId
		ifAbsent: [ ^ self notFound ].
	^ run value asWebsideJson
]

{ #category : #'testing endpoints' }
WebsideAPI >> testRunStatus [
	| id run suite result total summary |
	id := self requestedId.
	run := self testRuns at: id ifAbsent: [ ^ self notFound ].
	suite := run key.
	total := self testCountOf: suite.
	result := run value.
	summary := self newJsonObject
		at: 'run' put: result runCount;
		at: 'passed' put: result passedCount;
		at: 'failed' put: result failureCount;
		at: 'errors' put: result errorCount;
		at: 'skipped' put: result skippedCount;
		yourself.
	^ self newJsonObject
		at: 'id' put: id asString;
		at: 'name' put: suite name;
		at: 'total' put: total;
		at: 'running' put: total > result runCount;
		at: 'summary' put: summary;
		yourself
]

{ #category : #private }
WebsideAPI >> testRuns [
	^ server testRuns
]

{ #category : #'objects endpoints' }
WebsideAPI >> unpinAllObjects [

	self objects removeAll.
	^ nil
]

{ #category : #'objects endpoints' }
WebsideAPI >> unpinObject [

	self objects removeKey: self requestedId ifAbsent: [ ^ self notFound ].
	^ nil
]

{ #category : #'workspaces endpoints' }
WebsideAPI >> updateWorkspace [

	| id workspace source |
	id := self requestedId.
	workspace := self workspaces at: id ifAbsent: [ ^ self notFound ].
	source := self bodyAt: 'source' ifAbsent: ''.
	workspace contents: source.
	^ workspace asWebsideJson
		  at: 'id' put: id asString;
		  yourself
]

{ #category : #private }
WebsideAPI >> urlAt: aString [
	^request at: aString ifAbsent: nil
]

{ #category : #'code endpoints' }
WebsideAPI >> usedCategories [

	^ #(  )
]

{ #category : #'code endpoints' }
WebsideAPI >> usualCategories [
^#()
]

{ #category : #'code endpoints' }
WebsideAPI >> variables [
	| class |
	class := self requestedClass.
	class ifNil: [ ^ self notFound ].
	^ self instanceVariables , self classVariables
]

{ #category : #'workspaces endpoints' }
WebsideAPI >> workspace [

	| id workspace |
	id := self requestedId.
	workspace := self workspaces at: id ifAbsent: [ ^ self notFound ].
	^ workspace asWebsideJson
		  at: 'id' put: id asString;
		  yourself
]

{ #category : #'workspaces endpoints' }
WebsideAPI >> workspaceBindings [

	| id workspace |
	id := self requestedId.
	workspace := self workspaces at: id ifAbsent: [ ^ self notFound ].
	^workspace bindings associations collect: [:a | 
		self newJsonObject
			at: 'name' put: a key;
			at: 'value' put: a value printString;
			yourself]
]

{ #category : #private }
WebsideAPI >> workspaces [
	^ server workspaces
]
