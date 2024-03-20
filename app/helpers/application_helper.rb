module ApplicationHelper

  ### Implementing Help files management with Markdown
  def markdown
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, tables: true)
  end

  def displayHelp
    puts "Help requested for: #{params[:page_name]}.#{params[:format]}"
    # Parse the request from the page -> namespace/class/controller
    if params[:page_name].index('/')
      domain = params[:page_name].split('/')[0]
      page = params[:page_name].split('/')[1]
    else
      domain = ''
      page = params[:page_name]
    end
    method = params[:format] # The method from the controller is not used yet

    # Build the help file path and name using the current locale
    case page
    when 'Change_Log' # Does it still exist?
      filename = File.join(Rails.root, 'public', "CHANGELOG.md")
    when 'Release_notes' # Does it still exist?
      filename = File.join(Rails.root, 'public', "Release_notes.md")
    else
      filename = File.join(Rails.root,
                            'public',
                            'help',
                            domain,
                            page.classify,
                            "#{page}-#{I18n.locale.to_s[0,2]}.md"
                          )
    end
    puts "Requested help file: #{filename}"

    if not File.file?(filename)
      filename = File.join(Rails.root, 'public', 'help', "help-index-#{I18n.locale.to_s[0,2]}.md")
    end

    begin
      file = File.open(filename, "rb")
      markdown.render(file.read).html_safe.force_encoding('UTF-8')
    rescue Errno::ENOENT
      render :file => "public/404.html", :status => 404
    end
  end

  # Idenfify the namespace of the controller
  def namespace
    #case controller.class.parent.name
    byebug
    case params[:controller][0..(params[:controller].index('/'))]
    when 'Object'
      nil
    when 'Devise'
      :administration
    else
      controller.class.parent.name.downcase
    end
  end    

  ### ignore a block of code
  def ignore
  end

  
  end
  