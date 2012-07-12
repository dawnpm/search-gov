class TwitterProfile < ActiveRecord::Base
  has_many :tweets, :primary_key => :twitter_id, :dependent => :destroy
  has_and_belongs_to_many :affiliates
  validates_presence_of :screen_name
  validate :must_have_valid_screen_name, :if => :screen_name?
  validates_presence_of :twitter_id, :profile_image_url, :if => :screen_name?
  validates_uniqueness_of :twitter_id, :screen_name
  before_validation :lookup_twitter_id

  def recent
    self.tweets.recent
  end

  def link_to_profile
    "http://twitter.com/#{screen_name}"
  end

  private

  def get_twitter_user
    @twitter_user ||= Twitter.user(screen_name) rescue nil
  end

  def must_have_valid_screen_name
    errors.add(:screen_name, 'does not exist') unless get_twitter_user
  end

  def lookup_twitter_id
    if screen_name and twitter_id.nil?
      twitter_user = get_twitter_user
      if twitter_user
        self.twitter_id = twitter_user.id
        self.name = twitter_user.name
        self.profile_image_url = twitter_user.profile_image_url
      end
    end
  end
end
