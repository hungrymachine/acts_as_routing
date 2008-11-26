Merb::Router.send(:include, ActsAsRouting)

Merb::Router::Resources.class_eval do
  def resource_options_with_acts_as_routing
    resource_options_without_acts_as_routing + [ :acts_as ]
  end
  alias :resource_options_without_acts_as_routing :resource_options
  alias :resource_options :resource_options_with_acts_as_routing

  # always have a block, so resource_block gets called
  def resources_with_empty_block(*args, &block)
    block ||= Proc.new {}
    resources_without_empty_block(*args, &block)
  end
  alias :resources_without_empty_block :resources
  alias :resources :resources_with_empty_block

  def resource_block(builders, &block)
    all_acts_as = [@options.delete(:acts_as)].flatten.compact

    # original logic
    behavior = Merb::Router::ResourceBehavior.new(builders, @proxy, @conditions, @params, @defaults, @identifiers, @options, @blocks)
    with_behavior_context(behavior, &block)

    # run through each acts_as
    all_acts_as.each do |acts_as|
      raise Merb::ControllerExceptions::NotImplemented, "\"#{acts_as}\" is not a valid acts_as type" unless Merb::Router.routes_for_acts_as(acts_as)
      with_behavior_context(behavior, &Merb::Router.routes_for_acts_as(acts_as))
    end
  end
end
