class Comment < ActiveRecord::Base
  attr_accessor :subscribe

  acts_as_voteable

  opinio counter_cache: true

  include Rakismet::Model
  # AKISMET parameters:
  # author        : name submitted with the comment
  # author_url    : URL submitted with the comment
  # author_email  : email submitted with the comment
  # comment_type  : Defaults to comment but you can set it to trackback, pingback, or something more appropriate
  # content       : the content submitted
  # permalink     : the permanent URL for the entry the comment belongs to
  # user_ip       : IP address used to submit this comment
  # user_agent    : user agent string
  # referrer      : referring URL (note the spelling)

  validates_presence_of :body
  attr_accessible :body, :commentable_id, :commentable_type, :approved, :marked_spam, :suspicious, :approved_by, :subscribe

  # belongs_to :user
  belongs_to :approving_user, foreign_key: :approved_by, class_name: "User"

  after_create  :notify_admin, :notify_users, :subscribe_users
  before_save   :check_for_spam, :check_suspicious
  after_save    :touch_commentable

  delegate :name, to: :owner, allow_nil: true


  def subscribe_users
    if (subscribe.to_s == "1" or subscribe == true)
      unless CommentSubscription.where(item_id: self.commentable_id, user_id: self.owner_id).first
        CommentSubscription.create(item_id: self.commentable_id, user_id: self.owner_id)
      end
    end
  end

  def touch_commentable
    if !marked_spam? && commentable
      commentable.reload.update_attributes(last_commented_at: DateTime.now)
    end
  end

  # Send email to users 60 seconds after creation
  def notify_users
    unless marked_spam
      if Rails.env.production?
        CommentsNotifier.delay_for(60).to_users(self.id)
      else
        CommentsNotifier.to_users(self.id).deliver
      end
    end
  end

  # Send email to admins 15 seconds after creation
  def notify_admin
    if Rails.env.production?
      CommentsNotifier.delay_for(15).to_admin(self.id)
    else
      CommentsNotifier.to_admin(self.id).deliver
    end
  end

  def check_for_spam
    if !Rails.env.test? && self.spam?
      self.marked_spam = true
      self.approved = false
      Rails.logger.info("  Security: Comment marked as SPAM")
    else
      self.marked_spam = false
      self.approved = true
    end
    true
  end

  def check_suspicious
    return true if (self.owner.has_any_role?(:admin, :security) or self.approving_user)
    check = %w{ <applet <body <embed <frame <script <frameset <html <iframe <layer <ilayer <meta <object
      script base64 onclick onmouse onfocus onload createelement
    }.join("|")
    if body.downcase.match(check)
      Rails.logger.info("  Security: Comment marked as SUSPICIOUS")
      self.suspicious = true
      self.approved = false
    else
      self.suspicious = false
      self.approved = true
    end
    true
  end

  def from_item?
    self.commentable && self.commentable.is_a?(Item)
  end

  def commentable_title
    if self.commentable && from_item?
      self.commentable.title
    else
      "in reply"
    end
  end

  def display_name
    self.owner.title if self.owner
  end
  
  def author
    self.owner.title if self.owner
  end

  def author_email
    if self.owner
      self.owner.email
    else
      ""
    end
  end
  
  def akismet_attributes
    {
      key:                  AKISMET_KEY,
      blog:                 'http://worldmathaba.net',
      user_ip:              user_ip,
      user_agent:           user_agent,
      comment_author:       author,
      comment_author_email: author_email,
      comment_content:      body
    }
  end

  def allowed_html_tags
    tags = %w(p em b i u a br blockquote strong div pre ul ol li)
    tags += %w(iframe img) if approving_user
    tags
  end

  def allowed_html_attributes
    tags = %w(href target rel rev)
    tags += %w(src width height allowfullscreen) if approving_user
    tags
  end

  # Returns the last 10 approved comments
  def self.recent(limit=10)
    where(approved: true).
    where(suspicious: false).
    where(marked_spam: false).
    order("updated_at DESC").
    includes([:owner, :commentable]).
    limit(limit)
  end

  # Returns the last 10 pending comments
  def self.pending(limit=10)
    where(approved: false).
    order("updated_at DESC").
    limit(limit)
  end

  # Returns the last 10 suspicious comments
  def self.suspicious(limit=10)
    where(suspicious: true).
    where(marked_spam: false).
    order("updated_at DESC").
    limit(limit)
  end

  # Returns the last 10 comments marked as spam
  def self.as_spam(limit=10)
    where(marked_spam: true).
    includes([:owner, :commentable]).
    order("updated_at DESC").
    limit(limit)
  end

  def self.last_cache_key
    if comment = self.last_comment
      comment.updated_at.to_s(:number)
    else
      ""
    end
  end

  def self.last_comment
    order("id DESC").first
  end

end
