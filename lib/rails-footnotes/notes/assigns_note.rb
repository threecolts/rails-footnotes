require "active_record"

module Footnotes
  module Notes
    class AssignsNote < AbstractNote
      cattr_accessor :ignored_assigns, instance_writer: false, default: [
        :@real_format,
        :@before_filter_chain_aborted,
        :@performed_redirect,
        :@performed_render,
        :@_params,
        :@_response,
        :@url,
        :@template,
        :@_request,
        :@db_rt_before_render,
        :@db_rt_after_render,
        :@view_runtime,
        :@marked_for_same_origin_verification
      ]
      cattr_accessor :ignored_assigns_pattern, instance_writer: false, default: /^@_/

      def initialize(controller)
        @controller = controller
      end

      def title
        "Assigns (#{assigns.size})"
      end

      def valid?
        assigns.present?
      end

      def content
        mount_table(to_table, :summary => "Debug information for #{title}")
      end

      protected
        def to_table
          table = assigns.inject([]) do |rr, var|
            class_name = assigned_value(var).class.name
            var_value = assigned_value(var)
            if var_value.is_a?(ActiveRecord::Relation) && var_value.limit_value.nil?
              var_value = var_value.limit(Footnotes::Filter.default_limit)
            end
            rr << ["<strong>#{var.to_s}</strong>" + "<br /><em>#{class_name}</em>", escape(var_value.inspect)]
          end

          table.unshift(['Name', 'Value'])
        end

        def assigns
          @assigns ||= @controller.instance_variables.map {|v| v.to_sym}.select {|v| v.to_s !~ ignored_assigns_pattern } - ignored_assigns
        end

        def assigned_value(key)
          @controller.instance_variable_get(key)
        end

    end
  end
end
