ActionController::Routing.send(:include, ActsAsRouting)

ActionController::Routing::RouteSet::Mapper.class_eval do
  def map_resource_with_acts_as_routing(entities, options = {}, &block)
    # call the original and let it do whatever
    map_resource_without_acts_as_routing(entities, options.dup, &block)
    
    unless options[:acts_as].blank?
      # recreate the resource from original options because we can't get to the one created above
      resource = ActionController::Resources::Resource.new(entities, options)

      # loop through acts_as and call the block for each one
      options[:acts_as].each do |acts_as|
        raise ActionController::RoutingError, "\"#{acts_as}\" is not a valid acts_as type" unless ActionController::Routing.routes_for_acts_as(acts_as)
        with_options(:path_prefix => resource.nesting_path_prefix, :name_prefix => resource.nesting_name_prefix, :namespace => options[:namespace], &ActionController::Routing.routes_for_acts_as(acts_as))
      end
    end
  end
  alias_method_chain :map_resource, :acts_as_routing
end
