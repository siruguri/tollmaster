RailsAdmin.config do |config|
  # Configure this
  config.included_models = ["User", 'PaymentTokenRecord']
  ### Popular gems integration

  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)
  
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
  config.model 'User' do
    object_label_method do
      :phone_number
    end

    # This decides the appearance of the list of records
    list do
      field :phone_number do
        label 'Phone'
      end
    end
  end
end
