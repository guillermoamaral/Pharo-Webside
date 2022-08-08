"
Handy class to make WebsideAPI accessible on a Teapot server.

WebsideServer allInstances.

WebsideServer new
	baseUri: '/pharo';
	port: 9001;
	start
"
Class {
	#name : #WebsideServer,
	#superclass : #Object,
	#instVars : [
		'server',
		'apiClass',
		'baseUri',
		'port',
		'resources'
	],
	#category : #'Webside-Base'
}

{ #category : #accessing }
WebsideServer >> apiClass: aClass [
	apiClass := aClass
]

{ #category : #accessing }
WebsideServer >> baseUri [
	^baseUri
]

{ #category : #accessing }
WebsideServer >> baseUri: aString [
	baseUri := aString
]

{ #category : #accessing }
WebsideServer >> baseUrl [
	^ server server localUrl / baseUri
]

{ #category : #accessing }
WebsideServer >> debuggers [
	^ self resourcesAt: #debuggers
]

{ #category : #initialization }
WebsideServer >> defaultBaseUri [
	^ '/pharo'
]

{ #category : #initialization }
WebsideServer >> defaultPort [ 
	^9001
]

{ #category : #accessing }
WebsideServer >> evaluations [
	^ self resourcesAt: #evaluations
]

{ #category : #actions }
WebsideServer >> handlePreflightRequest: request [
	| response |
	(self isPreflight: request)
		ifFalse: [ ^ ZnResponse serverError: 'Cannot process this request' ].
	response := ZnResponse ok: (ZnEntity text: '').
	request headers
		at: 'Origin'
		ifPresent:
			[ :origin | response headers at: 'Access-Control-Allow-Origin' put: origin ].
	request headers
		at: 'Access-Control-Request-Method'
		ifPresent:
			[ :method | response headers at: 'Access-Control-Allow-Methods' put: method ].
	request headers
		at: 'Access-Control-Request-Headers'
		ifPresent:
			[ :headers | response headers at: 'Access-Control-Allow-Headers' put: headers ].
	^ response
]

{ #category : #actions }
WebsideServer >> handleRequest: request with: selector [
	| api result response |
	api := apiClass new
		server: self;
		request: request.
	response := [ result := api perform: selector.
	(result isKindOf: ZnResponse)
		ifTrue: [ result ]
		ifFalse: [ self responseFrom: result ] ]
		on: Error
		do: [ :e | ZnResponse serverError: e description ].
	response headers at: 'Access-Control-Allow-Origin' put: '*'.
	^ response
]

{ #category : #initialization }
WebsideServer >> initialize [
	super initialize.
	apiClass := WebsideAPI.
	port := self defaultPort.
	baseUri := self defaultBaseUri.
	self initializeResources
]

{ #category : #initialization }
WebsideServer >> initializeChangesRoutes [
	self
		routeGET: '/changes' to: #changes;
		routePOST: '/changes' to: #addChange
]

{ #category : #initialization }
WebsideServer >> initializeCodeRoutes [
	self
		routeGET: '/packages' to: #packages;
		routeGET: '/packages/<name>' to: #package;
		routeGET: '/packages/<name>/classes' to: #packageClasses;
		routeGET: '/packages/<name>/methods' to: #packageMethods;
		routeGET: '/classes' to: #classes;
		routeGET: '/classes/<name>' to: #classDefinition;
		routeGET: '/classes/<name>/subclasses' to: #subclasses;
		routeGET: '/classes/<name>/variables' to: #variables;
		routeGET: '/classes/<name>/instance-variables'
			to: #instanceVariables;
		routeGET: '/classes/<name>/class-variables' to: #classVariables;
		routeGET: '/classes/<name>/categories' to: #categories;
		routeGET: '/classes/<name>/methods' to: #methods;
		routeGET: '/classes/<name>/methods/<selector>' to: #method;
		routeGET: '/methods' to: #methods
]

{ #category : #initialization }
WebsideServer >> initializeDebuggingRoutes [

	self
		routeGET: '/debuggers' to: #activeDebuggers;
		routePOST: '/debuggers' to: #createDebugger;
		routeGET: '/debuggers/<id>/frames' to: #debuggerFrames;
		routeGET: '/debuggers/<id>/frames/<index>' to: #debuggerFrame;
		routeGET: '/debuggers/<id>/frames/<index>/bindings'
		to: #frameBindings;
		routePOST: '/debuggers/<id>/frames/<index>/stepover'
		to: #stepOverDebugger;
		routePOST: '/debuggers/<id>/frames/<index>/stepthrough'
		to: #stepThroughDebugger;
		routePOST: '/debuggers/<id>/frames/<index>/stepinto'
		to: #stepIntoDebugger;
		routePOST: '/debuggers/<id>/frames/<index>/restart'
		to: #restartDebugger;
		routePOST: '/debuggers/<id>/resume' to: #resumeDebugger;
		routePOST: '/debuggers/<id>/terminate' to: #terminateDebugger;
		routeDELETE: '/debuggers/<id>' to: #deleteDebugger
]

{ #category : #initialization }
WebsideServer >> initializeEvaluationRoutes [
	self
		routePOST: '/evaluations' to: #evaluateExpression;
		routeGET: '/evaluations' to: #activeEvaluations;
		routeGET: '/evaluations/<id>' to: #activeEvaluation;
		routeDELETE: '/evaluations/<id>' to: #cancelEvaluation
]

{ #category : #initialization }
WebsideServer >> initializeGeneralRoutes [
	self
		routeGET: '/dialect' to: #dialect;
        routePOST: '/save' to: #saveImage
]

{ #category : #initialization }
WebsideServer >> initializeObjectsRoutes [

	self
		routeGET: '/objects' to: #pinnedObjects;
		routeGET: '/objects/<id>' to: #pinnedObject;
		routeDELETE: '/objects/<id>' to: #unpinObject;
		routeGET: '/objects/<id>/*' to: #pinnedObjectSlots;
		routePOST: '/objects' to: #pinObjectSlot;
		routeDELETE: '/objects' to: #unpinAllObjects
]

{ #category : #initialization }
WebsideServer >> initializePreflightRoutes [
	server
		OPTIONS:
			(baseUri , '/*')
				-> [ :request | self handlePreflightRequest: request ].	"This is not that well"
	
]

{ #category : #initialization }
WebsideServer >> initializeResources [
	resources := Dictionary new.
	
	resources at: #evaluations put: Dictionary new;
	at: #objects put: Dictionary new;
	at: #workspaces put: Dictionary new;
	at: #debuggers put: Dictionary new; at: #testRuns put: Dictionary new
]

{ #category : #initialization }
WebsideServer >> initializeRoutes [
	self
    	initializePreflightRoutes;
		initializeGeneralRoutes;
        initializeCodeRoutes;
		initializeChangesRoutes;
		initializeEvaluationRoutes;
		initializeObjectsRoutes;
		initializeWorkspacesRoutes;
		initializeDebuggingRoutes;
		initializeTestsRoutes 
]

{ #category : #initialization }
WebsideServer >> initializeServer [
	server := Teapot
		configure:
			{(#defaultOutput -> #json).
			(#port -> port).
			(#debugMode -> true).
			(#notFoundHandlerClass -> Tea405AwareNotFoundHandler)}.
]

{ #category : #initialization }
WebsideServer >> initializeTestsRoutes [
	self
		routeGET: '/test-runs' to: #activeTestRuns;
		routePOST: '/test-runs' to: #runTests;
		routeGET: '/test-runs/<id>/status'
		to: #testRunStatus;
		routeGET: '/test-runs/<id>/results'
		to: #testRunResults;
		routePOST: '/test-runs/<id>/run' to: #runTestRun;
		routePOST: '/test-runs/<id>/debug' to: #debugTest;
		routePOST: '/test-runs/<id>/stop' to: #stopTestRun;
		routeDELETE: '/test-runs/<id>' to: #deleteTestRun

]

{ #category : #initialization }
WebsideServer >> initializeWorkspacesRoutes [
	self
		routePOST: '/workspaces' to: #createWorkspace;
		routeGET: '/workspaces' to: #activeWorkspaces;
		routeGET: '/workspaces/<id>' to: #workspace;
		routeDELETE: '/workspaces/<id>' to: #deleteWorkspace
]

{ #category : #testing }
WebsideServer >> isPreflight: request [
	^ request method = 'OPTIONS' and: [ (request headers at: 'origin') notNil ]
]

{ #category : #accessing }
WebsideServer >> objects [
	^ self resourcesAt: #objects
]

{ #category : #accessing }
WebsideServer >> port [
	^ port
]

{ #category : #accessing }
WebsideServer >> port: anInteger [
	port := anInteger
]

{ #category : #actions }
WebsideServer >> reset [
	self debuggers removeAll.
	self evaluations removeAll.
	self objects removeAll.
	self workspaces removeAll
]

{ #category : #accessing }
WebsideServer >> resourcesAt: aSymbol [
	^ resources at: aSymbol ifAbsent: nil
]

{ #category : #accessing }
WebsideServer >> resourcesAt: aSymbol put: anObject [
	resources at: aSymbol put: anObject
]

{ #category : #private }
WebsideServer >> responseFrom: anObject [
	| json type entity |
	json := NeoJSONWriter toString: anObject.
	type := ZnMimeType applicationJson.
	type
		charSet: 'utf-8'.
	entity := ZnStringEntity with: json type: type.
	^ ZnResponse ok: entity
]

{ #category : #initialization }
WebsideServer >> routeDELETE: uri to: selector [
	server
		DELETE:
			(baseUri , uri)
				-> [ :request | self handleRequest: request with: selector ]
]

{ #category : #initialization }
WebsideServer >> routeGET: uri to: selector [
	server
		GET:
			(baseUri , uri)
				-> [ :request | self handleRequest: request with: selector ]
]

{ #category : #initialization }
WebsideServer >> routePOST: uri to: selector [
	server
		POST:
			(baseUri , uri)
				-> [ :request | self handleRequest: request with: selector ]
]

{ #category : #accessing }
WebsideServer >> server [
	^ server
]

{ #category : #actions }
WebsideServer >> start [
	self
		initializeServer;
		initializeRoutes; reset.
	server start
]

{ #category : #actions }
WebsideServer >> stop [
	server stop
]

{ #category : #accessing }
WebsideServer >> testRuns [
	^ self resourcesAt: #testRuns
]

{ #category : #accessing }
WebsideServer >> workspaces [
	^ self resourcesAt: #workspaces
]
