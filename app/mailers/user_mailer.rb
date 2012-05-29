class UserMailer < ActionMailer::Base
  
  def new_user(user_id)
    @user = User.find(user_id)
    @url = url_for(admin_user_path(@user, only_path: false, protocol: 'https'))
    @emails_list = User.admin_users.map{|t| t.email}.join(",")
    mail(
      from:     "WorldMathaba <inbox@worldmathaba.net>",
      sender:   "inbox@worldmathaba.net",
      reply_to: "inbox@worldmathaba.net",
      to:       "inbox@worldmathaba.net",
      bcc:      @emails_list,
      subject:  "A new user has been registered",
      tag:      "new_user"
    )
  end
end