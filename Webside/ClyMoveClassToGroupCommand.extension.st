Extension { #name : #ClyMoveClassToGroupCommand }

{ #category : #'*Webside' }
ClyMoveClassToGroupCommand >> asWebsideJson [
  "Used on just one class from Webside"

	^ super asWebsideJson
		  at: 'className' put: classes first name;
          at: 'package' put: classGroup name;
		  yourself
]

{ #category : #'*Webside' }
ClyMoveClassToGroupCommand >> fromWebsideJson: json [
	"Used on just one class from Webside"

	| environment |
	super fromWebsideJson: json.
	environment := ClySystemEnvironment currentImage.
	json at: 'className' ifPresent: [ :c |
		classes := { environment classNamed: c } ].
	json
		at: 'package'
		ifPresent: [ :p | classGroup := environment packageNamed: p ]
]
