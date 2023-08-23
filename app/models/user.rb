class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
  :trackable, :confirmable, :lockable, :password_archivable, :registerable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  before_save :email_format
  before_save :name_update
  # after_save :member_of_Everyone_group

### validations
  # validates :current_playground_id, presence: true
  validates :email, presence: true, 
                    uniqueness: {case_sensitive: false}, 
                    length: { maximum: 100 }
  validates_format_of :email, with: /\A(\S+)@(.+)\.(\S+)\z/
  validate :password_confirmed
  validate :password_complexity

  validates :first_name,    presence: true, length: { maximum: 100 }
  validates :last_name,     presence: true, length: { maximum: 100 }
  validates :user_name,     presence: true, uniqueness: {case_sensitive: false}, length: { maximum: 100 }
  validates :external_directory_uri,        length: { maximum: 100 }
  validates :created_by_id, presence: true, length: { maximum: 30 }
  validates :updated_by_id, presence: true, length: { maximum: 30 } 
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

# Relations
  has_many :groups_users
  has_many :groups, through: :groups_users

  ### Translation support
  mattr_accessor :translated_fields, default: ['description']

### Public functions

  def principal_group
    self.groups_users.find_by(is_principal: true).group_id
  end

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/
    errors.add :password, 'Complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
  end

  def password_confirmed
    return if password == password_confirmation
    errors.add :password, 'Password and confirmation do not match'
  end

  ### full-text local search
  pg_search_scope :search_by_user_name, against: [:user_name, :name, :description],
    using: { tsearch: { prefix: true, negation: true } }

  def self.search(criteria)
    if criteria.present?
      search_by_user_name(criteria)
    else
      # No query? Return all records, sorted by uuid.
      order( :updated_at )
    end
  end


### private functions definitions
  private

  ### before filters

  def email_format
    self.email = email.downcase
  end

  def name_update
    self.name = "#{first_name} #{last_name}"
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(user_name) = :value OR lower(email) = :value", { value: login.downcase }]).first
    elsif conditions.has_key?(:user_name) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

end

