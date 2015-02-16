class Shared::AvatarPresenter
  include Curlybars::MethodsWhitelisting
  attr_reader :avatar

  allow_methods :url

  def initialize(avatar)
    @avatar = avatar
  end

  def url
    @avatar.url
  end
end
