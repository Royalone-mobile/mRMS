class Channel < ApplicationRecord
  default_scope {where(is_active: true)}
  has_many :channel_users
  has_many :reports
  belongs_to :user

  has_many :users, through: :channel_users
  scope :personal, -> { where(option: 3)}
  scope :not_personal, -> { where.not(option: 3)}
  scope :is_public, -> { where(option: 2)}
  scope :for_shared_users, -> { where(option: 1)}
  scope :for_user, -> { includes(:channel_users).for_shared_users.where(channel_users: {user_id: User.current.id}).where(is_public: false)}

  accepts_nested_attributes_for :channel_users, reject_if: :all_blank, allow_destroy: true


  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  before_create do
    self.created_by_id = User.current.id
  end

  before_save do
    self.updated_by_id = User.current.id
  end

  after_create do
    ChannelUser.create(user_id: self.user_id, channel_id: self.id)
  end

  def self.market_place
    personal.where(user_id: User.current.id, name: 'Market Analyses' ).first_or_create
  end

  def self.segmented_market
    personal.where(user_id: User.current.id, name: 'Segmented Market' ).first_or_create
  end


  def self.safe_attributes
    [:user_id, :name, :is_public, :description, :is_personal]
  end

  def visible_reports
    if is_personal?
      User.current.reports
    else
      reports
    end
  end

  def to_s
    name
  end
end
