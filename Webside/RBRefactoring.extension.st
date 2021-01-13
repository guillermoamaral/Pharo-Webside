Extension { #name : #RBRefactoring }

{ #category : #'*Webside' }
RBRefactoring class >> acceptsWebsideJson: json [
	| type |
	type := json at: 'type' ifAbsent: nil.
	^ self websideType = type
]

{ #category : #'*Webside' }
RBRefactoring >> asWebsideJson [
	^ NeoJSONObject new
		at: 'type' put: self class websideType asString;
		at: 'label' put: self printString;
		at: 'project' put: 'self projectName';
		at: 'timestamp' put: DateAndTime now asString;
		at: 'author' put: Author uniqueInstance fullName;
		yourself
]

{ #category : #'*Webside' }
RBRefactoring class >> classForWebsideJson: json [
	^ self allSubclasses
		detect: [ :c | c acceptsWebsideJson: json ]
		ifNone: nil
]

{ #category : #'*Webside' }
RBRefactoring class >> fromWebsideJson: json [
	| class |
	class := self classForWebsideJson: json.
	^ class ifNotNil: [class new fromWebsideJson: json]
]

{ #category : #'*Webside' }
RBRefactoring >> fromWebsideJson: json [
]

{ #category : #'*Webside' }
RBRefactoring class >> websideType [
	^ nil
]
