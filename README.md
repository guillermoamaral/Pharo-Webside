# Pharo-Webside
[Webside](https://github.com/guillermoamaral/Webside) API implementation for Pharo (currently, Pharo 9 and 10).

## Installation

You can load **Webside** evaluating:
```smalltalk
Metacello new
	baseline: 'Webside';
	repository: 'github://guillermoamaral/Pharo-Webside:main';
	load
```
>  Change `main` to some released version if you want a pinned version.

## Usage

You can start `WebsideServer` by evaluating:
```smalltalk
WebsideServer new
	baseUri: '/pharo/v1';
	port: 9002;
	start
```

> Note that you can change the `baseUri` and `port` to whatever you want. This information should be promtped by Webside client once the user wants to connect to a given Smalltalk system.
