# Pharo-Webside
[Webside](https://github.com/guillermoamaral/Webside) API implementation for Pharo.
Currently supported version: Pharo 12.

(To install it in Pharo 11 point to pharo11 branch instead of main in the following script)

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
	baseUri: '/pharo';
	port: 9002;
	start
```

> Note that you can change the `baseUri` and `port` to whatever you want. This information should be promtped by Webside client once the user wants to connect to a given Smalltalk system.
