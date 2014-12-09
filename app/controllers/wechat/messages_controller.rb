class Wechat::MessagesController < Wechat::BaseController
  before_action :modify_data

  def create
    if @message.save!
      respond_message @serverName, @user.openId , '你的消息小紫已收到并记录，稍后回复你~'
    else
      respond_message @serverName, @user.openId , '抱歉，小紫的服务器好像出了一些问题，请重新发送消息~'
    end
  end

  private
  def modify_data
    rawData = Nokogiri::XML params
    @user = User.find_or_create(rawData.xpath("//FromUserName").first.content)
    @serverName = rawData.xpath("//ToUserName").first.content
    case rawData.xpath("//MsgType").first.content
    when "text" then text_data rawData
    when "event" then event_data rawData
    end
  end
  # 接收微信普通消息
  #<xml>
  #  <ToUserName><![CDATA[toUser]]></ToUserName>
  #  <FromUserName><![CDATA[fromUser]]></FromUserName>
  #  <CreateTime>1348831860</CreateTime>
  #  <MsgType><![CDATA[text]]></MsgType>
  #  <Content><![CDATA[this is a test]]></Content>
  #  <MsgId>1234567890123456</MsgId>
  #</xml>
  def text_data rawData
    @message = @user.messages.new
    @message.type = 'text'
    @message.content = rawData.xpath("//Content").first.content
    @message.msgId = rawData.xpath("//MsgId").first.content
  end
end
