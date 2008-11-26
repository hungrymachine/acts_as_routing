#!/usr/bin/env ruby

require 'test/unit'
require 'rubygems'

begin
  require 'merb-core'
rescue LoadError
  puts "WARNING: Couldn't load merb... skipping merb tests."
end

begin
  require 'action_controller'
rescue LoadError
  puts "WARNING: Couldn't load rails... skipping rails tests."
end

$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')
require "acts_as_routing"

class ActsAsRoutingTest < Test::Unit::TestCase
  if defined?(Merb::Router)
    def test_merb_basic
      assert_nil Merb::Router.routes_for_acts_as(:commentable)
      assert_raise(Merb::ControllerExceptions::NotImplemented) do
        Merb::Router.prepare { resources :people, :acts_as => [:commentable] }
      end

      Merb::Router.routes_for_acts_as(:commentable) { |map| map.resources :comments }
      Merb::Router.prepare { resources :people, :acts_as => [:commentable] }
      assert_not_nil Merb::Router.routes_for_acts_as(:commentable)
      
      assert_equal "/people/1/comments", Merb::Router.url(:person_comments, :person_id => 1)
    end

    def test_merb_named_routes
      Merb::Router.routes_for_acts_as(:commentable) do |map|
        map.match('/best-comment').to(:controller => 'comments', :action => 'best').name(:best_comment)
      end

      Merb::Router.prepare do
        resources :people, :acts_as => [:commentable]
      end
      
      assert_equal "/people/1/best-comment", Merb::Router.url(:person_best_comment, :person_id => 1)
    end
  end
  
  if defined?(ActionController::Routing)
    def test_rails_basic
      assert_nil ActionController::Routing.routes_for_acts_as(:commentable)
      assert_raise(ActionController::RoutingError) do
        ActionController::Routing::Routes.draw { |map| map.resources :people, :acts_as => [:commentable] }
      end

      ActionController::Routing.routes_for_acts_as(:commentable) { |map| map.resources :comments }
      ActionController::Routing::Routes.draw { |map| map.resources :people, :acts_as => [:commentable] }
      assert_not_nil ActionController::Routing.routes_for_acts_as(:commentable)

      assert_equal "/people/1/comments", ActionController::Routing::Routes.generate(:use_route => :person_comments, :person_id => 1)
    end

    def test_rails_named_routes
      ActionController::Routing.routes_for_acts_as(:commentable) do |map|
        map.best_comment '/best-comment', :controller => 'comments', :action => 'best'
      end

      ActionController::Routing::Routes.draw do |map|
        map.resources :people, :acts_as => [:commentable]
      end
      
      assert_equal "/people/1/best-comment", ActionController::Routing::Routes.generate(:use_route => :person_best_comment, :person_id => 1)
    end

  end
end
