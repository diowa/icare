class References::OutgoingReference < References::Base

  belongs_to :referenced_user, class_name: User.model_name

end
