module LibWebSocket
  class Cookie
    # Construct or parse a WebSocket response cookie.
    class Response < Cookie

      attr_accessor :name, :value, :comment, :comment_url, :discard, :max_age, :path, :portlist, :secure

      # Construct a WebSocket response cookie.
      # @example
      #   cookie = LibWebSocket::Cookie::Response.new(
      #     :name    => 'foo',
      #     :value   => 'bar',
      #     :discard => 1,
      #     :max_age => 0
      #   )
      #   cookie.to_s # foo=bar; Discard; Max-Age=0; Version=1
      def to_s
        pairs = []

        pairs.push([self.name, self.value])

        pairs.push ['Comment', self.comment] if self.comment
        pairs.push ['CommentURL', self.comment_url] if self.comment_url
        pairs.push ['Discard'] if self.discard
        pairs.push ['Max-Age', self.max_age] if self.max_age
        pairs.push ['Path', self.path] if self.path

        if self.portlist
          self.portlist = Array(self.portlist)
          list          = self.portlist.join(' ')
          pairs.push ['Port', "\"#{list}\""]
        end

        pairs.push ['Secure'] if self.secure
        pairs.push ['Version', '1']

        self.pairs = pairs

        super
      end

    end
  end
end
