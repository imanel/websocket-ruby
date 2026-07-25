# frozen_string_literal: true

module WebSocket
  module Handshake
    module Handler
      # Marker base class for hybi-family server handshakes (drafts 04 and up).
      # Behaviour is fully provided by {Base}; concrete handlers only need
      # protocol-version-specific overrides.
      class Server < Base
      end
    end
  end
end
