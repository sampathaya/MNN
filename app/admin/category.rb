# Categories
ActiveAdmin.register Category do
  controller.authorize_resource
  config.comments = false
  config.sort_order = "priority_asc"
  menu parent: "Settings", priority: 80, if: lambda{|tabs_renderer|
    controller.current_ability.can?(:manage, Category)
  }
  index do
    id_column
    column :title
    column :description
    column :priority
    bool_column :active
    column "Updated" do |category|
      category.updated_at.to_s(:short)
    end
    default_actions
  end
end
