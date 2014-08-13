
require 'mail'
require 'net/imap'

require_relative 'config'
require_relative 'utils'

class Imap
  RFC822 = 'RFC822'

  def initialize(config)
    @config = config
    @imap = Net::IMAP.new @config['host'], @config['port'], @config['use_ssl']
    begin
      @imap.login @config['username'], Utils.read_password
    rescue Net::IMAP::NoResponseError => error
      Utils.fatal "IMAP:#{error.message}"
    end
  end

  def list(mailbox=nil)
    @imap.list(mailbox || '', '*')
  end

  def mails_for(mailbox)
    @imap.examine mailbox
    @imap.uid_search('ALL').each do |uid|
      yield Mail.new(@imap.uid_fetch(uid, RFC822).first.attr[RFC822])
    end
  end
end