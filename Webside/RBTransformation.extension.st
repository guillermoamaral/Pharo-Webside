Extension { #name : 'RBTransformation' }

{ #category : '*Webside' }
RBTransformation class >> acceptsWebsideJson: json [

	| type |
	type := json at: 'type' ifAbsent: nil.
	^ self websideType = type
]

{ #category : '*Webside' }
RBTransformation >> asWebsideJson [

	^ NeoJSONObject new
		  at: 'type' put: self class websideType asString;
		  at: 'label' put: self class websideType asString;
		  at: 'package' put: nil;
		  at: 'timestamp' put: DateAndTime now asString;
		  at: 'author' put: Author uniqueInstance fullName;
		  yourself
]

{ #category : '*Webside' }
RBTransformation class >> classForWebsideJson: json [

	^ self allSubclasses
		  detect: [ :c | c acceptsWebsideJson: json ]
		  ifNone: nil
]

{ #category : '*Webside' }
RBTransformation class >> fromWebsideJson: json [

	| class |
	class := self classForWebsideJson: json.
	^ class ifNotNil: [ class new fromWebsideJson: json ]
]

{ #category : '*Webside' }
RBTransformation >> fromWebsideJson: json [

	
]

{ #category : '*Webside' }
RBTransformation >> websideExecute [

	^ self execute
]

{ #category : '*Webside' }
RBTransformation class >> websideType [

	^ (self name withoutPrefix: 'RB') withoutSuffix: 'Transformation'
]
