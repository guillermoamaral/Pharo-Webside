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
		do: [ spec
				package: 'Webside' with: [ spec requires: #('Teapot' 'NeoJSON') ]]
]
