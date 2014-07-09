require "red_snow/version"
require "red_snow/binding"
require "red_snow/blueprint"
require "ffi"

module RedSnow
  include Binding

  def self.parse(rawBlueprint)

    bp = Blueprint.new

    blueprint = FFI::MemoryPointer.new :pointer
    result = FFI::MemoryPointer.new :pointer
    ret = RedSnow::Binding.sc_c_parse(rawBlueprint, 0, result, blueprint)

    blueprint = blueprint.get_pointer(0)
    result = result.get_pointer(0)
    # BP name, desc
    bp.name = RedSnow::Binding.sc_blueprint_name(blueprint)
    bp.description = RedSnow::Binding.sc_blueprint_description(blueprint)
    # BP resourceGroups
    sc_resource_groups_collection_handle = RedSnow::Binding.sc_resource_groups_collection_handle(blueprint)
    sc_resource_groups_collection_size = RedSnow::Binding.sc_resource_groups_collection_size(sc_resource_groups_collection_handle)
    bp.resource_groups = Array.new
    if sc_resource_groups_collection_size > 0
      group_size = sc_resource_groups_collection_size - 1
      for index in 0..group_size do
        sc_resource_groups_handle = RedSnow::Binding.sc_resource_groups_handle(sc_resource_groups_collection_handle, index)
        resource = ResourceGroup.new
        resource.name = RedSnow::Binding.sc_resource_groups_name(sc_resource_groups_handle)
        resource.description = RedSnow::Binding.sc_resource_groups_description(sc_resource_groups_handle)
        # BP Resources
        sc_resource_collection_handle = RedSnow::Binding.sc_resource_collection_handle(sc_resource_groups_handle)
        sc_resource_collection_size = RedSnow::Binding.sc_resource_collection_size(sc_resource_collection_handle)
        resource.resources = Array.new
        if sc_resource_collection_size > 0
          resource_size = sc_resource_collection_size - 1
          for index in 0..resource_size do
            sc_resource_handle = RedSnow::Binding.sc_resource_handle(sc_resource_collection_handle, index)
            res = Resource.new
            res.name = RedSnow::Binding.sc_resource_name(sc_resource_handle)
            res.description = RedSnow::Binding.sc_resource_description(sc_resource_handle)
            res.uri_template = RedSnow::Binding.sc_resource_uritemplate(sc_resource_handle)
            resource.resources << res
          end
        end
        bp.resource_groups << resource
      end
    end

    return bp
  ensure
    RedSnow::Binding.sc_blueprint_free(blueprint)
    RedSnow::Binding.sc_result_free(result)
  end

end