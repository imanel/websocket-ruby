# Protocol::WebSocket

A WebSocket message parser/constructor. It is not a server and is not meant to
be one. It can be used in any server, event loop etc.

## Server handshake

    h = LibWebSocket::OpeningHandshake::Server.new

    # Parse client request
    h.parse \<<EOF
    GET /demo HTTP/1.1
    Upgrade: WebSocket
    Connection: Upgrade
    Host: example.com
    Origin: http://example.com
    Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
    Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0

    Tm[K T2u
    EOF

    h.error # Check if there were any errors
    h.done? # Returns true

    # Create response
    h.to_s # HTTP/1.1 101 WebSocket Protocol Handshake
           # Upgrade: WebSocket
           # Connection: Upgrade
           # Sec-WebSocket-Origin: http://example.com
           # Sec-WebSocket-Location: ws://example.com/demo
           #
           # fQJ,fN/4F4!~K~MH

## Client handshake

    h = LibWebSocket::OpeningHandshake::Client.new(url => 'ws://example.com')

    # Create request
    h.to_s # GET /demo HTTP/1.1
           # Upgrade: WebSocket
           # Connection: Upgrade
           # Host: example.com
           # Origin: http://example.com
           # Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
           # Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0
           #
           # Tm[K T2u

    # Parse server response
    h.parse \<<EOF
    HTTP/1.1 101 WebSocket Protocol Handshake
    Upgrade: WebSocket
    Connection: Upgrade
    Sec-WebSocket-Origin: http://example.com
    Sec-WebSocket-Location: ws://example.com/demo

    fQJ,fN/4F4!~K~MH
    EOF

    h.error # Check if there were any errors
    h.done? # Returns true

## Parsing and constructing frames

    # Create frame
    frame = LibWebSocket::Frame.new('123')
    frame.to_s # \x00123\xff

    # Parse frames
    frame = LibWebSocket::Frame.new
    frame.append("123\x00foo\xff56\x00bar\xff789")
    frame.next # foo
    frame.next # bar

## Examples

For examples on how to use LibWebSocket with various event loops see
examples directory in the repository.

## Copyright

Copyright (C) 2010, Bernard Potocki.

Based on protocol-websocket perl distribution by Viacheslav Tykhanovskyi.

This program is free software, you can redistribute it and/or modify it under
the MIT License.