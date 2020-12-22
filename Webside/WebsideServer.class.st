"
Handy class to make WebsideAPI accessible on a Teapot server.

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
		'baseUri',
		'port'
	],
	#category : #'Webside-Base'
}

{ #category : #accessing }
WebsideServer >> baseUri [
	^baseUri
]

{ #category : #accessing }
WebsideServer >> baseUri: aString [
	baseUri := aString
]

{ #category : #initialization }
WebsideServer >> defaultBaseUri [
	^ '/pharo'
]

{ #category : #initialization }
WebsideServer >> defaultPort [ 
	^9001
]

{ #category : #actions }
WebsideServer >> handlePreflightRequest: request [
	| response origin method headers |
	(self isPreflight: request)
		ifFalse: [ ^ ZnResponse serverError: 'Cannot process this request' ].
	response := ZnResponse new.
	response
		statusLine: ZnStatusLine ok;
		headers: ZnHeaders defaultResponseHeaders;
		entity: (ZnEntity text: '').
	origin := request headers at: 'Origin'.
	method := request headers at: 'Access-Control-Request-Method'.
	headers := request headers at: 'Access-Control-Request-Headers'.
	response headers
		at: 'Access-Control-Allow-Origin' put: origin;
		at: 'Access-Control-Allow-Methods' put: method;
		at: 'Access-Control-Allow-Headers' put: headers.
	^ response
]

{ #category : #actions }
WebsideServer >> handleRequest: request with: selector [
	| api result entity response |
	api := WebsideAPI new request: request.
	result := api perform: selector.
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
	port := self defaultPort.
	baseUri := self defaultBaseUri.

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
		routeGET: '/classes/<name>/methods/<selector>' to: #method
]

{ #category : #initialization }
WebsideServer >> initializeRoutes [
	server
		OPTIONS:
			(baseUri , '/*')
				-> [ :request | self handlePreflightRequest: request ].	"This is not that well"
	self initializeCodeRoutes ; initializeChangesRoutes 
]

{ #category : #initialization }
WebsideServer >> initializeServer [
	server := Teapot
		configure:
			{(#defaultOutput -> #json).
			(#port -> port).
			(#debugMode -> true).
			(#notFoundHandlerClass -> Tea405AwareNotFoundHandler)}
]

{ #category : #testing }
WebsideServer >> isPreflight: request [
	^ request method = 'OPTIONS' and: [ (request headers at: 'origin') notNil ]
]

{ #category : #accessing }
WebsideServer >> port [
	^ port
]

{ #category : #accessing }
WebsideServer >> port: anInteger [
	^ port := anInteger
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

{ #category : #actions }
WebsideServer >> start [
	self
		initializeServer;
		initializeRoutes.
	server start
]

{ #category : #actions }
WebsideServer >> stop [
	server stop
]
