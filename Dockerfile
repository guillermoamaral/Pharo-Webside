FROM ghcr.io/ba-st/pharo:v11.0.0
RUN pharo metacello install github://guillermoamaral/Pharo-Webside:main BaselineOfWebside
EXPOSE 9005/tcp
CMD ./pharo eval --no-quit "WebsideServer new baseUri: '/pharo'; port: 9005; start"