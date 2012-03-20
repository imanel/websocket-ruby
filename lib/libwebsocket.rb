# Client/server WebSocket message and frame parser/constructor. This module does
# not provide a WebSocket server or client, but is made for using in http servers
# or clients to provide WebSocket support.
module LibWebSocket

  VERSION = '0.1.3' # Version of LibWebSocket

  autoload :Cookie,           "#{File.dirname(__FILE__)}/libwebsocket/cookie"
  autoload :Frame,            "#{File.dirname(__FILE__)}/libwebsocket/frame"
  autoload :OpeningHandshake, "#{File.dirname(__FILE__)}/libwebsocket/opening_handshake"
  autoload :Message,          "#{File.dirname(__FILE__)}/libwebsocket/message"
  autoload :Request,          "#{File.dirname(__FILE__)}/libwebsocket/request"
  autoload :Response,         "#{File.dirname(__FILE__)}/libwebsocket/response"
  autoload :Stateful,         "#{File.dirname(__FILE__)}/libwebsocket/stateful"
  autoload :URL,              "#{File.dirname(__FILE__)}/libwebsocket/url"

end
