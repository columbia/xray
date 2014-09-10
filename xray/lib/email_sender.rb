class EmailSender
  class EmailAlreadyPresentError < RuntimeError; end

  def initialize
    @accs = []
    @current = 0
    self.generate_sender_accounts
  end

  def generate_sender_accounts
    # we use old accounts not to polute the new ones with emails in sent box
    @accs.shuffle!
  end

  def random_recipient
    acc = @accs.sample
    acc["email"] = "#{acc["login"]}@gmail.com"
    acc
  end

  def send_test
    acc = @accs.first
    gmail = Gmail.connect!(acc["login"], acc["passwd"])
    email = { "subject" => "hello,",
              "text" => "world!",
              # "html" => "<b>world!</b>",
    }
    self.send_email(email, "email adress", gmail)
  end

  def send_thread(thread, dest, acc = nil, async = false, check = true)
    @current = (@current + 1) % @accs.size if !acc
    acc ||= @accs[@current]
    puts "#{thread} #{dest} #{acc} #{async} #{check}"
    if async
      EmailWorker.perform_async(thread, dest, acc, false, check)
    else
      gmail = Gmail.connect!(acc["login"], acc["passwd"])
      thread.each do |email|
        puts "[EMAIL] #{email} #{dest} #{acc["login"]}"
        send_email(email, dest, gmail, check)
        puts "[EMAIL] sent"
        sleep(60 + Random.rand(10))
      end
    end
  end

  def send_email(email, dest, gmail, check = true)
    # we don't send the email if it's already there
    puts check
    sent = {}
    if check
      g = Gmail.connect(dest["login"], dest["passwd"])
      g.inbox.all.each do |e|
        (sent[e.message.subject.to_s] ||= []).push(e.message.body.to_s)
      end
      dup = nil
      dup = sent[email["subject"]].select do |s|
        !!s &&
          ( email["text"] && s.include?(email["text"]) ) ||
          ( email["html"] && s.include?(email["html"]) )
      end if !!sent.keys && sent.keys.include?(email["subject"])
      if !!dup && dup.size > 0
        puts "[send_email] tried to resend an email: #{dup}"
        return
      end
    end

    email = gmail.compose do
      to dest["email"]
      subject email["subject"]
      text_part { body email["text"] } if !!email && email.include?("text")
      html_part do
        content_type 'text/html; charset=UTF-8'
        body email["html"]
      end if !!email && email.include?("html")
      add_file email["f_path"] if !!email && email.include?("f_path")
    end
    email.deliver!
  rescue => e
    puts "[send_email] error delivering message: #{e}"
    raise e
  end
end
