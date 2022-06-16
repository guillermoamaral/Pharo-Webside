Extension { #name : #RBRefactoryChange }

{ #category : #'*Webside' }
RBRefactoryChange class >> acceptsWebsideJson: json [
	| type |
	type := json at: 'type' ifAbsent: nil.
	^ self websideType = type
]

{ #category : #'*Webside' }
RBRefactoryChange >> asWebsideJson [
	^ NeoJSONObject new
		at: 'type' put: self class websideType asString;
		at: 'label' put: self changeString;
		at: 'package' put: nil;
		at: 'timestamp' put: DateAndTime now asString;
		at: 'author' put: Author uniqueInstance fullName;
		yourself
]

{ #category : #'*Webside' }
RBRefactoryChange class >> classForWebsideJson: json [
	^ self allSubclasses
		detect: [ :c | c acceptsWebsideJson: json ]
		ifNone: nil
]

{ #category : #'*Webside' }
RBRefactoryChange class >> fromWebsideJson: json [
	| class |
	class := self classForWebsideJson: json.
	^ class ifNotNil: [ class new fromWebsideJson: json ] 
]

{ #category : #'*Webside' }
RBRefactoryChange >> fromWebsideJson: json [
]

{ #category : #'*Webside' }
RBRefactoryChange class >> websideType [
	^ nil
]
