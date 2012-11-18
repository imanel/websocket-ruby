require 'digest/md5'

module WebSocket
  module Handshake
    module Handler
      module Client76

        include Client75

        def key1
          @key1 ||= generate_key(:key1)
        end

        def key2
          @key2 ||= generate_key(:key2)
        end

        def key3
          @key3 ||= generate_key3
        end

        def valid?
          super && verify_challenge
        end

        private

        def reserved_leftover_lines
          1
        end

        def handshake_keys
          keys = super
          keys << ['Sec-WebSocket-Key1', key1]
          keys << ['Sec-WebSocket-Key2', key2]
          keys
        end

        def verify_challenge
          set_error(:invalid_challenge) and return false unless @leftovers == challenge
          true
        end

        def challenge
          return @challenge if defined?(@challenge)
          key1 && key2
          sum = [@key1_number].pack("N*") +
                [@key2_number].pack("N*") +
                key3

          @challenge = Digest::MD5.digest(sum)
        end

        def finishing_line
          key3
        end

        NOISE_CHARS = ("\x21".."\x2f").to_a() + ("\x3a".."\x7e").to_a()

        def generate_key(key)
          spaces = 1 + rand(12)
          max = 0xffffffff / spaces
          number = rand(max + 1)
          instance_variable_set("@#{key}_number", number)
          key = (number * spaces).to_s
          (1 + rand(12)).times() do
            char = NOISE_CHARS[rand(NOISE_CHARS.size)]
            pos = rand(key.size + 1)
            key[pos...pos] = char
          end
          spaces.times() do
            pos = 1 + rand(key.size - 1)
            key[pos...pos] = " "
          end
          return key
        end

        def generate_key3
          return [rand(0x100000000)].pack("N") + [rand(0x100000000)].pack("N")
        end

      end
    end
  end
end
