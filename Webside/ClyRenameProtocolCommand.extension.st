Extension { #name : 'ClyRenameProtocolCommand' }

{ #category : '*Webside' }
ClyRenameProtocolCommand >> asWebsideJson [
	"This is super hacky (and the level of incursion is really uggly). It was tryging to avoid repeating code and reusing existing services (but this hierarchy is used by Pharo IDE, and probably it would be better to reimplement this functionality at Webside level)."

	^ super asWebsideJson
		  at: 'className'
		  put: methodGroup methodQuery scope basisObjects asArray first name;
		  at: 'category' put: methodGroup protocol;
		  at: 'newName' put: newName;
		  yourself
]

{ #category : '*Webside' }
ClyRenameProtocolCommand >> fromWebsideJson: json [
  "This is super hacky. It was tryging to avoid repeating code and reusing existing services (but this hierarchy is used by Pharo IDE, and probably it would be better to reimplement this functionality at Webside level)."

	| class scope |
	super fromWebsideJson: json.
	json at: 'className' ifPresent: [ :n |
		json at: 'category' ifPresent: [ :c |
			class := ClySystemEnvironment  currentImage classNamed: n.
			scope := ClyClassScope of: class in: ClyNavigationEnvironment currentImage.
			methodGroup := ClyMethodsInProtocolGroup
				               withMethodsFrom: scope
				               inProtocol: c asSymbol ] ].
	newName := json at: 'newName' ifAbsent: nil
]

{ #category : '*Webside' }
ClyRenameProtocolCommand class >> websideType [
  ^'RenameCategory'
]
