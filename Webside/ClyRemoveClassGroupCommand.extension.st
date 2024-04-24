Extension { #name : #ClyRemoveClassGroupCommand }

{ #category : #'*Webside' }
ClyRemoveClassGroupCommand >> asWebsideJson [
	"To review: we are using here RPackage and RPackageTag (instead of ClyTaggedClassGroup),
	since it was easier/faster to implement."

	| json |
	json := super asWebsideJson.
	json
		at: 'package' put: classGroup package name;
		at: 'category' put: classGroup name.
	^ json
]

{ #category : #'*Webside' }
ClyRemoveClassGroupCommand >> fromWebsideJson: json [
	"To review: we are using here RPackage and RPackageTag (instead of ClyTaggedClassGroup),
	since it was easier/faster to implement."

	| package |
	super fromWebsideJson: json.
	json at: 'package' ifPresent: [ :p |
		package := RPackageOrganizer default packageNamed: p.
		json
			at: 'category'
			ifPresent: [ :c |
			classGroup := package classTagNamed: c ifAbsent: nil ] ]
]

{ #category : #'*Webside' }
ClyRemoveClassGroupCommand >> websideExecute [
	"To review: we are using here RPackage and RPackageTag (instead of ClyTaggedClassGroup),
	since it was easier/faster to implement."

	| remotions |
	classGroup ifNil: [ ^ self ].
	classGroup isEmpty ifTrue: [ ^ classGroup removeFromPackage ].
	remotions := classGroup classes collect: [ :c |
		             RBRemoveClassChange remove: c ].
	"This is a bit tricky: as removing non-empty tags (groups) imply removing all their classes first,
	we return an error with such remotions (for the user to confirm them). However, when those class
	remotions are executed, the tag is removed automatically, so there is no need to include its own
	remotion in suggested changes."
	(WebsideChangeError from: self)
		messageText: 'Remove category';
		suggest:
			'Category is not empty. Do you want to remove all its classes?'
		withChanges: remotions;
		signal
]

{ #category : #'*Webside' }
ClyRemoveClassGroupCommand class >> websideType [ 
	^'RemoveClassCategory'
]
