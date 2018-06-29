require 'delegate'
require_relative 'carrier'
require_relative 'route_builder'

module Carrier
  class Content < SimpleDelegator
    include RouteBuilder

    def initialize(*packages)
      super([*packages])
    end

    def sort_by_origin(address, container_properties, attributes=nil)
      sorted_packages = 
        build_route(address, *address_list)
        .then { |route| sort_by_route(route) }
        .then { |packages| sort_by_properties(packages)}
      self.clear 
      sorted_packages.each { |package| self << package }
    end

    def sort_by_route(route, attributes=nil)
      route.flat_map do |rt|
        self.select { |package| package.destination == rt['destination'] }
      end
    end

    def sort_by_properties(packages)
      grouped_packages = packages.group_by { |package| package.destination }
      grouped_packages.flat_map do |_, packs|
        packs.sort_by do |pack|
          [pack.properties.weight, pack.properties.volume]
        end.reverse
      end
    end
    
    def address_list
      self.group_by { |package| package.destination }.keys
    end

  end
end