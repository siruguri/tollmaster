RailsAdmin.config do |config|
  # Configure this
  # config.included_models = ["FreeTextQuestion", "MultipleChoiceQuestion", "FormStructure", "FormStructureEntry"]
  
  ### Popular gems integration

  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  # Configure some of this too.
  config.model 'Task' do
    object_label_method do
      :task_name
    end

    configure :category do
      label 'Pick a category'
    end

    # This decides the appearance of the list of records
    list do
      field :task_name do
        label 'Task Titled As'
      end
    end
  end

  def task_name
    self.name.capitalize
  end
end
