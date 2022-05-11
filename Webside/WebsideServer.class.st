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
	| api result entity response |
	api := apiClass new server: self; request: request.
	result := [ api perform: selector ]
		on: Error
		do: [ :e | ^ ZnResponse serverError: e description ].
	response := (result isKindOf: ZnResponse)
		ifTrue: [ result ]
		ifFalse: [ entity := ZnStringEntity
				with: (NeoJSONWriter toString: result)
				type:
					(ZnMimeType applicationJson
						charSet: 'utf-8';
						yourself).
			ZnResponse ok: entity ].
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
		routeGET: '/dialect' to: #dialect;
		routeGET: '/projects' to: #projects;
		routeGET: '/projects/<name>' to: #project;
		routeGET: '/projects/<name>/classes' to: #projectClasses;
		routeGET: '/projects/<name>/methods' to: #projectMethods;
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
WebsideServer >> initializeObjectsRoutes [
	self
		routeGET: '/objects' to: #pinnedObjects;
		routeGET: '/objects/<id>' to: #pinnedObject;
		routeDELETE: '/objects/<id>' to: #unpinObject;

		routeGET: '/objects/<id>/instance-variables'
			to: #pinnedObjectInstanceVariables;
			
		routeGET: '/objects/<id>/*/instance-variables'
			to: #pinnedObjectInstanceVariables;
		routeGET: '/objects/<id>/*' to: #pinnedObjectSlot
]

{ #category : #initialization }
WebsideServer >> initializeResources [
	resources := Dictionary new.
	
	resources at: #evaluations put: Dictionary new;
	at: #objects put: Dictionary new;
	at: #workspaces put: Dictionary new;
	at: #debuggers put: Dictionary new
]

{ #category : #initialization }
WebsideServer >> initializeRoutes [
	self
		initializeCodeRoutes;
		initializeChangesRoutes;
		initializeEvaluationRoutes;
		initializeObjectsRoutes;
		initializeWorkspacesRoutes;initializeDebuggingRoutes
]

{ #category : #initialization }
WebsideServer >> initializeServer [
	server := Teapot
		configure:
			{(#defaultOutput -> #json).
			(#port -> port).
			(#debugMode -> true).
			(#notFoundHandlerClass -> Tea405AwareNotFoundHandler)}.
			
			server
		OPTIONS:
			(baseUri , '/*')
				-> [ :request | self handlePreflightRequest: request ].	"This is not that well"

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

{ #category : #accessing }
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
WebsideServer >> workspaces [
	^ self resourcesAt: #workspaces
]
