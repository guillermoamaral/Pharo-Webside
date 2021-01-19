Class {
	#name : #WebsideAPITest,
	#superclass : #TestCase,
	#instVars : [
		'server',
		'client'
	],
	#category : #'Webside-Tests'
}

{ #category : #private }
WebsideAPITest >> delete: uri [
	| data |
	data := client delete: uri.
	^ data ifNotNil: [ NeoJSONObject fromString: data ]
]

{ #category : #private }
WebsideAPITest >> get: uri [
	| data |
	data := client get: server baseUrl / uri.
	client isNotFound ifTrue: [ ^nil ].
	^ data ifNotNil: [ NeoJSONObject fromString: data ]
]

{ #category : #running }
WebsideAPITest >> setUp [
	super setUp.
	server := WebsideServer new.
	server
		baseUri: '/websideapitest';
		port: 9999;
		start.
	client := ZnClient new
		accept: ZnMimeType applicationJson
]

{ #category : #running }
WebsideAPITest >> tearDown [
	super tearDown.
	server stop.
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testCancelEvaluation [
	| evaluation result id active |
	evaluation := NeoJSONObject new
		at: 'expression' put: 'Delay wait: 10000';
		at: 'sync' put: false;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self delete: '/evaluations/' , id asString.
	active := self get: '/evaluations'.
	self assert: (active noneSatisfy: [ :e | (e at: 'id') = id ])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testCategories [
	| categories |
	categories := self get: 'classes/Point/categories'.
	self
		assert: categories notEmpty;
		assert: (categories allSatisfy: #isString);
		assert: (categories includes: 'arithmetic')
		
  
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testClassCommentDefinition [
	| definition comment |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestClassCommentDefinition';
		at: 'definition'
			put:
			'Object
	subclass: #TestClassCommentDefinition
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	comment := NeoJSONObject new
		at: 'type' put: 'ClassCommentDefinition';
		at: 'class' put: 'TestClassCommentDefinition';
		at: 'comment' put: 'Testing class comment';
		yourself.
	[ | class |
	self
		post: '/changes' with: definition;
		post: '/changes' with: comment.
	class := self get: '/classes/TestClassCommentDefinition'.
	self
		assert: class notNil;
		assert: class comment equals: 'Testing class comment' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestClassCommentDefinition';
				yourself.
			self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testClassRemove [
	| definition remotion class |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestClassRemove';
		definition:
			'Object
	subclass: #TestClassRemove
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	remotion := NeoJSONObject new
		at: 'type' put: 'ClassRemove';
		at: 'class' put: 'TestClassRemove';
		yourself.
	self
		post: '/changes' with: definition;
		post: '/changes' with: remotion.
	class := self get: '/classes/TestClassRemove'.
	self assert: class isNil
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testClassRename [
	| definition renaming class |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestClassRename';
		definition:
			'Object
	subclass: #TestClassRename
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	renaming := NeoJSONObject new
		at: 'type' put: 'ClassRename';
		at: 'class' put: 'TestClassRename';
		at: 'newName' put: 'TestClassRename2';
		yourself.
	[ self
		post: '/changes' with: definition;
		post: '/changes' with: renaming.
	class := self get: '/classes/TestClassRename'.
	self assert: class isNil.
	class := self get: '/classes/TestClassRename2'.
	self assert: class notNil ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestClassRename2';
				yourself.
			self post: '/changes' with: remotion ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testClassVariables [
	| variables |
	variables := self get: 'classes/Float/class-variables'.
	self assert: (variables anySatisfy: [ :v | v name = 'Infinity' ])
]

{ #category : #'debugging endpoints' }
WebsideAPITest >> testCreateDebugger [
	| evaluation halt id debugger |
	evaluation := NeoJSONObject new
		at: 'expression' put: '1 halt factorial';
		at: 'sync' put: true;
		yourself.
	halt := false.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			| error |
			halt := true.
			self
				assert: (e isKindOf: Error);
				assert: e hasData.
			error := e data.
			self
				assert: ((error at: 'description') asLowercase includesSubstring: 'halt');
				assert: (error includesKey: 'evaluation').
			id := error at: 'evaluation' ].
	self
		assert: halt;
		assert: id notNil.
	[ | target frames |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	self assert: debugger notNil.
	frames := self get: '/debuggers/' , debugger , '/frames'.
	self assert: frames notEmpty ]
		ensure: [ debugger notNil
				ifTrue: [ self delete: '/debuggers/' , debugger asString ] ]
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testEvaluationError [
	| evaluation failed |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + ';
		at: 'sync' put: true;
		yourself.
	failed := false.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			| description |
			failed := true.
			self
				assert: (e isKindOf: Error);
				assert: e hasData.
			description := (e data at: 'description') asLowercase.
			self
				assert:
					(description includesSubstring: 'primary missing')
						| (description includesSubstring: 'variable or expression expected') ].
	self assert: failed
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testInstanceVariableMoveUp [
	| superclass class movement |
	superclass := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableMoveUp';
		definition:
			'Object
	subclass: #TestInstanceVariableMoveUp
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	class := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableMoveUp2';
		at: 'definition'
			put:
			'TestInstanceVariableMoveUp
	subclass: #TestInstanceVariableMoveUp2
	instanceVariableNames: ''x''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	movement := NeoJSONObject new
		at: 'type' put: 'InstanceVariableMoveUp';
		at: 'class' put: 'TestInstanceVariableMoveUp2';
		at: 'variable' put: 'x';
		yourself.
	[ | variables |
	self
		post: '/changes' with: superclass;
		post: '/changes' with: class;
		post: '/changes' with: movement.
	variables := self
		get: '/classes/TestInstanceVariableMoveUp/instance-variables'.
	self
		assert: variables size = 1;
		assert: variables first name = 'x'.
	variables := self
		get: '/classes/TestInstanceVariableMoveUp2/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x';
		assert: (variables first at: 'class') equals: 'TestInstanceVariableMoveUp' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableMoveUp2';
				yourself.
			self post: '/changes' with: remotion.
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableMoveUp';
				yourself.
			self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testInstanceVariableRename [
	| definition renaming |
	definition := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestInstanceVariableRename';
		at: 'definition'
			put:
			'Object
	subclass: #TestInstanceVariableRename
	instanceVariableNames: ''x''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	renaming := NeoJSONObject new
		at: 'type' put: 'InstanceVariableRename';
		at: 'class' put: 'TestInstanceVariableRename';
		at: 'variable' put: 'x';
		at: 'newName' put: 'y';
		yourself.
	[ | variables |
	self
		post: '/changes' with: definition;
		post: '/changes' with: renaming.
	variables := self
		get: '/classes/TestInstanceVariableRename/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'y' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestInstanceVariableRename';
				yourself.
			self post: '/changes' with: remotion ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testMethod [
	| method |
	method := self get: 'classes/Point/methods/x'.
	self
		assert: method selector equals: 'x';
		assert:
			((method source includesSubstring: '^x')
				or: [ method source includesSubstring: '^ x' ])
]

{ #category : #'objects endpoints' }
WebsideAPITest >> testPinEvaluationResult [
	| evaluation result |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ self
		assert: (result includesKey: 'id');
		assert: (result at: 'class') equals: 'SmallInteger';
		assert: (result at: 'printString') equals: '7' ]
		ensure: [ self delete: '/objects/' , (result at: 'id') asString ]
]

{ #category : #'debugging endpoints' }
WebsideAPITest >> testStepInto [
	| evaluation id debugger |
	evaluation := NeoJSONObject new
		at: 'expression' put: '1 halt factorial';
		at: 'sync' put: true;
		yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | id := e data at: 'evaluation' ].
	self assert: id notNil.
	[ | target frame |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	self post: '/debuggers/' , debugger , '/frames/1/stepinto'.
	frame := self get: '/debuggers/' , debugger , '/frames/1'.
	self assert: ((frame at: 'method') at: 'selector') equals: 'factorial' ]
		ensure: [ self delete: '/debuggers/' , debugger asString ]
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testSynchronousEvaluation [
	| evaluation result |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	self
		assert: (result at: 'class') equals: 'SmallInteger';
		assert: (result at: 'printString') equals: '7'
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testTestCategoryRename [
	| class method renaming |
	class := NeoJSONObject new
		at: 'type' put: 'ClassDefinition';
		at: 'class' put: 'TestCategoryRename';
		at: 'definition'
			put:
			'Object
	subclass: #TestCategoryRename
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''';
		at: 'author' put: self class name;
		yourself.
	method := NeoJSONObject new
		at: 'type' put: 'MethodDefinition';
		at: 'class' put: 'TestCategoryRename';
		at: 'category' put: 'x';
		at: 'sourceCode' put: 'testCategoryRename';
		at: 'author' put: self class name;
		yourself.
	renaming := NeoJSONObject new
		at: 'type' put: 'CategoryRename';
		at: 'class' put: 'TestCategoryRename';
		at: 'category' put: 'x';
		at: 'newName' put: 'y';
		yourself.
	[ | categories |
	self
		post: '/changes' with: class;
		post: '/changes' with: method;
		post: '/changes' with: renaming.
	categories := self get: '/classes/TestCategoryRename/categories'.
	self
		assert: categories size equals: 1;
		assert: categories first name equals: 'y' ]
		ensure: [ | remotion |
			remotion := NeoJSONObject new
				at: 'type' put: 'ClassRemove';
				at: 'class' put: 'TestCategoryRename';
				yourself.
			self post: '/changes' with: remotion ]
]

{ #category : #'workspaces endpoints' }
WebsideAPITest >> testWorkspace [
	| id |
	id := self post: '/workspaces'.
	[ | context assignment evaluation result |
	context := NeoJSONObject new
		at: 'workspace' put: id;
		yourself.
	assignment := NeoJSONObject new
		at: 'expression' put: 'a := 1';
		at: 'sync' put: true;
		context: context;
		yourself.
	self post: '/evaluations' with: assignment.
	evaluation := NeoJSONObject new
		at: 'expression' put: 'a';
		at: 'sync' put: true;
		context: context;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	self
		assert: (result at: 'class') equals: 'SmallInteger';
		assert: (result at: 'printString') equals: '1' ]
		ensure: [ self delete: '/workspaces/' , id ]
]
