Class {
	#name : #BaselineOfWebside,
	#superclass : #BaselineOf,
	#category : #BaselineOfWebside
}

{ #category : #baselines }
BaselineOfWebside >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec. spec
				package: 'Webside'
				with: [ spec requires: #('Teapot' 'NeoJSON') ] ]
]

{ #category : #baselines }
BaselineOfWebside >> projectClass [

^ MetacelloCypressBaselineProject 
]

{ #category : #baselines }
BaselineOfWebside >> setUpDependencies: spec [
	spec
		baseline: 'Teapot'
		with: [ spec repository: 'github://zeroflag/Teapot:v2.6.0/source' ].
		
		
	spec baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
]
