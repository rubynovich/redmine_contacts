module RedmineContacts
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return stylesheet_link_tag(:contacts, :plugin => 'redmine_contacts') unless defined?(RedminePluginAssetPipeline)
      end
    end
  end
end
