# TAGS
ActiveAdmin.register Tag do
  controller.authorize_resource
  config.comments = false
  menu parent: "Tags", priority: 15, if: lambda{|tabs_renderer|
    controller.current_ability.can?(:read, Tag)
  }
  form partial: "form"
end
ActiveAdmin.register GeneralTag do
  controller.authorize_resource
  config.comments = false
  menu parent: "Tags", priority: 15, if: lambda{|tabs_renderer|
    controller.current_ability.can?(:read, Tag)
  }
  form partial: "form"
end
ActiveAdmin.register RegionTag do
  controller.authorize_resource
  config.comments = false
  menu parent: "Tags", priority: 17, if: lambda{|tabs_renderer|
    controller.current_ability.can?(:read, Tag)
  }
  form partial: "form"
end
ActiveAdmin.register CountryTag do
  controller.authorize_resource
  config.comments = false
  menu parent: "Tags", priority: 19, if: lambda{|tabs_renderer|
    controller.current_ability.can?(:read, Tag)
  }
  form partial: "form"
end
