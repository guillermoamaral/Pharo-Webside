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
	data := client delete: server baseUrl / uri.
	^ data ifNotNil: [ NeoJSONObject fromString: data ]
]

{ #category : #private }
WebsideAPITest >> get: uri [
	| url data |
	url := server baseUrl asString.
	(uri beginsWith: '/')
		ifFalse: [ url := url , '/' ].
	url := url , uri.
	data := client get: url.
	client isNotFound
		ifTrue: [ ^ nil ].
	client isSuccess ifFalse: [ self error: client contents asString ].
	^ data ifNotNil: [ NeoJSONObject fromString: data ]
]

{ #category : #private }
WebsideAPITest >> post: uri [
	^ self post: uri with: ''
]

{ #category : #private }
WebsideAPITest >> post: uri with: body [
	| data |
	data := client post: server baseUrl / uri contents: body asString.
	client isSuccess ifFalse: [ self error: client contents ] .
	^ NeoJSONObject fromString: data
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

{ #category : #'code endpoints' }
WebsideAPITest >> testAccessors [
	| accessors |
	accessors := self get: 'methods?class=Fraction&accessing=numerator'.
	self
		assert: accessors notEmpty;
		assert:
			(accessors
				allSatisfy: [ :m | m source includesSubstring: 'numerator' ]).
	accessors := self get: 'methods?class=Fraction&assigning=numerator'.
	self
		assert: accessors notEmpty;
		assert:
			(accessors
				allSatisfy: [ :m | m source includesSubstring: 'numerator :=' ])
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testActiveEvaluations [
	| evaluation result id |
	evaluation := NeoJSONObject new
		at: 'expression' put: '(Delay forSeconds: 1) wait';
		at: 'sync' put: false;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ | active |
	id := result at: 'id'.
	active := self get: '/evaluations'.
	self
		assert: active notEmpty;
		assert: (active anySatisfy: [ :e | (e at: 'id') = id ]) ]
		ensure: [ self delete: '/evaluations/' , id asString ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testAddCass [

	| definition |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestCassDefinition';
		              at: 'definition' put: 'Object
	subclass: #TestCassDefinition
	instanceVariableNames: ''x''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	[
	| class |
	self post: '/changes' with: definition.
	class := self get: '/classes/TestCassDefinition'.
	self
		assert: class notNil;
		assert: class name equals: 'TestCassDefinition' ] ensure: [
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestCassDefinition';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testAddClassVariable [

	| definition addition |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestClassVariableAddition';
		              definition: 'Object
	subclass: #TestClassVariableAddition
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	addition := NeoJSONObject new
		            at: 'type' put: 'AddClassVariable';
		            at: 'className' put: 'TestClassVariableAddition';
		            at: 'variable' put: 'X';
		            yourself.
	[
	| variables |
	self
		post: '/changes' with: definition;
		post: '/changes' with: addition.
	variables := self get:
		             '/classes/TestClassVariableAddition/class-variables'.
	self assert: (variables anySatisfy: [ :v | (v at: 'name') = 'X' ]) ]
		ensure: [
			| remotion |
			remotion := NeoJSONObject new
				            at: 'type' put: 'RemoveClass';
				            at: 'className' put: 'TestClassVariableAddition';
				            yourself.
			self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testAddInstanceVariable [

	| definition addition |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestInstanceVariableAddition';
		              definition: 'Object
	subclass: #TestInstanceVariableAddition
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	addition := NeoJSONObject new
		            at: 'type' put: 'AddInstanceVariable';
		            at: 'className' put: 'TestInstanceVariableAddition';
		            at: 'variable' put: 'x';
		            yourself.
	[
	| variables |
	self
		post: '/changes' with: definition;
		post: '/changes' with: addition.
	variables := self get:
		             '/classes/TestInstanceVariableAddition/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x' ] ensure: [
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestInstanceVariableAddition';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testAddMethod [

	| change method |
	change := NeoJSONObject new
		          at: 'type' put: 'AddMethod';
		          at: 'className' put: 'Point';
		          at: 'category' put: self class name;
		          at: 'sourceCode' put: 'testMethodDefinition
	^x + 1';
		          at: 'author' put: self class name;
		          yourself.
	[ 
	self post: '/changes' with: change.
	method := self get: '/classes/Point/methods/testMethodDefinition'.
	self
		assert: method notNil;
		assert: method selector equals: 'testMethodDefinition';
		assert: method category equals: self class name;
		assert: method source equals: 'testMethodDefinition

	^ x + 1' ] ensure: [ 
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveMethod';
			            at: 'className' put: 'Point';
			            at: 'selector' put: 'testMethodDefinition';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testAddPackage [

	| creation |
	creation := NeoJSONObject new
		            at: 'type' put: 'AddPackage';
		            at: 'name' put: 'TestPackageCreation';
		            at: 'author' put: self class name;
		            yourself.
	[ 
	| package |
	self post: '/changes' with: creation.
	package := self get: '/packages/TestPackageCreation'.
	self
		assert: package notNil;
		assert: package name equals: 'TestPackageCreation' ] ensure: [ 
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemovePackage';
			            at: 'name' put: 'TestPackageCreation';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testAst [
	| method ast traverse return x |
	method := self get: 'classes/Point/methods/x?ast=true'.
	ast := method ast.
	self assert: ast notNil.
	traverse := [ :node :block | 
	block value: node.
	(node includesKey: 'children')
		ifTrue: [ (node at: 'children')
				do: [ :child | traverse value: child value: block ] ] ].
	traverse
		value: ast
		value: [ :n | 
			(n at: 'type') = 'Return'
				ifTrue: [ return := n ] ].
	self assert: return notNil.
	traverse
		value: return
		value: [ :n | 
			((n at: 'type') = 'Identifier' and: [ (n at: 'value') = 'x' ])
				ifTrue: [ x := n ] ].
	self assert: x notNil
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testAsynchronousEvaluation [
	| evaluation result id |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: false;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ | attempts object |
	id := result at: 'id'.
	self
		assert: (result includesKey: 'id');
		deny: (result at: 'printString' ifAbsent: '') equals: '7'.
	attempts := 0.
	object := nil.
	[ attempts <= 3 and: [ object isNil ] ]
		whileTrue: [ attempts := attempts + 1.
			(Delay forMilliseconds: 200) wait.
			object := self get: '/objects/' , id asString ].
	self
		assert: object notNil;
		assert: (object at: 'id') equals: id;
		assert: (object at: 'class') equals: 'SmallInteger';
		assert: (object at: 'printString') equals: '7' ]
		ensure: [ self delete: '/objects/' , id asString ]
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
WebsideAPITest >> testChanges [

	| change changes |
	change := NeoJSONObject new
		          at: 'type' put: 'AddMethod';
		          at: 'className' put: 'Point';
		          at: 'category' put: self class name;
		          at: 'sourceCode' put: 'testChanges
	^x + 1';
		          at: 'author' put: self class name;
		          yourself.
	[ 
	| retrieved |
	self post: '/changes' with: change.
	changes := self get: '/changes'.
	self assert: changes notEmpty.
	retrieved := changes last.
	self
		assert: (retrieved at: 'type') equals: 'AddMethod';
		assert: (retrieved at: 'className') equals: 'Point';
		assert: (retrieved at: 'selector') equals: 'testChanges' ] ensure: [ 
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveMethod';
			            at: 'className' put: 'Point';
			            at: 'selector' put: 'testChanges';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testClassDefinition [
	| definition |
	definition := self get: 'classes/Point'.
	self
		assert: definition name equals: 'Point';
		assert: (definition definition includesSubstring: 'x');
		assert: (definition definition includesSubstring: 'y')
]

{ #category : #'code endpoints' }
WebsideAPITest >> testClassVariables [
	| variables |
	variables := self get: 'classes/Float/class-variables'.
	self assert: (variables anySatisfy: [ :v | (v at: 'name') = 'Infinity' and: [(v at: 'type') = 'class']])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testClasses [
	| classes names tree root integer |
	classes := self get: 'classes?root=Magnitude'.
	self
		assert: (classes anySatisfy: [ :c | c name = 'Date' ]);
		assert:
			(classes
				anySatisfy: [ :c | 
					c name = 'Fraction'
						and: [ c definition includesSubstring: 'denominator' ] ]).
	names := self get: 'classes?root=Magnitude&names=true'.
	self
		assert: names notEmpty;
		assert: (names allSatisfy: #isString).
	tree := self get: 'classes?root=Number&tree=true'.
	self
		assert: tree isCollection;
		assert: tree size equals: 1.
	root := tree first.
	self
		assert: root name = 'Number';
		assert: (root subclasses anySatisfy: [ :c | c name = 'Integer' ]).
	integer := root subclasses detect: [ :c | c name = 'Integer' ].
	self
		assert: (integer subclasses anySatisfy: [ :c | c name = 'SmallInteger' ])
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testClassifyMethod [

	| definition classification method methodRemotion categoryRemotion |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddMethod';
		              at: 'className' put: 'Object';
		              at: 'category' put: self class name;
		              at: 'sourceCode' put: 'testClassifyMethod';
		              at: 'author' put: self class name;
		              yourself.
	classification := NeoJSONObject new
		                  at: 'type' put: 'ClassifyMethod';
		                  at: 'className' put: 'Object';
		                  at: 'selector' put: 'testClassifyMethod';
		                  at: 'category' put: 'testClassifyMethod';
		                  at: 'author' put: self class name;
		                  yourself.
	[
	self post: '/changes' with: definition.
	method := self get: '/classes/Object/methods/testClassifyMethod'.
	self
		assert: method notNil;
		assert: (method at: 'category') equals: self class name.
	self post: '/changes' with: classification.
	method := self get: '/classes/Object/methods/testClassifyMethod'.
	self assert: (method at: 'category') equals: 'testClassifyMethod' ]
		ensure: [
			methodRemotion := NeoJSONObject new
				            at: 'type' put: 'RemoveMethod';
				            at: 'className' put: 'Object';
				            at: 'selector' put: 'testClassifyMethod';
				            yourself.
						categoryRemotion := NeoJSONObject new
				            at: 'type' put: 'RemoveCategory';
				            at: 'className' put: 'Object';
				            at: 'category' put: 'testClassifyMethod';
				            yourself.
			self post: '/changes' with: methodRemotion; post: '/changes' with: categoryRemotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testCodeSuggestion [

	| change method error suggestions |
	change := NeoJSONObject new
		          at: 'type' put: 'AddMethod';
		          at: 'className' put: 'Point';
		          at: 'category' put: self class name;
		          at: 'sourceCode' put: 'testMethodDefinition
	^t + 1';
		          at: 'author' put: self class name;
		          yourself.
	[
	self
		post: '/changes' with: change]
		on: Error
		do: [ :e | 
			error := NeoJSONObject fromString: client contents].
[
	self assert: error notNil.
	suggestions := error at: 'suggestions'.
	self post: '/changes' with: suggestions first changes first.
	method := self get: '/classes/Point/methods/testMethodDefinition'.
	self
		assert: method notNil;
		assert: method selector equals: 'testMethodDefinition';
		assert: method category equals: self class name;
		assert: method source equals: 'testMethodDefinition

	| t |
	^ t + 1' ] ensure: [ 
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveMethod';
			            at: 'className' put: 'Point';
			            at: 'selector' put: 'testMethodDefinition';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testCommentClass [

	| definition comment |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestClassCommentDefinition';
		              at: 'definition' put: 'Object
	subclass: #TestClassCommentDefinition
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	comment := NeoJSONObject new
		           at: 'type' put: 'CommentClass';
		           at: 'className' put: 'TestClassCommentDefinition';
		           at: 'comment' put: 'Testing class comment';
		           yourself.
	[
	| class |
	self
		post: '/changes' with: definition;
		post: '/changes' with: comment.
	class := self get: '/classes/TestClassCommentDefinition'.
	self
		assert: class notNil;
		assert: class comment equals: 'Testing class comment' ] ensure: [
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestClassCommentDefinition';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'debugging endpoints' }
WebsideAPITest >> testCreateDebugger [

	| evaluation id debugger error |
	evaluation := NeoJSONObject new
		              at: 'expression' put: '1 halt factorial';
		              at: 'sync' put: true;
		              yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			error := NeoJSONObject fromString: client contents.
			self
				assert:
					((error at: 'description') asLowercase includesSubstring: 'halt');
				assert: (error includesKey: 'evaluation').
			id := error at: 'evaluation' ].
	self assert: id notNil.
	[ 
	| target frames |
	target := NeoJSONObject new
		          at: 'evaluation' put: id;
		          yourself.
	debugger := self post: '/debuggers' with: target.
	self assert: debugger notNil.
	id := debugger at: 'id'.
	frames := self get: '/debuggers/' , id , '/frames'.
	self assert: frames notEmpty ] ensure: [ 
		debugger notNil ifTrue: [ self delete: '/debuggers/' , id ] ]
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testDebuggerContext [
	| evaluation id debugger error |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 halt factorial';
		at: 'sync' put: true;
		yourself.
 	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			error := NeoJSONObject fromString: client contents.
			self
				assert:
					((error at: 'description') asLowercase includesSubstring: 'halt');
				assert: (error includesKey: 'evaluation').
			id := error at: 'evaluation' ].
	self assert: id notNil.
	[ | target context receiver |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	id := debugger at: 'id'.
	self post: '/debuggers/' , id , '/frames/1/stepinto'.
	context := NeoJSONObject new
		at: 'debugger' put: id;
		at: 'frame' put: 1;
		yourself.
	evaluation := NeoJSONObject new
		at: 'expression' put: 'self';
		at: 'sync' put: true;
		at: 'pin' put: false;
		at: 'context' put: context;
		yourself.
	receiver := self post: '/evaluations' with: evaluation.
	self
		assert: (receiver at: 'class') equals: 'SmallInteger';
		assert: (receiver at: 'printString') equals: '3' ]
		ensure: [ self delete: '/debuggers/' , id asString ]
]

{ #category : #'debugging endpoints' }
WebsideAPITest >> testDebuggerFrames [
	| evaluation error id debugger |
	evaluation := NeoJSONObject new
		at: 'expression' put: '1 halt factorial';
		at: 'sync' put: true;
		yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			error := NeoJSONObject fromString: client contents.
			self
				assert:
					((error at: 'description') asLowercase includesSubstring: 'halt');
				assert: (error includesKey: 'evaluation').
			id := error at: 'evaluation' ].
	id := error at: 'evaluation'.
	self assert: id notNil.
	[ | target frames |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	id := debugger at: 'id'.
	frames := self get: '/debuggers/' , id , '/frames'.
	self
		assert: frames notEmpty;
		assert: (frames anySatisfy: [ :f | (f at: 'label') notEmpty ]) ]
		ensure: [ self delete: '/debuggers/' , id ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testDialect [
	| dialect |
	dialect := self get: 'dialect'.
	self assert: dialect equals: 'Pharo'
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testEvaluationError [

	| evaluation error description |
	evaluation := NeoJSONObject new
		              at: 'expression' put: '3 + '; 
		              at: 'sync' put: true;
		              yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | error := NeoJSONObject fromString: client contents ].
	self assert: error notNil.
	description := (error at: 'description') asLowercase.
	self assert: (description includesSubstring: 'primary missing')
		| (description includesSubstring: 'variable or expression expected')
]

{ #category : #'debugging endpoints' }
WebsideAPITest >> testFrameBindings [
	| evaluation error id debugger |
	evaluation := NeoJSONObject new
		at: 'expression' put: '1 halt factorial';
		at: 'sync' put: true;
		yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			error := NeoJSONObject fromString: client contents.
			self
				assert:
					((error at: 'description') asLowercase includesSubstring: 'halt');
				assert: (error includesKey: 'evaluation').
			id := error at: 'evaluation' ].
	self assert: id notNil.
	[ | target frames bindings |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	id := debugger at: 'id'.
	frames := self get: '/debuggers/' , id , '/frames'.
	self assert: frames notEmpty.
	bindings := self get: '/debuggers/' , id , '/frames/1/bindings'.
	self
		assert: bindings notEmpty;
		assert: (bindings anySatisfy: [ :b | (b at: 'name') = 'self' ]) ]
		ensure: [ self delete: '/debuggers/' , id ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testImplementors [

	| implementors local |
	implementors := self get: 'methods?selector=reciprocal'.
	self
		assert: implementors notEmpty;
		assert:
			(implementors allSatisfy: [ :m | m selector = 'reciprocal' ]);
		assert:
			(implementors anySatisfy: [ :m | 
					 (m at: 'methodClass') = 'Fraction' ]).
	local := self get: 'methods?selector=reciprocal&class=Fraction'.
	self
		assert: local notEmpty;
		assert: (local allSatisfy: [ :m | m selector = 'reciprocal' ]);
		assert: (local allSatisfy: [ :m | (m at: 'methodClass') = 'Fraction' ])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testInstanceVariables [
	| variables |
	variables := self get: 'classes/Fraction/instance-variables'.
	self
		assert: (variables anySatisfy: [ :v | v name = 'numerator' ]);
		assert: (variables anySatisfy: [ :v | v name = 'denominator' ])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testMatchingSelectors [
	| matching |
	matching := self get: 'methods?selectorMatching=testMa*'.
	self
		assert: matching notEmpty;
		assert: (matching
			anySatisfy: [:m | (m at: 'selector') = 'testMatchingSelectors'])
]

{ #category : #'debugging endpoints' }
WebsideAPITest >> testMessageNotUnderstood [

	| change method evaluation error id debugger target frame remotion |
	change := NeoJSONObject new
		          at: 'type' put: 'AddMethod';
		          at: 'className' put: 'Object';
		          at: 'category' put: self class name;
		          at: 'sourceCode' put: 'blah
1.
2.
3 blahblahblah';
		          at: 'author' put: self class name;
		          yourself.
	[ 
	self post: '/changes' with: change.
	method := self get: '/classes/Object/methods/blah'.
	self assert: method notNil.
	evaluation := NeoJSONObject new
		              at: 'expression' put: 'Object new blah';
		              at: 'sync' put: true;
		              yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			error := NeoJSONObject fromString: client contents.
			self
				assert: ((error at: 'description') asLowercase includesSubstring:
							 'blahblahblah');
				assert: (error includesKey: 'evaluation').
			id := error at: 'evaluation' ].
	self assert: id notNil.
	[
	target := NeoJSONObject new
		          at: 'evaluation' put: id;
		          yourself.
	debugger := self post: '/debuggers' with: target.
	id := debugger at: 'id'.
	frame := self get: '/debuggers/' , id , '/frames/1'.
	self
		assert: ((frame at: 'method') at: 'selector') equals: 'blah';
		assert: ((frame at: 'interval') at: 'start') > 10 ] ensure: [ 
		self delete: '/debuggers/' , id asString ] ] ensure: [ 
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveMethod';
			            at: 'className' put: 'Object';
			            at: 'selector' put: 'blah';
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

{ #category : #'code endpoints' }
WebsideAPITest >> testMethodCount [

	| methods count |
	methods := self get: 'classes/Point/methods'.
	count := self get: 'classes/Point/methods?count=true'.
	self assert: count equals: methods size
]

{ #category : #'code endpoints' }
WebsideAPITest >> testMethods [

	| methods |
	methods := self get: 'classes/Point/methods'.
	self
		assert: methods notEmpty;
		assert: (methods allSatisfy: [ :m | (m at: 'methodClass') = 'Point' ])
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testMoveDownInstanceVariable [

	| superclass class movement remotion |
	superclass := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestMoveDownInstanceVariable';
		              at: 'definition' put: 'Object
	subclass: #TestMoveDownInstanceVariable
	instanceVariableNames: ''x''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	class := NeoJSONObject new
		         at: 'type' put: 'AddClass';
		         at: 'className' put: 'TestMoveDownInstanceVariable2';
		         at: 'definition' put: 'TestMoveDownInstanceVariable
	subclass: #TestMoveDownInstanceVariable2
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		         at: 'author' put: self class name;
		         yourself.
	movement := NeoJSONObject new
		            at: 'type' put: 'MoveDownInstanceVariable';
		            at: 'className' put: 'TestMoveDownInstanceVariable';
		            at: 'variable' put: 'x';
		            at: 'target' put: 'TestMoveDownInstanceVariable2';
		            yourself.
	[
	| variables |
	self
		post: '/changes' with: superclass;
		post: '/changes' with: class;
		post: '/changes' with: movement.
	variables := self get:
		             '/classes/TestMoveDownInstanceVariable/instance-variables'.
	self assert: variables isEmpty.
	variables := self get:
		             '/classes/TestMoveDownInstanceVariable2/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x' ] ensure: [
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestMoveDownInstanceVariable2';
			            yourself.
		self post: '/changes' with: remotion.
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestMoveDownInstanceVariable';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testMoveUpInstanceVariable [

	| superclass class movement |
	superclass := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestMoveUpInstanceVariable';
		              definition: 'Object
	subclass: #TestMoveUpInstanceVariable
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	class := NeoJSONObject new
		         at: 'type' put: 'AddClass';
		         at: 'className' put: 'TestMoveUpInstanceVariable2';
		         at: 'definition' put: 'TestMoveUpInstanceVariable
	subclass: #TestMoveUpInstanceVariable2
	instanceVariableNames: ''x''
	classVariableNames: ''''
	package: ''Unclassified''';
		         at: 'author' put: self class name;
		         yourself.
	movement := NeoJSONObject new
		            at: 'type' put: 'MoveUpInstanceVariable';
		            at: 'className' put: 'TestMoveUpInstanceVariable2';
		            at: 'variable' put: 'x';
		            yourself.
	[
	| variables |
	self
		post: '/changes' with: superclass;
		post: '/changes' with: class;
		post: '/changes' with: movement.
	variables := self get:
		             '/classes/TestMoveUpInstanceVariable/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x'.
	variables := self get:
		             '/classes/TestMoveUpInstanceVariable2/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'x';
		assert: (variables first at: 'class')
		equals: 'TestMoveUpInstanceVariable' ] ensure: [
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestMoveUpInstanceVariable2';
			            yourself.
		self post: '/changes' with: remotion.
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestMoveUpInstanceVariable';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testObjectContext [
	| evaluation object |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 @ 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	object := self post: '/evaluations' with: evaluation.
	[ | context x |
	context := NeoJSONObject new
		at: 'object' put: (object at: 'id');
		yourself.
	evaluation := NeoJSONObject new
		at: 'expression' put: 'x';
		at: 'sync' put: true;
		at: 'pin' put: false;
		at: 'context' put: context;
		yourself.
	x := self post: '/evaluations' with: evaluation.
	self
		assert: (x at: 'class') equals: 'SmallInteger';
		assert: (x at: 'printString') equals: '3' ]
		ensure: [ self delete: '/objects/' , (object at: 'id') asString ]
]

{ #category : #'evaluation  endpoints' }
WebsideAPITest >> testObjectSlotContext [
	| evaluation object |
	evaluation := NeoJSONObject new 
		at: 'expression' put: '3 @ 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	object := self post: '/evaluations' with: evaluation.
	[| context x |
		context := NeoJSONObject new
			at: 'object' put: (object at: 'id') , '/x';
			yourself.
		evaluation := NeoJSONObject new
			at: 'expression' put: 'self';
			at: 'sync' put: true;
			at: 'pin' put: false;
			at: 'context' put: context;
			yourself.
		x := self post: '/evaluations' with: evaluation.
		self
			assert: (x at: 'class') = 'SmallInteger';
			assert: (x at: 'printString') = '3']
		ensure: [self delete: '/objects/' , (object at: 'id') asString]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testPackage [
	| package |
	package := self get: 'packages/Webside'.
	self
		assert: package notNil;
		assert: (package at: 'classes') notEmpty;
		assert: (package at: 'methods') notEmpty
]

{ #category : #'code endpoints' }
WebsideAPITest >> testPackageClasses [
	| classes |
	classes := self get: 'packages/Webside/classes'.
	self
		assert: (classes anySatisfy: [ :c | (c at: 'name') = 'WebsideAPI' ]);
		deny: (classes anySatisfy: [ :c | (c at: 'name') = 'Object' ]).
	classes := self get: 'packages/Webside/classes?extended=true'.
	self
		assert: (classes anySatisfy: [ :c | (c at: 'name') = 'Object' ])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testPackageMethods [

	| methods |
	methods := self get: 'packages/Webside/methods'.
	self
		assert: methods notEmpty;
		assert: (methods anySatisfy: [ :m | 
					 (m at: 'methodClass') = 'Object' and: [ 
							 (m at: 'selector') = 'asWebsideJson' ] ])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testPackages [
	| packages package |
	packages := self get: 'packages'.
	package := packages
		detect: [ :p | p name = 'Webside' ]
		ifNone: [ self assert: false ].
	self assert: ((package at: 'classes') includes: 'WebsideAPI'); assert: ((package at: 'methods') includesKey: 'Object'); assert: (((package at: 'methods') at: 'Object') includes: 'asWebsideJson')
]

{ #category : #'evaluation  endpoints' }
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

{ #category : #'objects endpoints' }
WebsideAPITest >> testPinObjectSlot [
	| evaluation result id uri pinned x |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 @ 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.

	uri := NeoJSONObject new
		at: 'uri' put: '/objects/' , id , '/x';
		yourself.
	pinned := self post: '/objects' with: uri.
	self
		assert: pinned notNil;
		deny: (pinned at: 'id') equals: id.
	id := pinned at: 'id'.
	x := self get: '/objects/' , id asString.
	self
		assert: (x at: 'class') equals: 'SmallInteger';
		assert: (x at: 'printString') equals: '3'
]

{ #category : #'objects endpoints' }
WebsideAPITest >> testPinnedObject [
	| evaluation result id |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ | pinned |
	id := result at: 'id'.
	pinned := self get: '/objects/' , id asString.
	self
		assert: (pinned at: 'id') equals: id;
		assert: (pinned at: 'class') equals: 'SmallInteger';
		assert: (pinned at: 'printString') equals: '7' ]
		ensure: [ self delete: '/objects/' , id asString ]
]

{ #category : #'objects endpoints' }
WebsideAPITest >> testPinnedObjectIndexedSlots [
	| evaluation result id slots slot |
	evaluation := NeoJSONObject new
		at: 'expression' put: '#(true 2 nil)';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self
		assert: (result at: 'class') equals: 'Array';
		assert: (result at: 'hasIndexedSlots') equals: true.
	slots := self get: '/objects/' , id asString , '/indexed-slots'.
	self
		assert: slots size equals: 3;
		assert:
			(slots
				anySatisfy: [ :s | (s at: 'slot') = 1 and: [ (s at: 'printString') = 'true' ] ]);
				assert:
			(slots
				anySatisfy: [ :s | (s at: 'slot') = 2 and: [ (s at: 'printString') = '2' ] ]);
				assert:
			(slots
				anySatisfy: [ :s | (s at: 'slot') = 3 and: [ (s at: 'printString') = 'nil' ] ]).
	slot := self get: '/objects/', id asString , '/3'.
	self assert: (slot at: 'printString') equals: 'nil'.			
slots := self get: '/objects/' , id asString , '/indexed-slots?from=2&to=2'.
	self
		assert: slots size equals: 1;
		assert:
			((slots first at: 'slot') = 2 and: [ (slots first at: 'printString') = '2' ])
]

{ #category : #'objects endpoints' }
WebsideAPITest >> testPinnedObjectInstanceVariables [
	| evaluation result id vars |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 @ 4 extent: 1 @ 1';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self assert: (result at: 'class') equals: 'Rectangle'.
	vars := self get: '/objects/' , id asString , '/instance-variables'.
	self
		assert: vars size equals: Rectangle allInstVarNames size;
		assert:
			(Rectangle allInstVarNames
				allSatisfy: [ :n | vars anySatisfy: [ :v | (v at: 'name') = n ] ]).
	vars := self
		get: '/objects/' , id asString , '/corner/instance-variables'.
	self
		assert: vars size equals: Point allInstVarNames size;
		assert:
			(Point allInstVarNames
				allSatisfy: [ :n | vars anySatisfy: [ :v | (v at: 'name') = n ] ])
]

{ #category : #'objects endpoints' }
WebsideAPITest >> testPinnedObjectNamedSlots [

	| evaluation result id slots |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 @ 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self
		assert: (result at: 'class') equals: 'Point';
		assert: (result at: 'hasIndexedSlots') equals: false.
	slots := self get: '/objects/' , id asString , '/named-slots'.
	self
		assert: slots size equals: 2;
		assert:
			(slots
				anySatisfy: [ :s | (s at: 'slot') = 'x' and: [ (s at: 'printString') = '3' ] ]);
		assert:
			(slots
				anySatisfy: [ :s | (s at: 'slot') = 'y' and: [ (s at: 'printString') = '4' ] ])
]

{ #category : #'objects endpoints' }
WebsideAPITest >> testPinnedObjectSlot [
	| evaluation result id x |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 @ 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self assert: (result at: 'class') equals: 'Point'.
	x := self get: '/objects/' , id asString , '/x'.
	self
		assert: (x at: 'class') equals: 'SmallInteger';
		assert: (x at: 'printString') equals: '3'
]

{ #category : #'objects endpoints' }
WebsideAPITest >> testPinnedObjects [
	| evaluation result id |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	[ | pinned |
	id := result at: 'id'.
	pinned := self get: '/objects'.
	self
		assert:
			(pinned
				anySatisfy: [ :o | 
					(o at: 'id') = id
						and: [ (o at: 'class') = 'SmallInteger' 
						and: [ (o at: 'printString') = '7' ]] ]) ]
		ensure: [ self delete: '/objects/' , id asString ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testQuickSearch [
	| results |
	results := self get: 'search?text=Point&ignoreCase=false'.
	self
		assert: results notEmpty;
		assert: (results
			anySatisfy: [:r | (r at: 'type') = 'class' and: [(r at: 'text') = 'Point']])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testReferencesToClass [
	| references |
	references := self get: 'methods?referencingClass=Fraction'.
	self
		assert: references notEmpty;
		assert:
			(references
				allSatisfy: [ :m | m source includesSubstring: 'Fraction' ])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testReferencesToString [
	| references |
	references := self get: 'methods?referencingString=referencingString'.
	self
		assert: references notEmpty;
		assert:
			(references
				allSatisfy: [ :m | m source includesSubstring: 'referencingString' ])
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRemoveCategory [

	| class method methodRemotion categoryRemotion categories remotion |
	class := NeoJSONObject new
		         at: 'type' put: 'AddClass';
		         at: 'className' put: 'TestRemoveCategory';
		         at: 'definition' put: 'Object
	subclass: #TestRemoveCategory
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		         at: 'author' put: self class name;
		         yourself.
	method := NeoJSONObject new
		          at: 'type' put: 'AddMethod';
		          at: 'className' put: 'TestRemoveCategory';
		          at: 'category' put: 'testRemoveCategory';
		          at: 'sourceCode' put: 'x';
		          at: 'author' put: self class name;
		          yourself.
	methodRemotion := NeoJSONObject new
		                  at: 'type' put: 'RemoveMethod';
		                  at: 'className' put: 'TestRemoveCategory';
		                  at: 'selector' put: 'x';
		                  yourself.
	categoryRemotion := NeoJSONObject new
		                    at: 'type' put: 'RemoveCategory';
		                    at: 'className' put: 'TestRemoveCategory';
		                    at: 'category' put: 'testRemoveCategory';
		                    yourself.

	[
	self
		post: '/changes' with: class;
		post: '/changes' with: method.
	categories := self get: '/classes/TestRemoveCategory/categories'.
	self assert: (categories includes: 'testRemoveCategory').
	self
		post: '/changes' with: methodRemotion;
		post: '/changes' with: categoryRemotion.
	categories := self get: '/classes/TestRemoveCategory/categories'.
	self deny: (categories includes: 'testRemoveCategory') ] ensure: [
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestRemoveCategory';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRemoveClass [

	| definition remotion class |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestClassRemove';
		              definition: 'Object
	subclass: #TestClassRemove
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	remotion := NeoJSONObject new
		            at: 'type' put: 'RemoveClass';
		            at: 'className' put: 'TestClassRemove';
		            yourself.
	self
		post: '/changes' with: definition;
		post: '/changes' with: remotion.
	class := self get: '/classes/TestClassRemove'.
	self assert: class isNil
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRemoveInstanceVariable [

	| definition remotion |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestInstanceVariableRemove';
		              at: 'definition' put: 'Object
	subclass: #TestInstanceVariableRemove
	instanceVariableNames: ''x''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	remotion := NeoJSONObject new
		            at: 'type' put: 'RemoveInstanceVariable';
		            at: 'className' put: 'TestInstanceVariableRemove';
		            at: 'variable' put: 'x';
		            yourself.
	[ 
	| variables |
	self
		post: '/changes' with: definition;
		post: '/changes' with: remotion.
	variables := self get:
		             '/classes/TestInstanceVariableRemove/instance-variables'.
	self assert: variables isEmpty ] ensure: [ 
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestInstanceVariableRemove';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRemoveMethod [

	| definition remotion method |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddMethod';
		              at: 'className' put: 'Point';
		              at: 'category' put: self class name;
		              at: 'sourceCode' put: 'testMethodRemove
	^x + 1';
		              at: 'author' put: self class name;
		              yourself.
	remotion := NeoJSONObject new
		            at: 'type' put: 'RemoveMethod';
		            at: 'className' put: 'Point';
		            at: 'selector' put: 'testMethodRemove';
		            yourself.
	self
		post: '/changes' with: definition;
		post: '/changes' with: remotion.
	method := self get: '/classes/Point/methods/testMethodRemove'.
	self assert: method isNil
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRenameCategory [

	| class method renaming categories remotion |
	class := NeoJSONObject new
		         at: 'type' put: 'AddClass';
		         at: 'className' put: 'TestCategoryRename';
		         at: 'definition' put: 'Object
	subclass: #TestCategoryRename
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		         at: 'author' put: self class name;
		         yourself.
	method := NeoJSONObject new
		          at: 'type' put: 'AddMethod';
		          at: 'className' put: 'TestCategoryRename';
		          at: 'category' put: 'x';
		          at: 'sourceCode' put: 'testCategoryRename';
		          at: 'author' put: self class name;
		          yourself.
	renaming := NeoJSONObject new
		            at: 'type' put: 'RenameCategory';
		            at: 'className' put: 'TestCategoryRename';
		            at: 'category' put: 'x';
		            at: 'newName' put: 'y';
		            yourself.
	[self
		post: '/changes' with: class;
		post: '/changes' with: method;
		post: '/changes' with: renaming.
	categories := self get: '/classes/TestCategoryRename/categories'.
	self
		assert: categories size equals: 1;
		assert: categories first equals: 'y' ] ensure: [
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestCategoryRename';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRenameClass [

	| definition renaming class remotion |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestClassRename';
		              definition: 'Object
	subclass: #TestClassRename
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	renaming := NeoJSONObject new
		            at: 'type' put: 'RenameClass';
		            at: 'className' put: 'TestClassRename';
		            at: 'newName' put: 'TestClassRename2';
		            yourself.
	[
	self
		post: '/changes' with: definition;
		post: '/changes' with: renaming.
	class := self get: '/classes/TestClassRename'.
	self assert: class isNil.
	class := self get: '/classes/TestClassRename2'.
	self assert: class notNil ] ensure: [

		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestClassRename2';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRenameInstanceVariable [

	| definition renaming |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddClass';
		              at: 'className' put: 'TestInstanceVariableRename';
		              at: 'definition' put: 'Object
	subclass: #TestInstanceVariableRename
	instanceVariableNames: ''x''
	classVariableNames: ''''
	package: ''Unclassified''';
		              at: 'author' put: self class name;
		              yourself.
	renaming := NeoJSONObject new
		            at: 'type' put: 'RenameInstanceVariable';
		            at: 'className' put: 'TestInstanceVariableRename';
		            at: 'variable' put: 'x';
		            at: 'newName' put: 'y';
		            yourself.
	[ 
	| variables |
	self
		post: '/changes' with: definition;
		post: '/changes' with: renaming.
	variables := self get:
		             '/classes/TestInstanceVariableRename/instance-variables'.
	self
		assert: variables size equals: 1;
		assert: variables first name equals: 'y' ] ensure: [ 
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveClass';
			            at: 'className' put: 'TestInstanceVariableRename';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRenamePackage [

	| creation renaming |
	creation := NeoJSONObject new
		            at: 'type' put: 'AddPackage';
		            at: 'name' put: 'TestPackageRename';
		            at: 'author' put: self class name;
		            yourself.
	renaming := NeoJSONObject new
		            at: 'type' put: 'RenamePackage';
		            at: 'name' put: 'TestPackageRename';
		            at: 'newName' put: 'TestPackageRename2';
		            at: 'author' put: self class name;
		            yourself.
	[ 
	| package |
	self
		post: '/changes' with: creation;
		post: '/changes' with: renaming.
	package := self get: '/packages/TestPackageRename2'.
	self
		assert: package notNil;
		assert: package name equals: 'TestPackageRename2' ] ensure: [ 
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemovePackage';
			            at: 'name' put: 'TestPackageRename2';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'changes endpoints' }
WebsideAPITest >> testRenameSelector2 [

	| definition renaming |
	definition := NeoJSONObject new
		              at: 'type' put: 'AddMethod';
		              at: 'className' put: 'Point';
		              at: 'category' put: self class name;
		              at: 'sourceCode' put: 'testSelectorRename
	^x + 1';
		              at: 'author' put: self class name;
		              yourself.
	renaming := NeoJSONObject new
		            at: 'type' put: 'RenameMethod';
		            at: 'className' put: 'Point';
		            at: 'selector' put: 'testSelectorRename';
		            at: 'newSelector' put: 'testSelectorRename2';
		            at: 'author' put: self class name;
		            yourself.
	[ 
	| method |
	self
		post: '/changes' with: definition;
		post: '/changes' with: renaming.
	method := self get: '/classes/Point/methods/testSelectorRename'.
	self assert: method isNil.
	method := self get: '/classes/Point/methods/testSelectorRename2'.
	self assert: method notNil ] ensure: [ 
		| remotion |
		remotion := NeoJSONObject new
			            at: 'type' put: 'RemoveMethod';
			            at: 'className' put: 'Point';
			            at: 'selector' put: 'testSelectorRename2';
			            yourself.
		self post: '/changes' with: remotion ]
]

{ #category : #'testing endpoints' }
WebsideAPITest >> testRunTests [
	| test suite run id results |
	test := NeoJSONObject new
		at: 'class' put: 'DateTest';
		at: 'selector' put: 'testAddDays';
		yourself.
	suite := NeoJSONObject new
		at: 'methods' put: {test};
		yourself.
	run := self post: '/test-runs' with: suite.
	self assert: run notNil.
	id := run at: 'id'.
	[ results := self get: 'test-runs/' , id , '/results'.
	self
		assert: results size equals: 1;
		assert:
			((results first at: 'class') = 'DateTest'
				and: [ (results first at: 'selector') = 'testAdd' 
				and: [ (results first at: 'type') = 'passed' ]]) ]
		ensure: [ self delete: '/test-runs/' , id asString ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testScope [
	| methods hierarchy retrieved |
	methods := self get: 'methods?scope=Collection&sending=notEmpty'.
	self assert: methods notEmpty.
	hierarchy := Collection withAllSuperAndSubclasses collect: [ :c | c name ].
	retrieved := (methods collect: [ :m | m at: 'class' ]) asSet.
	self assert: retrieved size > 1; assert: (retrieved allSatisfy: [:n |  hierarchy includes: n]) 
]

{ #category : #'code endpoints' }
WebsideAPITest >> testSelectorInSource [
	| selector source |
    source := NeoJSONObject new at: 'source' put: 'to: 2 do: [:i'; yourself.
	selector := self post: 'selectors' with: source.
	self assert: selector equals: 'to:do:'.
    source := NeoJSONObject new at: 'source' put: '1 to: 2 do: [:i |'; at: 'position' put: 3; yourself.
	selector := self post: 'selectors' with: source.
	self assert: selector equals: 'to:do:'.
]

{ #category : #'code endpoints' }
WebsideAPITest >> testSenders [
	| senders local |
	senders := self get: 'methods?sending=reciprocal'.
	self
		assert: senders notEmpty;
		assert: (senders allSatisfy: [ :m | m source includesSubstring: 'reciprocal' ]);
		assert: (senders anySatisfy: [ :m | (m at: 'methodClass') = 'Fraction' ]).
	local := self get: 'methods?sending=reciprocal&class=Fraction'.
	self
		assert: local notEmpty;
		assert: (local allSatisfy: [ :m | m source includesSubstring: ' reciprocal' ]);
		assert: (local allSatisfy: [ :m | (m at: 'methodClass') = 'Fraction' ])
]

{ #category : #'debugging endpoints' }
WebsideAPITest >> testStepInto [
	| evaluation error id debugger |
	evaluation := NeoJSONObject new
		at: 'expression' put: '1 halt factorial';
		at: 'sync' put: true;
		yourself.
	[ self post: '/evaluations' with: evaluation ]
		on: Error
		do: [ :e | 
			error := NeoJSONObject fromString: client contents.
			self
				assert:
					((error at: 'description') asLowercase includesSubstring: 'halt');
				assert: (error includesKey: 'evaluation').
			id := error at: 'evaluation' ].
	self assert: id notNil.
	[ | target frame |
	target := NeoJSONObject new
		at: 'evaluation' put: id;
		yourself.
	debugger := self post: '/debuggers' with: target.
	id := debugger at: 'id'.
	self post: '/debuggers/' , id , '/frames/1/stepinto'.
	frame := self get: '/debuggers/' , id , '/frames/1'.
	self
		assert: ((frame at: 'method') at: 'selector')
		equals: 'factorial' ]
		ensure: [ self delete: '/debuggers/' , id asString ]
]

{ #category : #'code endpoints' }
WebsideAPITest >> testSubclasses [
	| subclasses |
	subclasses := self get: 'classes/Magnitude/subclasses'.
	self
		assert: (subclasses anySatisfy: [ :c | c name = 'Time' ]);
		assert: (subclasses anySatisfy: [ :c | c name = 'Number' ])
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

{ #category : #'objects endpoints' }
WebsideAPITest >> testUnpinObject [
	| evaluation result id pinned |
	evaluation := NeoJSONObject new
		at: 'expression' put: '3 + 4';
		at: 'sync' put: true;
		at: 'pin' put: true;
		yourself.
	result := self post: '/evaluations' with: evaluation.
	id := result at: 'id'.
	self delete: '/objects/' , id asString.
	pinned := self get: '/objects'.
	self assert: (pinned noneSatisfy: [ :o | (o at: 'id') = id ])
]

{ #category : #'code endpoints' }
WebsideAPITest >> testVariables [
	| variables |
	variables := self get: 'classes/Float/variables'.
	self assert: (variables anySatisfy: [ :v | (v at: 'name') = 'Infinity' and: [(v at: 'type') = 'class']]).
	variables := self get: 'classes/Fraction/variables'.
	self
		assert: (variables anySatisfy: [ :v | (v at:'name') = 'numerator' and: [(v at: 'type') = 'instance']]);
		assert: (variables anySatisfy: [ :v | (v at:'name') = 'denominator' and: [(v at: 'type') = 'instance']])
]

{ #category : #'workspaces endpoints' }
WebsideAPITest >> testWorkspace [

	| response id |
	response := self post: '/workspaces'.
	id := response at: 'id'.
	[
	| context assignment evaluation result |
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
		assert: (result at: 'printString') equals: '1' ] ensure: [
		self delete: '/workspaces/' , id ]
]

{ #category : #'workspaces endpoints' }
WebsideAPITest >> testWorkspaceBindings [

	| response id bindings |
	response := self post: '/workspaces'.
	id := response at: 'id'.
	[
	| context assignment |
	context := NeoJSONObject new
		           at: 'workspace' put: id;
		           yourself.
	assignment := NeoJSONObject new
		              at: 'expression' put: 'a := 1';
		              at: 'sync' put: true;
		              context: context;
		              yourself.
	self post: '/evaluations' with: assignment.

	bindings := self get: '/workspaces/' , id , '/bindings'.
	self
		assert: bindings size equals: 1;
		assert: (bindings first at: 'name') equals: 'a';
        assert: (bindings first at: 'value') equals: 1 printString] ensure: [
		self delete: '/workspaces/' , id ]
]

{ #category : #'workspaces endpoints' }
WebsideAPITest >> testWorkspaces [

	| response id result |
	response := self post: '/workspaces'.
	id := response at: 'id'.
	[
	result := self get: '/workspaces'.
	self assert: (result anySatisfy: [ :w | (w at: 'id') = id ]) ]
		ensure: [ self delete: '/workspaces/' , id ]
]
