module ActsAsRouting
  def self.included(base)
    base.class_eval do
      class << self

        ActsAsBlocks = {}

        def routes_for_acts_as(type, &block)
          if block
            ActsAsBlocks[type] = block
          else
            ActsAsBlocks[type]
          end
        end

      end
    end
  end
end

require File.join(File.dirname(__FILE__), 'acts_as_routing_rails') if defined?(ActionController::Routing)
require File.join(File.dirname(__FILE__), 'acts_as_routing_merb') if defined?(Merb::Router)
