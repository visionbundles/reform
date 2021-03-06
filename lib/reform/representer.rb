require 'representable/hash'
require 'representable/decorator'

module Reform
  class Representer < Representable::Decorator
    include Representable::Hash

    # Returns hash of all property names.
    def fields
      representable_attrs.map(&:name)
    end

    def nested_forms(&block)
      clone_config!.
        find_all { |attr| attr.options[:form] }.
        collect  { |attr| [attr, represented.send(attr.getter)] }. # DISCUSS: can't we do this with the Binding itself?
        each(&block)
    end

  private
    def clone_config!
      # TODO: representable_attrs.clone! which does exactly what's done below.
      attrs = Representable::Config.new
      attrs.inherit(representable_attrs) # since in every use case we modify Config we clone.
      @representable_attrs = attrs
    end

    def self.inline_representer(base_module, &block) # DISCUSS: separate module?
      Class.new(Form) do
        instance_exec &block

        def self.name # FIXME: needed by ActiveModel::Validation - why?
          "AnonInlineForm"
        end
      end
    end
  end
end