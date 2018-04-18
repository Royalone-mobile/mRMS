class Report < ApplicationRecord
  belongs_to :channel
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  has_many :report_documents
  has_many :shared_reports
  has_many :users, through: :shared_reports

  # mount_uploader :document, ReportUploader

  before_create do
    self.created_by_id = User.current.id
  end

  before_save do
    self.updated_by_id = User.current.id
  end

  after_create do
    if channel.is_personal?
      SharedReport.create(user_id: self.user_id, report_id: self.id)
    end
  end

  def document
    report_documents.first_or_initialize
  end

  def document_url
    document.file_url
  end

  def self.safe_attributes
    [:name, :category_id, :channel_id, :category_type_id, :user_id, :description ]
  end


end
