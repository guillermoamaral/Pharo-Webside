Extension { #name : #CmdCommand }

{ #category : #'*Webside' }
CmdCommand class >> acceptsWebsideJson: json [
	| type |
	type := json at: 'type' ifAbsent: nil.
	^ self websideType = type
]

{ #category : #'*Webside' }
CmdCommand >> asWebsideJson [

	^ NeoJSONObject new
		  at: 'type' put: self class websideType asString;
		  at: 'label' put: self printString;
		  at: 'package' put: nil;
		  at: 'timestamp' put: DateAndTime now asString;
		  at: 'author' put: Author uniqueInstance fullName;
		  yourself
]

{ #category : #'*Webside' }
CmdCommand class >> classForWebsideJson: json [
	^ self allSubclasses
		detect: [ :c | c acceptsWebsideJson: json ]
		ifNone: nil
]

{ #category : #'*Webside' }
CmdCommand class >> fromWebsideJson: json [
	| class |
	class := self classForWebsideJson: json.
	^ class ifNotNil: [class new fromWebsideJson: json]
]

{ #category : #'*Webside' }
CmdCommand >> fromWebsideJson: json [
]

{ #category : #'*Webside' }
CmdCommand >> websideExecute [

	^ self execute
]

{ #category : #'*Webside' }
CmdCommand class >> websideType [

	^ ((self name withoutPrefix: 'Cly') withoutPrefix: 'Syc') withoutSuffix: 'Command'
]
