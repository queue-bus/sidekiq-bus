require 'sidekiq/web'

module SidekiqBus
  module Server
    def self.registered(app)
      app.get('/bus') do
        # you can define @instance_variables for passing into template
        # Sidekiq uses erb for its templates so you should do it aswell
        erb File.read(File.join(File.dirname(__FILE__), "server/views/bus.erb"))
       end

      app.post '/bus/unsubscribe' do
        bus_app = ::QueueBus::Application.new(params[:name]).unsubscribe
        redirect "#{root_path}bus"
      end
    end

    class Helpers
      class << self
        def parse_query(query_string)
          has_open_brace = query_string.include?("{")
          has_close_brace = query_string.include?("}")
          has_multiple_lines = query_string.include?("\n")
          has_colon = query_string.include?(":")
          has_comma = query_string.include?(",")
          has_quote = query_string.include?("\"")

          exception = nil

          # first let's see if it parses
          begin
            query_attributes = JSON.parse(query_string)
            raise "Not a JSON Object" unless query_attributes.is_a?(Hash)
          rescue Exception => e
            exception = e
          end
          return query_attributes unless exception

          if query_attributes
            # it parsed but it's something else
            if query_attributes.is_a?(Array) && query_attributes.length == 1
              # maybe it's the thing from the queue
              json_string = query_attributes.first
              fixed = JSON.parse(json_string) rescue nil
              return fixed if fixed
            end

            # something else?
            raise exception
          end

          if !has_open_brace && !has_close_brace
            # maybe they just forgot the braces
            fixed = JSON.parse("{ #{query_string} }") rescue nil
            return fixed if fixed
          end

          if !has_open_brace
            # maybe they just forgot the braces
            fixed = JSON.parse("{ #{query_string}") rescue nil
            return fixed if fixed
          end

          if !has_close_brace
            # maybe they just forgot the braces
            fixed = JSON.parse("#{query_string} }") rescue nil
            return fixed if fixed
          end

          if !has_multiple_lines && !has_colon && !has_open_brace && !has_close_brace
            # we say they just put a bus_event type here, so help them out
            return {"bus_event_type" => query_string, "more_here" => true}
          end

          if has_colon && !has_quote
            # maybe it's some search syntax like this: field: value other: true, etc
            # maybe use something like this later: https://github.com/dxwcyber/search-query-parser

            # quote all the strings, (simply) tries to avoid integers
            test_query = query_string.gsub(/([a-zA-z]\w*)/,'"\0"')
            if !has_comma
              test_query.gsub!("\n", ",\n")
            end
            if !has_open_brace  && !has_close_brace
              test_query = "{ #{test_query} }"
            end

            fixed = JSON.parse(test_query) rescue nil
            return fixed if fixed
          end

          if has_open_brace && has_close_brace
            # maybe the whole thing is a hash output from a hash.inspect log
            ruby_hash_text = query_string.clone
            # https://stackoverflow.com/questions/1667630/how-do-i-convert-a-string-object-into-a-hash-object
            # Transform object string symbols to quoted strings
            ruby_hash_text.gsub!(/([{,]\s*):([^>\s]+)\s*=>/, '\1"\2"=>')
            # Transform object string numbers to quoted strings
            ruby_hash_text.gsub!(/([{,]\s*)([0-9]+\.?[0-9]*)\s*=>/, '\1"\2"=>')
            # Transform object value symbols to quotes strings
            ruby_hash_text.gsub!(/([{,]\s*)(".+?"|[0-9]+\.?[0-9]*)\s*=>\s*:([^,}\s]+\s*)/, '\1\2=>"\3"')
            # Transform array value symbols to quotes strings
            ruby_hash_text.gsub!(/([\[,]\s*):([^,\]\s]+)/, '\1"\2"')
            # fix up nil situation
            ruby_hash_text.gsub!(/=>nil/, '=>null')
            # Transform object string object value delimiter to colon delimiter
            ruby_hash_text.gsub!(/([{,]\s*)(".+?"|[0-9]+\.?[0-9]*)\s*=>/, '\1\2:')
            fixed = JSON.parse(ruby_hash_text) rescue nil
            return fixed if fixed
          end

          raise exception
        end

        def sort_query(query_attributes)
          query_attributes.each do |key, value|
            if value.is_a?(Hash)
              query_attributes[key] = sort_query(value)
            end
          end
          query_attributes.sort_by { |key| key }.to_h
        end

        def query_subscriptions(app, query_attributes)
          # TODO: all of this can move to method in queue-bus to replace event_display_tuples
          if query_attributes
            subscriptions = app.subscription_matches(query_attributes)
          else
            subscriptions = app.send(:subscriptions).all
          end
        end
      end
    end
  end
end

Sidekiq::Web.register SidekiqBus::Server
Sidekiq::Web.locales << File.expand_path(File.dirname(__FILE__) + "/web/locales")
Sidekiq::Web.tabs['Bus'] = 'bus'
